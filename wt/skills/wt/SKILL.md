---
name: wt
description: Create or locate git worktrees for GitHub PRs and branches using the wt and clone-bare shell commands. Use whenever the user wants to work on a PR, review a PR in a worktree, start parallel work on a new branch, set up a bare-clone worktree container for a repo, or asks where a worktree lives. Always prefer wt over hand-rolled git worktree add.
allowed-tools:
  - Bash(wt *)
  - Bash(clone-bare *)
  - Bash(bash *create-worktree.sh *)
  - Bash(bash *clone-bare.sh *)
---

# Worktrees via wt

All worktree work goes through two bash scripts. Never hand-roll
`git worktree add`; the scripts handle naming, placement, and idempotency.

## Running the commands

Run the scripts directly with bash. If commands section bellow is not clear check also the usage inside the scripts.
They sit in `scripts/` beside this SKILL.md, in the skill's base directory
(Claude Code exposes it as `${CLAUDE_SKILL_DIR}`).

## Commands

- `bash <base>/scripts/create-worktree.sh <PR number|URL> [branch]` — worktree
  for an existing GitHub PR. Branch defaults to the issue key at the start of
  the PR title (OCPBUGS-1234), else `pr-<number>`. An optional second argument
  overrides the branch name; it also names the worktree directory suffix.
- `bash <base>/scripts/create-worktree.sh <branch>` — worktree for a branch.
  Creates it from the HEAD of the worktree you launch from (the current
  branch), or from the default branch when launched from a container or bare
  root. Attaches an existing branch instead of creating it. Works from any
  checkout, worktree, or bare clone.
- `bash <base>/scripts/create-worktree.sh -C <dir> ...` — create the worktree
  under a specific directory instead of the default location.
- `bash <base>/scripts/clone-bare.sh <user:repo | repo URL> [dir] [branch]` —
  one-time setup for a repo: bare clone at `<dir>/.bare`, a `.git` pointer
  file, fork wiring (upstream remote added, gh default repo set), then opens
  the default branch in a worktree. Pass the fork URL when one exists. The
  cd into the container happens in the script's process only; use the path it
  prints.

## Where worktrees land

- Normal checkout: sibling of the checkout, `../<repo>-<name>`.
- Bare container (this kind of pattern: `~/directory/reponame/.bare`): inside the container,
  `~/directory/reponame/<name>`, sibling of `.bare`.
- Any worktree of a family: same place as above, routed through the shared
  repo.

## Agent rules

1. Run the script with bash, then `cd` to the path it prints before doing any work.
2. Re-running a command is safe: it is idempotent. If the branch is already checked out somewhere, it prints that path and creates nothing.
3. A PR number that does not exist aborts cleanly with gh's error before anything is created.
4. Push work with `git push -u origin <branch>` (origin is the fork in clone-bare setups) and open PRs with `gh pr create`; the base repo is already resolved, no `--repo` needed.
5. The scripts need git; PR mode and fork wiring need an authenticated gh CLI. If a script is missing, tell the user instead of falling back to raw git worktree.
