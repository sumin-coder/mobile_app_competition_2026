import '../module_a/step_09_product_detail.dart';
import 'step_07_ui.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  Widget build(BuildContext context) {
    final state = context.moduleB, items = state.favoriteProducts;
    return AppPage(
      title: '관심 상품',
      back: false,
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.favorite_border,
              title: '관심 상품이 없습니다.',
              subtitle: '마음에 드는 상품에 하트를 눌러보세요.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 90),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 18),
              itemBuilder: (_, i) {
                final p = items[i];
                return Dismissible(
                  key: ValueKey(p.id),
                  direction: DismissDirection.endToStart,
                  background: const ColoredBox(
                    color: AppColors.danger,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.all(22),
                        child: Icon(Icons.delete_outline),
                      ),
                    ),
                  ),
                  confirmDismiss: (_) => confirmAction(
                    context,
                    title: '관심 상품 삭제',
                    message: '${p.albumName}을(를) 삭제하시겠습니까?',
                    confirmLabel: '삭제',
                  ),
                  onDismissed: (_) => _remove(context, p.id, p.albumName),
                  child: InkWell(
                    onTap: () => openProductDetail(
                      context,
                      p.id,
                      actionsBuilder: moduleBProductDetailActions,
                    ),
                    child: SizedBox(
                      height: 80,
                      child: Row(
                        children: [
                          SizedBox.square(
                            dimension: 80,
                            child: ProductImage(product: p),
                          ),
                          hGap12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                singleLine(
                                  p.albumName,
                                  style: AppTextStyles.cardTitle,
                                ),
                                singleLine(
                                  p.artist,
                                  style: AppTextStyles.caption,
                                ),
                                vGap6,
                                Row(
                                  children: [
                                    InfoBadge(p.condition),
                                    hGap8,
                                    Text(
                                      genreLabel(p.genre),
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                formatWon(p.price),
                                style: AppTextStyles.price,
                              ),
                              vGap4,
                              Text(
                                tradeLabel(p.tradeMethod),
                                style: AppTextStyles.caption,
                              ),
                              FavoriteButton(
                                selected: !state.disabledFavoriteIds.contains(
                                  p.id,
                                ),
                                onPressed: () =>
                                    state.togglePendingFavorite(p.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _remove(BuildContext context, int id, String name) {
    final state = context.moduleB;
    state.removeFavoriteNow(id);
    context.notify(
      '$name을(를) 관심 목록에서 삭제했습니다.',
      action: SnackBarAction(
        label: '실행 취소',
        onPressed: () => state.restoreFavorite(id),
      ),
    );
  }
}
