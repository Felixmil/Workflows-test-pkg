# Workflow test results

Validation of the split reusable workflows from
`Felixmil/Workflows@rework-description-tagging`, exercised on this test package.
Every scenario below has a passing GitHub Actions run linked.

Repo: https://github.com/Felixmil/Workflows-test-pkg

## Caller workflows under test

| Workflow | Trigger | Role |
|---|---|---|
| `pr.yaml` | pull_request | sync-remotes (Remotes follow version) → R-CMD-check |
| `merge.yaml` | push: main | R-CMD-check → publish-release (release ver) / bump-dev-version (dev ver) |
| `release-pr.yaml` | dispatch (which) | usethis::use_version + pin Remotes → open release PR |
| `dev-pr.yaml` | dispatch (also after release) | usethis::use_dev_version + unpin → open restore-dev PR |
| `check-dev-deps.yaml` | nightly + dispatch | R-CMD-check against current (dev) deps |
| `check-released-deps.yaml` | nightly + dispatch | R-CMD-check against latest released deps |

## Scenarios

| # | Scenario | Expected | Run |
|---|---|---|---|
| 1 | **PR, sync pin** — release Version + bare Remotes | pin `@*release`, push to PR branch; R-CMD-check after sync | [26896458528](https://github.com/Felixmil/Workflows-test-pkg/actions/runs/26896458528) |
| 2 | **PR, sync unpin** — dev Version + pinned Remotes | strip `@*release`, push to PR branch | [26896719961](https://github.com/Felixmil/Workflows-test-pkg/actions/runs/26896719961) |
| 3 | **PR, dev contribution** — code change on dev main | sync no-op (bare stays bare) + R-CMD-check | [26903075532](https://github.com/Felixmil/Workflows-test-pkg/actions/runs/26903075532) |
| 4 | **Merge, dev bump** — dev contribution hits main | bump `.NNNN`, commit; publish-release no-ops | [26903179950](https://github.com/Felixmil/Workflows-test-pkg/actions/runs/26903179950) |
| 5 | **release-pr dispatch** — which=patch | use_version(patch) → Version, NEWS heading; pin; open PR | [26903525992](https://github.com/Felixmil/Workflows-test-pkg/actions/runs/26903525992) |
| 6 | **Merge, release** — release PR hits main (v0.2.2) | tag `v0.2.2` + GitHub Release + binary; bump no-ops | [26903670964](https://github.com/Felixmil/Workflows-test-pkg/actions/runs/26903670964) |
| 7 | **Merge, release w/ NEWS notes** — release PR hits main (v0.2.1) | release body from NEWS.md section (not fallback) | [26897085383](https://github.com/Felixmil/Workflows-test-pkg/actions/runs/26897085383) |
| 8 | **dev-pr dispatch** — restore dev (0.2.2 → 0.2.2.9000) | use_dev_version + unpin; open restore-dev PR | [26903827917](https://github.com/Felixmil/Workflows-test-pkg/actions/runs/26903827917) |
| 9 | **Merge, dev restore** — restore-dev PR hits main | post-merge bump to `.9001` | [26903964607](https://github.com/Felixmil/Workflows-test-pkg/actions/runs/26903964607) |
| 10 | **check-dev-deps** — nightly/manual, current deps | R-CMD-check against dev deps | [26904044639](https://github.com/Felixmil/Workflows-test-pkg/actions/runs/26904044639) |
| 11 | **check-released-deps** — nightly/manual, released deps | pin `@*release` ephemerally, check against released deps | [26904047539](https://github.com/Felixmil/Workflows-test-pkg/actions/runs/26904047539) |

## Full maintainer cycle validated

dev contribution (#3) → bump (#4) → `release-pr` (#5) → merge tags `v0.2.2` (#6)
→ `dev-pr` (#8) → merge restores dev + bumps (#9). Resulting `main`: `0.2.2.9001`,
bare Remotes; tag/release `v0.2.2` published with binary.

## Notes

- An empty `NEWS.md` release section correctly falls back to a generated
  "Release vX.Y.Z" note (seen for v0.2.2); a populated section is used verbatim
  (seen for v0.2.1, scenario 7).
- `release_pr` / `dev_pr` stage only `DESCRIPTION` + `NEWS.md` (the earlier
  `git add -A` that leaked a `.workflows-repo` gitlink onto main is fixed).
- The reusable workflows currently point their helper-script checkout at
  `Felixmil/Workflows@rework-description-tagging` for testing; this is reverted
  to the upstream repo before the PR.

## Resolved: release/dev PRs need an App token to trigger CI

A PR opened by a workflow using the default `GITHUB_TOKEN` does **not** trigger
other workflows (a GitHub safety rule against recursive Actions). So the early
release PRs `release_pr` opened (PRs #8, #10, authored by `app/github-actions`)
had **no `pr.yaml` / R-CMD-check runs** — merge-able without CI.

**Fix:** open the PR with a GitHub App token. `release_pr`/`dev_pr` mint and use
an App token when `app-id`/`private-key` are provided (for both the branch push
and `gh pr create`); the test-pkg callers pass `vars.OSP_BOT_APP_ID` /
`secrets.OSP_BOT_PRIVATE_KEY`. With no App they fall back to `GITHUB_TOKEN`
(PR opens, no CI trigger).

**Confirmed working** — App `personal-actions-manager` installed on the repo:
- `release-pr` dispatch → PR **#11** `release-pr-0.2.3`, authored by
  **`app/personal-actions-manager`** (not the default Actions bot).
- `pr.yaml` triggered on it and passed:
  [run 26937162542](https://github.com/Felixmil/Workflows-test-pkg/actions/runs/26937162542)
  (`sync-remotes` ✅ + `R-CMD-check` ✅).

Setup that made it work (one-time, GitHub UI + secrets):
1. GitHub App (personal account) with `contents: write` + `pull_requests: write`,
   installed on this repo.
2. Repo variable `OSP_BOT_APP_ID`; repo secret `OSP_BOT_PRIVATE_KEY` = the App
   private key. The key must be a parseable PEM (convert with
   `openssl pkcs8 -topk8 -nocrypt` if `create-github-app-token` reports
   `Invalid keyData`).

## Nightly schedule

`check-dev-deps` (cron `0 3 * * *`) and `check-released-deps` (cron `0 4 * * *`)
declare their schedules on `main`. Both jobs are validated via `workflow_dispatch`
(green). GitHub commonly skips a newly-added cron's first occurrence, so the
first *scheduled* fire is pending a natural nightly run.
