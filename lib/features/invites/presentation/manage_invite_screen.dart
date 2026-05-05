import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../match/providers/match_provider.dart';
import '../data/invite_model.dart'; // For Clipboard

class ManageInvitesScreen extends ConsumerWidget {
  final String matchId;

  const ManageInvitesScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitesAsync = ref.watch(matchInvitesProvider(matchId));

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Invites")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInviteDialog(context, ref, matchId),
        child: const Icon(Icons.add),
      ),
      body: invitesAsync.when(
        data: (invites) => ListView.builder(
          itemCount: invites.length,
          itemBuilder: (context, i) {
            final invite = invites[i];
            final fullUrl = "http://bingoapp.kroon-en.nl/join/${invite.token}";

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(invite.name),
                subtitle: Text(
                  "Role: ${invite.metadata.joinAsRole} • Active: ${invite.isActive}",
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: fullUrl));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Link copied to clipboard!"),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _showInviteDialog(context, ref, matchId, invite),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }

  void _showInviteDialog(
    BuildContext context,
    WidgetRef ref,
    String matchId, [
    InviteModel? invite,
  ]) {
    final isEditing = invite != null;

    // Controllers
    final nameController = TextEditingController(text: invite?.name);
    final descController = TextEditingController(
      text: invite?.metadata.description,
    );

    // Local State for Dialog
    DateTime expiresAt =
        invite?.expiresAt ?? DateTime.now().add(const Duration(days: 7));
    bool isActive = invite?.isActive ?? true;
    bool watchAd = invite?.metadata.watchAdBeforeJoin ?? false;
    String joinAsRole = invite?.metadata.joinAsRole ?? 'user';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? "Edit Invite" : "Create New Invite"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Invite Name (e.g. 'Social Media')",
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: "Description (Optional)",
                  ),
                ),

                const Divider(height: 32),

                // Metadata Settings
                DropdownButtonFormField<String>(
                  value: joinAsRole,
                  decoration: const InputDecoration(labelText: "Join As Role"),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text("Player")),
                    DropdownMenuItem(value: 'master', child: Text("Co-Master")),
                  ],
                  onChanged: (val) => setDialogState(() => joinAsRole = val!),
                ),

                SwitchListTile(
                  title: const Text("Active"),
                  subtitle: const Text("Can people use this link?"),
                  value: isActive,
                  onChanged: (v) => setDialogState(() => isActive = v),
                ),

                SwitchListTile(
                  title: const Text("Watch Ad"),
                  subtitle: const Text("Requirement for Web users"),
                  value: watchAd,
                  onChanged: (v) => setDialogState(() => watchAd = v),
                ),

                ListTile(
                  title: const Text("Expires At"),
                  subtitle: Text("${expiresAt.toLocal()}".split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: expiresAt,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null)
                      setDialogState(() => expiresAt = picked);
                  },
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

                // Construct the Metadata object
                final metadata = {
                  "watchAdBeforeJoin": watchAd,
                  "joinAsRole": joinAsRole,
                  "description": descController.text,
                };

                try {
                  if (isEditing) {
                    await service.updateInvite(matchId, invite.id, {
                      "name": nameController.text,
                      "isActive": isActive,
                      "expiresAt": expiresAt.toIso8601String(),
                      "metadata": metadata,
                    });
                  } else {
                    await service.createInvite(matchId, {
                      "matchId": matchId,
                      // Explicitly linked to this match
                      "name": nameController.text,
                      "metadata": metadata,
                      "expiresAt": expiresAt.toIso8601String(),
                    });
                  }

                  // Refresh the specific list for this match
                  ref.invalidate(matchInvitesProvider(matchId));

                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text("Invite Saved!")),
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
              child: Text(isEditing ? "Save Changes" : "Create Invite"),
            ),
          ],
        ),
      ),
    );
  }
}
