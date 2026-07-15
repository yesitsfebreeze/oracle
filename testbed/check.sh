#!/usr/bin/env bash
# Checks the oracle.
#
#   ./check.sh                     behaviors library contract. Free, offline, instant.
#   ./check.sh --install           also install end-to-end with a real agent.
#
# The two halves cost wildly different things, so the expensive one is opt-in:
# the contract check reads files, the install check spawns an agent and bills for it.
#
#   HARNESS=codex ./check.sh --install                     same install, another agent
#   ORACLE_URL=https://raw.../ORACLE.md ./check.sh --install   test the real remote
#
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

pass=0; fail=0
say() { if [ "$1" = 0 ]; then echo "  PASS  $2"; pass=$((pass+1)); else echo "  FAIL  $2"; fail=$((fail+1)); fi; }
check() { local name="$1"; shift; "$@" >/dev/null 2>&1; say $? "$name"; }

# ─────────────────────────────────────────────────────────────────────────────
# The behaviors library keeps exactly one contract: any subset, any order,
# concatenated, is coherent markdown. Nothing enforced that, so it broke —
# a compression pass stripped every trailing newline and glued each heading
# onto the paragraph above it. Silent, and invisible until something composed.
# ─────────────────────────────────────────────────────────────────────────────
behaviors_contract() {
  cd "$REPO/behaviors" || { echo "  FAIL  behaviors/ exists"; fail=$((fail+1)); return; }

  local files
  files=$(ls *.md 2>/dev/null)

  # A check over zero files passes every assertion below and means nothing. This
  # script once lived beside the behaviors and was moved; it kept reporting 5/5
  # while checking an empty list. Refuse to be green about nothing.
  if [ -z "$files" ]; then
    echo "  FAIL  found behaviors to check (looked in $PWD, found none)"
    fail=$((fail+1)); return
  fi
  echo "checking $(echo "$files" | wc -l) behaviors in $PWD"

  # Composability: the only contract. A file without a trailing newline welds its
  # neighbour's heading to its own last line, and markdown stops seeing a heading.
  local missing glued fm xr odd
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
}

# ─────────────────────────────────────────────────────────────────────────────
# Isolated end-to-end test of the install path.
#
# Serves this repo over HTTP, then hands a fresh agent nothing but the raw
# ORACLE.md URL — the paste that is supposed to be the entire install — and
# checks what it built. Fresh CLAUDE_CONFIG_DIR, no plugins, no MCP servers,
# no user settings: text and an agent, which is all the install claims to need.
#
# Harnesses: claude, codex, opencode. An agent that errors is not a harness
# failure to hide — the verdict reports what it actually left on disk.
# ─────────────────────────────────────────────────────────────────────────────
# Not local: the EXIT trap fires after install_e2e has returned, and a local
# would be out of scope by then — cleanup would leave the borrowed credential.
WORK=""; SERVER_PID=""
inconclusive=0

install_e2e() {
  local HARNESS="${HARNESS:-claude}"
  local PORT="${PORT:-8017}"
  WORK="$(mktemp -d /tmp/oracle-testbed-XXXXXX)"

  cleanup() {
    [ -z "$WORK" ] && return
    [ -n "$SERVER_PID" ] && kill "$SERVER_PID" 2>/dev/null
    rm -f "$WORK/config/.credentials.json"
    echo "testbed: $WORK"
  }
  trap cleanup EXIT

  mkdir -p "$WORK/config" "$WORK/project"

  # CLAUDE_CONFIG_DIR isolates credentials along with everything else, so a fresh
  # config cannot authenticate. Borrow the credential only; settings, plugins and
  # MCP servers stay empty. Removed on exit.
  if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
    cp "$HOME/.claude/.credentials.json" "$WORK/config/.credentials.json" 2>/dev/null || {
      echo "  FAIL  no ANTHROPIC_API_KEY and no ~/.claude/.credentials.json to borrow"
      fail=$((fail+1)); return; }
    chmod 600 "$WORK/config/.credentials.json"
  fi

  if [ -z "${ORACLE_URL:-}" ]; then
    python3 -m http.server "$PORT" --directory "$REPO" --bind 127.0.0.1 >/dev/null 2>&1 &
    SERVER_PID=$!
    for _ in $(seq 20); do
      curl -sf "http://127.0.0.1:$PORT/ORACLE.md" -o /dev/null && break
      sleep 0.2
    done
    ORACLE_URL="http://127.0.0.1:$PORT/ORACLE.md"
  fi

  curl -sf "$ORACLE_URL" -o /dev/null || {
    echo "  FAIL  $ORACLE_URL not fetchable"; fail=$((fail+1)); return; }
  echo "source: $ORACLE_URL"

  # The install request as a user actually performs it: the URL plus the intent.
  # A bare URL is not an install request — agents rightly refuse a document that
  # claims fetching it is its own authorization, and a test that sends one is
  # measuring a scenario no real user creates. The human authorises; the file does not.
  local REQUEST="${REQUEST:-Install this in this repo: $ORACLE_URL}"

  cd "$WORK/project" || { echo "  FAIL  testbed workdir"; fail=$((fail+1)); return; }
  git init -q
  echo "harness: $HARNESS"

  case "$HARNESS" in
  claude)
    CLAUDE_CONFIG_DIR="$WORK/config" \
    claude --strict-mcp-config \
           --dangerously-skip-permissions \
           -p "$REQUEST" </dev/null \
      2>&1 | tee "$WORK/transcript.txt"
    ;;
  codex)
    # Codex auto-loads AGENTS.md, not CLAUDE.md — the install must detect that
    # rather than assume. That difference is the point of testing a second harness.
    codex exec --dangerously-bypass-approvals-and-sandbox \
               --skip-git-repo-check \
               -C "$WORK/project" \
               "$REQUEST" </dev/null \
      2>&1 | tee "$WORK/transcript.txt"
    ;;
  opencode)
    # Third vendor. The `opencode` on PATH here is a Windows build reached from
    # WSL — a platform mismatch, not opencode being broken, which is what this
    # was misdiagnosed as for most of a session. The linux binary works; its
    # backend returned UnknownError on every free model, so this path is wired
    # and unverified. Install it when you want to try again:
    #   npm i --prefix testbed/.oc opencode-linux-x64
    local OC="$REPO/testbed/.oc/node_modules/opencode-linux-x64/bin/opencode"
    [ -x "$OC" ] || { echo "  FAIL  no linux opencode at $OC — npm i --prefix .oc opencode-linux-x64"
      fail=$((fail+1)); return; }
    "$OC" run ${OC_MODEL:+-m "$OC_MODEL"} "$REQUEST" </dev/null \
      2>&1 | tee "$WORK/transcript.txt"
    ;;
  *)
    echo "  FAIL  unknown harness '$HARNESS' (claude|codex|opencode)"; fail=$((fail+1)); return ;;
  esac || agent_rc=1

  # The testbed cannot test an install that never started. An agent that failed
  # to launch or authenticate leaves behind exactly what an install that silently
  # did nothing leaves behind — an empty repo — and scoring that as ten FAILs
  # reports a broken oracle when what actually broke was the harness. Red over
  # nothing is the same lie as green over nothing, and harder to spot.
  if [ "${agent_rc:-0}" != 0 ] && [ ! -f ORACLE.md ]; then
    echo
    echo "  INCONCLUSIVE  agent exited non-zero and landed nothing — install path untested"
    if grep -qi 'authenticat\|credential\|api key\|oauth' "$WORK/transcript.txt" 2>/dev/null; then
      echo "                cause looks like auth. Set ANTHROPIC_API_KEY, or refresh the"
      echo "                credential this borrows from ~/.claude/.credentials.json."
    fi
    echo "                transcript: $WORK/transcript.txt"
    inconclusive=1
    return
  fi
  [ "${agent_rc:-0}" != 0 ] && echo "(agent exited non-zero — verdict below says what it left behind)"

  echo
  check "ORACLE.md landed at repo root"            test -f ORACLE.md
  check "auto-loaded instruction file created"     sh -c '[ -f AGENTS.md ] || [ -f CLAUDE.md ]'
  check "pre-commit hook installed (ruling 1-2)"   test -f .git/hooks/pre-commit
  check "install products excluded from history"   grep -qs "AGENTS.md\|CLAUDE.md" .git/info/exclude

  # ORACLE.md is machinery whole. A vision heading or an `_Empty._` placeholder
  # means the agent reproduced the old shape, where content lived in the file.
  check "ORACLE.md carries no content of its own" \
    sh -c '[ -f ORACLE.md ] && ! grep -q "^## What we are building\|_Empty\._" ORACLE.md'

  # Content files appear when they first hold something. An install that lays
  # down empty scaffolds puts a lie about what was decided into every session.
  check "no empty content scaffold laid down" \
    sh -c '! [ -f VISION.md ] && ! [ -f FEATURES.md ] && ! [ -f ROADMAP.md ] && ! [ -f SPECIALISTS.md ]'

  # Step 6: the install is a decision, and CHANGELOG.md is what first records it.
  check "install recorded itself in CHANGELOG.md" \
    sh -c '[ -f CHANGELOG.md ] && grep -q "Decided by:" CHANGELOG.md'

  # Ruling 1 must count entries, not grep for "Decided by:" — a changelog holds
  # every past entry, so a grep goes green from the second commit onward forever.
  check "hook keys on CHANGELOG.md" \
    sh -c '[ -f .git/hooks/pre-commit ] && grep -qi "CHANGELOG" .git/hooks/pre-commit'

  # Ruling 1 can only fire on a file git actually stages. If the install excluded
  # ORACLE.md, every commit below is vacuous — nothing staged, nothing checked.
  check "ORACLE.md is tracked, so ruling 1 has something to fire on" \
    sh -c '[ -f ORACLE.md ] && ! git check-ignore -q ORACLE.md'

  # Step 6: the install block runs once, then deletes itself. If it survives, the
  # repo keeps a 2.7k manual for a finished job and reads it every session.
  check "install scaffolding removed (step 6)" \
    sh -c '[ -f ORACLE.md ] && ! grep -q "oracle:install:start" ORACLE.md'
  check "Ruling survived the scaffolding removal" \
    sh -c 'grep -q "^## Ruling" ORACLE.md'

  # Ruling 1 must actually bite: an ORACLE.md edit that adds no new "Decided by:"
  # entry to CHANGELOG.md is rejected. "Prove it": the rejection must come from the
  # hook. A commit that fails because nothing was staged is not the hook working —
  # it is the check lying.
  printf '\n<!-- probe -->\n' >> ORACLE.md
  git add -A >/dev/null 2>&1
  git add -f ORACLE.md >/dev/null 2>&1
  if [ -z "$(git diff --cached --name-only)" ]; then
    echo "  FAIL  ruling 1 rejection is real (nothing staged — probe never reached the hook)"
    fail=$((fail+1))
  elif git commit -q -m "probe: unrecorded ORACLE.md edit" >/dev/null 2>&1; then
    echo "  FAIL  ruling 1 blocks an unrecorded ORACLE.md change"; fail=$((fail+1))
  else
    echo "  PASS  ruling 1 blocks an unrecorded ORACLE.md change"; pass=$((pass+1))
  fi
  # Undo the probe. checkout alone leaves the appended line when ORACLE.md was
  # never committed, which dirties the artifact the byte measurements read.
  git reset -q 2>/dev/null
  git checkout -- ORACLE.md 2>/dev/null
  if grep -q '<!-- probe -->' ORACLE.md 2>/dev/null; then
    grep -v '<!-- probe -->' ORACLE.md > "$WORK/.clean" && mv "$WORK/.clean" ORACLE.md
  fi

  echo
  echo "delivered artifact: $(wc -c < ORACLE.md) bytes"
}

case "${1:-}" in
  --install) behaviors_contract; echo; install_e2e ;;
  "")        behaviors_contract ;;
  *)         echo "usage: ${0##*/} [--install]"; exit 2 ;;
esac

echo
echo "$pass passed, $fail failed"
# Exit 3, not 1: "the install was never tested" is not "the install is broken",
# and a caller that cannot tell them apart will read one as the other.
[ "$inconclusive" = 1 ] && { echo "install path INCONCLUSIVE — see above"; exit 3; }
[ "$fail" -eq 0 ]
