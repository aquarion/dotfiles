#!/bin/bash
# Pull frames from video files so you can READ them (Read tool) and see what an episode really is.
# Run where ffmpeg and the files live (e.g. `ssh host 'bash -s -- ...' < titlecards.sh`).
#
#   titlecards.sh OUTDIR FILE...                 one frame per file at SEEK (default 00:00:32.01, accurate seek)
#   SWEEP=1 titlecards.sh OUTDIR FILE            contact sheet of the first SWEEP_SECS (default 300) at one frame every
#                                                STEP s (default 20), 4x4 tiles: look for the episode's title caption
#   SEEK=00:01:30 titlecards.sh OUTDIR FILE...   a different timestamp
#
# Outputs: OUTDIR/<n>-<basename>.jpg, plus OUTDIR/sheet.jpg (ImageMagick montage, same order as the arguments, no labels)
# when several single frames were made. ffmpeg runs with -nostdin so the script can be piped over ssh.
# Needs: ffmpeg; montage (ImageMagick) only for the combined sheet. Never modifies the source files.
set -euo pipefail
out=${1:?usage: titlecards.sh OUTDIR FILE...}; shift
mkdir -p "$out"
n=0; made=()
for f in "$@"; do
  [ -f "$f" ] || { echo "skip (not a file): $f" >&2; continue; }
  case "${f,,}" in *.mkv|*.mp4|*.avi|*.m4v|*.mov) ;; *) echo "skip (not video): $f" >&2; continue;; esac
  n=$((n+1)); base=$(basename "$f" | tr -c 'A-Za-z0-9._-' '_')
  if [ -n "${SWEEP:-}" ]; then
    ffmpeg -nostdin -v error -y -t "${SWEEP_SECS:-300}" -i "$f" -vf "fps=1/${STEP:-20},scale=480:270,tile=4x4" -frames:v 1 "$out/$n-$base.sheet.jpg"
    echo "$out/$n-$base.sheet.jpg"
  else
    ffmpeg -nostdin -v error -y -accurate_seek -ss "${SEEK:-00:00:32.01}" -i "$f" -frames:v 1 -q:v 3 "$out/$n-$base.jpg"
    made+=("$out/$n-$base.jpg"); echo "$out/$n-$base.jpg"
  fi
done
if [ "${#made[@]}" -gt 1 ] && command -v montage >/dev/null; then
  # montage warns about a missing default font and exits non-zero even though it writes the sheet
  montage "${made[@]}" -tile 4x -geometry 640x360+6+6 -background '#222' "$out/sheet.jpg" 2>/dev/null || true
  [ -s "$out/sheet.jpg" ] && echo "$out/sheet.jpg"
fi
