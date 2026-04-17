recursively-pull-repos
======================


Recursively find all git repositories under the current directory and run `git pull` in each one.


Files
-----

| File                             | Description                                                         |
|----------------------------------|---------------------------------------------------------------------|
| `recursively-pull-repos.sh`      | Core logic script — can be run directly from the terminal           |
| `recursively-pull-repos.command` | macOS double-clickable launcher — calls `recursively-pull-repos.sh` |


Setup
-----

Copy both files into the parent folder that contains your git repositories, then double-click `recursively-pull-repos.command` or run the `.sh` directly.


Usage
-----

```bash
./recursively-pull-repos.sh [options]
```

The script searches the current directory recursively for `.git` folders and runs `git pull --recurse-submodules --autostash` in each repository root.


Parameters
----------

| Parameter         | Description                                                            |
|-------------------|------------------------------------------------------------------------|
| `-n`, `--dry-run` | Show the commands that would be executed without actually running them |
| `-h`, `--help`.   | Show the help message and exit                                         |


Examples
--------

```bash
# Pull all repos under the current directory
./recursively-pull-repos.sh

# Preview what would be pulled without making any changes
./recursively-pull-repos.sh --dry-run
```


Requirements
------------

- `git` — must be installed and available in PATH
