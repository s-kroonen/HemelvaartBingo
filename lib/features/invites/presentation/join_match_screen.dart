// lib/features/invites/presentation/pages/join_match_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ads/models/ad_model.dart';
import '../../ads/widgets/custom_ad_widget.dart';
import '../providers/invite_provider.dart';

// lib/features/invites/presentation/pages/join_match_screen.dart
class JoinMatchScreen extends ConsumerStatefulWidget {
  final String token;
  const JoinMatchScreen({super.key, required this.token});

  @override
  ConsumerState<JoinMatchScreen> createState() => _JoinMatchScreenState();
}

class _JoinMatchScreenState extends ConsumerState<JoinMatchScreen> {
  bool adCompleted = false;

  @override
  Widget build(BuildContext context) {
    final inviteAsync = ref.watch(inviteMetadataProvider(widget.token));

    return Scaffold(
      appBar: AppBar(title: const Text("Join Match")),
      body: inviteAsync.when(
        data: (invite) {
          final needsAd = invite.metadata.watchAdBeforeJoin ?? false && !adCompleted;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("You've been invited to ${invite.name}!", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                if (needsAd)
                  CustomAdWidget(
                    ad: AdModel(type: AdType.photo, url: "https://placehold.co/600x400", forcedWatchTime: 5),
                    onComplete: () => setState(() => adCompleted = true),
                  )
                else
                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(inviteServiceProvider).joinMatch(widget.token);
                      // Clear token and navigate home
                      ref.read(pendingInviteTokenProvider.notifier).state = null;
                    },
                    child: const Text("Join Now"),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(child: Text("Invite expired or invalid.")),
      ),
    );
  }
}