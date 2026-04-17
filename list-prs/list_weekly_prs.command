#!/bin/bash

# Script to list PRs from author lhypds during current week, grouped by date
# Repository: linktivity/ars-neo-miniapp
# Usage: ./list_weekly_prs.command [-v]
#   -v: verbose mode (show PR number, state, and URL)

# Constants
REPO="linktivity/ars-neo-miniapp"

# Parse flags
VERBOSE=false
if [[ "$1" == "-v" ]]; then
    VERBOSE=true
fi

echo "=== PRs by lhypds - Current Week ==="
echo "Repository: $REPO"
echo ""

# Get the start of the current week (Monday)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    week_start=$(date -v-Mon +%Y-%m-%d)
else
    # Linux
    week_start=$(date -d "last monday" +%Y-%m-%d)
fi

echo "Week starting: $week_start"
echo ""

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    echo "Please install it from: https://cli.github.com/"
    read -p "Press Enter to exit..."
    exit 1
fi

# Get PRs from the author created this week
# Using --search to filter by date and author
prs=$(gh pr list -R "$REPO" --state all --search "author:lhypds created:>=$week_start" --json number,title,createdAt,url,state --limit 100 2>&1)

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
    echo "No PRs found for author lhypds during current week."
fi

echo ""
read -p "Press Enter to exit..."
