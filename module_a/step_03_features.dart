// Module B 기능을 Module A 화면에 선택적으로 끼워 넣는 확장 계약입니다.

import 'package:flutter/widgets.dart';
import 'step_01_models.dart';

typedef ProductCardBuilder =
    Widget Function(
      BuildContext context,
      Product product,
      VoidCallback onTap,
      double? width,
    );

typedef ProductDetailActionsBuilder =
    List<Widget> Function(
      BuildContext context,
      Product product,
    );

/// Optional extension points supplied by later modules.
///
/// Module A owns only these contracts and never imports Module B or C.
class ModuleAFeatures {
  const ModuleAFeatures({
    this.notificationCount,
    this.openNotifications,
    this.openScanner,
    this.recommendationBuilder,
    this.productCardBuilder,
    this.productDetailActionsBuilder,
  });

  final int Function(BuildContext context)? notificationCount;
  final void Function(BuildContext context)? openNotifications;
  final void Function(BuildContext context)? openScanner;
  final Widget Function(BuildContext context, List<Product> products)?
  recommendationBuilder;
  final ProductCardBuilder? productCardBuilder;
  final ProductDetailActionsBuilder? productDetailActionsBuilder;
}
