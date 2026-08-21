import 'step_07_ui.dart';
import 'step_09_product_detail.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.onExplore,
    this.features = emptyModuleAFeatures,
    super.key,
  });
  final ValueChanged<String?> onExplore;
  final ModuleAFeatures features;
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int sort = 0;
  Widget build(BuildContext context) {
    final state = context.moduleA;
    return RefreshIndicator(
      onRefresh: state.refreshProducts,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          AppHeader(
            notificationCount:
                widget.features.notificationCount?.call(context) ?? 0,
            onNotification: () => widget.features.showNotifications(context),
          ),
          vGap12,
          MarketSearch(
            onTap: () => widget.onExplore(null),
            onScan: () => widget.features.scanBarcode(context),
          ),
          const SizedBox(height: 16),
          _content(state),
        ],
      ),
    ).safe();
  }
  Widget _content(ModuleAState state) => loadState(
    status: state.productStatus,
    empty: state.products.isEmpty,
    error: state.productError ?? '상품을 불러오지 못했습니다.',
    retry: state.refreshProducts,
    height: 450,
    emptyView: EmptyState(
      icon: Icons.album_outlined,
      title: '등록된 상품이 없습니다.',
      subtitle: '잠시 후 다시 확인해주세요.',
    ),
    success: () => _products(state),
  );
  Widget _products(ModuleAState state) {
    final sorted = _sorted(state.products), items = sorted.take(10).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.features.recommendationBuilder != null) ...[
          widget.features.recommendationBuilder!(
            context,
            _sorted(state.products, by: 0).take(5).toList(),
          ),
          vGap28,
        ],
        _title('장르별 둘러보기', () => widget.onExplore(null)),
        vGap14,
        GenreGrid(onTap: widget.onExplore),
        vGap28,
        Row(
          children: [
            for (final (i, text) in ['인기 매물', '최신 등록', '가격 인하'].indexed)
              InkWell(
                onTap: () => setState(() => sort = i),
                child: Container(
                  margin: const EdgeInsets.only(right: 24),
                  padding: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: sort == i
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontWeight: sort == i
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            const Spacer(),
            TextButton(
              onPressed: () => widget.onExplore(null),
              child: const Text('전체 보기 ›'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 235,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => hGap12,
            itemBuilder: (_, i) {
              final p = items[i];
              final open = () => openProductDetail(
                context,
                p.id,
                actionsBuilder: widget.features.productDetailActionsBuilder,
              );
              return widget.features.productCardBuilder?.call(
                    context,
                    p,
                    open,
                    145,
                  ) ??
                  ProductCard(product: p, onTap: open, width: 145);
            },
          ),
        ),
      ],
    );
  }
  Widget _title(String text, VoidCallback more) => Row(
    children: [
      Expanded(child: Text(text, style: AppTextStyles.section)),
      TextButton(onPressed: more, child: const Text('전체 보기 ›')),
    ],
  );
  List<Product> _sorted(List<Product> source, {int? by}) {
    return source.sortedBy(switch (by ?? sort) {
      0 => (a, b) => b.likeCount.compareTo(a.likeCount),
      1 => (a, b) => b.createdAt.compareTo(a.createdAt),
      _ => (a, b) => a.price.compareTo(b.price),
    });
  }
}
