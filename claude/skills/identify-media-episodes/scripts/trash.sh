#!/bin/bash
# Move files into the trash instead of deleting them. Run on the media host (sudo needed for ownership).
#   sudo bash trash.sh FILE...
# Files land in /home/medialibrary/trash/<date>/<path relative to /home/medialibrary/>, so the user can
# empty the trash in one go (and a wrong call is reversible). Same filesystem as the library: instant mv.
set -euo pipefail
TRASH=${TRASH:-/home/medialibrary/trash}/$(date +%F)
for f in "$@"; do
  [[ -f $f ]] || { echo "skip (not a file): $f" >&2; continue; }
  dest="$TRASH/${f#/home/medialibrary/}"
  mkdir -p "$(dirname "$dest")"
  mv -v -- "$f" "$dest"
done
