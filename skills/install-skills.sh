#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$SCRIPT_DIR/skills-manifest.tsv"

if [[ ! -f "$MANIFEST" ]]; then
  echo "Manifest not found: $MANIFEST" >&2
  exit 1
fi

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

tmp_raw="$(mktemp)"
tmp_skills="$(mktemp)"
trap 'rm -f "$tmp_raw" "$tmp_skills"' EXIT

npx skills ls -g >"$tmp_raw"

python - "$tmp_raw" >"$tmp_skills" <<'PY'
import re
import sys

path = sys.argv[1]
text = open(path, "r", encoding="utf-8", errors="ignore").read()
ansi = re.compile(r"\x1b\[[0-9;]*m")

skills = []
for raw in text.splitlines():
    line = ansi.sub("", raw).strip()
    if not line or line.startswith("Global Skills"):
        continue
    if line.startswith("Agents:"):
        continue
    skill = line.split()[0] if line.split() else ""
    if skill and skill not in skills:
        skills.append(skill)

print("\n".join(skills))
PY

declare -A installed
while IFS= read -r skill; do
  [[ -n "$skill" ]] && installed["$skill"]=1
done <"$tmp_skills"

declare -A seen
declare -a repos
declare -a skills
need_update=0

while IFS=$'\t' read -r repo skill; do
  repo="$(trim "${repo:-}")"
  skill="$(trim "${skill:-}")"

  if [[ -z "$repo" || "$repo" == \#* ]]; then
    continue
  fi

  if [[ -z "$skill" ]]; then
    echo "Invalid manifest row (missing skill) for repo: $repo" >&2
    exit 1
  fi

  key="$repo|$skill"
  if [[ -n "${seen[$key]:-}" ]]; then
    continue
  fi
  seen["$key"]=1

  repos+=("$repo")
  skills+=("$skill")

  if [[ -n "${installed[$skill]:-}" ]]; then
    need_update=1
  fi
done <"$MANIFEST"

if [[ ${#repos[@]} -eq 0 ]]; then
  echo "No skills found in manifest: $MANIFEST" >&2
  exit 1
fi

if [[ "$need_update" -eq 1 ]]; then
  npx skills update
fi

for i in "${!repos[@]}"; do
  npx skills add "${repos[$i]}" --skill "${skills[$i]}" -g -a opencode -a claude-code -y
done
