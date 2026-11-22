#!/usr/bin/env bash
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
SCOPE="project"
TARGET="."

usage() {
  echo "Usage: bash skill-install.sh [--project] [TARGET] | --global | --help"
}

case "${1:-}" in
  --global) SCOPE="global"; shift ;;
  --project) SCOPE="project"; shift ;;
  --help|-h) usage; exit 0 ;;
  --) shift ;;
  -*) usage >&2; echo "Unknown option: $1" >&2; exit 1 ;;
esac

if [[ "$SCOPE" == "project" ]]; then
  if [[ "$#" -gt 1 || "${1:-}" == -* || ( "$#" -eq 1 && -z "$1" ) ]]; then
    usage >&2; echo "Expected one nonempty project path; prefix dash-leading paths with ./" >&2; exit 1
  fi
  TARGET="${1:-.}"
else
  if [[ "$#" -ne 0 ]]; then
    usage >&2; echo "--global does not accept a project target." >&2; exit 1
  fi
  HOME_PATH="${HOME:?HOME must be set for global installation}"
  KIRO_HOME="${KIRO_HOME:-$HOME_PATH/.kiro}"
  HERMES_HOME="${HERMES_HOME:-$HOME_PATH/.hermes}"
  XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME_PATH/.config}"
  for name in HOME_PATH KIRO_HOME HERMES_HOME XDG_CONFIG_HOME; do
    case "${!name}" in
      /*) ;;
      *) echo "$name must be an absolute POSIX path (use /c/... in Git Bash)." >&2; exit 1 ;;
    esac
  done
fi

WORKFLOW="$SRC/skills/solid-tdd-craft/references/WORKFLOW.md"
if [[ ! -s "$WORKFLOW" ]]; then
  echo "Required engineering workflow is missing or empty: $WORKFLOW" >&2; exit 1
fi

install_skills() {
  local skills_root="$1"
  mkdir -p "$skills_root"
  cp -R "$SRC/skills/." "$skills_root/"
  echo "Skills -> $skills_root"
}

add_line() {
  local path="$1" header="$2" line
  mkdir -p "$(dirname "$path")"
  [[ -f "$path" ]] || printf '%b\n' "$header" > "$path"
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    [[ -n "$line" ]] || continue
    if grep -F -- "$line" "$path" >/dev/null; then
      continue
    else
      local status=$?
      if [[ "$status" -ne 1 ]]; then
        echo "Cannot read instruction file: $path" >&2; return "$status"
      fi
      printf '\n%s\n' "$line" >> "$path"
    fi
  done < "$WORKFLOW"
  echo "Always-on -> $path"
}

copy_command() {
  local source_name="$1" destination="$2"
  mkdir -p "$(dirname "$destination")"
  cp "$SRC/commands/$source_name" "$destination"
  echo "Command -> $destination"
}

if [[ "$SCOPE" == "global" ]]; then
  install_skills "$HOME_PATH/.claude/skills"
  install_skills "$HOME_PATH/.copilot/skills"
  install_skills "$KIRO_HOME/skills"
  install_skills "$HERMES_HOME/skills"
  install_skills "$XDG_CONFIG_HOME/opencode/skills"
  add_line "$HOME_PATH/.claude/CLAUDE.md" "# User Instructions"
  add_line "$HOME_PATH/.copilot/copilot-instructions.md" "# Copilot User Instructions"
  add_line "$KIRO_HOME/steering/solid-tdd-craft.md" $'---\ninclusion: always\n---\n# Engineering Craft'
  add_line "$XDG_CONFIG_HOME/opencode/AGENTS.md" "# Global Agent Instructions"
  copy_command "claude-review.md" "$HOME_PATH/.claude/commands/review.md"
  copy_command "opencode-review.md" "$XDG_CONFIG_HOME/opencode/commands/review.md"
  copy_command "kiro-review.md" "$KIRO_HOME/steering/kiro-review.md"
else
  install_skills "$TARGET/.claude/skills"
  install_skills "$TARGET/.github/skills"
  install_skills "$TARGET/.kiro/skills"
  install_skills "$TARGET/.hermes/skills"
  install_skills "$TARGET/.opencode/skills"
  add_line "$TARGET/CLAUDE.md" "# Project Instructions"
  add_line "$TARGET/.github/copilot-instructions.md" "# Copilot Instructions"
  add_line "$TARGET/.kiro/steering/craft.md" $'---\ninclusion: always\n---\n# Engineering Craft'
  add_line "$TARGET/AGENTS.md" "# Agent Instructions"
  copy_command "claude-review.md" "$TARGET/.claude/commands/review.md"
  copy_command "copilot-review.prompt.md" "$TARGET/.github/prompts/review.prompt.md"
  copy_command "opencode-review.md" "$TARGET/.opencode/commands/review.md"
  copy_command "kiro-review.md" "$TARGET/.kiro/steering/kiro-review.md"
fi
