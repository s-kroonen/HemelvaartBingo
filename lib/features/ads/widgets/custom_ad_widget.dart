import 'package:flutter/material.dart';
import 'package:hemelvaartbingo/core/network/api_client.dart';
import 'package:pod_player/pod_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../data/ad_model.dart';
import 'dart:async';

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

  // Keep controllers as state, not locals inside build methods
  PodPlayerController? _podController;
  YoutubePlayerController? _ytController;
  bool _podReady = false;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.ad.forcedWatchTime;
    _initMediaPlayer();
    _startTimer();
  }

  Future<void> _initMediaPlayer() async {
    if (widget.ad.type != AdType.video) return;

    final url = widget.ad.url;
    final isYoutube = url.contains("youtube.com") || url.contains("youtu.be");

    if (isYoutube) {
      final videoId = YoutubePlayerController.convertUrlToId(url);
      if (videoId == null) return;

      _ytController = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
        ),
      );
      // Trigger rebuild so YoutubePlayer gets the controller
      if (mounted) setState(() {});
    } else {
      // Raw MP4 — initialize PodPlayerController properly
      final controller = PodPlayerController(
        playVideoFrom: PlayVideoFrom.network(url),
        podPlayerConfig: const PodPlayerConfig(autoPlay: true),
      );
      await controller.initialise();
      if (mounted) {
        setState(() {
          _podController = controller;
          _podReady = true;
        });
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
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
    _podController?.dispose();
    _ytController?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 300,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildMediaContent(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _timeLeft == 0 ? widget.onComplete : null,
          style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
          child: Text(_timeLeft > 0 ? "Wait $_timeLeft..." : "Continue to App"),
        ),
      ],
    );
  }

  Widget _buildMediaContent() {
    switch (widget.ad.type) {
      case AdType.photo:
        return _buildImageWithCorsWorkaround();

      case AdType.video:
        final url = widget.ad.url;
        final isYoutube = url.contains("youtube.com") || url.contains("youtu.be");

        if (isYoutube) {
          if (_ytController == null) {
            return const Center(child: CircularProgressIndicator());
          }
          // YoutubePlayerScaffold handles the iframe embedding properly
          return YoutubePlayerScaffold(
            controller: _ytController!,
            builder: (context, player) => player,
          );
        } else {
          if (!_podReady || _podController == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return PodVideoPlayer(
            controller: _podController!,
            frameAspectRatio: 16 / 9,
          );
        }
    }
  }

  Widget _buildImageWithCorsWorkaround() {
    final proxiedUrl = _proxied(widget.ad.url);
    return Image.network(
      proxiedUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) =>
      const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 48)),
    );
  }

  /// Replace with your actual proxy endpoint, e.g.:
  /// https://yourbackend.com/proxy?url=<encoded>
  String _proxied(String originalUrl) {
    final encoded = Uri.encodeComponent(originalUrl);
    return '$apiBaseUrl/media-proxy?url=$encoded';
  }
}