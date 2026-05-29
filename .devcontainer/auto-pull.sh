#!/usr/bin/env bash
# postStartCommand hook -- keep the Codespace workspace in sync with origin
# on every container start (boot, restart, resume from suspend). Goal:
# a freshly-opened Codespace is "good to go" with the latest course
# materials. Students should not have to run `git pull` manually before
# starting an assignment.
#
# All actions are non-fatal: if the workspace has local commits, a
# divergent branch, no network, no origin, or detached HEAD, this prints
# a friendly diagnostic and continues so the Codespace still opens.
#
# Tested by:
#   cd /workspaces/fmaiv && bash .devcontainer/auto-pull.sh
set -u

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # Workspace isn't a git repo (unexpected); nothing to refresh.
  exit 0
fi

branch="$(git branch --show-current 2>/dev/null || true)"
if [ -z "$branch" ]; then
  echo "[auto-pull] detached HEAD -- skipping refresh; checkout a branch and rerun"
  exit 0
fi

# Try to fetch; silently skip if the remote / network is unreachable.
if ! git fetch --quiet origin 2>/dev/null; then
  echo "[auto-pull] (no origin / network); skipping update"
  exit 0
fi

before="$(git rev-parse --short HEAD)"

# Fast-forward only. NEVER overwrite local commits -- if students have
# their own work-in-progress, we leave it alone and tell them how to
# resolve.
if git pull --ff-only --quiet 2>/dev/null; then
  after="$(git rev-parse --short HEAD)"
  if [ "$before" = "$after" ]; then
    echo "[auto-pull] $branch is up to date @ $after"
  else
    echo "[auto-pull] $branch updated: $before -> $after"
    git log --oneline "$before..$after" 2>/dev/null | sed 's/^/    /' | head -10
    # If there are more commits, hint at it.
    extra="$(git rev-list --count "$before..$after" 2>/dev/null || echo 0)"
    if [ "${extra:-0}" -gt 10 ]; then
      echo "    ...and $((extra - 10)) more"
    fi
  fi
else
  cat <<'EOF'
[auto-pull] could not fast-forward this branch -- you have local commits or a
            divergent branch. Resolve manually, e.g.:

              git status                              # see what diverged
              git pull --rebase                       # if your local commits are unpublished
              git stash && git pull --ff-only && git stash pop   # if dirty tree

            The Codespace is otherwise ready; this is just a refresh advisory.
EOF
fi
