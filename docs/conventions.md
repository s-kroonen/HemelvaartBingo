# Flutter code conventions

Rules for all new and changed code in this repo. Existing code that breaks them is
cleaned up under HEM-51; don't mix that cleanup into feature work.
The analyzer settings in `analysis_options.yaml` enforce part of this.

## 1. Project structure

Feature-first. Each feature owns its data, state and UI:

```
lib/features/<feature>/
  data/                 models (<name>_model.dart) and services (<name>_service.dart)
  providers/            Riverpod providers (<name>_provider.dart)
  presentation/
    pages/              full screens (<name>_page.dart)
    widgets/            pieces of screens (<name>_widget.dart or a descriptive name)
```

- Cross-feature code goes in `lib/core/` (app-wide infrastructure: router, network, storage)
  or `lib/shared/` (reusable widgets, theme, shared providers).
- A feature never imports another feature's `presentation/` folder. Share through providers or `shared/`.
- Use package imports (`package:hemelvaartbingo/...`) across features, relative imports inside a feature.

## 2. Naming

| Thing | Style | Example |
|---|---|---|
| Files and folders | `snake_case` | `match_service.dart` |
| Classes, enums, typedefs | `UpperCamelCase` | `MatchContext` |
| Variables, functions, params | `lowerCamelCase` | `currentMatchId` |
| Enum values | `lowerCamelCase` | `BingoMode.bingo75` |
| Providers | `<thing>Provider` | `currentMatchProvider` |
| Private members | leading `_` | `_loadTheme()` |

Map wire values (e.g. `"BINGO_75"`) explicitly in `fromJson`/`toJson`; don't name Dart
enum values after them.

## 3. State management (Riverpod 3)

- Allowed: `Provider`, `FutureProvider`, `StreamProvider`, `NotifierProvider`, `AsyncNotifierProvider`
  (and their `.family` variants).
- Not allowed in new code: `StateProvider`, `StateNotifierProvider`, imports from
  `package:flutter_riverpod/legacy.dart`.
- Services are created in a provider and read through it. Never `new` a service inside a widget
  or another provider body:

  ```dart
  final matchServiceProvider = Provider<MatchService>((ref) {
    return MatchService(ref.watch(dioProvider));
  });
  ```

- In `build()` use `ref.watch`; in callbacks use `ref.read`.
- Async notifier methods that change state use `AsyncValue.guard` and `await` every future
  (an un-awaited future inside `try` means the `catch` never runs).

## 4. Networking and errors

- All HTTP calls go through the Dio instance from `dioProvider` and are wrapped in `safeRequest`.
  Services return typed models, never raw `Response` or `Map`.
- Errors reaching the UI are `AppError`. Show `error.message`; never interpolate a raw exception
  (`'Error: $e'`) into user-facing text.
- Use `AsyncValueView` (`lib/shared/widgets/async_value_view.dart`) for loading/error/data states
  instead of hand-written `.when(...)` blocks where possible.
- API base URL and other environment values come from `--dart-define`, never hardcoded URLs.

## 5. Models

- Immutable: `final` fields, `const` constructors where possible, `copyWith` when state needs updating.
- `fromJson` is defensive (null-safe defaults) but doesn't silently invent data the API never sends.
- Keep models in sync with the API's DTOs; if a field doesn't exist on the API, don't add it here.

## 6. Widgets and UI

- Keep files around 300 lines max. Extract sub-widgets into their own files instead of
  long private `_build...` methods.
- Prefer `StatelessWidget`/`ConsumerWidget`; use stateful widgets only for local UI state
  (controllers, animations, timers) and dispose what you create.
- After any `await` in a widget, check `context.mounted` (or `mounted`) before using `context`.
- Colours and text styles come from `Theme.of(context)`; no hardcoded colours outside `shared/theme.dart`.
- User-facing strings: once i18n lands (HEM-30) they go in ARB files. Until then keep them in the
  widget, short and in English — the i18n story will extract them.

## 7. Platform code

Production is web-only, but Android must keep compiling. Anything that uses
`dart:js_interop`, `dart:html` or `package:web` goes behind a conditional import:

```dart
import 'pwa_update_stub.dart'
    if (dart.library.js_interop) 'pwa_update_web.dart';
```

## 8. Comments and docs

- Comments explain *why*, not *what*. Public classes and non-obvious functions get a `///` doc comment.
- No commented-out code (git has the history), no file-path header comments, no emoji markers.
- `TODO` only with an issue key: `// TODO(HEM-123): ...`.

## 9. Formatting and analysis

- `dart format` on every changed file (default 80 columns, the formatter manages trailing commas).
- `flutter analyze` must report no new issues. Fix the cause; use `// ignore:` only with a comment
  explaining why.
- `dart fix --apply` is fine for mechanical fixes, but only in files your issue touches.

## 10. Tests

- Unit tests for models (`fromJson`), services (with a mocked Dio) and notifiers.
- Widget tests for non-trivial widgets.
- Tests live in `test/` mirroring `lib/` (`test/features/match/data/match_models_test.dart`).
