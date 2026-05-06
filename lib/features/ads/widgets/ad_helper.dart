// lib/shared/utils/ad_helper.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ad_service.dart';
import 'custom_ad_widget.dart';

Future<void> showAdOverlay({
  required BuildContext context,
  required WidgetRef ref,
  required String placement,
  required VoidCallback onAdCompleted,
  bool isMandatory = true,
}) async {
  final adService = ref.read(adServiceProvider);
  final ad = await adService.fetchAd(placement);

  if (ad == null) {
    if (isMandatory) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ads currently unavailable. Try again later.")),
      );
    } else {
      onAdCompleted(); // Silent bypass for Join flow
    }
    return;
  }

  // Show Ad in a Dialog
  showDialog(
    context: context,
    barrierDismissible: false, // Force them to watch
    builder: (context) => AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
      content: CustomAdWidget(
        ad: ad,
        onComplete: () {
          Navigator.pop(context);
          onAdCompleted();
        },
      ),
    ),
  );
}