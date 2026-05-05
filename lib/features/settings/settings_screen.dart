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
                    value: user.settings.emailNotifications,
                    // Use data from backend
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
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showMatchDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text("Create or Join Match"),
                    ),
                    const SizedBox(height: 10),
                    ...filtered.map((match) {
                      final isActive = match.id == currentMatchId;
                      final isMaster = match.roleInMatch == 'master';
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isMaster)
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () =>
                                      _showMatchDialog(existingMatch: match),
                                ),
                              if (isActive)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              else
                                const Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () => _selectMatch(match.id),
                          // onLongPress: () => _confirmLeave(match.id),
                        ),
                      );
                    }).toList(),
                  ],
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

  void _showMatchDialog({MatchModel? existingMatch}) {
    final isEditing = existingMatch != null;
    final nameController = TextEditingController(text: existingMatch?.name);
    final cardSizeController = TextEditingController(
      text: existingMatch?.cardSize.toString() ?? '25',
    );
    final tokenController = TextEditingController();

    // New fields from DTO
    DateTime startDate = existingMatch?.startDate ?? DateTime.now();
    DateTime endDate =
        existingMatch?.endDate ?? DateTime.now().add(const Duration(days: 1));
    String status = existingMatch?.status ?? 'ACTIVE';
    int numbersPerEvent = existingMatch?.numbersPerEvent ?? 1;
    bool autoDist = existingMatch?.autoNumberDistribution ?? true;

    bool isCreateMode = !isEditing;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            isEditing
                ? "Edit Match"
                : (isCreateMode ? "Create Match" : "Join Match"),
          ),
          content: SingleChildScrollView(
            // Added for form length
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEditing) ...[
                  ToggleButtons(
                    isSelected: [isCreateMode, !isCreateMode],
                    onPressed: (index) =>
                        setDialogState(() => isCreateMode = index == 0),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text("Create"),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text("Join"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                if (isCreateMode || isEditing) ...[
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Match Name"),
                  ),
                  TextField(
                    controller: cardSizeController,
                    decoration: const InputDecoration(
                      labelText: "Card Size (e.g. 25)",
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  // Date Pickers
                  ListTile(
                    title: const Text("Start Date"),
                    subtitle: Text("${startDate.toLocal()}".split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null)
                        setDialogState(() => startDate = picked);
                    },
                  ),
                  ListTile(
                    title: const Text("End Date"),
                    subtitle: Text("${endDate.toLocal()}".split(' ')[0]),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null)
                        setDialogState(() => endDate = picked);
                    },
                  ),

                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: status,
                    items: ['ACTIVE', 'DRAFT', 'COMPLETED', 'CANCELLED']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setDialogState(() => status = val!),
                    decoration: const InputDecoration(labelText: "Status"),
                  ),

                  if (isEditing) ...[
                    const Divider(),
                    SwitchListTile(
                      title: const Text("Auto Distribution"),
                      value: autoDist,
                      onChanged: (v) => setDialogState(() => autoDist = v),
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "Numbers Per Event",
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => numbersPerEvent = int.tryParse(v) ?? 1,
                    ),
                  ],
                ],

                if (!isCreateMode && !isEditing)
                  TextField(
                    controller: tokenController,
                    decoration: const InputDecoration(labelText: "Join Token"),
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
              onPressed: () async {
                final service = ref.read(matchServiceProvider);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);

                try {
                  if (isEditing) {
                    await service.updateMatch(existingMatch.id, {
                      "name": nameController.text,
                      "startDate": startDate.toIso8601String(),
                      "endDate": endDate.toIso8601String(),
                      "cardSize": int.tryParse(cardSizeController.text) ?? 25,
                      "status": status,
                      "numbersPerEvent": numbersPerEvent,
                      "autoNumberDistribution": autoDist,
                    });
                  } else if (isCreateMode) {
                    await service.createMatch({
                      "name": nameController.text,
                      "startDate": startDate.toIso8601String(),
                      "endDate": endDate.toIso8601String(),
                      "cardSize": int.tryParse(cardSizeController.text) ?? 25,
                      "status": status,
                    });
                  } else {
                    // await service.joinMatch(tokenController.text);
                  }

                  // 🔥 KEY FIX: Invalidate and await the refresh
                  ref.invalidate(allMatchesProvider);
                  await ref.read(allMatchesProvider.future);

                  if (mounted) navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text("Success!")),
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text("Error: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
        "settings": {field: value},
      };

      await ref.read(userServiceProvider).updateProfile(updateData);

      // Invalidate the userProvider to fetch the fresh state from the backend
      ref.invalidate(userProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Setting updated"),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Update failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectMatch(String matchId) async {
    try {
      await ref.read(userServiceProvider).updateCurrentMatch(matchId);
      ref.invalidate(currentMatchProvider);
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
