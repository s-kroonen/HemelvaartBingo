// lib/features/invites/presentation/pages/join_match_screen.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ads/data/ad_model.dart';
import '../../ads/widgets/custom_ad_widget.dart';
import '../providers/invite_provider.dart';

class JoinMatchScreen extends ConsumerStatefulWidget {
  final String token;

  const JoinMatchScreen({super.key, required this.token});

  @override
  ConsumerState<JoinMatchScreen> createState() => _JoinMatchScreenState();
}

class _JoinMatchScreenState extends ConsumerState<JoinMatchScreen> {
  bool adCompleted = false;
  bool isJoining = false;

  @override
  Widget build(BuildContext context) {
    final inviteAsync = ref.watch(inviteMetadataProvider(widget.token));

    return Scaffold(
      appBar: AppBar(title: const Text("Join Match")),
      body: inviteAsync.when(
        data: (invite) {
          final needsAd = invite.metadata.watchAdBeforeJoin && !adCompleted;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "You've been invited to ${invite.name}!",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                if (needsAd)
                  CustomAdWidget(
                    ad: AdModel(
                      type: AdType.photo,
                      url: "https://placehold.co/600x400",
                      forcedWatchTime: 5,
                    ),
                    onComplete: () => setState(() => adCompleted = true),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: isJoining ? null : _handleJoin,
                      child: isJoining
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Accept Invite & Join Now",
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
              ],
            ),
          );
        },

        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) {
          // 1. Log to console for the developer
          debugPrint("❌ Invite Fetch Error: $err");
          debugPrint("Stacktrace: $stack");

          String displayMessage = "Something went wrong.";

          // 2. Extract NestJS error message if it's a Dio error
          if (err is DioException) {
            // Check if backend returned a JSON error (e.g., { "message": "..." })
            final backendMessage = err.response?.data?['message'];
            if (backendMessage != null) {
              displayMessage = backendMessage.toString();
            } else {
              displayMessage = "Network error: ${err.type.name}";
            }
          } else {
            displayMessage = err.toString();
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    "Oops!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        ref.invalidate(inviteMetadataProvider(widget.token)),
                    child: const Text("Try Again"),
                  ),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Text("Go Home"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  Future<void> _handleJoin() async {
    setState(() => isJoining = true);
    try {
      await ref.read(inviteServiceProvider).joinMatch(widget.token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully joined the match!")),
        );
        ref.read(pendingInviteTokenProvider.notifier).state = null;
        context.go('/'); // Redirect home
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to join: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isJoining = false);
    }
  }
}
