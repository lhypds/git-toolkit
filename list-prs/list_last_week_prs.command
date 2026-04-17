#!/bin/bash

# Script to list PRs from author lhypds during last week, grouped by date
# Repository: linktivity/ars-neo-miniapp
# Usage: ./list_last_week_prs.command [-v]
#   -v: verbose mode (show PR number, state, and URL)

# Constants
REPO="linktivity/ars-neo-miniapp"

# Parse flags
VERBOSE=false
if [[ "$1" == "-v" ]]; then
    VERBOSE=true
fi

echo "=== PRs by lhypds - Last Week ==="
echo "Repository: $REPO"
echo ""

# Get the start and end of last week (Monday to Sunday)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    week_start=$(date -v-Mon -v-7d +%Y-%m-%d)
    week_end=$(date -v-Mon -v-1d +%Y-%m-%d)
else
    # Linux
    week_start=$(date -d "last monday -7 days" +%Y-%m-%d)
    week_end=$(date -d "last monday -1 day" +%Y-%m-%d)
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

# Get PRs from the author created last week
# Using --search to filter by date range and author
prs=$(gh pr list -R "$REPO" --state all --search "author:lhypds created:$week_start..$week_end" --json number,title,createdAt,url,state --limit 100 2>&1)

# Check if the command was successful
if [ $? -ne 0 ]; then
    echo "Error fetching PRs. Make sure you're in a GitHub repository or specify one with -R owner/repo"
    echo ""
    echo "Error details:"
    echo "$prs"
    echo ""
    read -p "Press Enter to exit..."
    exit 1
fi

# Parse and group by date
if [ "$VERBOSE" = true ]; then
    echo "$prs" | jq -r '
      group_by(.createdAt | split("T")[0]) |
      .[] |
      "Date: \(.[0].createdAt | split("T")[0])\n" +
      (map("  • #\(.number) [\(.state)]: \(.title)\n    \(.url)") | join("\n")) + "\n"
    '
else
    echo "$prs" | jq -r '
      group_by(.createdAt | split("T")[0]) |
      .[] |
      "Date: \(.[0].createdAt | split("T")[0])\n" +
      (map("  • \(.title)") | join("\n")) + "\n"
    '
fi

if [ $? -ne 0 ]; then
    echo "No PRs found for author lhypds during last week."
fi

echo ""
read -p "Press Enter to exit..."
