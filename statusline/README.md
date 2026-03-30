# Claude Code Statusline

A 2-line status bar for [Claude Code](https://claude.ai/code) that shows context usage, cost, session time, git info, system stats, and rate limit usage.

## Preview

```
[Opus] my-repo | main +2 ~1 | RAM:8.2G/16G(51%) CPU:12%
[====------] 42%  $0.05  8m5s  |  5h:23% 7d:41%
```

### Line 1

| Segment | Description |
|---------|-------------|
| `[Opus]` | Current model name |
| `my-repo` | Repo name (clickable link to GitHub via OSC 8) |
| `main` | Git branch (blue) |
| `+2` | Staged files count (green) |
| `~1` | Modified files count (yellow) |
| `RAM:8.2G/16G(51%)` | Memory usage |
| `CPU:12%` | CPU load |

### Line 2

| Segment | Description |
|---------|-------------|
| `[====------] 42%` | Context window usage bar (green <60%, yellow <80%, red >=80%) |
| `$0.05` | Session cost (from API) |
| `8m5s` | Session elapsed time |
| `5h:23%` | 5-hour session rate limit usage (green <60%, yellow <80%, red >=80%) |
| `7d:41%` | 7-day weekly rate limit usage — all models (green <60%, yellow <80%, red >=80%) |

> Rate limit indicators only appear when the API provides usage data (after the first response in a session).

## Install

### One-liner

```bash
git clone https://github.com/alanceloth/claude-code-plugins.git /tmp/cc-plugins && bash /tmp/cc-plugins/statusline/install.sh
```

### Manual

```bash
# 1. Install jq (required)
# macOS: brew install jq
# Ubuntu: sudo apt install jq
# Windows: scoop install jq

# 2. Copy script
cp statusline-command.sh ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh

# 3. Add to ~/.claude/settings.json
# {
#   "statusLine": {
#     "type": "command",
#     "command": "bash ~/.claude/statusline-command.sh"
#   }
# }
```

## Requirements

- [Claude Code](https://claude.ai/code) CLI
- [jq](https://jqlang.github.io/jq/) (JSON parser)
- Bash (Git Bash on Windows)

## Platform Support

| Platform | RAM/CPU | Git | Repo Link |
|----------|---------|-----|-----------|
| Windows (Git Bash) | wmic | git | OSC 8 |
| macOS | vm_stat + sysctl | git | OSC 8 |
| Linux | /proc/meminfo | git | OSC 8 |

## Customization

Edit `~/.claude/statusline-command.sh` to change colors, segments, or layout. Key variables:

- `BAR_WIDTH=10` — progress bar character width
- `CACHE_MAX_AGE=5` — git cache refresh interval (seconds)
- Color thresholds: green <60%, yellow <80%, red >=80%

## Uninstall

Remove `statusLine` from `~/.claude/settings.json` and delete `~/.claude/statusline-command.sh`.

## License

MIT
