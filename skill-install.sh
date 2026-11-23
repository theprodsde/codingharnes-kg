#!/usr/bin/env bash
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
SCOPE="project"
TARGET="."

HARNESS_NAMES="claude copilot kiro opencode hermes"
HARNESSES=()
POSITIONAL=()

usage() {
  echo "Usage: bash skill-install.sh [--project] [TARGET] [--harness NAME[,NAME]...] | --global [--harness NAME[,NAME]...] | --help"
  echo "Harnesses: ${HARNESS_NAMES// /, } (default: all)"
}

fail_usage() { usage >&2; echo "$1" >&2; exit 1; }

add_harnesses() {
  local list="$1" name
  [[ -n "$list" ]] || fail_usage "--harness requires a name."
  local IFS=','
  for name in $list; do
    name="$(printf '%s' "$name" | tr 'A-Z' 'a-z')"
    case " $HARNESS_NAMES " in
      *" $name "*) HARNESSES+=("$name") ;;
      *) fail_usage "Unknown harness: $name" ;;
    esac
  done
}

has_harness() {
  [[ "${#HARNESSES[@]}" -eq 0 ]] && return 0
  local name
  for name in "${HARNESSES[@]}"; do [[ "$name" == "$1" ]] && return 0; done
  return 1
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --global) SCOPE="global"; shift ;;
    --project) SCOPE="project"; shift ;;
    --harness)
      [[ "$#" -ge 2 ]] || fail_usage "--harness requires a name."
      add_harnesses "$2"; shift 2 ;;
    --harness=*) add_harnesses "${1#--harness=}"; shift ;;
    --help|-h) usage; exit 0 ;;
    --) shift; POSITIONAL+=("$@"); break ;;
    -*) fail_usage "Unknown option: $1" ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

if [[ "$SCOPE" == "project" ]]; then
  if [[ "${#POSITIONAL[@]}" -gt 1 || ( "${#POSITIONAL[@]}" -eq 1 && ( -z "${POSITIONAL[0]}" || "${POSITIONAL[0]}" == -* ) ) ]]; then
    fail_usage "Expected one nonempty project path; prefix dash-leading paths with ./"
  fi
  TARGET="${POSITIONAL[0]:-.}"
else
  if [[ "${#POSITIONAL[@]}" -ne 0 ]]; then
    fail_usage "--global does not accept a project target."
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
  if has_harness claude; then
    install_skills "$HOME_PATH/.claude/skills"
    add_line "$HOME_PATH/.claude/CLAUDE.md" "# User Instructions"
    copy_command "claude-review.md" "$HOME_PATH/.claude/commands/review.md"
  fi
  if has_harness copilot; then
    install_skills "$HOME_PATH/.copilot/skills"
    add_line "$HOME_PATH/.copilot/copilot-instructions.md" "# Copilot User Instructions"
  fi
  if has_harness kiro; then
    install_skills "$KIRO_HOME/skills"
    add_line "$KIRO_HOME/steering/solid-tdd-craft.md" $'---\ninclusion: always\n---\n# Engineering Craft'
    copy_command "kiro-review.md" "$KIRO_HOME/steering/kiro-review.md"
  fi
  if has_harness hermes; then
    install_skills "$HERMES_HOME/skills"
  fi
  if has_harness opencode; then
    install_skills "$XDG_CONFIG_HOME/opencode/skills"
    add_line "$XDG_CONFIG_HOME/opencode/AGENTS.md" "# Global Agent Instructions"
    copy_command "opencode-review.md" "$XDG_CONFIG_HOME/opencode/commands/review.md"
  fi
else
  if has_harness claude; then
    install_skills "$TARGET/.claude/skills"
    add_line "$TARGET/CLAUDE.md" "# Project Instructions"
    copy_command "claude-review.md" "$TARGET/.claude/commands/review.md"
  fi
  if has_harness copilot; then
    install_skills "$TARGET/.github/skills"
    add_line "$TARGET/.github/copilot-instructions.md" "# Copilot Instructions"
    copy_command "copilot-review.prompt.md" "$TARGET/.github/prompts/review.prompt.md"
  fi
  if has_harness kiro; then
    install_skills "$TARGET/.kiro/skills"
    add_line "$TARGET/.kiro/steering/craft.md" $'---\ninclusion: always\n---\n# Engineering Craft'
    copy_command "kiro-review.md" "$TARGET/.kiro/steering/kiro-review.md"
  fi
  if has_harness hermes; then
    install_skills "$TARGET/.hermes/skills"
  fi
  if has_harness opencode; then
    install_skills "$TARGET/.opencode/skills"
    add_line "$TARGET/AGENTS.md" "# Agent Instructions"
    copy_command "opencode-review.md" "$TARGET/.opencode/commands/review.md"
  fi
fi