---
name: pr-review-orchestration
description: >
  Auto-trigger comprehensive PR review orchestration. Activates when the user mentions
  reviewing a pull request, PR review, code review for a PR, reviewing changes before merge,
  or asks to check/analyze/audit a PR. Dispatches all available review specialist agents
  in parallel and aggregates findings into a single consolidated PR comment.
triggers:
  - "review my PR"
  - "review this PR"
  - "review pull request"
  - "PR review"
  - "code review PR"
  - "check my PR"
  - "analyze this PR"
  - "audit PR"
  - "review before merge"
  - "review changes"
  - "comprehensive review"
  - "full PR review"
  - "revisar PR"
  - "revisar pull request"
  - "revisão de PR"
  - "revisão de código"
---

# PR Review Orchestration — Auto-Trigger Skill

This skill activates when PR review context is detected. It delegates all work to the `/pr-review-orchestrator:pr-review` command.

## When This Activates

This skill triggers when the user:
- Asks to review a PR (any variation: "review my PR", "check PR #42", "audit this pull request")
- Mentions wanting a comprehensive or full code review of a pull request
- Asks to review changes before merging
- Uses Portuguese equivalents ("revisar PR", "revisão de código")

## What To Do

1. **Detect PR number:** Look for a PR number in the user's message. If not found, it will be auto-detected from the current branch.

2. **Detect language preference:** If the user is writing in Portuguese, pass `--lang pt`.

3. **Invoke the command:**

   Use the Skill tool to invoke `pr-review-orchestrator:pr-review` with the appropriate arguments:
   - If PR number found: `pr-review-orchestrator:pr-review {PR_NUMBER}`
   - If Portuguese detected: add `--lang pt`
   - If user says "just show me" or "don't post": add `--no-post`
   - If user wants a preview: add `--dry-run`

4. **The command handles everything else:** Agent discovery, parallel dispatch, aggregation, and posting.

## Examples

| User says | Invoke as |
|-----------|-----------|
| "Review my PR" | `pr-review-orchestrator:pr-review` |
| "Review PR #42" | `pr-review-orchestrator:pr-review 42` |
| "Revisar o PR 15" | `pr-review-orchestrator:pr-review 15 --lang pt` |
| "Show me what agents would review PR 7" | `pr-review-orchestrator:pr-review 7 --dry-run` |
| "Do a full review of my changes but don't post" | `pr-review-orchestrator:pr-review --no-post` |
