import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ads/widgets/ad_helper.dart';
import '../../../event/data/event_model.dart';
import '../../../event/providers/event_provider.dart';

class LastCalledBar extends ConsumerStatefulWidget {
  final String matchId;
  final int visibilitySeconds;

  const LastCalledBar({super.key, required this.matchId, required this.visibilitySeconds});

  @override
  ConsumerState<LastCalledBar> createState() => _LastCalledBarState();
}

class _LastCalledBarState extends ConsumerState<LastCalledBar> {
  bool _isVisible = true;
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    final latestEventAsync = ref.watch(latestEventProvider(widget.matchId));

    // Listen for changes to trigger the timer
    ref.listen(latestEventProvider(widget.matchId), (prev, next) {
      if (next.hasValue && next.value != null) {
        setState(() => _isVisible = true);
        _timer?.cancel();
        _timer = Timer(Duration(seconds: widget.visibilitySeconds), () {
          if (mounted) setState(() => _isVisible = false);
        });
      }
    });

    return latestEventAsync.when(
      data: (event) {
        if (event == null || !_isVisible) {
          return _buildCollapsedBar(context);
        }
        return _buildActiveEventBar(context, event);
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => _buildCollapsedBar(context),
    );
  }

  Widget _buildActiveEventBar(BuildContext context, EventModel event) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withAlpha(230),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("CURRENT CALL", style: theme.textTheme.labelSmall),
                Text(event.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                if (event.description != null)
                  Text(event.description!, style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                // Show the numbers associated with this event (e.g. [12, 44])
                Wrap(
                  spacing: 8,
                  children: event.numbers.map((n) => Chip(label: Text("$n"), visualDensity: VisualDensity.compact)).toList(),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: () => _handleShowHistory(context),
            icon: const Icon(Icons.history),
          )
        ],
      ),
    );
  }

  Widget _buildCollapsedBar(BuildContext context) {
    return InkWell(
      onTap: () => _handleShowHistory(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Tap to view call history...", style: TextStyle(fontStyle: FontStyle.italic)),
            Icon(Icons.history, size: 20),
          ],
        ),
      ),
    );
  }

  void _handleShowHistory(BuildContext context) async {
    await showAdOverlay(
      context: context,
      ref: ref,
      placement: 'history',
      onAdCompleted: () async {
        // 1. Fetch History
        final history = await ref.read(eventServiceProvider).getEventHistory(widget.matchId);
        // 2. Open Bottom Sheet
        if (context.mounted) _showHistorySheet(context, history);
      },
    );
  }
  void _showHistorySheet(BuildContext context, List<EventModel> history) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Allow themed background to show
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Match History", style: theme.textTheme.headlineSmall),
            ),
            Expanded(
              child: history.isEmpty
                  ? const Center(child: Text("No numbers called yet!"))
                  : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final event = history[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text("${history.length - index}"), // Call count
                    ),
                    title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(event.description ?? "No details provided"),
                    trailing: Text(
                      event.numbers.join(", "),
                      style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}