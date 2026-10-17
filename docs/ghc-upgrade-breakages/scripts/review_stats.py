"""Review statistics for GHC merge requests, from a local SQLite dump of
gitlab.haskell.org/ghc/ghc (the gitlab.db built in the ghc-gitlab project).

Usage: python3 -I review_stats.py path/to/gitlab.db

A merge request counts as landed if GitLab marks it merged, or if Marge Bot
closed it (Marge lands MRs in batches). A review is an approval or a
non-system comment by someone other than the MR's author. Accounts whose
name contains "bot" are ignored.
"""

import collections
import datetime
import sqlite3
import statistics
import sys

db = sqlite3.connect(f"file:{sys.argv[1]}?mode=ro&immutable=1", uri=True)


def user_field(field):
    return dict(db.execute(
        """select ru.iid, u.username from record_users ru
           join users u on u.row_id = ru.user_row
           where ru.kind = 'mr' and ru.field = ? and ru.position = 0""",
        (field,)))


author = user_field("author")
closed_by = user_field("closed_by")
mrs = {iid: (state, created) for iid, state, created in db.execute(
    """select iid, json_extract(rest, '$.state'), json_extract(rest, '$.created_at')
       from records where kind = 'mr'""")}

approvals = collections.defaultdict(list)  # iid -> [(time, user)]
comments = collections.defaultdict(list)
for iid, user, system, body, time in db.execute(
        "select iid, author, system, body, created_at from view_notes where kind = 'mr'"):
    if user is None or "bot" in user.lower() or user == author.get(iid):
        continue
    if system and body == "approved this merge request":
        approvals[iid].append((time, user))
    elif not system:
        comments[iid].append((time, user))


def days(a, b):
    p = lambda t: datetime.datetime.fromisoformat(t.replace("Z", "+00:00"))
    return (p(b) - p(a)).total_seconds() / 86400


def landed(iid):
    state = mrs[iid][0]
    return state == "merged" or (state == "closed" and closed_by.get(iid) == "marge-bot")


print("year mrs authors landed approved% commented% unreviewed% >=2reviewers% "
      "approvers approvers>=10 reviewers reviewers>=10 half-of-reviews top1% top5% "
      "median-days-to-first-review")
years = sorted({c[:4] for _, c in mrs.values() if c[:4] >= "2019"})
for year in years:
    ids = [i for i, (_, c) in mrs.items() if c[:4] == year and author.get(i) != "marge-bot"]
    land = [i for i in ids if landed(i)]
    appr = collections.Counter()
    revs = collections.Counter()
    n_appr = n_comm = n_none = n_two = 0
    first = []
    for i in land:
        a = {u for _, u in approvals[i]}
        r = a | {u for _, u in comments[i]}
        n_appr += bool(a)
        n_comm += bool(comments[i])
        n_none += not r
        n_two += len(r) >= 2
        appr.update(a)
        revs.update(r)
        events = sorted(approvals[i] + comments[i])
        if events:
            first.append(days(mrs[i][1], events[0][0]))
    total = sum(revs.values())
    acc = half = 0
    for _, v in revs.most_common():
        acc += v
        half += 1
        if acc >= total / 2:
            break
    share = lambda k: round(100 * sum(v for _, v in appr.most_common(k)) / sum(appr.values()))
    pct = lambda n: round(100 * n / len(land))
    print(year, len(ids), len({author.get(i) for i in ids}), len(land),
          pct(n_appr), pct(n_comm), pct(n_none), pct(n_two),
          len(appr), sum(v >= 10 for v in appr.values()),
          len(revs), sum(v >= 10 for v in revs.values()), half,
          share(1), share(5), round(statistics.median(first), 1))

latest = max(c for _, c in mrs.values())
cut = (datetime.datetime.fromisoformat(latest.replace("Z", "+00:00"))
       - datetime.timedelta(days=365)).isoformat()
appr, revs, unreviewed = collections.Counter(), collections.Counter(), collections.Counter()
for i, (_, c) in mrs.items():
    if c < cut or author.get(i) == "marge-bot":
        continue
    a = {u for _, u in approvals[i]}
    r = a | {u for _, u in comments[i]}
    appr.update(a)
    revs.update(r)
    if landed(i) and not r:
        unreviewed[author.get(i)] += 1
print(f"\nlast 12 months (to {latest[:10]}):")
print("  people who approved:", len(appr), "of whom >= 10 approvals:", sum(v >= 10 for v in appr.values()))
print("  most approvals:", appr.most_common(10))
print("  most MRs reviewed:", revs.most_common(10))
print("  authors of landed MRs with no review:", unreviewed.most_common(8))
