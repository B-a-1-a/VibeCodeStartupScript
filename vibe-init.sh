#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: vibe-init.sh [options] [path]

Bootstraps a project with:
  - git init (if needed)
  - Context7 MCP config for Codex, Cursor, and Claude Code
  - find-skills skill via skills.sh

Options:
  --no-git        Skip git init
  --no-skills     Skip skills installation
  --force         Overwrite existing config files
  -h, --help      Show this help
USAGE
}

force=0
do_git=1
do_skills=1
target="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-git) do_git=0; shift ;;
    --no-skills) do_skills=0; shift ;;
    --force) force=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) target="$1"; shift ;;
  esac
done

if [[ ! -d "$target" ]]; then
  echo "Error: target directory not found: $target" >&2
  exit 1
fi

cd "$target"

if [[ "$do_git" -eq 1 ]]; then
  if [[ -d ".git" ]]; then
    echo "git already initialized — skipping."
  else
    git init
  fi
fi

mkdir -p .codex .cursor

write_file() {
  local path="$1"
  local content="$2"

  if [[ -e "$path" && "$force" -ne 1 ]]; then
    echo "Exists: $path (use --force to overwrite)"
    return 0
  fi

  printf '%s' "$content" > "$path"
  echo "Wrote: $path"
}

write_file ".codex/config.toml" \
"[mcp_servers.context7]
command = \"npx\"
args = [\"-y\", \"@upstash/context7-mcp\"]
"

write_file ".cursor/mcp.json" \
"{
  \"mcpServers\": {
    \"context7\": {
      \"type\": \"stdio\",
      \"command\": \"npx\",
      \"args\": [\"-y\", \"@upstash/context7-mcp\"]
    }
  }
}
"

write_file ".mcp.json" \
"{
  \"mcpServers\": {
    \"context7\": {
      \"command\": \"npx\",
      \"args\": [\"-y\", \"@upstash/context7-mcp\"]
    }
  }
}
"

if [[ "$do_skills" -eq 1 ]]; then
  if command -v npx >/dev/null 2>&1; then
    npx -y skills add https://github.com/vercel-labs/skills \
      --skill find-skills \
      -a claude-code -a codex -a cursor \
      -y
  else
    echo "npx not found — skipping skills installation."
  fi
fi

echo "Done."
