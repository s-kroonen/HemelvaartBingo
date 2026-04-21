import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/theme_provider.dart';
import '../match/providers/match_provider.dart';
import '../user/providers/user_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String query = '';
  bool notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final matchesAsync = ref.watch(allMatchesProvider); // Fetch via API
    final theme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Column(
        children: [
          // 1. App Settings Section
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: theme == ThemeMode.dark,
            onChanged: (val) {
              ref.read(themeProvider.notifier)
                  .setTheme(val ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          SwitchListTile(
            title: const Text("Notifications"),
            value: notificationsEnabled,
            onChanged: (val) async {
              // Use permission_handler package here to check/request
              setState(() => notificationsEnabled = val);
            },
          ),
          const Divider(),
          // 2. Match Selection Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(hintText: "Search Matches", prefixIcon: Icon(Icons.search)),
              onChanged: (v) => setState(() => query = v),
            ),
          ),
          Expanded(
            child: matchesAsync.when(
              data: (matches) {
                final list = matches.where((m) => m.name.contains(query)).toList();
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, i) => ListTile(
                    title: Text(list[i].name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await ref.read(userServiceProvider).updateCurrentMatch(list[i].id);
                      ref.invalidate(currentMatchProvider); // Refresh data
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Match Updated!")));
                    },
                  ),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text("Error: $e"),
            ),
          ),
        ],
      ),
    );
  }
}