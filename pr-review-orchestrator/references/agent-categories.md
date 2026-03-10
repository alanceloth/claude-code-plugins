# Agent Categories & Context-Aware Discovery

This reference defines the review agent registry used by the PR Review Orchestrator to select which agents to dispatch based on the PR's diff, title, body, and changed files.

## Selection Algorithm

1. **Always dispatch:** Code Quality (every PR has code changes)
2. **Analyze diff signals:** Match file patterns, code patterns, and PR metadata against each category
3. **Prefer Ring agents:** They provide deeper, non-overlapping specialized analysis
4. **Scale by PR size:** Small PRs (<50 lines) → max 3-4 agents. Large PRs (>200 lines) → all relevant agents
5. **Dynamic wildcard:** Also scan available Agent `subagent_type` values for any containing keywords: "review", "security", "audit", "test", "architect", "lint" — include even if not listed below

## Agent Categories

### 1. Code Quality — ALWAYS DISPATCH
| Priority | Agent | Plugin |
|----------|-------|--------|
| 1 (preferred) | `ring-default:ring:code-reviewer` | ring-default |
| 2 | `pr-review-toolkit:code-reviewer` | pr-review-toolkit |
| 3 | `comprehensive-review:code-reviewer` | comprehensive-review |
| 4 | `coderabbit:code-reviewer` | coderabbit |

**Dispatch rule:** Always. Pick the highest-priority available agent. For large PRs (>200 lines), dispatch up to 2 agents from this category for broader coverage.

---

### 2. Architecture
| Priority | Agent | Plugin |
|----------|-------|--------|
| 1 (preferred) | `comprehensive-review:architect-review` | comprehensive-review |

**Diff/context signals:**
- New modules, classes, or packages created
- Import restructuring (many import changes across files)
- Service boundary changes (new directories under services/, adapters/, etc.)
- PR title/body contains: "architecture", "refactor", "restructure", "redesign", "migrate", "modularize"
- PR touches 5+ different directories

---

### 3. Security
| Priority | Agent | Plugin |
|----------|-------|--------|
| 1 (preferred) | `ring-default:ring:security-reviewer` | ring-default |
| 2 | `comprehensive-review:security-auditor` | comprehensive-review |

**Diff/context signals:**
- Files matching: `*auth*`, `*security*`, `*crypto*`, `*token*`, `*session*`, `*permission*`
- Environment/config files: `.env*`, `*config*`, `*secret*`
- API route definitions or middleware changes
- Dependency changes (`requirements.txt`, `package.json`, `go.mod`, `Pipfile`, `Gemfile`)
- Code patterns: `password`, `secret`, `api_key`, `bearer`, `jwt`, `oauth`, `hmac`, `hash`
- PR title/body contains: "security", "auth", "permission", "vulnerability", "CVE", "patch"

---

### 4. Error Handling
| Priority | Agent | Plugin |
|----------|-------|--------|
| 1 (preferred) | `pr-review-toolkit:silent-failure-hunter` | pr-review-toolkit |

**Diff/context signals:**
- Code patterns: `try`, `catch`, `except`, `rescue`, `on_error`, `fallback`, `recover`
- Error callback patterns: `.catch(`, `onerror`, `on_failure`
- Exception class definitions
- Logging changes near error paths
- Empty catch/except blocks

---

### 5. Testing
| Priority | Agent | Plugin |
|----------|-------|--------|
| 1 (preferred) | `ring-default:ring:test-reviewer` | ring-default |
| 2 | `pr-review-toolkit:pr-test-analyzer` | pr-review-toolkit |

**Diff/context signals:**
- Test files changed: `*test*`, `*spec*`, `*_test.*`, `test_*`
- Core logic changed WITHOUT corresponding test changes (flag for missing coverage)
- Test configuration files: `pytest.ini`, `jest.config.*`, `vitest.config.*`
- PR title/body contains: "test", "coverage", "TDD", "spec"

---

### 6. Types & Nil Safety
| Priority | Agent | Plugin |
|----------|-------|--------|
| 1 (preferred) | `ring-default:ring:nil-safety-reviewer` | ring-default |
| 2 | `pr-review-toolkit:type-design-analyzer` | pr-review-toolkit |

**Diff/context signals:**
- New type/interface/struct definitions
- Nullable/optional patterns: `Optional`, `| null`, `| undefined`, `*Type`, `?:`
- Pointer operations in Go/Rust/C
- Type assertion/casting patterns
- `.d.ts` or type definition files changed

---

### 7. Documentation & Comments
| Priority | Agent | Plugin |
|----------|-------|--------|
| 1 (preferred) | `pr-review-toolkit:comment-analyzer` | pr-review-toolkit |

**Diff/context signals:**
- Docstrings or JSDoc comments modified
- README or documentation files changed
- New public API functions/methods added without docs
- Comment blocks added or substantially modified
- PR title/body contains: "docs", "documentation", "README", "comments"

---

### 8. Simplification
| Priority | Agent | Plugin |
|----------|-------|--------|
| 1 (preferred) | `pr-review-toolkit:code-simplifier` | pr-review-toolkit |

**Diff/context signals:**
- Functions with >50 lines changed
- High nesting depth (3+ levels of indentation in diff)
- Complex conditional chains (multiple `if/elif/else` or ternary operators)
- Long parameter lists (>5 parameters)
- Duplicated code patterns within the diff

---

### 9. Business Logic
| Priority | Agent | Plugin |
|----------|-------|--------|
| 1 (preferred) | `ring-default:ring:business-logic-reviewer` | ring-default |

**Diff/context signals:**
- Domain service/model files changed
- Business rule implementations (validation, calculations, state machines)
- Pricing, billing, or financial logic
- Workflow/process orchestration changes
- PR title/body contains: "business", "domain", "rule", "validation", "workflow", "process"

---

### 10. Consequences & Ripple Effects
| Priority | Agent | Plugin |
|----------|-------|--------|
| 1 (preferred) | `ring-default:ring:consequences-reviewer` | ring-default |

**Diff/context signals:**
- Shared utility/helper files modified
- Public API or exported function signatures changed
- Interface/contract modifications
- Database schema or migration changes
- Configuration file changes that affect multiple services
- PR modifies files imported by 3+ other files

---

## Dynamic Wildcard Discovery

After evaluating the categories above, also scan all available Agent `subagent_type` values for any that match these keyword patterns but are NOT already in the registry:

- Keywords: `review`, `security`, `audit`, `test`, `architect`, `lint`, `quality`, `safety`

If found, include them with a generic prompt appropriate to their name. This ensures new review agents installed by the user are automatically picked up.

## Size-Based Scaling

| PR Size | Max Agents | Strategy |
|---------|-----------|----------|
| Tiny (<20 lines) | 2 | Code Quality + 1 most relevant |
| Small (<50 lines) | 3-4 | Code Quality + top signal matches |
| Medium (50-200 lines) | 5-7 | All matched categories |
| Large (>200 lines) | All matched | Full coverage, consider 2 agents per critical category |
| Huge (>500 lines) | All matched + warning | Suggest splitting PR, review anyway |
