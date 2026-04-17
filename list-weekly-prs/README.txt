
list-weekly-prs
===============


List GitHub Pull Requests by a chosen week, grouped by date.


Files
-----

| File | Description |
|------|-------------|
| `list_weekly_prs.sh` | Core logic script — can be run directly from the terminal |
| `list_weekly_prs.command` | macOS double-clickable launcher — calls `list_weekly_prs.sh` with a preconfigured repo |


Usage
-----

```bash
./list_weekly_prs.sh [--repo=owner/repo] [-v]
```

When run, the script will prompt:

```
How many weeks ago? (0 = current week, 1 = last week, 2 = week before last, ...):
```


Parameters
----------

| Parameter | Description | Default |
|-----------|-------------|---------|
| `--repo=owner/repo` | GitHub repository to query | `linktivity/ars-neo-miniapp` |
| `-v` | Verbose mode — shows PR number, state, and URL for each PR | off |


Examples
--------

```bash
# Current week, default repo
./list_weekly_prs.sh

# Last week, custom repo
./list_weekly_prs.sh --repo=myorg/myrepo

# Two weeks ago, verbose output
./list_weekly_prs.sh --repo=myorg/myrepo -v
```


Requirements
------------

- [GitHub CLI (`gh`)](https://cli.github.com/) — must be installed and authenticated
- [`jq`](https://stedolan.github.io/jq/) — used for JSON parsing and output formatting
