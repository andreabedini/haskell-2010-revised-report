# Activity on the GHC repository

How much work goes into GHC, measured by commits, contributors, issues and
merge requests on the upstream repository. Part of the [GHC upgrade breakage
catalog](README.md). These numbers give context for the catalog and for
[GHC 10.0](ghc-10.0.md): fewer people and fewer changes per release make
breakage reviews and warning periods harder to staff.

The numbers were taken on 17 October 2026 from
[`gitlab.haskell.org/ghc/ghc`](https://gitlab.haskell.org/ghc/ghc). The last
commit counted is `7dedcf13` on master (16 October 2026). 2026 is a partial
year, about 79% of the way through.

## Summary

- Commits on master held at about 1,800–1,900 a year from 2018 to 2023. They
  fell to 1,441 in 2024 and 1,086 in 2025. 2026 is on course for about
  1,120.
- Active authors per year fell from about 150 (2018–2022) to 100 in 2025.
- First-time authors fell from about 75 a year (2019–2020) to about 30.
- The ten most active authors write about two thirds of the commits every
  year, so the work stays concentrated.
- Release cycles land fewer commits per day: about 5 for 9.2–9.8, about 3
  for 9.14 and later.
- New issues and merge requests fell from 2022 to 2025. In 2026 issues are
  back near the earlier level. Merge requests recover more slowly.
- About a third of the issues opened in each year are still open.

## Totals

| Measure | Count |
|---|---|
| Commits reachable from master (since 1996) | 69,774 |
| Distinct author names, after `.mailmap` | 1,067 |
| Issues (including those imported from Trac) | 26,523 |
| Issues still open | 6,825 |

## Commits and contributors per year

Counted along master's first-parent history. This leaves out the histories
of Hadrian and Haddock, which were merged into the tree later and would
otherwise add to 2016 and 2024.

| Year | Commits | Active authors | First-time authors | Top 10 share |
|---|---|---|---|---|
| 2016 | 2,236 | 120 | 54 | |
| 2017 | 2,121 | 127 | 66 | |
| 2018 | 1,838 | 150 | 72 | 65% |
| 2019 | 1,906 | 147 | 76 | |
| 2020 | 1,816 | 152 | 75 | 68% |
| 2021 | 1,877 | 144 | 63 | |
| 2022 | 1,800 | 155 | 70 | 67% |
| 2023 | 1,742 | 142 | 52 | |
| 2024 | 1,441 | 118 | 43 | 64% |
| 2025 | 1,086 | 100 | 34 | 68% |
| 2026 (to 16 Oct) | 886 | 91 | 29 | 61% |

The most active authors from October 2025 to October 2026 were Cheng Shao
(166 commits), Duncan Coutts (113), Simon Jakobi (86), Simon Peyton Jones
(80) and sheaf (77).

## Commits per release cycle

A release's development runs on master between two `ghc-X-start` tags. For
example, 9.14 was developed between `ghc-9.13-start` and `ghc-9.15-start`.

| Release | Development window | Commits | Authors | Days | Commits per day |
|---|---|---|---|---|---|
| 9.2 | 2020-07-22 – 2021-03-23 | 1,240 | 115 | 244 | 5.1 |
| 9.4 | 2021-03-23 – 2022-04-09 | 1,944 | 143 | 381 | 5.1 |
| 9.6 | 2022-04-09 – 2022-12-22 | 1,196 | 133 | 257 | 4.7 |
| 9.8 | 2022-12-22 – 2023-06-21 | 965 | 96 | 181 | 5.3 |
| 9.10 | 2023-06-21 – 2024-03-10 | 1,139 | 111 | 262 | 4.3 |
| 9.12 | 2024-03-10 – 2024-09-27 | 811 | 93 | 201 | 4.0 |
| 9.14 | 2024-09-27 – 2025-07-15 | 913 | 87 | 290 | 3.1 |
| 10.0 | 2025-07-15 – 2026-04-10 | 942 | 100 | 269 | 3.5 |
| 10.2 (so far) | 2026-04-10 – 2026-10-16 | 610 | 63 | 189 | 3.2 |

## Issues and merge requests per year

From the GitLab API. GHC moved to GitLab at the end of 2018, so the table
starts in 2019.

| Year | Issues opened | Still open | MRs opened | MRs resolved | MRs still open | Marge Bot batches |
|---|---|---|---|---|---|---|
| 2019 | 1,496 | 500 | 1,756 | 1,696 | 60 | 560 |
| 2020 | 1,509 | 567 | 1,689 | 1,599 | 90 | 613 |
| 2021 | 1,748 | 620 | 1,803 | 1,714 | 89 | 769 |
| 2022 | 1,774 | 578 | 1,573 | 1,472 | 101 | 774 |
| 2023 | 1,611 | 572 | 1,492 | 1,356 | 136 | 730 |
| 2024 | 1,313 | 554 | 1,294 | 1,158 | 136 | 641 |
| 2025 | 1,093 | 509 | 1,010 | 879 | 131 | 472 |
| 2026 (to 17 Oct) | 1,229 | 733 | 1,026 | 730 | 296 | 546 |

- "Still open" counts the issues or MRs opened that year that are open
  today.
- The MR columns leave out Marge Bot's batch MRs, which are counted
  separately.
- "Resolved" means merged or closed. Marge Bot lands MRs in batches, and
  GitLab then marks most of the landed MRs as closed, not merged. So the API
  cannot tell a landed MR from an abandoned one.

## Reviews

From a local SQLite dump of the GitLab project that runs to 9 September
2026, so 2026 is about 69% of a year. The counts use
[`scripts/review_stats.py`](scripts/review_stats.py).

- A merge request **landed** if GitLab marks it merged, or if Marge Bot
  closed it.
- A **review** is an approval, or a comment, by someone other than the MR's
  author. Bots are left out.
- GHC does not require approvals, and some review happens off GitLab, for
  example in chat. So "no review" means no review visible on the MR.

| Year | MRs | MR authors | Landed | Approved | Commented on | No review | 2+ reviewers | Regular reviewers | Reviewers covering half of reviews | Median days to first review |
|---|---|---|---|---|---|---|---|---|---|---|
| 2019 | 1,756 | 166 | 1,215 | 71% | 67% | 18% | 43% | 22 | 3 | 0.3 |
| 2020 | 1,689 | 168 | 1,254 | 64% | 67% | 18% | 42% | 23 | 4 | 0.4 |
| 2021 | 1,803 | 159 | 1,393 | 58% | 67% | 19% | 40% | 20 | 4 | 0.7 |
| 2022 | 1,573 | 170 | 1,170 | 55% | 66% | 19% | 39% | 21 | 5 | 0.8 |
| 2023 | 1,492 | 158 | 1,175 | 63% | 72% | 14% | 45% | 27 | 5 | 0.8 |
| 2024 | 1,294 | 150 | 1,000 | 64% | 72% | 15% | 47% | 26 | 6 | 0.8 |
| 2025 | 1,010 | 118 | 768 | 65% | 71% | 16% | 42% | 16 | 5 | 2.0 |
| 2026 (to 9 Sep) | 912 | 123 | 578 | 70% | 71% | 13% | 35% | 15 | 5 | 0.8 |

The percentages are of landed MRs. A regular reviewer reviewed at least 10
landed MRs that year.

- **Most MRs have one reviewer.** The median is one. About 40% get two or
  more.
- **About one landed MR in six has no visible review.** Almost all of these
  come from maintainers. In 2019, 184 of the 222 came from Ben Gamari, then
  release manager. In the last 12 months the most came from Cheng Shao
  (43), Andreas Klebinger (14) and Sylvain Henry (12).
- **The pool of regular reviewers is shrinking.** It was 20–27 people a year
  up to 2024, and is 15–16 now. In 2025, 118 people opened MRs and 16
  reviewed regularly.
- **Review is less dependent on one person than it was.** In 2019–2020 one
  person, Ben Gamari, gave half of all approvals. Since 2023 the busiest
  approver gives under a fifth. But half of all reviews still come from
  about five people.
- **Reviews start quickly.** The first review usually comes within a day.
  2025 was slower, at two days.

In the last 12 months of the dump, 39 people approved at least one MR, and
14 approved ten or more. The most MRs reviewed (approved or commented on)
were by sheaf (199), Andreas Klebinger (174), Cheng Shao (173), Rodrigo
Mesquita (132) and Simon Peyton Jones (130).

## Caveats

- Authors are counted by name, after GHC's `.mailmap`. A person with two
  identities that the map does not join counts twice. Bot commits are
  included.
- A commit's year is its author date. The release-cycle windows use the
  commit dates of the tags.
- Commits count what landed on master. One merge request can land as
  several commits.
- Issues from before 2019 were imported from Trac, so the per-year table
  covers only the GitLab years.

## Reproducing

Commits and contributors, from a GHC checkout with `upstream` pointing at
`https://gitlab.haskell.org/ghc/ghc.git`:

```sh
git fetch upstream master
# commits and active authors per year
git log --first-parent --format='%ad %aN' --date=format:%Y FETCH_HEAD |
  awk '{y=$1; $1=""; c[y]++; if (!((y,$0) in s)) {s[y,$0]=1; n[y]++}}
       END {for (y in c) print y, c[y], n[y]}' | sort -n
# first-time authors per year
git log --first-parent --reverse --format='%ad %aN' --date=format:%Y FETCH_HEAD |
  awk '{y=$1; $1=""; if (!($0 in f)) {f[$0]=y; n[y]++}}
       END {for (y in n) print y, n[y]}' | sort -n
# one release cycle, for example 9.14
git rev-list --first-parent --count ghc-9.13-start..ghc-9.15-start
```

Issues and merge requests, from the public API without a token:

```sh
B='https://gitlab.haskell.org/api/v4/projects/ghc%2Fghc'
w='created_after=2025-01-01T00:00:00Z&created_before=2026-01-01T00:00:00Z'
curl -s "$B/issues_statistics?$w"
# MRs: read the x-total header; it is missing when the count exceeds 10,000
curl -s -D - -o /dev/null \
  "$B/merge_requests?per_page=1&state=all&$w&not%5Bauthor_username%5D=marge-bot" |
  grep -i '^x-total:'
```
