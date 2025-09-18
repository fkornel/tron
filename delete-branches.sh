#!/usr/bin/env bash
set -euo pipefail

echo "WARNING: Deleting all local branches except 'main' and removing their remote counterparts on 'origin'."

# Ensure we are on main
CURRENT=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT" != "main" ]; then
  echo "Switching to 'main' branch (current: $CURRENT)..."
  if git show-ref --verify --quiet refs/heads/main; then
    git checkout main
  else
    git fetch origin main:main || git checkout -b main origin/main || true
    git checkout main || true
  fi
fi

# Update remotes
git fetch --all --prune

# Collect local branches except main
mapfile -t LOCAL_BRANCHES < <(git for-each-ref refs/heads --format='%(refname:short)' | grep -v '^main$' || true)

if [ "${#LOCAL_BRANCHES[@]}" -eq 0 ]; then
  echo "No local branches to delete."
else
  echo "Local branches to delete:"
  for b in "${LOCAL_BRANCHES[@]}"; do
    echo "  $b"
  done

  for b in "${LOCAL_BRANCHES[@]}"; do
    echo "Deleting local branch: $b"
    git branch -D "$b" && echo "Deleted local branch $b" || echo "Failed to delete local branch $b"
  done
fi

# Collect remote branches on origin except main
mapfile -t REMOTE_BRANCHES < <(git ls-remote --heads origin | awk '{print $2}' | sed 's|refs/heads/||' | grep -v '^main$' || true)

if [ "${#REMOTE_BRANCHES[@]}" -eq 0 ]; then
  echo "No remote branches to delete on origin."
else
  echo "Remote branches to delete on origin:"
  for rb in "${REMOTE_BRANCHES[@]}"; do
    echo "  $rb"
  done

  for rb in "${REMOTE_BRANCHES[@]}"; do
    # skip HEAD or empty
    if [ -z "$rb" ] || [ "$rb" = "HEAD" ]; then
      continue
    fi
    echo "Deleting remote branch origin/$rb"
    git push origin --delete "$rb" && echo "Deleted remote origin/$rb" || echo "Failed to delete remote origin/$rb"
  done
fi

# Final prune and summary
git fetch --all --prune

echo "Remaining local branches:";
git for-each-ref refs/heads --format='%(refname:short)'

echo "Remaining remote branches on origin:";
git ls-remote --heads origin | awk '{print $2}' | sed 's|refs/heads/||'
