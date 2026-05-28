# Claude Code Plugins by alanceloth

A collection of plugins for [Claude Code](https://claude.ai/code) — Anthropic's official CLI for Claude.

## Available

### Statusline

**2-line status bar showing context usage, cost, session time, git info, system stats, and rate limit usage.**

```
[Opus] my-repo | main +2 ~1 | RAM:8.2G/16G(51%) CPU:12%
[====------] 42%  $0.05  8m5s  |  5h:23% 7d:41%
```

Quick install:
```bash
git clone https://github.com/alanceloth/claude-code-plugins.git && bash claude-code-plugins/statusline/install.sh
```

See [statusline/README.md](statusline/README.md) for details.

---

## Plugins

### PR Review Orchestrator

**Meta-orchestrator that dynamically discovers all installed review specialist agents, dispatches them in parallel, scores findings for confidence, and aggregates the survivors into a single consolidated PR comment.**

Features:
- **Dynamic agent discovery** — automatically detects all installed review agents (ring-default, pr-review-toolkit, comprehensive-review, coderabbit, etc.)
- **Context-aware selection** — analyzes diff patterns, file types, PR title/body to pick the right agents
- **Parallel dispatch** — launches all selected agents simultaneously for fast reviews
- **Eligibility gate (v1.1)** — skips closed/draft/automated PRs and ones we already reviewed recently
- **CLAUDE.md awareness (v1.1)** — loads repo conventions and injects them into reviewers so they enforce your standards
- **Confidence scoring (v1.1)** — each finding is scored 0-100 by a Haiku pass; cuts noise below `--min-confidence` (default 75)
- **Modified-line filter (v1.1)** — drops findings on lines the PR didn't touch (kills pre-existing-code noise)
- **Comment dedup (v1.1)** — suppresses findings already raised in earlier reviews of the same PR
- **Permalink citations (v1.1)** — every finding links to the exact line at the head SHA, surviving rebase/squash
- **Smart aggregation** — deduplicates findings, sorts by severity, merges overlapping issues
- **Bilingual output** — auto-detects Portuguese or English from PR body
- **Size-aware scaling** — adjusts agent count based on PR size
- **Token-disciplined** — Haiku handles all mechanical phases (eligibility, scoring, dedup, formatting); Sonnet+/Ring agents reserved for semantic review

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

# Stricter review (only findings scoring >=85/100)
/pr-review-orchestrator:pr-review 42 --min-confidence 85

# Looser review (catch more, accept more noise)
/pr-review-orchestrator:pr-review 42 --min-confidence 60

# Re-review a PR you already reviewed
/pr-review-orchestrator:pr-review 42 --skip-eligibility

# Skip CLAUDE.md loading (raw review against generic best practices)
/pr-review-orchestrator:pr-review 42 --skip-claude-md

# Include findings on pre-existing code (lines not touched by the diff)
/pr-review-orchestrator:pr-review 42 --include-preexisting
```

The skill also auto-triggers when you say things like "review my PR" or "revisar o PR".

## License

MIT
