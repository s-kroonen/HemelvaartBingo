import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/ad_model.dart';

class CustomAdWidget extends StatefulWidget {
  final AdModel ad;
  final VoidCallback onComplete;

  const CustomAdWidget({super.key, required this.ad, required this.onComplete});

  @override
  State<CustomAdWidget> createState() => _CustomAdWidgetState();
}

class _CustomAdWidgetState extends State<CustomAdWidget> {
  late int _timeLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.ad.forcedWatchTime;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)),
          child: widget.ad.type == AdType.photo
              ? Image.network(widget.ad.url, fit: BoxFit.cover)
              : const Center(child: Text("Video Player Here")), // Add video_player pkg later
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _timeLeft == 0 ? widget.onComplete : null,
          child: Text(_timeLeft > 0 ? "Wait $_timeLeft..." : "Continue to Match"),
        ),
      ],
    );
  }
}