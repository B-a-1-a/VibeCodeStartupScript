# Vibe Init Script

`vibe-init.sh` bootstraps a new project with:
- `git init` (if needed)
- Context7 MCP setup for Codex, Cursor, and Claude Code
- The `find-skills` skill from skills.sh

## Usage

```bash
./vibe-init.sh
```

You can target a specific directory:

```bash
./vibe-init.sh /path/to/project
```

## Options

```bash
./vibe-init.sh --no-git --no-skills --force
```

## Files It Creates

- `.codex/config.toml` (Codex MCP config)
- `.cursor/mcp.json` (Cursor MCP config)
- `.mcp.json` (Claude Code MCP config)

If any of these files already exist, the script will not overwrite them unless you pass `--force`.
