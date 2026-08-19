// Module B 알림 화면과 상태에서 사용하는 가격 변동 알림 모델입니다.

import '../../module_a/step_01_models.dart';

// 서버의 상품 가격 변동 내역과 읽음 상태를 표현합니다.
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
