# Claude Code Plugins by alanceloth

A collection of plugins for [Claude Code](https://claude.ai/code) — Anthropic's official CLI for Claude.

## Available

### Statusline

**2-line status bar showing context usage, cost, session time, git info, and system stats.**

```
[Opus] my-repo | main +2 ~1 | RAM:8.2G/16G(51%) CPU:12%
[████░░░░░░] 42%  $0.05  8m5s
```

Quick install:
```bash
git clone https://github.com/alanceloth/claude-code-plugins.git /tmp/cc-plugins && bash /tmp/cc-plugins/statusline/install.sh
```

See [statusline/README.md](statusline/README.md) for details.

---

## Plugins

### PR Review Orchestrator

**Meta-orchestrator that dynamically discovers all installed review specialist agents, dispatches them in parallel, and aggregates findings into a single consolidated PR comment.**

Features:
- **Dynamic agent discovery** — automatically detects all installed review agents (ring-default, pr-review-toolkit, comprehensive-review, coderabbit, etc.)
- **Context-aware selection** — analyzes diff patterns, file types, PR title/body to pick the right agents
- **Parallel dispatch** — launches all selected agents simultaneously for fast reviews
- **Smart aggregation** — deduplicates findings, sorts by severity, merges overlapping issues
- **Bilingual output** — auto-detects Portuguese or English from PR body
- **Size-aware scaling** — adjusts agent count based on PR size

#### Install

```bash
# 1. Add the marketplace
/plugin marketplace add alanceloth/claude-code-plugins

# 2. Install the plugin
/plugin install pr-review-orchestrator@alanceloth-plugins
```

#### Usage

```bash
# Review a specific PR
/pr-review-orchestrator:pr-review 42

# Auto-detect PR from current branch
/pr-review-orchestrator:pr-review

# Preview which agents would be dispatched
/pr-review-orchestrator:pr-review 42 --dry-run

# Force Portuguese output
/pr-review-orchestrator:pr-review 42 --lang pt

# Review without posting to GitHub
/pr-review-orchestrator:pr-review 42 --no-post

# Skip specific agents
/pr-review-orchestrator:pr-review 42 --skip code-simplifier,comment-analyzer
```

The skill also auto-triggers when you say things like "review my PR" or "revisar o PR".

## License

MIT
