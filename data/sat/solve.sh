#!/bin/sh
# ./solve.sh n infile

export PATH="$PATH:/usr/local/bin:/opt/local/bin"
outfile="tmp.$$"

n="$1"
file="$2"

minisat "$file" "$outfile" 2>&1 >/dev/null

head -1 "$outfile"
cat "$outfile" |
 tr ' ' '\n' | sed '/^\-/d' |
 perl -ne 'if (0 < $_ && $_ <= '"$n"') { print; }'

rm -f "$outfile"
