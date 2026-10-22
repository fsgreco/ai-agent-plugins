#!/usr/bin/env bash
set -euo pipefail

# Create or locate a git worktree, for a GitHub PR or a branch.
# Works from a normal checkout, any of its worktrees, or a bare clone.
# PR mode requires an authenticated gh CLI.
#
# Usage: wt [-C dir] <PR URL|number> [branch]
#        wt [-C dir] <branch>
#
# -C <dir>  create the worktree under <dir> instead of the default location;
#           relative paths resolve against the repo root
#
# Default locations (worktrees are always siblings of their repo):
#   normal checkout          sibling of the checkout: ../<repo>-<name>
#   bare in a container      sibling of the bare:     ~/src/console/<name>
#     (~/src/console/.bare)
#   bare in a shared dir     prefixed sibling:        ~/src/console-<name>
#     (~/src/console.git)
#   -C <dir>                 under <dir>, named <repo>-<name>
#
# PR mode (arg is a PR number or URL):
#   name is PR-<number>[-<branch>]; branch defaults to the issue key at the
#   start of the PR title, else pr-<number>. PR numbers are looked up on the
#   'upstream' remote when present, else 'origin': PRs live on the base repo,
#   not on your fork.
# Branch mode (arg is anything else):
#   opens <branch> in a worktree, creating it from HEAD if it does not exist.
#
# Idempotent: if the branch is already checked out in any worktree, prints
# that path instead of creating anything.
#
# Examples, from any checkout of openshift/console or a bare clone of it:
#   wt 14243            # worktree PR-14243-OCPBUGS-9999, branch OCPBUGS-9999
#   wt 14243 fix-thing  # worktree PR-14243-fix-thing, branch fix-thing
#   wt ABC-12           # worktree ABC-12, new branch from HEAD
#   wt main             # worktree main, existing branch attached

usage='Usage: wt [-C dir] <PR URL|number> [branch] | wt [-C dir] <branch>'
base_override=
while getopts ":C:h" opt; do
  case $opt in
    C) base_override=$OPTARG ;;
    h) printf '%s\n' "$usage"; exit 0 ;;
    \?) printf 'wt: unknown flag -%s\n%s\n' "$OPTARG" "$usage" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
arg=${1:?$usage}

common=$(git rev-parse --git-common-dir)
[[ $common == /* ]] || common=$(cd "$common" && pwd)
toplevel=$(git rev-parse --show-toplevel 2>/dev/null || true)

remote_url=$(git remote get-url upstream 2>/dev/null || git remote get-url origin)
repo=$(basename "$remote_url" .git)
owner=$(basename "$(dirname "$remote_url")")

if [[ $common == */.git ]]; then
  root=$toplevel
  base=$(dirname "$toplevel")
  prefix=$repo-
else
  root=$(dirname "$common")
  base=$root
  # hidden bare (.bare) lives in its own container: no prefix needed
  if [[ $(basename "$common") == .* ]]; then prefix=; else prefix=$repo-; fi
fi

if [[ -n $base_override ]]; then
  [[ $base_override == /* ]] || base_override=$root/$base_override
  base=$base_override
  prefix=$repo-
fi

if [[ $arg =~ ^[0-9]+$ || $arg == *"/pull/"* ]]; then
  if [[ $arg == */pull/* ]]; then
    metadata=$(gh pr view "$arg" --json number,url,title --jq '[.number, .url, .title] | @tsv')
  else
    metadata=$(gh pr view "$arg" --repo "$owner/$repo" --json number,url,title --jq '[.number, .url, .title] | @tsv')
  fi
  IFS=$'\t' read -r number url title <<< "$metadata"
  issue=$(printf '%s\n' "$title" | sed -nE 's/^([A-Z][A-Z0-9]+-[0-9]+).*/\1/p')
  name=${2:-$issue}
  branch=${name:-pr-$number}
  path="$base/${prefix}PR-$number${name:+-$name}"
else
  branch=$arg
  path="$base/${prefix}${branch}"
fi

existing=$(git worktree list --porcelain | awk -v b="refs/heads/$branch" '
  /^worktree / { wt = substr($0, 10) }
  $1 == "branch" && $2 == b { print wt; exit }
')
if [[ -n $existing ]]; then
  printf '\ncd %q\n' "$existing"
  exit 0
fi

if git show-ref --verify --quiet "refs/heads/$branch"; then
  git worktree add "$path" "$branch"
elif [[ -n ${url:-} ]]; then
  git fetch "${url%/pull/*}.git" "pull/$number/head"
  git worktree add -b "$branch" "$path" FETCH_HEAD
else
  git worktree add -b "$branch" "$path"
fi

printf '\ncd %q\n' "$path"
