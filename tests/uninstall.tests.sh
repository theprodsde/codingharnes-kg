#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALLER="$ROOT/skill-install.sh"
UNINSTALLER="$ROOT/skill-uninstall.sh"
TEMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TEMP_HOME"' EXIT

export HOME="$TEMP_HOME/user home"
export KIRO_HOME="$TEMP_HOME/kiro-profile"
export HERMES_HOME="$TEMP_HOME/hermes-profile"
export XDG_CONFIG_HOME="$TEMP_HOME/custom config"
mkdir -p "$HOME/.claude"

instruction='For any code change, follow the `solid-tdd-craft` skill and its companion skills; its Restrictions are mandatory.'
skills=(solid-tdd-craft tdd-workflow solid-design clean-code code-review security-review production-readiness deployment microservices-architecture monolithic-architecture frontend-development backend-development database-production api-contracts authentication-authorization dependency-supply-chain configuration-secrets observability-recovery data-privacy-retention)

assert_no_skills() {
  local root="$1" skill
  for skill in "${skills[@]}"; do
    test ! -e "$root/$skill" || { echo "Skill still present: $root/$skill" >&2; return 1; }
  done
}

assert_absent() {
  local path
  for path in "$@"; do
    test ! -e "$path" || { echo "Expected removed: $path" >&2; return 1; }
  done
}

assert_present() {
  local path
  for path in "$@"; do
    test -e "$path" || { echo "Expected kept: $path" >&2; return 1; }
  done
}

assert_no_workflow() {
  local path="$1"
  if grep -F -e '## Required engineering workflow' -e 'solid-tdd-craft' "$path" >/dev/null; then
    echo "Workflow guidance still present in $path" >&2; return 1
  fi
}

cd "$TEMP_HOME"

# Argument and configuration validation matches the installer and never writes.
if bash "$UNINSTALLER" --unknown >/dev/null 2>&1; then echo "Expected an unknown option to be rejected." >&2; exit 1; fi
if bash "$UNINSTALLER" --global ignored-target >/dev/null 2>&1; then echo "Expected extra global arguments to be rejected." >&2; exit 1; fi
if bash "$UNINSTALLER" --project "$TEMP_HOME/p" extra >/dev/null 2>&1; then echo "Expected extra project arguments to be rejected." >&2; exit 1; fi
if KIRO_HOME=relative-kiro-home bash "$UNINSTALLER" --global >/dev/null 2>&1; then echo "Expected a relative KIRO_HOME to be rejected." >&2; exit 1; fi
bash "$UNINSTALLER" --help | grep -F 'skill-uninstall.sh' >/dev/null

# Uninstalling when nothing is installed succeeds and creates nothing.
bash "$UNINSTALLER" --global >/dev/null
assert_absent "$HOME/.claude/skills" "$HOME/.copilot" "$KIRO_HOME" "$HERMES_HOME" "$XDG_CONFIG_HOME"

# Global scope.
printf 'Existing guidance\r\n%s\r\n' "$instruction" > "$HOME/.claude/CLAUDE.md"
bash "$INSTALLER" --global >/dev/null
mkdir -p "$HOME/.claude/skills/my-own-skill" "$HERMES_HOME/skills/my-own-skill"
echo 'mine' > "$HOME/.claude/skills/my-own-skill/SKILL.md"
echo 'mine' > "$HERMES_HOME/skills/my-own-skill/SKILL.md"
echo 'customized' >> "$XDG_CONFIG_HOME/opencode/commands/review.md"

bash "$UNINSTALLER" --global >/dev/null
for root in "$HOME/.claude/skills" "$HOME/.copilot/skills" "$KIRO_HOME/skills" "$HERMES_HOME/skills" "$XDG_CONFIG_HOME/opencode/skills"; do
  assert_no_skills "$root"
done
assert_present "$HOME/.claude/skills/my-own-skill/SKILL.md" "$HERMES_HOME/skills/my-own-skill/SKILL.md"
assert_absent "$HOME/.copilot/skills" "$KIRO_HOME/skills" "$XDG_CONFIG_HOME/opencode/skills"
# Instruction files: user content survives with its line endings; installer-created files are removed.
assert_present "$HOME/.claude/CLAUDE.md"
assert_no_workflow "$HOME/.claude/CLAUDE.md"
tr -d '\r' < "$HOME/.claude/CLAUDE.md" | grep -Fx 'Existing guidance' >/dev/null
test "$(tr -cd '\r' < "$HOME/.claude/CLAUDE.md" | wc -c)" -ge 1
assert_absent "$HOME/.copilot/copilot-instructions.md" "$KIRO_HOME/steering/solid-tdd-craft.md" "$XDG_CONFIG_HOME/opencode/AGENTS.md"
# Review commands: pristine copies are removed, customized copies are kept.
assert_absent "$HOME/.claude/commands/review.md" "$KIRO_HOME/steering/kiro-review.md"
assert_present "$XDG_CONFIG_HOME/opencode/commands/review.md"
grep -F 'customized' "$XDG_CONFIG_HOME/opencode/commands/review.md" >/dev/null

# Repeat uninstall is harmless.
bash "$UNINSTALLER" --global >/dev/null
assert_present "$HOME/.claude/CLAUDE.md" "$HOME/.claude/skills/my-own-skill/SKILL.md"

# Project scope, including a pre-existing empty AGENTS.md and unrelated files.
PROJECT="$TEMP_HOME/project [fixture] with spaces"
mkdir -p "$PROJECT/.github"
: > "$PROJECT/AGENTS.md"
printf 'Team rules\n' > "$PROJECT/.github/copilot-instructions.md"
echo 'keep me' > "$PROJECT/notes.txt"
bash "$INSTALLER" --project "$PROJECT" >/dev/null

bash "$UNINSTALLER" --project "$PROJECT" >/dev/null
for root in .claude/skills .github/skills .kiro/skills .hermes/skills .opencode/skills; do
  assert_no_skills "$PROJECT/$root"
  assert_absent "$PROJECT/$root"
done
assert_present "$PROJECT/AGENTS.md" "$PROJECT/notes.txt" "$PROJECT/.github/copilot-instructions.md"
test ! -s "$PROJECT/AGENTS.md"
test "$(cat "$PROJECT/.github/copilot-instructions.md")" = 'Team rules'
assert_absent "$PROJECT/CLAUDE.md" "$PROJECT/.kiro/steering/craft.md" \
  "$PROJECT/.claude/commands/review.md" "$PROJECT/.github/prompts/review.prompt.md" \
  "$PROJECT/.opencode/commands/review.md" "$PROJECT/.kiro/steering/kiro-review.md"

# Positional project path and current-directory default.
bash "$INSTALLER" "$PROJECT" >/dev/null
bash "$UNINSTALLER" "$PROJECT" >/dev/null
assert_absent "$PROJECT/CLAUDE.md"
bash "$INSTALLER" "$PROJECT" >/dev/null
(cd "$PROJECT"; bash "$UNINSTALLER" >/dev/null)
assert_absent "$PROJECT/CLAUDE.md" "$PROJECT/.claude/skills"

# Harness selection: only the named harnesses are removed; no selection removes all.
SEL="$TEMP_HOME/selected project"
mkdir -p "$SEL"
bash "$INSTALLER" "$SEL" >/dev/null
bash "$UNINSTALLER" "$SEL" --harness kiro >/dev/null
assert_no_skills "$SEL/.kiro/skills"
assert_absent "$SEL/.kiro/skills" "$SEL/.kiro/steering/craft.md" "$SEL/.kiro/steering/kiro-review.md"
assert_present "$SEL/.claude/skills/solid-tdd-craft/SKILL.md" "$SEL/CLAUDE.md" "$SEL/.github/copilot-instructions.md" \
  "$SEL/.hermes/skills/solid-tdd-craft/SKILL.md" "$SEL/AGENTS.md" "$SEL/.opencode/commands/review.md"
bash "$UNINSTALLER" --harness=claude,hermes --project "$SEL" >/dev/null
assert_absent "$SEL/.claude/skills" "$SEL/CLAUDE.md" "$SEL/.hermes/skills"
assert_present "$SEL/.github/skills/solid-tdd-craft/SKILL.md" "$SEL/AGENTS.md"
bash "$UNINSTALLER" --harness copilot --harness opencode "$SEL" >/dev/null
assert_absent "$SEL/.github/skills" "$SEL/.github/copilot-instructions.md" "$SEL/AGENTS.md" "$SEL/.opencode/skills"

bash "$INSTALLER" --global >/dev/null
bash "$UNINSTALLER" --global --harness opencode >/dev/null
assert_absent "$XDG_CONFIG_HOME/opencode/skills" "$XDG_CONFIG_HOME/opencode/AGENTS.md"
assert_present "$HOME/.copilot/skills/solid-tdd-craft/SKILL.md" "$KIRO_HOME/skills/solid-tdd-craft/SKILL.md" "$HERMES_HOME/skills/solid-tdd-craft/SKILL.md"
bash "$UNINSTALLER" --global >/dev/null
assert_absent "$HOME/.copilot/skills" "$KIRO_HOME/skills"

if bash "$UNINSTALLER" --project "$SEL" --harness bogus >/dev/null 2>&1; then
  echo "Expected an unknown harness to be rejected." >&2; exit 1
fi
if bash "$UNINSTALLER" --project "$SEL" --harness >/dev/null 2>&1; then
  echo "Expected a missing harness name to be rejected." >&2; exit 1
fi
echo "Uninstaller tests passed."
