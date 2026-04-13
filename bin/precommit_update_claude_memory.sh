#!/bin/bash



CWD=$(realpath $0);
DIR=$(dirname $CWD);
cd $DIR/../claude/feedback/ || exit 5;

echo -e "# Memory Index\n" > MEMORY.md;

for FILE in *.md;
  do
    [[ $FILE == "MEMORY.md" ]] && continue;
    NAME=$(grep name: $FILE | cut -d\: -f2- );
    DESC=$(grep description: ${FILE} | cut -d\: -f2- );
    echo "- [${NAME## }]($FILE) -$DESC";
done >> MEMORY.md
