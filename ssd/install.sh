#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/agents"
CMD_SRC_DIR="$SCRIPT_DIR/commands"
WORKFLOW_SRC_DIR="$SCRIPT_DIR/workflows"

OPENCODE_DIR="${OPENCODE_AGENTS_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode/agents}"
OPENCODE_CMD_DIR="${OPENCODE_COMMANDS_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode/command}"
OPENCODE_SSD_WORKFLOW_DIR="${OPENCODE_SSD_WORKFLOW_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode/ssd/workflows}"

mkdir -p "$OPENCODE_DIR" "$OPENCODE_CMD_DIR" "$OPENCODE_SSD_WORKFLOW_DIR"

count=0
removed=0
cmd_count=0
cmd_removed=0
workflow_count=0
workflow_removed=0
shopt -s nullglob

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
  local file
  local base

  for file in "$WORKFLOW_SRC_DIR"/*.md; do
    base="$(basename "$file")"
    cp "$file" "$target_dir/$base"
    workflow_count=$((workflow_count + 1))
  done
}

remove_existing "$SRC_DIR" "$OPENCODE_DIR" removed
remove_existing "$CMD_SRC_DIR" "$OPENCODE_CMD_DIR" cmd_removed
remove_existing "$WORKFLOW_SRC_DIR" "$OPENCODE_SSD_WORKFLOW_DIR" workflow_removed

install_copies "$SRC_DIR" "$OPENCODE_DIR" count
install_copies "$CMD_SRC_DIR" "$OPENCODE_CMD_DIR" cmd_count
install_workflows "$OPENCODE_SSD_WORKFLOW_DIR"

echo "Installed $count agent(s) to: $OPENCODE_DIR (removed $removed existing file(s))"
echo "Installed $cmd_count command(s) to: $OPENCODE_CMD_DIR (removed $cmd_removed existing file(s))"
echo "Installed $workflow_count workflow file(s) to: $OPENCODE_SSD_WORKFLOW_DIR (removed $workflow_removed existing file(s))"
