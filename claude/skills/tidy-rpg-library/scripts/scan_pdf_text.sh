#!/bin/bash
f="$1"
t=$(timeout 90 gs -q -dNOPAUSE -dBATCH -sDEVICE=txtwrite -dFirstPage=1 -dLastPage=8 -sOutputFile=- "$f" 2>/dev/null | tr 'A-Z' 'a-z')
n=$(grep -o -E 'numenera|ninth world|amber monolith|steadfast' <<<"$t" | wc -l)
s=$(grep -o -E 'the strange|recursion|estate' <<<"$t" | wc -l)
c=$(grep -o -E 'cypher system|cypher' <<<"$t" | wc -l)
printf '%s\t%s\t%s\t%s\n' "$n" "$s" "$c" "$f"
