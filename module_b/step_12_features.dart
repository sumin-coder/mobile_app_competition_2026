// Module B 기능을 Module A의 확장 지점에 연결하는 어댑터입니다.

import 'step_07_ui.dart';
import 'step_08_recommendation.dart';
import 'step_10_notifications.dart';
import 'step_11_barcode.dart';

/// Connects Module B features to Module A's extension points.
/// Module A remains fully usable without constructing this object.
ModuleAFeatures moduleBFeatures() => ModuleAFeatures(
  notificationCount: (context) => context.moduleB.unreadCount,
  openNotifications: (context) => context.openPage(const NotificationScreen()),
  openScanner: openBarcodeSearch,
  recommendationBuilder: (_, products) => Recommendation(products),
  productCardBuilder: (context, product, onTap, width) => MarketCard(
    context.moduleB,
    product,
    onTap,
    width: width,
  ),
  productDetailActionsBuilder: moduleBProductDetailActions,
);
