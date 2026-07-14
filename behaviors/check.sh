#!/usr/bin/env bash
# The behaviors library keeps exactly one contract: any subset, any order,
# concatenated, is coherent markdown. Nothing enforced that, so it broke —
# a compression pass stripped every trailing newline and glued each heading
# onto the paragraph above it. Silent, and invisible until something composed.
#
#   ./check.sh   → exit 0 if the contract holds
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

pass=0; fail=0
say() { if [ "$1" = 0 ]; then echo "  PASS  $2"; pass=$((pass+1)); else echo "  FAIL  $2"; fail=$((fail+1)); fi; }

files=$(ls *.md | grep -v '^README.md$')

# Composability: the only contract. A file without a trailing newline welds its
# neighbour's heading to its own last line, and markdown stops seeing a heading.
missing=$(for f in $files; do tail -c1 "$f" | xxd -p | grep -q '0a' || echo "$f"; done)
[ -z "$missing" ]; say $? "every file ends in a newline (concatenation stays coherent)"
[ -n "$missing" ] && echo "$missing" | sed 's/^/          /'

# Prove it by composing, not by trusting the byte check above.
glued=$(cat $files | grep -c '[^[:space:]]##' || true)
[ "$glued" = 0 ]; say $? "no heading welded to a previous line when all files concatenate"

# Frontmatter would land in the composed prompt as literal noise.
fm=$(for f in $files; do head -1 "$f" | grep -q '^---' && echo "$f"; done)
[ -z "$fm" ]; say $? "no file carries frontmatter"

# A cross-reference breaks "any subset": the referent may not be there.
xr=$(grep -l '\]\(\.\|\[\[' $files 2>/dev/null || true)
[ -z "$xr" ]; say $? "no file references another"

# One heading each, or "any order" stops being meaningful.
odd=$(for f in $files; do [ "$(grep -c '^## ' "$f")" = 1 ] || echo "$f"; done)
[ -z "$odd" ]; say $? "each file is exactly one behavior"

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
