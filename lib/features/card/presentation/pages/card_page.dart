// lib/features/card/presentation/pages/card_page.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../event/data/event_model.dart';
import '../../../event/providers/event_provider.dart';
import '../../../match/data/match_models.dart';
import '../../../match/providers/match_provider.dart';
import '../widgets/bingo_grid.dart';
import '../widgets/last_called_bar.dart';

class CardPage extends ConsumerWidget {
  const CardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextAsync = ref.watch(currentMatchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Game Session")),
      body: contextAsync.when(
        data: (data) {
          // ROLE-BASED UI
          if (data.roleInMatch == "master") {
            return _buildMasterView(context, data, ref);
          } else {
            return _buildPlayerView(data, ref);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) {
          if (kDebugMode) {
            print(e);
            print(stack);
          }

          return Center(child: Text("Error: $e"));
        },
      ),
    );
  }

  Widget _buildMasterView(BuildContext context, MatchContext data, WidgetRef ref) {
    final matchId = data.match.id; // ⚠️ make sure match is typed!

    final eventsAsync = ref.watch(eventProvider);
    String query = '';

    return Column(
      children: [
        const Text(
          "MASTER EVENT CONTROL",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        // ➕ CREATE BUTTON
        ElevatedButton(
          onPressed: () => _openEventDialog(context, ref, matchId),
          child: const Text("Create Event"),
        ),

        // 🔍 SEARCH
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: "Search events",
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => query = v,
          ),
        ),

        // 📋 LIST
        Expanded(
          child: eventsAsync.when(
            data: (events) {
              final filtered = events
                  .where(
                    (e) => e.name.toLowerCase().contains(query.toLowerCase()),
                  )
                  .toList();

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final event = filtered[i];

                  return ListTile(
                    title: Text(event.name),
                    subtitle: Text(
                      event.called ? "CALLED: ${event.numbers}" : "Not called",
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🎯 CALL / RECALL
                        IconButton(
                          icon: Icon(event.called ? Icons.undo : Icons.casino),
                          onPressed: () {
                            if (event.called) {
                              ref
                                  .read(eventProvider.notifier)
                                  .recallEvent(event.id);
                            } else {
                              ref
                                  .read(eventProvider.notifier)
                                  .callEvent(event.id);
                            }
                          },
                        ),

                        // ✏️ EDIT
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _openEventDialog(context, ref, matchId, event),
                        ),

                        // 🗑 DELETE
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            ref
                                .read(eventProvider.notifier)
                                .deleteEvent(event.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text("Error: $e"),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerView(MatchContext data, WidgetRef ref) {
    final cells = data.cells;

    if (cells == null) {
      return const Center(child: Text("No card available for this match"));
    }

    return Column(
      children: [
        LastCalledBar(calledNumbers: data.match.calledNumbers),
        Expanded(child: BingoGrid(cells: cells)),
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