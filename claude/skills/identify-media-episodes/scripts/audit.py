#!/usr/bin/env python3
"""Read-only audit of video files against a family of Sonarr series.

Run where ffprobe and the media live (e.g. over ssh). Standard library only.

    sudo SERIES_RE='taskmaster' ROOTS='/home/medialibrary/Media/Taskmaster:/home/medialibrary/Media/TV/Taskmaster' \\
         python3 -I - < audit.py

Environment:
  SERIES_RE     regex (case-insensitive) selecting the series family by Sonarr title       (required)
  ROOTS         colon-separated host directories to scan for video files                   (required)
  SONARR_URL    default http://127.0.0.1:8989
  SONARR_CONFIG path to Sonarr's config.xml (to read the API key)  default /home/docker/vpn/config/sonarr/config.xml
  PATH_MAP      "container_prefix=host_prefix"  default /data/=/home/medialibrary/
  OUT           optional CSV path for the full per-file table
  TOL_SAME_S    seconds within which two files count as the same video  (default 3)
  TOL_RUNTIME_M minutes within which a file fits a TVDB runtime        (default 1.5)

Classes: TRACKED-OK, TRACKED-TITLE-DIFFERS, DUPLICATE (same length as the tracked twin),
DUPLICATE-DIFFERENT-LENGTH, OUTSIDE-SERIES-FOLDER (landing/stray copy), IMPORTABLE (title matches an empty episode), MISFILED (title matches an
episode of ANOTHER series in the family), UNKNOWN. TAG-CONFLICT marks files whose embedded title says
a different S/E or names another series of the family. It never modifies anything.
"""
import collections
import csv
import json
import os
import re
import subprocess
import sys
import urllib.request
from concurrent.futures import ThreadPoolExecutor

SONARR = os.environ.get("SONARR_URL", "http://127.0.0.1:8989")
CONFIG = os.environ.get("SONARR_CONFIG", "/home/docker/vpn/config/sonarr/config.xml")
SERIES_RE = os.environ.get("SERIES_RE") or sys.exit("set SERIES_RE")
ROOTS = [r for r in (os.environ.get("ROOTS") or sys.exit("set ROOTS")).split(":") if r]
CPREFIX, HPREFIX = os.environ.get("PATH_MAP", "/data/=/home/medialibrary/").split("=", 1)
TOL_SAME = float(os.environ.get("TOL_SAME_S", 3))
TOL_RT = float(os.environ.get("TOL_RUNTIME_M", 1.5))
VID = (".mkv", ".mp4", ".avi", ".m4v", ".mov")
KEY = re.search(r"<ApiKey>([^<]+)</ApiKey>", open(CONFIG).read()).group(1)


def get(path):
    req = urllib.request.Request(SONARR + "/api/v3" + path, headers={"X-Api-Key": KEY})
    return json.load(urllib.request.urlopen(req, timeout=180))


def host(p):
    return p.replace(CPREFIX, HPREFIX, 1)


def norm(t):
    return re.sub(r"[^a-z0-9]", "", t.lower())


def probe(path):
    try:
        out = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration:format_tags=title", "-of", "json", path],
                             capture_output=True, text=True, timeout=90).stdout
        fmt = json.loads(out).get("format", {})
        return float(fmt["duration"]), (fmt.get("tags") or {}).get("title") or (fmt.get("tags") or {}).get("TITLE") or ""
    except Exception:
        return None, ""


family = [s for s in get("/series") if re.search(SERIES_RE, s["title"], re.I)]
label = {s["id"]: "%s (%s)" % (s["title"], s["year"]) for s in family}
by_path = {host(s["path"]).rstrip("/"): s for s in family}
episodes, tracked, title_index = {}, {}, collections.defaultdict(list)
for s in family:
    for e in get("/episode?seriesId=%d&includeEpisodeFile=true" % s["id"]):
        k = (s["id"], e["seasonNumber"], e["episodeNumber"])
        episodes[k] = e
        if e["title"]:
            title_index[norm(e["title"])].append(k)
        if e.get("episodeFile"):
            tracked[host(e["episodeFile"]["path"])] = k

files = sorted({os.path.join(r, n) for root in ROOTS for r, _, ns in os.walk(root) for n in ns if n.lower().endswith(VID)})
with ThreadPoolExecutor(8) as ex:
    probed = dict(zip(files, ex.map(probe, files)))
dur = {p: v[0] for p, v in probed.items()}
tags = {p: v[1] for p, v in probed.items()}
tracked_dur = {}


def length_of(path):
    if path not in dur:
        dur[path] = probe(path)[0] if os.path.exists(path) else None
    return dur[path]


rows = []
for p in files:
    home = next((s for sp, s in sorted(by_path.items(), key=lambda x: -len(x[0])) if p.startswith(sp + "/")), None)
    n = os.path.basename(p)
    m = re.search(r"[Ss](\d+)[Ee](\d+)|(\d+)x(\d+)", n)
    se = (int(m.group(1) or m.group(3)), int(m.group(2) or m.group(4))) if m else None
    title = re.sub(r"\s*[\[(].*$", "", re.sub(r"^.*?(?:[Ss]\d+[Ee]\d+|\d+x\d+)\s*-\s*", "", os.path.splitext(n)[0]))
    ep = episodes.get((home["id"], se[0], se[1])) if home and se else None
    matches = title_index.get(norm(title), [])
    d = dur[p]
    twin = host(ep["episodeFile"]["path"]) if ep and ep.get("episodeFile") else None
    twin_d = length_of(twin) if twin and twin != p else None
    fits = None
    if ep and ep.get("runtime") and d:
        fits = abs(ep["runtime"] - d / 60) <= TOL_RT
    if p in tracked:
        kind = "TRACKED-OK" if ep and norm(ep["title"]) == norm(title) else "TRACKED-TITLE-DIFFERS"
    elif twin and twin_d and d and abs(d - twin_d) <= TOL_SAME:
        kind = "DUPLICATE"
    elif twin:
        kind = "DUPLICATE-DIFFERENT-LENGTH"
    elif ep and not ep["hasFile"] and norm(ep["title"]) == norm(title):
        kind = "IMPORTABLE"
    elif not home:
        kind = "OUTSIDE-SERIES-FOLDER"      # landing/stray copy not under any series path
    elif [x for x in matches if x[0] != home["id"]]:
        kind = "MISFILED"
    else:
        kind = "UNKNOWN"
    tag = tags[p]
    conflict = ""
    tm = re.search(r"[Ss](\d+)[Ee](\d+)", tag)
    if tm and se and (int(tm.group(1)), int(tm.group(2))) != se:
        conflict = "tag S/E %sx%s differs from filename" % (tm.group(1), tm.group(2))
    for s in family:   # the tag names a MORE specific series of the family than the folder it sits in
        ot, ht = norm(s["title"]), norm(home["title"]) if home else ""
        if home and s["id"] != home["id"] and ot != ht and ot not in ht and ot in norm(tag):
            conflict = "tag names %s" % label[s["id"]]
    rows.append(dict(kind=kind, conflict=conflict, file=p, home=label[home["id"]] if home else "-", se="S%02dE%02d" % se if se else "?",
                     title=title, sonarr_title=ep["title"] if ep else "", minutes=round(d / 60, 1) if d else "", tvdb_runtime=(ep or {}).get("runtime") or "",
                     fits_tvdb_runtime={True: "yes", False: "NO", None: ""}[fits], tag=tag, twin_delta_s=round(d - twin_d, 1) if twin_d and d else "",
                     likely_home="; ".join("%s S%02dE%02d" % (label[a], b, c) for a, b, c in matches[:3])))

if os.environ.get("OUT"):
    with open(os.environ["OUT"], "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)
print("series in family: %d | video files audited: %d" % (len(family), len(rows)))
for k, v in collections.Counter(r["kind"] for r in rows).most_common():
    print("  %-28s %4d files %7.1f GB" % (k, v, sum(os.path.getsize(r["file"]) for r in rows if r["kind"] == k) / 1e9))
print("  tag conflicts: %d" % sum(1 for r in rows if r["conflict"]))
for k in ("MISFILED", "OUTSIDE-SERIES-FOLDER", "DUPLICATE-DIFFERENT-LENGTH", "UNKNOWN", "TRACKED-TITLE-DIFFERS"):
    sel = [r for r in rows if r["kind"] == k]
    if sel:
        print("\n== %s (%d), first 12" % (k, len(sel)))
        for r in sel[:12]:
            print("   %-50s %-6s %6s min | sonarr here: %-26s | %s" % (r["file"][-50:], r["se"], r["minutes"], r["sonarr_title"][:26], (r["likely_home"] or r["tag"])[:48]))
sel = [r for r in rows if r["conflict"]]
if sel:
    print("\n== TAG CONFLICTS")
    for r in sel:
        print("   %-60s %s | tag: %s" % (r["file"][-60:], r["conflict"], r["tag"][:50]))
