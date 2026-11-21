---
name: identify-media-episodes
description: Use when video files in a Sonarr/Jellyfin library may be mislabelled, such as regional editions of one format (Taskmaster UK/AU/NZ/US), duplicate cuts, specials mapped to the wrong episode, YouTube uploads filed as broadcast episodes, or generic names like "Episode 7". Identifies what a file really is from embedded title tags, exact durations, and on-screen title cards (read as images), then fixes Sonarr with manual import and rename. Do NOT trust filenames or title-only matching.
---

# Identifying what a media file really is

Filenames lie. Filebot-era names match by loose title and mix up regional editions, so a UK episode can carry an Australian title. Sonarr trusts the filename's S/E number, so it happily maps the wrong video. **Never import, move or delete on a title match alone.** (Learned the hard way: three UK episodes were imported into the Australian series because their titles matched; only a look at the picture exposed it.)

## Evidence, strongest first

1. **Embedded `title` tag**: `ffprobe -v error -show_entries format_tags=title -of csv=p=0 FILE`. Often carries the original release/video title (e.g. "Taskmastermind | ED GAMBLE vs JENNY ECLAIR | Episode 1", "Champion of Champions S07E01 ... 2025"). Many files have none (about 60%); absence proves nothing.
2. **What is on screen.** Grab a frame and **read the image** with the Read tool. Look for: the show's logo card (e.g. "TASKMASTER AUSTRALIA"), the host and set (different host means different edition), a broadcaster bug or promo (Channel 10), and the **episode's own title caption** that appears with the first task (about 30 s in; e.g. "A fat bald white man."). The caption is the most reliable per-episode identifier.
3. **Exact duration (seconds)**.
   - A file that equals a tracked file's length to within about 3 s is the **same video** (even if the encode differs). That is what makes deleting a copy safe.
   - Compare against the **per-episode** TVDB runtime (minute-accurate, varies per episode), tolerance ±1.5 min. A series-wide average cannot separate similar formats (UK and AU are both about 47 min).
   - Caveats: YouTube uploads and ad-free edits are shorter than TVDB's broadcast runtime; broadcast captures with promos run longer. A length mismatch means "look at the picture", not "wrong".
4. **Sidecar subtitles (`.srt` beside the video)**: the dialogue names the plot, so they are cheap, strong evidence when a TVDB synopsis does not match the picture. Search them for distinctive words (names, places, "NASCAR", "antidote"). Caveat: a sidecar belongs to the **episode slot**, not necessarily to the video in it. A slot whose subtitles disagree with its video is the wrong one, and the video's true home is the episode whose subtitles do match. Worked case: Lucifer S2E13's video was a copy of S3E26; S2E13's own `.srt` was about the antidote and hell, while S3E26's `.srt` mentioned NASCAR six times, matching the video. TVDB's one-line synopsis for S3E26 never mentions racing, so do not trust a synopsis over the subtitles.
5. **Filename title and S/E**: a hint only.

## Workflow

1. **Scope.** Which Sonarr series form the family (all regional/variant series), and which folders hold their files, including "landing" folders outside the series paths.
2. **Audit (read-only)**: `scripts/audit.py` (run where ffprobe and the media live; usage in the file header). It classifies every file: `TRACKED-OK`, `TRACKED-TITLE-DIFFERS`, `DUPLICATE`, `MISFILED` (title matches another series in the family), `UNKNOWN`, with measured lengths and tag conflicts.
3. **Probe the doubtful ones**: tags, exact seconds against the tracked twin, TVDB runtime at that S/E.
4. **Look.** `scripts/titlecards.sh` makes frames and contact sheets; read the images. For anything you plan to **keep as the correct file**, check it too, not only the suspect. (Here a tracked "keeper" was itself the wrong episode; its sibling was the right one.)
5. **Decide** with the table below, write the plan as a reviewable list, and get approval before touching files.
6. **Apply in small steps** with a check after each (see `references/sonarr-recipes.md`). Re-run the audit at the end.

## Decision table

| Evidence | Meaning | Action |
|---|---|---|
| Same length (±3 s) as a tracked file at the same S/E, caption/tag agrees | duplicate of a correct file, wrong name | move the untracked one to the trash |
| Same length as a tracked file, but the **tracked** one fails the picture/tag check | the tracked file is the wrong episode | fix the tracked mapping first; do not delete either until sorted |
| Picture/tag says another series in the family | misfiled | import into that series (manual import), then rename |
| Fits only one candidate's per-episode runtime and the picture agrees | identified | import to it |
| Picture or tag says something not in TVDB (bonus clip, YouTube upload) | no slot | leave, or map to the nearest special by title; tell the user |
| Fits no candidate, picture inconclusive | unknown | **hold** and list for the user |

Specials (season 0) are numbered inconsistently between sources: never map them by number. Identify by tag/caption, then by title, then check the length is plausible (YouTube-origin specials are shorter than TVDB).

## Rules that kept this safe

- **Never delete; move to the trash** (the user's rule): `/home/medialibrary/trash/<date>/<original path under /home/medialibrary>`, on the same filesystem so it is an instant `mv` (`scripts/trash.sh FILE...`). The user empties the trash in one go when happy. Only trash a file that has a **tracked twin of the same length**, and only after the keeper passed the picture/tag check. This includes files Sonarr would delete itself: a manual import over an existing file destroys the old one, so `mv` the old file to the trash first.
- Hold anything unidentified; list it rather than guess.
- Dry-run first and show counts plus a full list; large delete/apply scripts may need the user to run them (the permission system may block bulk deletes). Give them one copy-pasteable line.
- Verify through Sonarr after every step (`hasFile`, path, episode file id); a rescan can silently re-map files by filename.
- Show the user what you saw ("caption reads ...", "host is ...") so they can overrule you.

## Pitfalls

- A name glob like `S03E08*` also matches `-thumb.jpg`; restrict by video extension.
- `ffmpeg -ss` before `-i` with `-accurate_seek` for a precise frame. Seeking inside a JPEG fails with "could not seek".
- TVDB writes country codes (`Taskmaster (AU)`), and folders use localised names (`España`, `Brasil`); match by TVDB id, not by name.
- Different TVDB season numbering for reboots (e.g. the Animaniacs reboot is seasons 6-8 of the original), so scene-mapped packs can look wrong but be right.
- `GET /manualimport?seriesId=N` lists the **series' own folder**, ignoring `folder`; use `folder` alone.
- **Sonarr tracks one file per episode**, so a wrongly mapped file can hide the real one beside it (same S/E in the name, different extension or apostrophe). After trashing or re-mapping, `RescanSeries` re-attaches whatever is in the folder **by filename**, so re-check the result: in The Terror three old `.avi` copies of the wrong show re-attached themselves to the freed slots.
- **Films filed as episodes.** A file far longer than the show's runtime (95-130 min in a 50-minute series) is usually a film, often matched by a release-year pattern such as `S01E1979 - Star Trek The Motion Picture`. Check the library's own `Movies` folder for a same-length twin (often a hardlink of the same inode) and trash the episode-slot name. Several slots can map to one film, so group by exact length and size too.
- **Library-wide sweep without ffprobe:** list every file Sonarr tracks with its size and inode and group by exact size (>20 MB). Same size under two slots means one is wrong: a **same-series** pair (Cutthroat Kitchen S11/S12, Lucifer, Gotham) is a copy filed under the wrong episode (the slot whose TVDB title/synopsis matches the frames is the real one); a **cross-series** pair (Drag Race France vs All Stars, Discovery vs Short Treks) means the file belongs to one of them. Also compare tracked sizes with untracked film folders. Ignore groups of identical size across many episodes of an old show: those were encoded to a fixed size (Mad Men, Xena `.avi`), so also compare exact length before acting.
- Featurettes, shorts and even unrelated documentaries (UFOTV filed as The Americans) get mapped by a filename match; a file far shorter than the runtime is often a Short Trek/featurette whose real slot exists in a sibling series.
- **Single frames mislead.** One frame per episode is a screening step, not identification: in TOS two "wrong" episodes (Mirror, Mirror vs The Apple, Cloud Minders vs Savage Curtain) turned out to be correct once a contact sheet of the first ten minutes was read. Confirm a doubt with a sheet before changing anything.
- A same-library **non-episode** (concert, Comic-Con panel) has no slot: park it as a plain file in `Specials/` with no `SxxExx` in the name (Jellyfin shows it, Sonarr ignores it), or trash it if the user says so.
- A re-map **within one series** (`ManualImport` to another episode of the same series) only changes the database; follow it with `RenameFiles` so the file moves to the right season folder.
- A tag naming another show or season (`The Terror: Devil in Silver S01E01`, `Forged in Fire S11E02`) means the file belongs to a different TVDB season or series; check TVDB's own season layout (Devil in Silver is The Terror season 3).

See `references/sonarr-recipes.md` for the API calls and a worked Taskmaster example.
