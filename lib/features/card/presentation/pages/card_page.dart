import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hemelvaartbingo/core/main_screen.dart';
import 'package:hemelvaartbingo/features/user/data/user_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/socket_provider.dart';
import '../../../../core/router.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../event/data/event_model.dart';
import '../../../event/providers/event_provider.dart';
import '../../../match/data/match_models.dart';
import '../../../match/providers/match_provider.dart';
import '../../../user/providers/user_provider.dart';
import '../../data/card_model.dart';
import '../../providers/card_provider.dart';
import '../widgets/bingo_grid.dart';
import '../widgets/last_called_bar.dart';
import 'package:showcaseview/showcaseview.dart';

class CardPage extends ConsumerStatefulWidget {
  const CardPage({super.key});

  @override
  ConsumerState<CardPage> createState() => _CardPageState();
}

class _CardPageState extends ConsumerState<CardPage> {
  String _searchQuery = ''; // Moved to state so UI updates when typing
  bool _isTutorial = false;
  bool _tutorialStarted = false;
  bool? _localPlayerSeen;
  bool? _localMasterSeen;
  final _gridKey = GlobalKey();
  final _bingoButtonKey = GlobalKey();
  final _lastCalledKey = GlobalKey();

  // Master
  final _masterHeaderKey = GlobalKey();
  final _createEventKey = GlobalKey();
  final _eventItemKey = GlobalKey();
  final _callButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Register the showcase view
    ShowcaseView.register(
      autoPlayDelay: const Duration(seconds: 3),
      semanticEnable: true,
      globalTooltipActionConfig: const TooltipActionConfig(
        position: TooltipActionPosition.inside,
        alignment: MainAxisAlignment.spaceBetween,
        actionGap: 20,
      ),
      globalTooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.previous,
          textStyle: const TextStyle(color: Colors.white),
          // Here we don't need previous action for the first showcase widget
          // so we hide this action for the first showcase widget
          hideActionWidgetForShowcase: [_gridKey, _masterHeaderKey],
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          textStyle: const TextStyle(color: Colors.white),
          backgroundColor: Colors.red,
          hideActionWidgetForShowcase: [_lastCalledKey, _callButtonKey],
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          textStyle: const TextStyle(color: Colors.white),
          // Here we don't need next action for the last showcase widget so we
          // hide this action for the last showcase widget
          hideActionWidgetForShowcase: [_lastCalledKey, _callButtonKey],
        ),
      ],
    );
    ShowcaseView.get().addOnFinishCallback(() async {
      await _completeTutorial();
    });

    ShowcaseView.get().addOnDismissCallback((_) async {
      await _completeTutorial();
    });
  }

  @override
  void dispose() {
    // Unregister the showcase view
    ShowcaseView.get().unregister();
    super.dispose();
  }

  void _startTutorial(MatchContext matchContext, UserModel user) {
    if (_tutorialStarted) return;

    final isMaster = matchContext.roleInMatch == "master";

    final seen = isMaster
        ? (_localMasterSeen ?? user.tutorials.masterSeen)
        : (_localPlayerSeen ?? user.tutorials.playerSeen);

    if (seen) return;

    _tutorialStarted = true;
    _isTutorial = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isMaster) {
        ShowcaseView.get().startShowCase([
          _masterHeaderKey,
          _createEventKey,
          _eventItemKey,
          _callButtonKey,
        ]);
      } else {
        ShowcaseView.get().startShowCase([
          _gridKey,
          _bingoButtonKey,
          _lastCalledKey,
        ]);
      }
    });
  }

  Future<void> _completeTutorial() async {
    if (!_isTutorial) return;

    final match = ref.read(currentMatchProvider).value;
    if (match == null) return;

    final isMaster = match.roleInMatch == "master";

    setState(() {
      _isTutorial = false;
      _tutorialStarted = false;

      if (isMaster) {
        _localMasterSeen = true;
      } else {
        _localPlayerSeen = true;
      }
    });

    try {
      await ref
          .read(userServiceProvider)
          .completeTutorial(isMaster ? "masterSeen" : "playerSeen");

      // refresh silently
      ref.invalidate(userProvider);
      // ref.invalidate(currentMatchProvider);
    } catch (e) {
      debugPrint("Failed to save tutorial state: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userProvider, (prev, next) {
      next.whenOrNull(
        error: (e, _) {
          if (e is AppError) showAppError(context, e);
        },
      );
    });

    ref.listen(currentMatchProvider, (prev, next) {
      next.whenOrNull(
        error: (e, _) {
          if (e is AppError) showAppError(context, e);
        },
      );
    });
    final userAsync = ref.watch(userProvider);
    final contextAsync = ref.watch(currentMatchProvider);
    contextAsync.whenData((matchContext) {
      if (matchContext == null) return;

      final match = matchContext.match;
      if (match == null) return;

      final socketAsync = ref.watch(socketProvider(match.id));

      socketAsync.whenData((socket) {
        socket.off('eventUpdated');

        socket.on('eventUpdated', (_) {
          ref.invalidate(eventProvider);
          ref.invalidate(latestEventProvider(match.id));
        });
      });
    });

    final router = ref.read(routerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Game Session"), centerTitle: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userProvider);
              ref.invalidate(currentMatchProvider);
              await ref.read(userProvider.future);
              final match = await ref.read(currentMatchProvider.future);
              if (match == null) throw AppError(message: "Match not found");
              if (match.roleInMatch == "master") {
                ref.invalidate(eventProvider);
                await ref.read(eventProvider.future);
              } else {
                ref.invalidate(currentCardProvider);
                await ref.read(currentCardProvider.future);
              }
            },
            child: Stack(
              children: [
                // Layer 1: Invisible scrollable area to enable Pull-to-Refresh
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                  ),
                ),

                // Layer 2: Actual Content
                AsyncValueView(
                  value: userAsync,
                  onRetry: () => ref.invalidate(userProvider),
                  data: (user) => AsyncValueView(
                    value: contextAsync,
                    onRetry: () => ref.invalidate(currentMatchProvider),
                    data: (matchContextNullable) {
                      if (user.currentMatchID == null ||
                          matchContextNullable == null) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.sports_esports_outlined,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No match selected",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "Please select a bingo match in settings.",
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    mainScreenKey.currentState?.goToTab(3);
                                  },
                                  child: const Text("Open Settings"),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final matchContext = matchContextNullable;
                      if (matchContext.roleInMatch == "master") {
                        _startTutorial(matchContext, user);
                        return _buildMasterView(context, matchContext);
                      } else {
                        final cardAsync = ref.watch(currentCardProvider);
                        return AsyncValueView(
                          value: cardAsync,
                          onRetry: () => ref.invalidate(currentCardProvider),
                          data: (card) {
                            _startTutorial(matchContext, user);
                            return _buildPlayerView(
                              matchContext,
                              _isTutorial ? CardModel.mock() : card,
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- PLAYER VIEW ---
  Widget _buildPlayerView(MatchContext? data, CardModel card) {
    if (data == null) throw AppError(message: "MatchContext not found");
    final match = data.match;
    if (match == null) throw AppError(message: "Match not found");
    return Column(
      children: [
        // 1. The Grid takes all available top space
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Showcase(
              key: _gridKey,
              description:
                  "This is your bingo card. Tap cells to mark numbers yourself.",
              child: BingoGrid(cells: card.cells),
            ),
          ),
        ),

        // 2. The "BINGO!" Button centered horizontally
        // We add some padding to give it breathing room from the grid and the bar
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Showcase(
              key: _bingoButtonKey,
              description: "Think you have bingo? Press this!",
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  elevation: 6,
                  shape: const StadiumBorder(),
                  // Makes it pill-shaped
                  shadowColor: Colors.red.withOpacity(0.5),
                ),
                onPressed: () => _confirmBingo(context, ref, card.id, match.id),
                icon: const Icon(Icons.star, color: Colors.yellow, size: 28),
                label: const Text("BINGO!"),
              ),
            ),
          ),
        ),
        // 3. The Last Called Bar pinned at the very bottom of the screen
        Showcase(
          key: _lastCalledKey,
          description:
              "Latest number appears here briefly. Want history? You can view it by watching an ad.",
          child: LastCalledBar(visibilitySeconds: 10, matchId: match.id),
        ),
      ],
    );
  }

  // --- MASTER VIEW ---
  Widget _buildMasterView(BuildContext context, MatchContext? data) {
    final eventsAsync = ref.watch(eventProvider);
    if (data == null) throw AppError(message: "MatchContext not found");
    final match = data.match;
    if (match == null) throw AppError(message: "Match not found");
    return Column(
      children: [
        Showcase(
          key: _masterHeaderKey,
          description:
              "You're the master! You control events and number calling in this match.",
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            width: double.infinity,
            color: Colors.amber.withOpacity(0.1),
            child: const Text(
              "MASTER EVENT CONTROL",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: "Search events...",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 10),
              Showcase(
                key: _createEventKey,
                description:
                    "Create events here. Enable auto-call to instantly call a number when created.",
                child: FloatingActionButton.small(
                  onPressed: () => _openEventDialog(context, ref, match),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: AsyncValueView(
            value: eventsAsync,
            onRetry: () {
              ref.invalidate(eventProvider);
            },

            data: (events) {
              final events = _isTutorial
                  ? EventModel.mockList()
                  : eventsAsync.value ?? [];
              final filtered = events
                  .where(
                    (e) => e.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
                  )
                  .toList();

              if (filtered.isEmpty) {
                return const Center(child: Text("No events found."));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final event = filtered[i];
                  final isFirst = i == 0;
                  return Showcase(
                    key: isFirst ? _eventItemKey : GlobalKey(),
                    description: isFirst
                        ? "Events define when numbers get called—for example: 'someone repeats a joke'."
                        : "",
                    child: Card(
                      child: ListTile(
                        title: Text(
                          event.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          event.called
                              ? "Called Numbers: ${event.numbers}"
                              : "Status: Waiting",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Showcase(
                              key: isFirst ? _callButtonKey : GlobalKey(),
                              description: isFirst
                                  ? "Call a number to send it to players. Recall removes it again."
                                  : "",
                              child: IconButton(
                                icon: Icon(
                                  event.called ? Icons.undo : Icons.casino,
                                  color: event.called
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                                onPressed: () => event.called
                                    ? ref
                                          .read(eventProvider.notifier)
                                          .recallEvent(event.id)
                                    : ref
                                          .read(eventProvider.notifier)
                                          .callEvent(event.id),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _openEventDialog(
                                context,
                                ref,
                                match,
                                event,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => ref
                                  .read(eventProvider.notifier)
                                  .deleteEvent(event.id),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

void _confirmBingo(
  BuildContext context,
  WidgetRef ref,
  String cardId,
  String matchId,
) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text("Call Bingo?"),
      content: const Text(
        "Are you sure? A false Bingo might have consequences!",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text("Wait!"),
        ),
        ElevatedButton(
          onPressed: () async {
            // 1. Close the confirmation dialog using its own context
            Navigator.pop(dialogContext);

            try {
              // 2. Perform the network call
              final result = await ref
                  .read(matchServiceProvider)
                  .callBingo(cardId, matchId);

              // 3. IMPORTANT: Check if the CardPage is still visible/mounted
              // before trying to show the result dialog.
              if (!context.mounted) return;

              _showResultDialog(context, result);
            } catch (e) {
              // Handle potential errors from the bingo call itself
              if (context.mounted && e is AppError) {
                showAppError(context, e);
              }
            }
          },
          child: const Text("YES, BINGO!"),
        ),
      ],
    ),
  );
}

void _showResultDialog(BuildContext context, BingoResultDto result) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      // Make it slightly transparent to see the camping/party background
      backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Icon Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: result.isValid
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              result.isValid ? Icons.stars : Icons.warning_amber_rounded,
              size: 64,
              color: result.isValid ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 24),

          // 2. The Message
          Text(
            result.isValid ? "BINGO!" : "FALSE ALARM",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: result.isValid ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            result.message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),

          // 3. The Prize (if valid)
          if (result.isValid && result.prize != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.card_giftcard, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Prize: ${result.prize}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: result.isValid
                  ? Colors.green
                  : theme.disabledColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(result.isValid ? "AWESOME!" : "BACK TO CARD"),
          ),
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
}

void _openEventDialog(
  BuildContext context,
  WidgetRef ref,
  MatchModel match, [
  EventModel? event,
]) {
  final nameController = TextEditingController(text: event?.name ?? '');
  final descController = TextEditingController(text: event?.description ?? '');
  final manualNumbersController = TextEditingController(
    text: (event?.manualNumbers ?? []).isNotEmpty
        ? (event!.manualNumbers!.join(', '))
        : '',
  );

  // Local dialog state
  bool autoCall = false;
  final maxNumber = match.mode == BingoMode.BINGO_90 ? 90 : 75;
  String? nameError;
  String? numbersError;
  final isCalled = event?.called ?? false;
  final isCreating = event == null;

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setDialogState) {
        // Validate numbers field
        List<int> _parseNumbers() {
          final text = manualNumbersController.text.trim();
          if (text.isEmpty) return [];
          return text
              .split(',')
              .map((s) => int.tryParse(s.trim()))
              .whereType<int>()
              .toList();
        }

        bool _validateNumbers() {
          final text = manualNumbersController.text.trim();
          if (text.isEmpty) return true;
          final parts = text.split(',');
          for (final part in parts) {
            final n = int.tryParse(part.trim());
            if (n == null) return false;
            if (n < 1 || n > maxNumber) return false; // ← uses match mode
          }
          return true;
        }

        return AlertDialog(
          title: Text(isCreating ? "Create Event" : "Edit Event"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name — required
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Name *",
                    errorText: nameError,
                  ),
                  onChanged: (_) {
                    if (nameError != null) {
                      setDialogState(() => nameError = null);
                    }
                  },
                ),
                const SizedBox(height: 8),

                // Description — optional
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                const SizedBox(height: 12),

                // Auto call — only on create
                if (isCreating)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Auto Call"),
                    subtitle: const Text(
                      "Numbers will be assigned immediately on creation",
                      style: TextStyle(fontSize: 11),
                    ),
                    value: autoCall,
                    onChanged: (v) =>
                        setDialogState(() => autoCall = v ?? false),
                  ),

                const SizedBox(height: 8),

                // Manual numbers — always shown, grayed out if called
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Manual Numbers",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isCalled ? Colors.black12 : null,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Badge showing called state
                        if (isCalled)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "Event already called",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: manualNumbersController,
                      enabled: !isCalled,
                      // grayed out if called
                      decoration: InputDecoration(
                        hintText: isCalled
                            ? "Cannot edit after calling"
                            : "e.g. 5, 12, 34  (1–$maxNumber, optional)",
                        errorText: numbersError,
                        filled: isCalled,
                        fillColor: isCalled ? Colors.black12 : null,
                        helperText: isCalled
                            ? "Recall the event first to change numbers"
                            : "Leave empty to use random numbers",
                        helperStyle: TextStyle(
                          color: isCalled ? Colors.orange : Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (_) {
                        if (numbersError != null) {
                          setDialogState(() => numbersError = null);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Validate name
                if (nameController.text.trim().isEmpty) {
                  setDialogState(() => nameError = "Name is required");
                  return;
                }

                // Validate numbers
                if (!_validateNumbers()) {
                  setDialogState(
                    () => numbersError =
                        "Enter valid numbers between 1–$maxNumber, separated by commas",
                  );
                  return;
                }

                final manualNumbers = _parseNumbers();
                final notifier = ref.read(eventProvider.notifier);

                try {
                  if (isCreating) {
                    notifier.createEvent({
                      "name": nameController.text.trim(),
                      "description": descController.text.trim(),
                      "autoCall": autoCall,
                      if (manualNumbers.isNotEmpty)
                        "manualNumbers": manualNumbers,
                    });
                  } else {
                    notifier.updateEvent(event!.id, {
                      "name": nameController.text.trim(),
                      "description": descController.text.trim(),
                      // Send null explicitly to clear if field was emptied
                      "manualNumbers": manualNumbers.isNotEmpty
                          ? manualNumbers
                          : null,
                    });
                  }
                } catch (e) {
                  if (context.mounted && e is AppError) {
                    showAppError(context, e);
                  }
                }

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    ),
  );
}
