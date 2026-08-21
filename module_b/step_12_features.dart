import 'step_07_ui.dart';
import 'step_08_recommendation.dart';
import 'step_10_notifications.dart';
import 'step_11_barcode.dart';
ModuleAFeatures moduleBFeatures() => (
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
