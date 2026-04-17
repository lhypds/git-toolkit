#!/bin/bash
# macOS double-clickable launcher for recursively-pull-repos.sh

# Run from the directory where this .command file lives.
script_dir="$(cd "$(dirname "$0")" && pwd -P)"
cd "$script_dir" || { echo "Failed to change directory to $script_dir" >&2; exit 1; }

bash "$script_dir/recursively-pull-repos.sh" "$@"
