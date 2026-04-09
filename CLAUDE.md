# CLAUDE.md

## Cel
Utrzymujemy fork `rustdesk` z regularnym synciem z upstream i własnymi zmianami.

## Gałęzie
- `main` — gałąź integracyjna projektu
- `upstream-main` — mirror `upstream/master`
- `feat/conn/*` — zmiany mechanizmu połączeń
- `feat/ui/*` — zmiany UI

## Remote
- `origin` = `b-y-t-e/rustdesk`
- `upstream` = `rustdesk/rustdesk`

## Standard pracy
1. Twórz branch od `main`.
2. Małe PR: 1 temat = 1 PR.
3. Przed PR: `git fetch`, `rebase main`, test lokalny.

## Sync upstream (regularnie)
```bash
git fetch upstream --prune
git checkout main
git merge upstream/master
git push origin main
```

## Odtworzenie na nowym komputerze
Push repo odtwarza kod, historię i branch flow, ale nie odtwarza automatycznie:
- lokalnych remote (np. `upstream`),
- lokalnych/globalnych ustawień git,
- kluczy SSH/tokenów,
- zależności i narzędzi systemowych.

## Szybka inicjalizacja
Po klonie uruchom z root repo:
```bash
./scripts/init-fork.sh
```
Skrypt ustawia `upstream`, przygotowuje `main` i `upstream-main`, zakłada/pushuje `feat/conn/base` i `feat/ui/base`, oraz włącza `rerere` lokalnie w repo.

## Uwaga
Panel webowy jest poza tym repo (nie rozwijamy go tutaj).
