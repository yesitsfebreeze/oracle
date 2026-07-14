#!/usr/bin/env bash
# Isolated end-to-end test of the oracle install path.
#
# Serves this repo over HTTP, then hands a fresh agent nothing but the raw
# ORACLE.md URL — the paste that is supposed to be the entire install — and
# checks what it built. Fresh CLAUDE_CONFIG_DIR, no plugins, no MCP servers,
# no user settings: text and an agent, which is all the install claims to need.
#
#   ./run.sh                       # serve this working tree, test against it
#   HARNESS=codex ./run.sh         # same install, a different agent
#   ORACLE_URL=https://raw.../ORACLE.md ./run.sh   # test the real remote
#
# Harnesses: claude, codex, opencode. An agent that errors is not a harness
# failure to hide — the verdict reports what it actually left on disk.
set -euo pipefail
HARNESS="${HARNESS:-claude}"

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d /tmp/oracle-testbed-XXXXXX)"
PORT="${PORT:-8017}"
SERVER_PID=""

cleanup() {
  [ -n "$SERVER_PID" ] && kill "$SERVER_PID" 2>/dev/null || true
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
    echo "FAIL: no ANTHROPIC_API_KEY and no ~/.claude/.credentials.json to borrow"; exit 1; }
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

curl -sf "$ORACLE_URL" -o /dev/null || { echo "FAIL: $ORACLE_URL not fetchable"; exit 1; }
echo "source: $ORACLE_URL"

# The install request as a user actually performs it: the URL plus the intent.
# A bare URL is not an install request — agents rightly refuse a document that
# claims fetching it is its own authorization, and a test that sends one is
# measuring a scenario no real user creates. The human authorises; the file does not.
REQUEST="${REQUEST:-Install this in this repo: $ORACLE_URL}"

cd "$WORK/project"
git init -q
echo "harness: $HARNESS"

set +e
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
  OC="$REPO/testbed/.oc/node_modules/opencode-linux-x64/bin/opencode"
  [ -x "$OC" ] || { echo "FAIL: no linux opencode at $OC — npm i --prefix .oc opencode-linux-x64"; exit 1; }
  (cd "$WORK/project" && "$OC" run ${OC_MODEL:+-m "$OC_MODEL"} "$REQUEST" </dev/null) \
    2>&1 | tee "$WORK/transcript.txt"
  ;;
*)
  echo "FAIL: unknown harness '$HARNESS' (claude|codex|opencode)"; exit 1 ;;
esac || echo "(agent exited non-zero — verdict below says what it left behind)"

echo
echo "──────── verdict ────────"
pass=0; fail=0
check() { # name, then the condition as a command
  local name="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "  PASS  $name"; pass=$((pass+1))
  else echo "  FAIL  $name"; fail=$((fail+1)); fi
}

check "ORACLE.md landed at repo root"            test -f ORACLE.md
check "content half reset to undecided vision"   grep -q "Undecided" ORACLE.md
check "auto-loaded instruction file created"     sh -c '[ -f AGENTS.md ] || [ -f CLAUDE.md ]'
check "pre-commit hook installed (ruling 1-2)"   test -f .git/hooks/pre-commit
check "install products excluded from history"   grep -qs "AGENTS.md\|CLAUDE.md" .git/info/exclude

# Ruling 1 must bite on a real edit, not on the file merely containing the
# string "Decided by:" — the machinery half quotes it while describing the rule.
check "hook is not satisfied by the file quoting its own rule" \
  sh -c '[ -f .git/hooks/pre-commit ] && grep -q "Changelog" .git/hooks/pre-commit'

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

# Ruling 1 must actually bite: an ORACLE.md edit with no Changelog entry is rejected.
# "Prove it": the rejection must come from the hook. A commit that fails because
# nothing was staged is not the hook working — it is the check lying.
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
git reset -q 2>/dev/null || true
git checkout -- ORACLE.md 2>/dev/null || true
if grep -q '<!-- probe -->' ORACLE.md 2>/dev/null; then
  grep -v '<!-- probe -->' ORACLE.md > "$WORK/.clean" && mv "$WORK/.clean" ORACLE.md
fi
echo
echo "delivered artifact: $(wc -c < ORACLE.md) bytes"

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
