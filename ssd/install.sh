#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/agents"
CMD_SRC_DIR="$SCRIPT_DIR/commands"

OPENCODE_DIR="${OPENCODE_AGENTS_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode/agents}"
CLAUDE_DIR="${CLAUDE_AGENTS_DIR:-$HOME/.claude/agents}"
OPENCODE_CMD_DIR="${OPENCODE_COMMANDS_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode/command}"
CLAUDE_CMD_DIR="${CLAUDE_COMMANDS_DIR:-$HOME/.claude/commands}"

mkdir -p "$OPENCODE_DIR" "$CLAUDE_DIR" "$OPENCODE_CMD_DIR" "$CLAUDE_CMD_DIR"

count=0
removed=0
cmd_count=0
cmd_removed=0
shopt -s nullglob

PYTHON_BIN="${PYTHON_BIN:-}"

if [[ -z "$PYTHON_BIN" ]]; then
  if command -v python3 >/dev/null 2>&1; then
    PYTHON_BIN="python3"
  elif command -v python >/dev/null 2>&1; then
    PYTHON_BIN="python"
  else
    echo "Python not found. Set PYTHON_BIN or install python3." >&2
    exit 1
  fi
fi

render_agent() {
  local runtime="$1"
  local src_file="$2"
  local dest_file="$3"

  "$PYTHON_BIN" - "$runtime" "$src_file" "$dest_file" <<'PY'
import json
import sys

runtime = sys.argv[1]
src_file = sys.argv[2]
dest_file = sys.argv[3]

with open(src_file, "r", encoding="utf-8") as f:
    lines = f.read().splitlines()

if not lines or lines[0].strip() != "---":
    raise SystemExit(f"Missing frontmatter in {src_file}")

try:
    end_idx = lines.index("---", 1)
except ValueError:
    raise SystemExit(f"Unterminated frontmatter in {src_file}")

front_lines = lines[1:end_idx]
body = "\n".join(lines[end_idx + 1:]).lstrip("\n")

front = {}
for raw in front_lines:
    line = raw.strip()
    if not line or line.startswith("#"):
        continue
    if ":" not in line:
        continue
    key, value = line.split(":", 1)
    key = key.strip()
    value = value.strip()
    front[key] = value

if runtime not in front:
    raise SystemExit(f"Missing {runtime} frontmatter in {src_file}")

try:
    data = json.loads(front[runtime])
except json.JSONDecodeError as exc:
    raise SystemExit(f"Invalid {runtime} JSON in {src_file}: {exc}")

def dump_yaml(data, indent=0):
    lines_out = []
    pad = "  " * indent
    if isinstance(data, dict):
        for key, value in data.items():
            if isinstance(value, dict):
                lines_out.append(f"{pad}{key}:")
                lines_out.extend(dump_yaml(value, indent + 1))
            elif isinstance(value, list):
                lines_out.append(f"{pad}{key}:")
                for item in value:
                    lines_out.append(f"{pad}  - {item}")
            elif isinstance(value, bool):
                lines_out.append(f"{pad}{key}: {'true' if value else 'false'}")
            elif isinstance(value, (int, float)):
                lines_out.append(f"{pad}{key}: {value}")
            else:
                lines_out.append(f"{pad}{key}: {value}")
    return lines_out

if runtime == "claude":
    if "name" not in data or "description" not in data:
        raise SystemExit(f"Claude frontmatter must include name and description: {src_file}")
    if isinstance(data.get("tools"), list):
        data["tools"] = ", ".join(data["tools"])

front_yaml = ["---"]
front_yaml.extend(dump_yaml(data))
front_yaml.append("---")

content = "\n".join(front_yaml) + "\n\n" + body.rstrip() + "\n"

with open(dest_file, "w", encoding="utf-8") as f:
    f.write(content)
PY
}

remove_existing() {
  local target_dir="$1"
  local file
  for file in "$SRC_DIR"/*.md; do
    base="$(basename "$file")"
    if [[ -e "$target_dir/$base" || -L "$target_dir/$base" ]]; then
      rm -f "$target_dir/$base"
      removed=$((removed + 1))
    fi
  done
}

remove_existing_commands() {
  local target_dir="$1"
  local file
  for file in "$CMD_SRC_DIR"/*.md; do
    base="$(basename "$file")"
    if [[ -e "$target_dir/$base" || -L "$target_dir/$base" ]]; then
      rm -f "$target_dir/$base"
      cmd_removed=$((cmd_removed + 1))
    fi
  done
}

install_copy() {
  local runtime="$1"
  local target_dir="$2"
  local file
  for file in "$SRC_DIR"/*.md; do
    base="$(basename "$file")"
    render_agent "$runtime" "$file" "$target_dir/$base"
    count=$((count + 1))
  done
}

install_commands() {
  local runtime="$1"
  local target_dir="$2"
  local file
  for file in "$CMD_SRC_DIR"/*.md; do
    base="$(basename "$file")"
    render_agent "$runtime" "$file" "$target_dir/$base"
    cmd_count=$((cmd_count + 1))
  done
}

remove_existing "$OPENCODE_DIR"
remove_existing "$CLAUDE_DIR"
remove_existing_commands "$OPENCODE_CMD_DIR"

install_copy "opencode" "$OPENCODE_DIR"
install_copy "claude" "$CLAUDE_DIR"
install_commands "opencode" "$OPENCODE_CMD_DIR"

mkdir -p "$CLAUDE_CMD_DIR/ssd"
if [[ -e "$CMD_SRC_DIR/ssd-new-feature.md" ]]; then
  if [[ -e "$CLAUDE_CMD_DIR/ssd/new-feature.md" || -L "$CLAUDE_CMD_DIR/ssd/new-feature.md" ]]; then
    rm -f "$CLAUDE_CMD_DIR/ssd/new-feature.md"
    cmd_removed=$((cmd_removed + 1))
  fi
  render_agent "claude" "$CMD_SRC_DIR/ssd-new-feature.md" "$CLAUDE_CMD_DIR/ssd/new-feature.md"
  cmd_count=$((cmd_count + 1))
fi

echo "Installed $count agent(s) to: $OPENCODE_DIR and $CLAUDE_DIR (removed $removed existing file(s))"
echo "Installed $cmd_count command(s) to: $OPENCODE_CMD_DIR and $CLAUDE_CMD_DIR (removed $cmd_removed existing file(s))"
