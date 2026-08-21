import 'package:flutter/material.dart';
import '../../module_a/step_00_app_theme.dart';
import '../../module_a/step_01_models.dart';
import '../../module_a/step_06_widgets.dart';
import 'step_04_state.dart';
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    required this.selected,
    required this.onPressed,
    this.large = false,
    super.key,
  });
  final bool selected, large;
  final VoidCallback onPressed;
  State<FavoriteButton> createState() => _FavoriteButtonState();
}
class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );
  late final scale = Tween(begin: 1.0, end: 1.18).animate(controller);
  void didUpdateWidget(FavoriteButton old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) {
      controller.forward(from: 0).then((_) {
        if (mounted) controller.reverse();
      });
    }
  }
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) => ScaleTransition(
    key: const Key('favorite-scale'),
    scale: scale,
    child: IconButton(
      key: const Key('favorite-button'),
      tooltip: widget.selected ? '관심상품 해제' : '관심상품 등록',
      onPressed: widget.onPressed,
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      iconSize: widget.large ? 28 : 22,
      constraints: BoxConstraints.tightFor(
        width: widget.large ? 42 : 34,
        height: widget.large ? 42 : 34,
      ),
      padding: EdgeInsets.zero,
      icon: Container(
        key: const Key('favorite-background'),
        width: widget.large ? 36 : 30,
        height: widget.large ? 36 : 30,
        decoration: const BoxDecoration(
          color: Colors.black26,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          widget.selected ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(widget.selected),
          size: widget.large ? 28 : 22,
          color: widget.selected ? AppColors.danger : Colors.white,
        ),
      ),
    ),
  );
}
Widget MarketCard(
  ModuleBState state,
  Product product,
  VoidCallback onTap, {
  double? width,
}) => ProductCard(
  width: width,
  product: product,
  favorite: FavoriteButton(
    selected: state.favoriteIds.contains(product.id),
    onPressed: () => state.toggleFavorite(product.id),
  ),
  onTap: onTap,
);
List<Widget> moduleBProductDetailActions(
  BuildContext context,
  Product product,
) => [
  FavoriteButton(
    selected: context.moduleB.favoriteIds.contains(product.id),
    onPressed: () => context.moduleB.toggleFavorite(product.id),
    large: true,
  ).padAll(8),
];
