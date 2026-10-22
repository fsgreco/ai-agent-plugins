#!/usr/bin/env bash
set -euo pipefail

# Container-pattern bare clone: clone-bare.sh <repo URL | user:repo> [dir] [branch]
# Creates <dir>/.bare (bare clone) + <dir>/.git (points at .bare), then opens
# the repo's default branch, or [branch], in a worktree via create-worktree.sh.
# Default dir name is the repo name. user:repo expands to the ssh GitHub URL.
# Pass your FORK's URL when you have one: on GitHub forks, upstream is added
# automatically (origin stays = your fork), the default branch is synced from
# it, and gh's default repo is set to the parent. Pushes then go to your fork
# and PRs target the parent. Requires the gh CLI for that wiring; without it,
# fork setup is skipped with a warning.
#
# Note: the cd into <dir> happens in this process only. The final worktree
# path is printed as a cd hint for the calling shell.

usage='Usage: clone-bare.sh <repo URL | user:repo> [dir] [branch]'
url=${1:?$usage}
if [[ $url =~ '^[^/:]+:[^/:]+$' ]]; then
  url="git@github.com:${url%%:*}/${url##*:}.git"
fi
dir=${2:-$(basename "$url" .git)}
branch=${3:-}

gh_ok=1
command -v gh >/dev/null 2>&1 || { gh_ok=0; echo "clone-bare.sh: gh CLI not found, skipping fork setup" >&2; }

mkdir -p "$dir"
git clone --bare "$url" "$dir/.bare"
echo "gitdir: .bare" > "$dir/.git"

default_branch=$(git -C "$dir/.bare" symbolic-ref --short HEAD)
cd "$dir"

if (( gh_ok )) && [[ $url == *github.com* ]]; then
  repo=$(basename "$url" .git)
  owner=$(basename "$(dirname "$url")")
  parent=$(gh api "repos/$owner/$repo" --jq '.parent.full_name // empty' 2>/dev/null || true)
  if [[ -n $parent ]]; then
    if [[ $url == git@* ]]; then
      upstream_url="git@github.com:${parent}.git"
    else
      upstream_url="https://github.com/${parent}.git"
    fi
    git remote add upstream "$upstream_url"
    git fetch upstream "+$default_branch:$default_branch" \
      || echo "clone-bare.sh: could not fetch upstream, continuing without sync" >&2
    gh repo set-default "$parent" 2>/dev/null \
      || echo "clone-bare.sh: gh repo set-default failed, continuing" >&2
  else
    gh repo set-default "$owner/$repo" 2>/dev/null \
      || echo "clone-bare.sh: gh repo set-default failed, continuing" >&2
  fi
fi

exec bash "$(dirname "$0")/create-worktree.sh" "${branch:-$default_branch}"
