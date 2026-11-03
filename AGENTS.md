# AGENTS.md — Hemelvaart Bingo app (Flutter)

These are the hard rules for changing this repository. They apply to everyone:
humans, Claude Code, and local models (Ollama via aider, opencode, etc.).
Read this whole file before you change anything.

## 1. Context

- **This repo:** the Flutter app. Production is **Flutter web (PWA)** only.
  Android builds must keep compiling but are not published; iOS is not set up.
- **Sibling repo:** `hemelvaartBingo-node` holds the NestJS API (`backend/`) and
  the React website for users, masters and admins (`frontend/`).
- **How the app talks to the backend:** REST under `/api/v1` (Dio, `lib/core/network/api_client.dart`),
  socket.io for live match updates, Firebase Auth for login and FCM for push.
- **Work tracker:** Jira project **HEM** — https://avansprojects.atlassian.net/browse/HEM.
  Work is planned in weekly sprints by the owner.
  It will move to self-hosted GitLab issues later; the rules stay the same.

## 2. Hard rules

The project record (Jira, git history, PRs, docs) must read as human work that AI assisted
with, never as AI-built or AI-controlled. Rules 2–6 exist for that reason.

1. **No work without an issue.** Every change belongs to exactly one HEM issue.
   If there is none, stop and ask for one. Agents with tracker access may create it.
   - **Story** for anything a user, master or admin notices in the app or API:
     `As a <role> I want <goal> so that <reason>` plus Given/When/Then acceptance criteria.
   - **Task** for tooling, CI/CD, docs, infrastructure and refactors without behaviour change.
   - **Bug** for defects. Link it ("relates to") to the story it breaks.
   - **Epic** only groups issues; never work directly on an epic.
2. **No branch, no work.** The owner plans weekly sprints and creates the branch for an issue
   from Jira (Development panel → *Create branch*, based on `dev`), named `HEM-<n>-<Summary-slug>`.
   Agents only work on issues that already have a branch: `git fetch && git checkout HEM-<n>-...`.
   Never create branches yourself. If there is no branch, stop and ask the owner.
   - Agents with tracker access always read the issue (description and acceptance criteria) first.
   - Agents without tracker access take the issue key and summary from the branch name and ask
     the owner for the acceptance criteria if they aren't given.
3. **Humans own git and PRs.** Agents never commit, push, merge, or open, approve or comment on PRs.
   Leave your changes uncommitted. The owner verifies, tests, commits (`HEM-<n>: <imperative summary>`),
   pushes and opens the PR into `dev`. Never run history- or work-destroying git commands
   (`reset --hard`, `clean`, `checkout -- <file>` on changes you didn't make, force anything).
4. **One issue at a time.** The working tree only contains changes for the issue of the
   checked-out branch. Don't start another issue until the owner has committed your work
   or tells you to continue. `main` only receives release merges from `dev`.
5. **Agents only create issues in the tracker.** Creating a Story, Task or Bug is allowed.
   Everything else — comments, status transitions, sprint changes, field or description edits,
   links, work logs — happens only when the owner explicitly asks, and then the text is exactly
   what the owner said, word for word. Never post progress, status or summaries to the tracker.
6. **No AI watermarks anywhere.** No `Co-Authored-By` AI trailers, "Generated with …", model or
   tool names, signatures or robot emoji in issues, commit messages, PR text, code, comments or docs.
7. **Docs and ADRs are written by the owner.** Don't write or rewrite docs (`docs/`, READMEs, ADRs,
   this file) unless the issue explicitly asks for it. Treat them as the source of truth: if code,
   an issue or a request contradicts a doc, stop and ask instead of choosing one yourself.
8. **Stay in scope.** Only change what the issue needs. If you find another problem,
   mention it in your handover and ask for a new issue — don't fix it on the side.
9. **No secrets in git.** Never commit `.env`, service-account JSON, tokens or keystores.
   (`lib/firebase_options.dart` and `google-services.json` are public client config and are allowed.)
10. **English** for code, comments, commits and issues.
    User-facing text must be translatable (NL + EN) once i18n lands (HEM-30).
11. **API contract changes need the API side too.** If the app needs a new or changed endpoint,
    the backend change is done under a linked issue in `hemelvaartBingo-node`,
    following its REST conventions. Don't work around a missing endpoint in the app.
12. **Don't guess.** If the issue or acceptance criteria are unclear, ask before building.

## 3. Setup and commands

```bash
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1
dart format lib test integration_test     # format
flutter analyze                           # static analysis
flutter test                              # unit/widget tests
flutter build web --release --dart-define=API_BASE_URL=<api url>
docker compose up --build                 # nginx image, reads API_BASE_URL from .env
```

`API_BASE_URL` is a compile-time `--dart-define`; without it the app falls back to the production API.
Point it at a local or dev API while developing.

## 4. Definition of Done

An issue is done only when all of these are true:

- [ ] Every acceptance criterion of the issue is met.
- [ ] `dart format` leaves your changed files unchanged.
- [ ] `flutter analyze` reports **no new issues**, and no errors or warnings in files you touched.
- [ ] New or changed logic has tests; `flutter test` passes.
- [ ] `flutter build web` succeeds.
- [ ] The handover is given to the owner (section 5).

Then stop. The owner verifies, tests, commits, opens the PR and moves the issue in Jira.

## 5. Handover

Report to the owner, not to the tracker. Details and the template:
[`docs/worklog/README.md`](docs/worklog/README.md).

- **In an interactive session** (Claude Code, aider, opencode): give the handover in the
  session, using the structure of `docs/worklog/TEMPLATE.md`.
- **In a headless run** (no session to reply to): write it to `docs/worklog/HEM-<n>.md`
  on the branch, uncommitted. The owner reads it and deletes it; it never reaches git or the tracker.
- The owner decides what goes into Jira and writes it there themselves.

## 6. Code conventions (summary)

Full rules: [`docs/conventions.md`](docs/conventions.md). The most important ones:

- Feature-first layout: `lib/features/<feature>/{data,providers,presentation/{pages,widgets}}`.
- File names in `snake_case.dart`; one public widget or class per file.
- Riverpod 3 `Notifier` / `AsyncNotifier` / `Provider` / `FutureProvider` only — no legacy
  `StateNotifier` / `StateProvider` in new code. Services are always obtained through providers.
- All HTTP goes through the shared Dio client and `safeRequest`; show users `AppError.message`,
  never raw exceptions.
- Keep widget files around 300 lines max; extract widgets instead.
- Comments explain *why*. No commented-out code, no file-path header comments.
- Web-only APIs (`dart:js_interop`, `package:web`) only behind conditional imports, so mobile builds keep compiling.

## 7. Project map

```
lib/
  main.dart              app entry, deep links, theme
  core/                  router, main screen, network (api client, socket)
  features/<feature>/    auth, user, match, card, event, invites, ads, settings, award
  shared/                theme, shared providers and widgets
  services/              cross-feature services (notifications)
integration_test/        screenshot test
docs/                    conventions, work logs, decision docs
```

## 8. Tool notes

- **Claude Code** loads this file through `CLAUDE.md`.
- **opencode / Codex-style tools** read `AGENTS.md` automatically.
- **aider:** start with `aider --read AGENTS.md --read docs/conventions.md`.
- Local models without tracker access get their issue context from the branch name (rule 2).
- Keep tool attribution off: no co-author trailers or "generated by" footers (rule 6).
