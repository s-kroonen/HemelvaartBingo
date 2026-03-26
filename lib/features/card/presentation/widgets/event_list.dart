// lib/features/card/presentation/widgets/event_list.dart

import 'package:flutter/material.dart';

class EventList extends StatelessWidget {
  final List<int> events;

  const EventList({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final number = events[index];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: index == 0 ? Colors.orange : Colors.blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}