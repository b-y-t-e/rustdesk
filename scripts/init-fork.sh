#!/usr/bin/env bash
set -euo pipefail

# Init rustdesk fork workspace on a new machine.
# Run from repository root: ./scripts/init-fork.sh

UPSTREAM_URL="https://github.com/rustdesk/rustdesk.git"
ORIGIN_URL_EXPECTED="https://github.com/b-y-t-e/rustdesk.git"
UPSTREAM_BASE_BRANCH="master"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[ERROR] Uruchom skrypt w katalogu repozytorium git."
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

echo "[1/7] Sprawdzam origin..."
ORIGIN_URL="$(git remote get-url origin 2>/dev/null || true)"
if [[ -z "$ORIGIN_URL" ]]; then
  echo "[ERROR] Brak remote 'origin'. Najpierw sklonuj fork."
  exit 1
fi

echo "origin = $ORIGIN_URL"
if [[ "$ORIGIN_URL" != "$ORIGIN_URL_EXPECTED" ]]; then
  echo "[WARN] origin różni się od oczekiwanego: $ORIGIN_URL_EXPECTED"
fi

echo "[2/7] Konfiguruję upstream..."
if git remote get-url upstream >/dev/null 2>&1; then
  git remote set-url upstream "$UPSTREAM_URL"
else
  git remote add upstream "$UPSTREAM_URL"
fi

echo "[3/7] Pobieram zmiany z remote..."
git fetch --all --prune

echo "[4/7] Przygotowuję branch main..."
if git show-ref --verify --quiet refs/heads/main; then
  git checkout main
else
  git checkout -b main "upstream/$UPSTREAM_BASE_BRANCH"
fi

if git show-ref --verify --quiet refs/remotes/origin/main; then
  git branch --set-upstream-to=origin/main main || true
else
  git branch --set-upstream-to="upstream/$UPSTREAM_BASE_BRANCH" main || true
fi

echo "[5/7] Przygotowuję branch upstream-main..."
git branch -f upstream-main "upstream/$UPSTREAM_BASE_BRANCH"

if git show-ref --verify --quiet refs/remotes/origin/main; then
  git push -u origin main
else
  git push -u origin main:main
fi

if git show-ref --verify --quiet refs/remotes/origin/upstream-main; then
  git push origin upstream-main
else
  git push -u origin upstream-main:upstream-main
fi

echo "[6/7] Tworzę branche feature (jeśli nie istnieją)..."
for b in feat/conn/base feat/ui/base; do
  if git show-ref --verify --quiet "refs/heads/$b"; then
    echo "- $b już istnieje lokalnie"
  else
    git checkout -b "$b" main
  fi

  if git show-ref --verify --quiet "refs/remotes/origin/$b"; then
    git push origin "$b"
  else
    git push -u origin "$b"
  fi

done

git checkout main

echo "[7/7] Ustawiam rerere (lokalnie w repo)..."
git config rerere.enabled true

echo
echo "Gotowe."
echo "- origin:   $(git remote get-url origin)"
echo "- upstream: $(git remote get-url upstream)"
echo "- bieżąca gałąź: $(git branch --show-current)"
echo "- rerere.enabled: $(git config --get rerere.enabled)"
