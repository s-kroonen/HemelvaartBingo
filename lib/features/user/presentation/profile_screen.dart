// lib/features/user/presentation/pages/profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../award/award_model.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (user) => Scaffold(
        body: CustomScrollView(
          slivers: [
            const SliverAppBar(expandedHeight: 120, title: Text("Player Profile"), floating: true),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                  Text(user.username, style: Theme.of(context).textTheme.headlineMedium),
                  _buildScoreCard(user.score),
                  const Divider(),
                  const Text("🏆 Trophy Room", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  _buildAwardsGrid(user.awards),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () => _showDeleteDialog(context, ref),
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text("Delete Account", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text(e.toString())),
    );
  }

  Widget _buildScoreCard(int score) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.orange, Colors.deepOrange]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("TOTAL SCORE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text("$score PTS", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAwardsGrid(List<AwardModel> awards) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemCount: awards.length,
      itemBuilder: (context, index) {
        final award = awards[index];
        return Column(
          children: [
            const Icon(Icons.emoji_events, size: 40, color: Colors.amber), // Replace with specific icons based on AwardType
            Text(award.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
          ],
        );
      },
    );
  }
}
// lib/features/user/presentation/pages/profile_screen.dart (Helper Method)
void _showDeleteDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Delete Account?"),
      content: const Text("This is permanent. All your awards and scores will be deleted from our servers."),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            try {
              // 1. Call Backend first (important!)
              await ref.read(userServiceProvider).deleteAccount();
              // 2. Delete from Firebase
              await FirebaseAuth.instance.currentUser?.delete();
              if (context.mounted) Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: Re-login required to delete account.")),
              );
            }
          },
          child: const Text("Delete Everything", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}