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
