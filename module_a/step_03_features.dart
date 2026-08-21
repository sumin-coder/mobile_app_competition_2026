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
typedef ModuleAFeatures = ({
  int Function(BuildContext context)? notificationCount,
  void Function(BuildContext context)? openNotifications,
  void Function(BuildContext context)? openScanner,
  Widget Function(BuildContext context, List<Product> products)?
  recommendationBuilder,
  ProductCardBuilder? productCardBuilder,
  ProductDetailActionsBuilder? productDetailActionsBuilder,
});
const ModuleAFeatures emptyModuleAFeatures = (
  notificationCount: null,
  openNotifications: null,
  openScanner: null,
  recommendationBuilder: null,
  productCardBuilder: null,
  productDetailActionsBuilder: null,
);
mixin ExploreShellState<T extends StatefulWidget> on State<T> {
  int page = 0, exploreKey = 0;
  String? genre;
  void explore(String? value) => setState(() {
    page = 1;
    genre = value;
    exploreKey++;
  });
}
