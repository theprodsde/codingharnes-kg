#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALLER="$ROOT/skill-install.sh"
TEMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TEMP_HOME"' EXIT

export HOME="$TEMP_HOME/user home"
export KIRO_HOME="$TEMP_HOME/kiro-profile"
export HERMES_HOME="$TEMP_HOME/hermes-profile"
export XDG_CONFIG_HOME="$TEMP_HOME/custom config"
mkdir -p "$HOME/.claude"

instruction='For any code change, follow the `solid-tdd-craft` skill and its companion skills; its Restrictions are mandatory.'
printf 'Existing guidance\r\n%s\r\n' "$instruction" > "$HOME/.claude/CLAUDE.md"

skills=(solid-tdd-craft tdd-workflow solid-design clean-code code-review security-review production-readiness deployment microservices-architecture monolithic-architecture frontend-development backend-development database-production api-contracts authentication-authorization dependency-supply-chain configuration-secrets observability-recovery data-privacy-retention)

assert_skill_set() {
  local root="$1"
  local skill
  for skill in "${skills[@]}"; do
    test -f "$root/$skill/SKILL.md" || { echo "Missing $root/$skill/SKILL.md" >&2; return 1; }
    tr -d '\r' < "$root/$skill/SKILL.md" | grep -Fx "name: $skill" >/dev/null || { echo "Incorrect skill ID in $root/$skill/SKILL.md" >&2; return 1; }
  done
  test -f "$root/solid-tdd-craft/references/CHECKLIST.md"
  test -f "$root/solid-tdd-craft/references/WORKFLOW.md"
}

assert_workflow() {
  local path="$1" text
  for text in '## Required engineering workflow' 'stop before code changes' 'Acceptance criteria' 'not verified' 'Do not weaken'; do
    grep -F "$text" "$path" >/dev/null || { echo "Missing workflow guidance '$text' in $path" >&2; return 1; }
  done
  test "$(tr -d '\r' < "$path" | grep -Fxc '## Required engineering workflow')" -eq 1
}

assert_paths() {
  local root="$1"
  shift
  local path
  for path in "$@"; do
    test -e "$root/$path" || { echo "Missing $root/$path" >&2; return 1; }
  done
}

cd "$TEMP_HOME"
if bash "$INSTALLER" --unknown >/dev/null 2>&1; then
  echo "Expected an unknown option to be rejected." >&2
  exit 1
fi
test ! -e "$TEMP_HOME/--unknown"
if bash "$INSTALLER" --global ignored-target >/dev/null 2>&1; then
  echo "Expected extra global arguments to be rejected." >&2
  exit 1
fi
if bash "$INSTALLER" --project "$TEMP_HOME/unexpected" ignored-target >/dev/null 2>&1; then
  echo "Expected extra project arguments to be rejected." >&2
  exit 1
fi
test ! -e "$TEMP_HOME/unexpected"
if KIRO_HOME=relative-kiro-home bash "$INSTALLER" --global >/dev/null 2>&1; then
  echo "Expected a relative KIRO_HOME to be rejected." >&2
  exit 1
fi
if XDG_CONFIG_HOME=relative-config bash "$INSTALLER" --global >/dev/null 2>&1; then
  echo "Expected a relative XDG_CONFIG_HOME to be rejected." >&2
  exit 1
fi
if HERMES_HOME=relative-hermes-home HOME="$HOME" bash "$INSTALLER" --global >/dev/null 2>&1; then
  echo "Expected a relative HERMES_HOME to be rejected." >&2
  exit 1
fi
if HERMES_HOME='C:\Windows-profile' bash "$INSTALLER" --global >/dev/null 2>&1; then
  echo "Expected a non-POSIX profile path to be rejected." >&2
  exit 1
fi
test ! -e "$HOME/.claude/skills"

bash "$INSTALLER" --global >/dev/null
assert_workflow "$HOME/.claude/CLAUDE.md"
assert_skill_set "$HOME/.claude/skills"
assert_skill_set "$HOME/.copilot/skills"
assert_skill_set "$KIRO_HOME/skills"
assert_skill_set "$HERMES_HOME/skills"
assert_skill_set "$XDG_CONFIG_HOME/opencode/skills"
assert_paths "$HOME" \
  .claude/CLAUDE.md \
  .copilot/copilot-instructions.md \
  .claude/commands/review.md
assert_paths "$XDG_CONFIG_HOME" opencode/AGENTS.md opencode/commands/review.md
assert_paths "$KIRO_HOME" \
  steering/solid-tdd-craft.md \
  steering/kiro-review.md

bash "$INSTALLER" --global >/dev/null
test "$(tr -d '\r' < "$HOME/.claude/CLAUDE.md" | grep -Fxc "$instruction")" -eq 1
grep -Fq 'Existing guidance' "$HOME/.claude/CLAUDE.md"
for path in "$HOME/.claude/CLAUDE.md" "$HOME/.copilot/copilot-instructions.md" "$KIRO_HOME/steering/solid-tdd-craft.md" "$XDG_CONFIG_HOME/opencode/AGENTS.md"; do
  assert_workflow "$path"
done

PROJECT="$TEMP_HOME/project [fixture] with spaces"
mkdir -p "$PROJECT"
: > "$PROJECT/AGENTS.md"
env -u HOME bash "$INSTALLER" --project "$PROJECT" >/dev/null
bash "$INSTALLER" "$PROJECT" >/dev/null
for path in AGENTS.md CLAUDE.md .github/copilot-instructions.md .kiro/steering/craft.md; do
  assert_workflow "$PROJECT/$path"
done
test "$(grep -Fxc "$instruction" "$PROJECT/AGENTS.md")" -eq 1
assert_skill_set "$PROJECT/.claude/skills"
assert_skill_set "$PROJECT/.github/skills"
assert_skill_set "$PROJECT/.kiro/skills"
assert_skill_set "$PROJECT/.hermes/skills"
assert_skill_set "$PROJECT/.opencode/skills"
assert_paths "$PROJECT" \
  CLAUDE.md \
  .github/copilot-instructions.md \
  .kiro/steering/craft.md \
  AGENTS.md \
  .claude/commands/review.md \
  .github/prompts/review.prompt.md \
  .kiro/steering/kiro-review.md \
  .opencode/commands/review.md

(cd "$PROJECT"; bash "$INSTALLER" >/dev/null)
test "$(grep -Fxc "$instruction" "$PROJECT/AGENTS.md")" -eq 1

env -u KIRO_HOME -u HERMES_HOME -u XDG_CONFIG_HOME HOME="$TEMP_HOME/defaults" bash "$INSTALLER" --global >/dev/null
assert_skill_set "$TEMP_HOME/defaults/.config/opencode/skills"
assert_skill_set "$TEMP_HOME/defaults/.kiro/skills"
assert_skill_set "$TEMP_HOME/defaults/.hermes/skills"

# Harness selection: only the named harnesses are installed; no selection installs all.
absent() { local base="$1" path; shift; for path in "$@"; do test ! -e "$base/$path" || { echo "Unexpected $base/$path" >&2; return 1; }; done; }
SEL="$TEMP_HOME/selected project"
mkdir -p "$SEL"
bash "$INSTALLER" --project "$SEL" --harness kiro >/dev/null
assert_skill_set "$SEL/.kiro/skills"
assert_paths "$SEL" .kiro/steering/craft.md .kiro/steering/kiro-review.md
absent "$SEL" .claude .github .hermes .opencode CLAUDE.md AGENTS.md
bash "$INSTALLER" --harness=claude,hermes "$SEL" >/dev/null
bash "$INSTALLER" "$SEL" --harness opencode >/dev/null
assert_skill_set "$SEL/.claude/skills"
assert_skill_set "$SEL/.hermes/skills"
assert_skill_set "$SEL/.opencode/skills"
assert_paths "$SEL" CLAUDE.md AGENTS.md .claude/commands/review.md .opencode/commands/review.md
absent "$SEL" .github

GSEL="$TEMP_HOME/selected-home"
env -u KIRO_HOME -u HERMES_HOME -u XDG_CONFIG_HOME HOME="$GSEL" bash "$INSTALLER" --global --harness copilot >/dev/null
assert_skill_set "$GSEL/.copilot/skills"
assert_paths "$GSEL" .copilot/copilot-instructions.md
absent "$GSEL" .claude .kiro .hermes .config

if bash "$INSTALLER" --project "$TEMP_HOME/bad-harness" --harness bogus >/dev/null 2>&1; then
  echo "Expected an unknown harness to be rejected." >&2; exit 1
fi
if bash "$INSTALLER" --project "$TEMP_HOME/bad-harness" --harness >/dev/null 2>&1; then
  echo "Expected a missing harness name to be rejected." >&2; exit 1
fi
test ! -e "$TEMP_HOME/bad-harness"
echo "Installer tests passed."
