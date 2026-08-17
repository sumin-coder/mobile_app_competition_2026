import '../module_a/models.dart';

class PriceNotification {
  PriceNotification({
    required this.id,
    required this.productId,
    required this.albumName,
    required this.artist,
    required this.albumImage,
    required this.previousPrice,
    required this.currentPrice,
    required this.isRead,
    required this.createdAt,
  });

  final int id, productId, previousPrice, currentPrice;
  final String albumName, artist, albumImage;
  bool isRead;
  final DateTime createdAt;

  factory PriceNotification.fromJson(
    Map<String, dynamic> json, {
    Uri? baseUri,
  }) => PriceNotification(
    id: jsonInt(json['id']),
    productId: jsonInt(json['productId']),
    albumName: jsonText(json['albumName']),
    artist: jsonText(json['artist']),
    albumImage: resolveImage(json['albumImage'], baseUri),
    previousPrice: jsonInt(json['previousPrice']),
    currentPrice: jsonInt(json['currentPrice']),
    isRead: json['isRead'] as bool? ?? false,
    createdAt: jsonDate(json['createdAt']),
  );
}
