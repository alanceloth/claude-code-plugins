#!/usr/bin/env bash
# Claude Code Status Line
# 2-line status bar: model, repo link, git, RAM/CPU + context bar, cost, duration
# https://github.com/alanceloth/claude-code-plugins

input=$(cat)

# ── ANSI colors ──────────────────────────────────────────────────────────────
R='\033[0m'
BOLD='\033[1m'
C_CYAN='\033[36m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_BLUE='\033[34m'
C_MAGENTA='\033[35m'
C_WHITE='\033[97m'
C_GRAY='\033[90m'

# ── Parse JSON fields ────────────────────────────────────────────────────────
MODEL=$(echo "$input" | jq -r '.model.display_name // "?"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // "."')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

# ── Context progress bar ─────────────────────────────────────────────────────
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
[ "$FILLED" -gt "$BAR_WIDTH" ] && FILLED=$BAR_WIDTH
EMPTY=$((BAR_WIDTH - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && printf -v FILL "%${FILLED}s" && BAR="${FILL// /█}"
[ "$EMPTY" -gt 0 ] && printf -v PAD "%${EMPTY}s" && BAR="${BAR}${PAD// /░}"

if   [ "$PCT" -lt 60 ]; then BAR_COLOR=$C_GREEN
elif [ "$PCT" -lt 80 ]; then BAR_COLOR=$C_YELLOW
else                          BAR_COLOR=$C_RED
fi
ctx_segment=$(printf "${BAR_COLOR}${BAR}${R} ${BAR_COLOR}${BOLD}%s%%${R}" "$PCT")

# ── Cost ──────────────────────────────────────────────────────────────────────
if [ "$(echo "$COST" | awk '{print ($1 >= 0.01)}')" = "1" ]; then
    COST_FMT=$(printf '$%.2f' "$COST")
else
    COST_FMT=$(printf '$%.4f' "$COST")
fi
cost_segment=$(printf "${C_MAGENTA}${BOLD}%s${R}" "$COST_FMT")

# ── Session duration ──────────────────────────────────────────────────────────
DURATION_SEC=$((DURATION_MS / 1000))
if [ "$DURATION_SEC" -ge 3600 ]; then
    H=$((DURATION_SEC / 3600))
    M=$(( (DURATION_SEC % 3600) / 60 ))
    elapsed_str="${H}h${M}m"
elif [ "$DURATION_SEC" -ge 60 ]; then
    elapsed_str="$((DURATION_SEC / 60))m$((DURATION_SEC % 60))s"
else
    elapsed_str="${DURATION_SEC}s"
fi
elapsed_segment=$(printf "${C_CYAN}${BOLD}%s${R}" "$elapsed_str")

# ── Git info (cached 5s for performance) ──────────────────────────────────────
CACHE_FILE="/tmp/statusline-git-cache"
CACHE_MAX_AGE=5

cache_is_stale() {
    [ ! -f "$CACHE_FILE" ] || \
    [ $(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0))) -gt $CACHE_MAX_AGE ]
}

if cache_is_stale; then
    if git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
        BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
        STAGED=$(git -C "$DIR" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
        MODIFIED=$(git -C "$DIR" diff --numstat 2>/dev/null | wc -l | tr -d ' ')
        REMOTE_URL=$(git -C "$DIR" config --get remote.origin.url 2>/dev/null)
        REPO_NAME=$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null)
        echo "${BRANCH}|${STAGED}|${MODIFIED}|${REMOTE_URL}|${REPO_NAME}" > "$CACHE_FILE"
    else
        echo "||||" > "$CACHE_FILE"
    fi
fi

IFS='|' read -r BRANCH STAGED MODIFIED REMOTE_URL REPO_NAME < "$CACHE_FILE"

git_segment=""
if [ -n "$BRANCH" ]; then
    branch_part=$(printf "${C_BLUE}${BOLD}%s${R}" "$BRANCH")
    indicators=""
    if [ "$STAGED" -gt 0 ] 2>/dev/null; then
        indicators="${C_GREEN}${BOLD}+${STAGED}${R}"
    fi
    if [ "$MODIFIED" -gt 0 ] 2>/dev/null; then
        [ -n "$indicators" ] && indicators="${indicators} "
        indicators="${indicators}${C_YELLOW}${BOLD}~${MODIFIED}${R}"
    fi
    [ -z "$indicators" ] && indicators="${C_GRAY}clean${R}"
    git_segment="${branch_part} ${indicators}"
fi

# ── Repo name + OSC 8 clickable link ──────────────────────────────────────────
repo_segment=""
if [ -n "$REPO_NAME" ]; then
    if echo "$REMOTE_URL" | grep -q "github.com" 2>/dev/null; then
        HTTPS_URL=$(echo "$REMOTE_URL" \
            | sed 's|git@github\.com:|https://github.com/|' \
            | sed 's|\.git$||')
        repo_segment=$(printf "\033]8;;%s\a${C_CYAN}${BOLD}%s${R}\033]8;;\a" "$HTTPS_URL" "$REPO_NAME")
    else
        repo_segment=$(printf "${C_CYAN}${BOLD}%s${R}" "$REPO_NAME")
    fi
fi

# ── RAM & CPU (Windows wmic, macOS vm_stat/sysctl, Linux /proc) ───────────────
sys_segment=""

case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*|Windows*)
        ram_info=$(wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /Format:List 2>/dev/null \
            | tr -d '\r' \
            | awk -F= '
                /FreePhysicalMemory/    { free=$2 }
                /TotalVisibleMemorySize/{ total=$2 }
                END {
                    if (total+0 > 0) {
                        used_gb  = (total - free) / 1048576
                        total_gb = total / 1048576
                        pct      = int((total - free) / total * 100 + 0.5)
                        printf "%.1fG/%.0fG(%d%%)", used_gb, total_gb, pct
                    }
                }
            ')
        cpu_info=$(wmic cpu get LoadPercentage /Format:List 2>/dev/null \
            | tr -d '\r' \
            | awk -F= '/LoadPercentage/ && $2+0 > 0 { printf "%d%%", $2+0 }')
        ;;
    Darwin)
        ram_info=$(vm_stat 2>/dev/null | awk '
            /page size/     { ps=$8 }
            /Pages free/    { free=$3 }
            /Pages active/  { active=$3 }
            /Pages inactive/{ inactive=$3 }
            /Pages wired/   { wired=$4 }
            /Pages speculative/ { spec=$3 }
            END {
                total_cmd = "sysctl -n hw.memsize"
                total_cmd | getline total_bytes
                close(total_cmd)
                if (total_bytes+0 > 0 && ps+0 > 0) {
                    used = (active + wired + spec) * ps
                    total_gb = total_bytes / 1073741824
                    used_gb  = used / 1073741824
                    pct = int(used / total_bytes * 100 + 0.5)
                    printf "%.1fG/%.0fG(%d%%)", used_gb, total_gb, pct
                }
            }
        ')
        cpu_info=$(top -l 1 -n 0 2>/dev/null | awk '/CPU usage/ {
            gsub(/%/, "", $3)
            printf "%d%%", $3+0
        }')
        ;;
    Linux)
        ram_info=$(awk '
            /MemTotal/     { total=$2 }
            /MemAvailable/ { avail=$2 }
            END {
                if (total+0 > 0) {
                    used_gb  = (total - avail) / 1048576
                    total_gb = total / 1048576
                    pct      = int((total - avail) / total * 100 + 0.5)
                    printf "%.1fG/%.0fG(%d%%)", used_gb, total_gb, pct
                }
            }
        ' /proc/meminfo 2>/dev/null)
        cpu_info=$(awk '{
            total = $2+$3+$4+$5+$6+$7+$8
            idle  = $5
        }' /proc/stat 2>/dev/null && \
            sleep 0.2 && \
            awk -v prev_total="$total" -v prev_idle="$idle" '{
                total = $2+$3+$4+$5+$6+$7+$8
                idle  = $5
                printf "%d%%", 100 * (1 - (idle - prev_idle) / (total - prev_total))
            }' /proc/stat 2>/dev/null)
        # Fallback: skip CPU on Linux if it's slow
        [ -z "$cpu_info" ] && cpu_info=""
        ;;
esac

if [ -n "$ram_info" ]; then
    sys_segment=$(printf "${C_GRAY}RAM:${C_WHITE}%s${R}" "$ram_info")
fi
if [ -n "$cpu_info" ]; then
    [ -n "$sys_segment" ] && sys_segment="${sys_segment} "
    sys_segment="${sys_segment}$(printf "${C_GRAY}CPU:${C_WHITE}%s${R}" "$cpu_info")"
fi

# ── Output (2 lines) ─────────────────────────────────────────────────────────
# Line 1: [Model] repo | branch +staged ~modified | RAM/CPU
line1="${C_CYAN}[${MODEL}]${R}"
[ -n "$repo_segment" ] && line1="${line1} ${repo_segment}"
[ -n "$git_segment"  ] && line1="${line1} ${C_GRAY}|${R} ${git_segment}"
[ -n "$sys_segment"  ] && line1="${line1} ${C_GRAY}|${R} ${sys_segment}"

# Line 2: [████░░░░░░] 42%  $0.05  8m5s
line2="${ctx_segment}  ${cost_segment}  ${elapsed_segment}"

printf '%b\n' "$line1"
printf '%b\n' "$line2"
