// lib/features/ads/models/ad_model.dart
enum AdType { photo, video }

class AdModel {
  final AdType type;
  final String url;
  final int forcedWatchTime; // in seconds

  AdModel({required this.type, required this.url, required this.forcedWatchTime});

  factory AdModel.fromJson(Map<String, dynamic> json) => AdModel(
    type: json['type'] == 'video' ? AdType.video : AdType.photo,
    url: json['url'],
    forcedWatchTime: json['forcedWatchTime'] ?? 5,
  );
}