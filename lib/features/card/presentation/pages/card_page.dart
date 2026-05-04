import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../event/data/event_model.dart';
import '../../../event/providers/event_provider.dart';
import '../../../match/data/match_models.dart';
import '../../../match/providers/match_provider.dart';
import '../../data/card_model.dart';
import '../../providers/card_provider.dart';
import '../widgets/bingo_grid.dart';
import '../widgets/last_called_bar.dart';

class CardPage extends ConsumerStatefulWidget {
  const CardPage({super.key});

  @override
  ConsumerState<CardPage> createState() => _CardPageState();
}

class _CardPageState extends ConsumerState<CardPage> {
  String _searchQuery = ''; // Moved to state so UI updates when typing

  @override
  Widget build(BuildContext context) {
    final contextAsync = ref.watch(currentMatchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Game Session"), centerTitle: true),
      body: contextAsync.when(
        data: (matchContext) {
          // 1. Check Role
          if (matchContext.roleInMatch == "master") {
            return _buildMasterView(context, matchContext);
          } else {
            // 2. If Player, watch the Card Provider
            final cardAsync = ref.watch(currentCardProvider);

            return cardAsync.when(
              data: (card) => _buildPlayerView(matchContext, card),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Card Error: $e")),
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Match Error: $e")),
      ),
    );
  }

  // --- PLAYER VIEW ---
  Widget _buildPlayerView(MatchContext data, CardModel card) {
    return Column(
      children: [
        LastCalledBar(calledNumbers: data.match.calledNumbers),
        Expanded(child: BingoGrid(cells: card.cells)),
      ],
    );
  }

  // --- MASTER VIEW ---
  Widget _buildMasterView(BuildContext context, MatchContext data) {
    final eventsAsync = ref.watch(eventProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          width: double.infinity,
          color: Colors.amber.withOpacity(0.1),
          child: const Text(
            "MASTER EVENT CONTROL",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
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
              FloatingActionButton.small(
                onPressed: () => _openEventDialog(context, ref, data.match.id),
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),

        Expanded(
          child: eventsAsync.when(
            data: (events) {
              final filtered = events
                  .where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();

              if (filtered.isEmpty) {
                return const Center(child: Text("No events found."));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final event = filtered[i];
                  return Card(
                    child: ListTile(
                      title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(event.called ? "Called Numbers: ${event.numbers}" : "Status: Waiting"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(event.called ? Icons.undo : Icons.casino,
                                color: event.called ? Colors.orange : Colors.green),
                            onPressed: () => event.called
                                ? ref.read(eventProvider.notifier).recallEvent(event.id)
                                : ref.read(eventProvider.notifier).callEvent(event.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _openEventDialog(context, ref, data.match.id, event),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => ref.read(eventProvider.notifier).deleteEvent(event.id),
                          ),
                        ],
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
          TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
          TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
          if (event == null)
            CheckboxListTile(
              title: const Text("Auto Call"),
              value: autoCall,
              onChanged: (v) => autoCall = v ?? false,
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            final notifier = ref.read(eventProvider.notifier);

            if (event == null) {
              await notifier.createEvent({
                "name": nameController.text,
                "description": descController.text,
                "autoCall": autoCall,
              });
            } else {
              await notifier.updateEvent(event.id, {
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