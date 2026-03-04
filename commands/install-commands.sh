#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${OPENCODE_COMMANDS_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode/commands}"

mkdir -p "$TARGET_DIR"

count=0
removed=0
shopt -s nullglob

is_desired_command() {
  local base="$1"
  local src
  for src in "$SCRIPT_DIR"/*.md; do
    if [[ "$(basename "$src")" == "$base" ]]; then
      return 0
    fi
  done
  return 1
}

for link in "$TARGET_DIR"/*.md; do
  if [[ -L "$link" ]]; then
    base="$(basename "$link")"
    if [[ ! -e "$link" ]] || ! is_desired_command "$base"; then
      rm "$link"
      removed=$((removed + 1))
    fi
  fi
done

for file in "$SCRIPT_DIR"/*.md; do
  base="$(basename "$file")"
  ln -sf "$file" "$TARGET_DIR/$base"
  count=$((count + 1))
done

echo "Installed $count command(s) to: $TARGET_DIR (removed $removed stale symlink(s))"
