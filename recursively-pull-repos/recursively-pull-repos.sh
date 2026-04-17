#!/usr/bin/env bash
# Recursively find git repositories (directories containing a .git folder)
# and run `git pull` in each one. Supports a dry-run mode.

set -euo pipefail
IFS=$'\n\t'

DRY_RUN=0

usage() {
	cat <<-USAGE
Usage: ${0##*/} [options]

Options:
	-n, --dry-run   Show the git commands that would be executed without running them
	-h, --help      Show this help message

This script searches the current directory recursively for directories named
.git (i.e. git repositories) and runs 'git pull --recurse-submodules --autostash'
in each repository's root.
USAGE
}

while [[ $# -gt 0 ]]; do
	case "$1" in
		-n|--dry-run) DRY_RUN=1; shift ;;
		-h|--help) usage; exit 0 ;;
		--) shift; break ;;
		-* ) echo "Unknown option: $1" >&2; usage; exit 2 ;;
		* ) break ;;
	esac
done

echo "Searching for git repositories under: $(pwd)"

# Collect .git directories (prune to avoid descending into .git itself)
mapfile -t GIT_DIRS < <(find . -type d -name .git -prune 2>/dev/null)

if [ ${#GIT_DIRS[@]} -eq 0 ]; then
	echo "No git repositories found."
	exit 0
fi

failures=0

for g in "${GIT_DIRS[@]}"; do
	repo_dir=$(dirname "$g")
	# Resolve to an absolute path to make output clearer
	if repo_abs=$(cd "$repo_dir" 2>/dev/null && pwd -P); then
		repo_dir="$repo_abs"
	fi

	printf "\n----\nRepository: %s\n" "$repo_dir"

	cmd=(git -C "$repo_dir" pull --recurse-submodules --autostash)

	if [ "$DRY_RUN" -eq 1 ]; then
		printf "[dry-run] %s\n" "${cmd[*]}"
		continue
	fi

	echo "Running: ${cmd[*]}"
	if "${cmd[@]}"; then
		echo "OK: $repo_dir"
	else
		echo "ERROR: git pull failed for $repo_dir" >&2
		failures=$((failures + 1))
	fi
done

if [ $failures -gt 0 ]; then
	echo "\nFinished with $failures failures." >&2
	exit 2
fi

echo "\nAll repositories updated successfully."

