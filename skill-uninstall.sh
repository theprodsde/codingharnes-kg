#!/usr/bin/env bash
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
SCOPE="project"
TARGET="."

HARNESS_NAMES="claude copilot kiro opencode hermes"
HARNESSES=()
POSITIONAL=()

usage() {
  echo "Usage: bash skill-uninstall.sh [--project] [TARGET] [--harness NAME[,NAME]...] | --global [--harness NAME[,NAME]...] | --help"
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
  HOME_PATH="${HOME:?HOME must be set for global uninstallation}"
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

TMP_FILES=()
cleanup() { [[ "${#TMP_FILES[@]}" -eq 0 ]] || rm -f -- "${TMP_FILES[@]}"; }
KNOWN_LINES="$(mktemp)"; TMP_FILES+=("$KNOWN_LINES")
tr -d '\r' < "$WORKFLOW" | grep -v '^[[:space:]]*$' > "$KNOWN_LINES" || true
trap cleanup EXIT

# Removes only the skill folders this repository ships, then the skills folder if it is empty.
remove_skills() {
  local skills_root="$1" dir name
  for dir in "$SRC"/skills/*/; do
    name="$(basename "$dir")"
    if [[ -e "$skills_root/$name" || -L "$skills_root/$name" ]]; then
      rm -rf -- "${skills_root:?}/$name"
    fi
  done
  rmdir "$skills_root" 2>/dev/null || true
  echo "Skills <- $skills_root"
}

# Reverses add_line: drops each workflow line (and the blank line the installer put before it).
# Deletes the file when only the installer's header remains; otherwise keeps the rest untouched.
remove_lines() {
  local path="$1" header="$2" tmp remaining expected
  if [[ ! -f "$path" ]]; then
    echo "Always-on (not found) -> $path"; return 0
  fi
  tmp="$(mktemp)"; TMP_FILES+=("$tmp")
  local line bare held="" has_held=0 changed=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    bare="${line%$'\r'}"
    if [[ -z "$bare" ]]; then
      if [[ "$has_held" -eq 1 ]]; then printf '%s\n' "$held" >> "$tmp"; fi
      held="$line"; has_held=1
    elif grep -Fxq -- "$bare" "$KNOWN_LINES"; then
      has_held=0; changed=1
    else
      if [[ "$has_held" -eq 1 ]]; then printf '%s\n' "$held" >> "$tmp"; has_held=0; fi
      printf '%s\n' "$line" >> "$tmp"
    fi
  done < "$path"
  if [[ "$has_held" -eq 1 ]]; then printf '%s\n' "$held" >> "$tmp"; fi
  if [[ "$changed" -eq 0 ]]; then
    echo "Always-on (unchanged) -> $path"; return 0
  fi
  remaining="$(tr -d '\r' < "$tmp" | grep -v '^[[:space:]]*$' || true)"
  expected="$(printf '%b\n' "$header" | grep -v '^[[:space:]]*$' || true)"
  if [[ "$remaining" == "$expected" ]]; then
    rm -f -- "$path"
    echo "Always-on removed -> $path"
  else
    cat "$tmp" > "$path"
    echo "Always-on cleaned -> $path"
  fi
}

# Removes a review command only when it still matches the shipped copy.
remove_command() {
  local source_name="$1" destination="$2"
  if [[ ! -f "$destination" ]]; then
    echo "Command (not found) -> $destination"
  elif cmp -s "$SRC/commands/$source_name" "$destination"; then
    rm -f -- "$destination"
    echo "Command removed -> $destination"
  else
    echo "Command kept (modified) -> $destination"
  fi
}

if [[ "$SCOPE" == "global" ]]; then
  if has_harness claude; then
    remove_skills "$HOME_PATH/.claude/skills"
    remove_lines "$HOME_PATH/.claude/CLAUDE.md" "# User Instructions"
    remove_command "claude-review.md" "$HOME_PATH/.claude/commands/review.md"
  fi
  if has_harness copilot; then
    remove_skills "$HOME_PATH/.copilot/skills"
    remove_lines "$HOME_PATH/.copilot/copilot-instructions.md" "# Copilot User Instructions"
  fi
  if has_harness kiro; then
    remove_skills "$KIRO_HOME/skills"
    remove_lines "$KIRO_HOME/steering/solid-tdd-craft.md" $'---\ninclusion: always\n---\n# Engineering Craft'
    remove_command "kiro-review.md" "$KIRO_HOME/steering/kiro-review.md"
  fi
  if has_harness hermes; then
    remove_skills "$HERMES_HOME/skills"
  fi
  if has_harness opencode; then
    remove_skills "$XDG_CONFIG_HOME/opencode/skills"
    remove_lines "$XDG_CONFIG_HOME/opencode/AGENTS.md" "# Global Agent Instructions"
    remove_command "opencode-review.md" "$XDG_CONFIG_HOME/opencode/commands/review.md"
  fi
else
  if has_harness claude; then
    remove_skills "$TARGET/.claude/skills"
    remove_lines "$TARGET/CLAUDE.md" "# Project Instructions"
    remove_command "claude-review.md" "$TARGET/.claude/commands/review.md"
  fi
  if has_harness copilot; then
    remove_skills "$TARGET/.github/skills"
    remove_lines "$TARGET/.github/copilot-instructions.md" "# Copilot Instructions"
    remove_command "copilot-review.prompt.md" "$TARGET/.github/prompts/review.prompt.md"
  fi
  if has_harness kiro; then
    remove_skills "$TARGET/.kiro/skills"
    remove_lines "$TARGET/.kiro/steering/craft.md" $'---\ninclusion: always\n---\n# Engineering Craft'
    remove_command "kiro-review.md" "$TARGET/.kiro/steering/kiro-review.md"
  fi
  if has_harness hermes; then
    remove_skills "$TARGET/.hermes/skills"
  fi
  if has_harness opencode; then
    remove_skills "$TARGET/.opencode/skills"
    remove_lines "$TARGET/AGENTS.md" "# Agent Instructions"
    remove_command "opencode-review.md" "$TARGET/.opencode/commands/review.md"
  fi
fi