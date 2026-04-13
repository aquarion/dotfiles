#!/bin/bash
set -euo pipefail

CWD=$(realpath "$0")
DIR=$(dirname "$CWD")
cd "$DIR/../claude/feedback/" || exit 5

TMPFILE=$(mktemp)

echo -e "# Memory Index\n" > "$TMPFILE"

for FILE in *.md; do
    [[ $FILE == "MEMORY.md" ]] && continue
    NAME=$(grep -m 1 "^name:" "$FILE" | cut -d: -f2-)
    DESC=$(grep -m 1 "^description:" "$FILE" | cut -d: -f2-)
    echo "- [${NAME## }]($FILE) -$DESC"
done >> "$TMPFILE"

mv "$TMPFILE" MEMORY.md
