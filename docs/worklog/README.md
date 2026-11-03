# Handover

Agents report their work to the owner, never to the tracker. The owner decides what goes
into Jira (or GitLab issues later) and writes it there themselves, so the project record
stays human-written.

## Flow

1. The owner plans the sprint and creates the branch from the Jira issue (Development panel → *Create branch*).
2. The agent checks out that branch and works on that one issue only.
3. The agent leaves all changes **uncommitted** and gives the handover (below).
4. The owner verifies and tests, commits, pushes, opens the PR into `dev` and updates the issue.

## How to hand over

- **Interactive session** (Claude Code, aider, opencode): reply to the owner in the session
  using the structure of [`TEMPLATE.md`](TEMPLATE.md).
- **Headless run** (nobody to reply to): write the same template to `docs/worklog/HEM-<n>.md`
  on the issue's branch. Don't commit it. The owner reads it and deletes it; these files never
  reach git or the tracker.

## Rules

- Never post comments, status, transitions or summaries to the tracker (AGENTS.md rule 5).
- No AI watermarks, model names or signatures in the handover text (AGENTS.md rule 6).
- Be factual: what changed, how it was verified, what failed. If tests were skipped or
  failed, say so.
- Reference files by repo-relative path.
- Out-of-scope problems go under *Follow-ups*; the owner decides whether they become issues.
