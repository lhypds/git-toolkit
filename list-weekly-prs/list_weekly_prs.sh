#!/bin/bash

# Script to list PRs from author lhypds for a chosen week, grouped by date
# Usage: ./list_weekly_prs.sh [--repos=owner/repo1,owner/repo2] [-v]
#   --repos=owner/repo1,owner/repo2 : comma-separated list of repositories to query
#   -v                              : verbose mode (show PR number, state, and URL)

REPOS=()
VERBOSE=false

# Parse flags
for arg in "$@"; do
    case "$arg" in
        --repos=*)
            IFS=',' read -ra REPOS <<< "${arg#--repos=}"
            ;;
        -v)
            VERBOSE=true
            ;;
    esac
done

# Validate repos
if [ ${#REPOS[@]} -eq 0 ]; then
    echo "Error: No repositories specified. Use --repos=owner/repo1,owner/repo2"
    read -p "Press Enter to exit..."
    exit 1
fi

# Ask user how many weeks ago
echo "=== PRs by lhypds ==="
echo "Repositories: ${REPOS[*]}"
echo ""
read -p "How many weeks ago? (default: 1, 0 = current week, 1 = last week, 2 = week before last, ...): " weeks_ago

if [ -z "$weeks_ago" ]; then
    weeks_ago=1
fi

# Validate input
if ! [[ "$weeks_ago" =~ ^[0-9]+$ ]]; then
    echo "Error: Please enter a non-negative integer."
    read -p "Press Enter to exit..."
    exit 1
fi

# Calculate week range
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    offset_start=$(( weeks_ago * 7 ))
    offset_end=$(( offset_start - 6 ))
    week_start=$(date -v-Mon -v-${offset_start}d +%Y-%m-%d)
    if [ "$weeks_ago" -eq 0 ]; then
        week_end=$(date +%Y-%m-%d)
    else
        week_end=$(date -v-Mon -v-${offset_end}d +%Y-%m-%d)
    fi
else
    # Linux
    offset_start=$(( weeks_ago * 7 ))
    offset_end=$(( (weeks_ago - 1) * 7 ))
    week_start=$(date -d "last monday -${offset_start} days" +%Y-%m-%d)
    if [ "$weeks_ago" -eq 0 ]; then
        week_end=$(date +%Y-%m-%d)
    else
        week_end=$(date -d "last monday -${offset_end} days" +%Y-%m-%d)
    fi
fi

if [ "$weeks_ago" -eq 0 ]; then
    echo ""
    echo "=== PRs by lhypds - Current Week ==="
else
    echo ""
    echo "=== PRs by lhypds - $weeks_ago week(s) ago ==="
fi
echo "Week: $week_start to $week_end"
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    echo "Please install it from: https://cli.github.com/"
    read -p "Press Enter to exit..."
    exit 1
fi

# Get PRs from the author for the chosen week, for each repo
for REPO in "${REPOS[@]}"; do
    echo "--- $REPO ---"
    prs=$(gh pr list -R "$REPO" --state all --search "author:lhypds created:$week_start..$week_end" --json number,title,createdAt,url,state --limit 100 2>&1)

    # Check if the command was successful
    if [ $? -ne 0 ]; then
        echo "Error fetching PRs for $REPO. Make sure you're authenticated with GitHub CLI."
        echo ""
        echo "Error details:"
        echo "$prs"
        echo ""
        continue
    fi

    # Parse and group by date
    if [ "$VERBOSE" = true ]; then
        result=$(echo "$prs" | jq -r '
          group_by(.createdAt | split("T")[0]) |
          .[] |
          "Date: \(.[0].createdAt | split("T")[0])\n" +
          (map("  • #\(.number) [\(.state)]: \(.title)\n    \(.url)") | join("\n")) + "\n"
        ')
    else
        result=$(echo "$prs" | jq -r '
          group_by(.createdAt | split("T")[0]) |
          .[] |
          "Date: \(.[0].createdAt | split("T")[0])\n" +
          (map("  • \(.title)") | join("\n")) + "\n"
        ')
    fi

    if [ -z "$result" ]; then
        echo "No PRs found for author lhypds during the selected week."
    else
        echo "$result"
    fi
    echo ""
done

echo ""
read -p "Press Enter to exit..."
