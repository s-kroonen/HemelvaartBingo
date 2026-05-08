import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hemelvaartbingo/features/user/data/user_model.dart';
import '../../../../core/network/api_client.dart';
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
    final contextAsync = ref.watch(currentMatchProvider);
    final userAsync = ref.watch(userProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Game Session"), centerTitle: true),
      body: userAsync.when(
        data: (user) => contextAsync.when(
          data: (matchContext) {
            // 1. Check Role
            if (matchContext.roleInMatch == "master") {
              _startTutorial(matchContext, user);
              return _buildMasterView(context, matchContext);
            } else {
              // 2. If Player, watch the Card Provider
              final cardAsync = ref.watch(currentCardProvider);

              return cardAsync.when(
                data: (card) {
                  _startTutorial(matchContext, user);
                  final card = _isTutorial
                      ? CardModel.mock()
                      : cardAsync.value!;
                  return _buildPlayerView(matchContext, card);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) {
                  if (e is AppError) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showAppError(context, e);
                    });
                    return const SizedBox();
                  }

                  return Text("Unexpected error");
                },
              );
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.casino, size: 64),
                  const SizedBox(height: 16),
                  const Text("You're not in a match yet"),
                  const SizedBox(height: 8),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // navigate to join/create
                  //   },
                  //   child: const Text("Join or Create Match"),
                  // ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("User Error: $e")),
      ),
    );
  }

  // --- PLAYER VIEW ---
  Widget _buildPlayerView(MatchContext data, CardModel card) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // 1. The Grid takes all available top space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Showcase(
                key: _gridKey,
                description:
                    "This is your bingo card. Tap cells to mark numbers yourself—nothing is filled automatically.",
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
                description:
                    "Think you have bingo? Press this! You'll need to confirm—false calls may have consequences.",
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
                  onPressed: () =>
                      _confirmBingo(context, ref, card.id, data.match.id),
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
            child: LastCalledBar(visibilitySeconds: 10, matchId: data.match.id),
          ),
        ],
      ),
    );
  }

  // --- MASTER VIEW ---
  Widget _buildMasterView(BuildContext context, MatchContext data) {
    final eventsAsync = ref.watch(eventProvider);

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
                  onPressed: () =>
                      _openEventDialog(context, ref, data.match.id),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: eventsAsync.when(
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
                                data.match.id,
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("Events Error: $e")),
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
    builder: (context) => AlertDialog(
      title: const Text("Call Bingo?"),
      content: const Text(
        "Are you sure? A false Bingo might have consequences!",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Wait!"),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context); // Close confirm
            // Perform Call
            final result = await ref
                .read(matchServiceProvider)
                .callBingo(cardId, matchId);

            _showResultDialog(context, result);
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
  String matchId, [
  EventModel? event,
]) {
  final nameController = TextEditingController(text: event?.name ?? '');
  final descController = TextEditingController(text: event?.description ?? '');
  bool autoCall = false;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(event == null ? "Create Event" : "Edit Event"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: descController,
            decoration: const InputDecoration(labelText: "Description"),
          ),
          if (event == null)
            CheckboxListTile(
              title: const Text("Auto Call"),
              value: autoCall,
              onChanged: (v) => autoCall = v ?? false,
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            final notifier = ref.read(eventProvider.notifier);

            if (event == null) {
              notifier.createEvent({
                "name": nameController.text,
                "description": descController.text,
                "autoCall": autoCall,
              });
            } else {
              notifier.updateEvent(event.id, {
                "name": nameController.text,
                "description": descController.text,
              });
            }

            Navigator.pop(context);
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}
