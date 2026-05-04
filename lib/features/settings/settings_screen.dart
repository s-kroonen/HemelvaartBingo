import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/theme_provider.dart';
import '../match/data/match_models.dart';
import '../match/providers/match_provider.dart';
import '../user/providers/user_provider.dart';
// lib/features/user/presentation/pages/settings_screen.dart

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String query = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final matchesAsync = ref.watch(allMatchesProvider);
    final userAsync = ref.watch(
      userProvider,
    ); // Current user profile from NestJS
    final currentMatchId = ref.watch(currentMatchIdProvider); // Just the ID

    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: userAsync.when(
        data: (user) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader("Account & Preferences"),
            Card(
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text("Email Notifications"),
                    value: user.settings.emailNotifications, // Use data from backend
                    onChanged: (val) =>
                        _updateUserField('emailNotifications', val),
                  ),
                  CheckboxListTile(
                    title: const Text("Newsletter"),
                    value: user.settings.newsletter,
                    onChanged: (val) => _updateUserField('newsletter', val),
                  ),
                  CheckboxListTile(
                    title: const Text("Tester Program"),
                    value: user.settings.testerProgram,
                    onChanged: (val) => _updateUserField('testerProgram', val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader("Appearance"),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: DropdownButtonFormField<ThemeMode>(
                  value: theme,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: "App Theme",
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text("System Default"),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text("Light Mode"),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text("Dark Mode"),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null)
                      ref.read(themeProvider.notifier).setTheme(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader("Match Selection"),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search your matches...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => query = '');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => query = v.toLowerCase()),
            ),
            const SizedBox(height: 12),
            matchesAsync.when(
              data: (matches) {
                final filtered = matches
                    .where((m) => m.name.toLowerCase().contains(query))
                    .toList();
                return Column(
                  children: filtered.map((match) {
                    final isActive = match.id == currentMatchId;
                    return Card(
                      color: isActive
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : null,
                      shape: isActive
                          ? RoundedRectangleBorder(
                              side: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            )
                          : null,
                      child: ListTile(
                        title: Text(
                          match.name,
                          style: TextStyle(
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text("Status: ${match.status}"),
                        trailing: isActive
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : const Icon(Icons.chevron_right),
                        onTap: () => _selectMatch(match.id),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error loading matches: $e")),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Profile Error: $e")),
      ),
    );
  }
// Helper method inside _SettingsScreenState
  void _showMatchDialog({MatchModel? existingMatch}) {
    final isEditing = existingMatch != null;
    final nameController = TextEditingController(text: existingMatch?.name);
    final tokenController = TextEditingController();
    bool isCreateMode = !isEditing;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? "Edit Match" : (isCreateMode ? "Create Match" : "Join Match")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEditing) ...[
                ToggleButtons(
                  isSelected: [isCreateMode, !isCreateMode],
                  onPressed: (index) => setDialogState(() => isCreateMode = index == 0),
                  children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Create")), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Join"))],
                ),
                const SizedBox(height: 16),
              ],
              if (isCreateMode || isEditing)
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Match Name")),
              if (!isCreateMode && !isEditing)
                TextField(controller: tokenController, decoration: const InputDecoration(labelText: "Join Token")),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final service = ref.read(matchServiceProvider);
                if (isEditing) {
                  await service.updateMatch(existingMatch.id, {"name": nameController.text});
                } else if (isCreateMode) {
                  await service.createMatch({"name": nameController.text});
                } else {
                  await service.joinMatch(tokenController.text);
                }
                ref.invalidate(allMatchesProvider); // REFRESH LIST INSTANTLY
                Navigator.pop(context);
              },
              child: Text(isEditing ? "Save" : "Confirm"),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // lib/features/user/presentation/pages/settings_screen.dart

  Future<void> _updateUserField(String field, bool? value) async {
    try {
      // We wrap the field inside a 'settings' map to match the backend structure
      final updateData = {
        "settings": {
          field: value,
        }
      };

      await ref.read(userServiceProvider).updateProfile(updateData);

      // Invalidate the userProvider to fetch the fresh state from the backend
      ref.invalidate(userProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Setting updated"), duration: Duration(seconds: 1)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update failed: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectMatch(String matchId) async {
    try {
      await ref.read(userServiceProvider).updateCurrentMatch(matchId);
      ref.invalidate(currentMatchIdProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Active Match Switched!")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Selection failed: $e")));
    }
  }
}
