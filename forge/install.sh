#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/agents"
CMD_SRC_DIR="$SCRIPT_DIR/commands"
WORKFLOW_SRC_DIR="$SCRIPT_DIR/workflows"
SKILLS_SRC_DIR="$SCRIPT_DIR/skills"
CLAUDE_EXAMPLE_FILE="$SCRIPT_DIR/examples/claude-code/CLAUDE.md"

OPENCODE_DIR="${OPENCODE_AGENTS_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode/agents}"
OPENCODE_CMD_DIR="${OPENCODE_COMMANDS_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode/command}"
OPENCODE_FORGE_WORKFLOW_DIR="${OPENCODE_FORGE_WORKFLOW_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode/forge/workflows}"
OPENCODE_SKILLS_DIR="${OPENCODE_SKILLS_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode/skills}"

CLAUDE_SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
CLAUDE_PROMPT_FILE="${CLAUDE_PROMPT_FILE:-$HOME/.claude/CLAUDE.md}"

MARKER_BEGIN="<!-- BEGIN:forge-agent-team -->"
MARKER_END="<!-- END:forge-agent-team -->"

TARGET="all"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: ./install.sh [--target opencode|claude|all]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: ./install.sh [--target opencode|claude|all]"
      exit 1
      ;;
  esac
done

shopt -s nullglob

cleanup_retired_files() {
  local dir="$1"
  shift
  local base
  for base in "$@"; do
    if [[ -e "$dir/$base" || -L "$dir/$base" ]]; then
      rm -f "$dir/$base"
    fi
  done
}

remove_existing() {
  local source_dir="$1"
  local target_dir="$2"
  local removed_counter_name="$3"
  local file
  local base

  for file in "$source_dir"/*.md; do
    base="$(basename "$file")"
    if [[ -e "$target_dir/$base" || -L "$target_dir/$base" ]]; then
      rm -f "$target_dir/$base"
      printf -v "$removed_counter_name" '%d' "$(( ${!removed_counter_name} + 1 ))"
    fi
  done
}

install_copies() {
  local source_dir="$1"
  local target_dir="$2"
  local count_name="$3"
  local file
  local base

  for file in "$source_dir"/*.md; do
    base="$(basename "$file")"
    cp "$file" "$target_dir/$base"
    printf -v "$count_name" '%d' "$(( ${!count_name} + 1 ))"
  done
}

install_workflows() {
  local target_dir="$1"
  local count_name="$2"
  local file
  local base

  for file in "$WORKFLOW_SRC_DIR"/*.md; do
    base="$(basename "$file")"
    cp "$file" "$target_dir/$base"
    printf -v "$count_name" '%d' "$(( ${!count_name} + 1 ))"
  done
}

install_skills() {
  local source_root="$1"
  local target_root="$2"
  local count_name="$3"
  local skill_dir
  local base

  for skill_dir in "$source_root"/*; do
    [[ -d "$skill_dir" ]] || continue
    base="$(basename "$skill_dir")"
    rm -rf "$target_root/$base"
    mkdir -p "$target_root/$base"
    cp -R "$skill_dir/"* "$target_root/$base/"
    printf -v "$count_name" '%d' "$(( ${!count_name} + 1 ))"
  done
}

install_claude_prompt() {
  local prompt_file="$1"
  local example_file="$2"

  if [[ ! -f "$example_file" ]]; then
    echo "Claude prompt template not found: $example_file"
    return
  fi

  mkdir -p "$(dirname "$prompt_file")"

  local content
  content="$(cat "$example_file")"

  if [[ -f "$prompt_file" ]]; then
    if grep -qF "$MARKER_BEGIN" "$prompt_file"; then
      local tmp
      tmp="$(mktemp)"
      awk -v begin="$MARKER_BEGIN" -v end="$MARKER_END" -v content="$content" '
        $0 == begin { print; print content; skip=1; next }
        $0 == end   { print; skip=0; next }
        !skip       { print }
      ' "$prompt_file" > "$tmp"
      mv "$tmp" "$prompt_file"
    else
      {
        echo ""
        echo "$MARKER_BEGIN"
        echo "$content"
        echo "$MARKER_END"
      } >> "$prompt_file"
    fi
  else
    {
      echo "$MARKER_BEGIN"
      echo "$content"
      echo "$MARKER_END"
    } > "$prompt_file"
  fi
}

install_opencode() {
  mkdir -p "$OPENCODE_DIR" "$OPENCODE_CMD_DIR" "$OPENCODE_FORGE_WORKFLOW_DIR" "$OPENCODE_SKILLS_DIR"

  local count=0
  local removed=0
  local cmd_count=0
  local cmd_removed=0
  local workflow_count=0
  local workflow_removed=0
  local skills_count=0

  remove_existing "$SRC_DIR" "$OPENCODE_DIR" removed
  remove_existing "$CMD_SRC_DIR" "$OPENCODE_CMD_DIR" cmd_removed
  remove_existing "$WORKFLOW_SRC_DIR" "$OPENCODE_FORGE_WORKFLOW_DIR" workflow_removed

  cleanup_retired_files "$OPENCODE_DIR" "ssd-deepdive.md" "ssd-orchestrator.md" "ssd-explore.md" "ssd-spec.md" "ssd-plan.md" "ssd-build.md"
  cleanup_retired_files "$OPENCODE_CMD_DIR" "ssd-new-feature.md" "ssd-quick-task.md" "ssd-new-project.md" "ssd-new.md" "ssd-continue.md"
  cleanup_retired_files "$OPENCODE_FORGE_WORKFLOW_DIR" "ssd-new-feature.md" "ssd-quick-task.md" "ssd-new-project.md" "ssd-new.md" "ssd-continue.md"

  install_copies "$SRC_DIR" "$OPENCODE_DIR" count
  install_copies "$CMD_SRC_DIR" "$OPENCODE_CMD_DIR" cmd_count
  install_workflows "$OPENCODE_FORGE_WORKFLOW_DIR" workflow_count
  install_skills "$SKILLS_SRC_DIR" "$OPENCODE_SKILLS_DIR" skills_count

  echo "OpenCode: installed $count agent(s) to $OPENCODE_DIR (removed $removed)"
  echo "OpenCode: installed $cmd_count command(s) to $OPENCODE_CMD_DIR (removed $cmd_removed)"
  echo "OpenCode: installed $workflow_count workflow file(s) to $OPENCODE_FORGE_WORKFLOW_DIR (removed $workflow_removed)"
  echo "OpenCode: installed $skills_count skill(s) to $OPENCODE_SKILLS_DIR"
}

install_claude() {
  mkdir -p "$CLAUDE_SKILLS_DIR"

  local skills_count=0
  install_skills "$SKILLS_SRC_DIR" "$CLAUDE_SKILLS_DIR" skills_count
  install_claude_prompt "$CLAUDE_PROMPT_FILE" "$CLAUDE_EXAMPLE_FILE"

  echo "Claude Code: installed $skills_count skill(s) to $CLAUDE_SKILLS_DIR"
  echo "Claude Code: updated orchestrator section in $CLAUDE_PROMPT_FILE"
}

case "$TARGET" in
  opencode)
    install_opencode
    ;;
  claude|claude-code)
    install_claude
    ;;
  all)
    install_opencode
    install_claude
    ;;
  *)
    echo "Invalid target: $TARGET"
    echo "Use --target opencode|claude|all"
    exit 1
    ;;
esac
