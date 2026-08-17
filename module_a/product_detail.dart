import '../module_b/ui.dart';

Future<void> openProductDetail(
  BuildContext context,
  int id, {
  bool moduleBEnabled = true,
}) => context.openPage(
  ProductDetailScreen(productId: id, moduleBEnabled: moduleBEnabled),
);

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    required this.productId,
    this.moduleBEnabled = true,
    super.key,
  });
  final int productId;
  final bool moduleBEnabled;
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? product;
  String? error;
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  Future<void> load() async {
    setState(() {
      product = null;
      error = null;
    });
    try {
      final p = await context.moduleA.moduleARepository.getProduct(
        widget.productId,
      );
      if (mounted) setState(() => product = p);
    } on AppException catch (e) {
      if (mounted) setState(() => error = e.message);
    }
  }

  Widget build(BuildContext context) => switch ((error, product)) {
    (final message?, _) => Scaffold(
      appBar: AppBar(),
      body: ErrorState(message: message, onRetry: load),
    ),
    (_, null) => const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    ),
    (_, final item?) => _content(context, item),
  };

  Widget _content(BuildContext context, Product p) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: _round(Icons.arrow_back, context.closePage),
            actions: widget.moduleBEnabled
                ? [
                    FavoriteButton(
                      selected: context.moduleB.favoriteIds.contains(p.id),
                      onPressed: () => context.moduleB.toggleFavorite(p.id),
                      large: true,
                    ).padAll(8),
                  ]
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(product: p, borderRadius: 0),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 110),
            sliver: SliverList.list(
              children: [
                Text(p.albumName, style: AppTextStyles.detailTitle),
                vGap4,
                Text(
                  p.artist,
                  style: AppTextStyles.caption.copyWith(fontSize: 17),
                ),
                vGap14,
                Wrap(
                  spacing: 8,
                  children: [
                    for (final text in [
                      genreLabel(p.genre),
                      p.condition,
                      tradeLabel(p.tradeMethod),
                    ])
                      Chip(label: Text(text)),
                  ],
                ),
                const SizedBox(height: 18),
                _panel(
                  Row(
                    children: [
                      _sellerAvatar(p.sellerProfileImage),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.sellerName, style: AppTextStyles.seller),
                            Text(p.sellerEmail, style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                _section(
                  '상태 등급',
                  p.condition,
                  p.conditionDescription.isNotEmpty
                      ? p.conditionDescription
                      : conditionDescription(p.condition),
                ),
                vGap26,
                _section('상품 설명', null, p.description),
                vGap26,
                _panel(
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('가격', style: AppTextStyles.caption),
                          Text(
                            formatWon(p.price),
                            style: AppTextStyles.price.copyWith(fontSize: 27),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('거래 방식', style: AppTextStyles.caption),
                          Text(
                            tradeLabel(p.tradeMethod),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                  padding: 18,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => context.notify('구매 기능은 준비 중입니다.'),
          child: const Text('구매하기'),
        ),
      ).safe(),
    );
  }

  Widget _round(IconData icon, VoidCallback tap) => IconButton.filled(
    onPressed: tap,
    style: IconButton.styleFrom(backgroundColor: Colors.black54),
    icon: Icon(icon, color: Colors.white),
  ).padAll(8);
  Widget _panel(Widget child, {double padding = 16}) => Container(
    padding: EdgeInsets.all(padding),
    decoration: AppDecor.rounded(color: AppColors.surface, radius: 14),
    child: child,
  );
  Widget _section(String title, String? badge, String body) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(title, style: AppTextStyles.section),
          if (badge != null) ...[
            hGap8,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.black,
              child: Text(badge, style: AppTextStyles.bold),
            ),
          ],
        ],
      ),
      const SizedBox(height: 10),
      Text(
        body,
        style: AppTextStyles.caption.copyWith(fontSize: 15, height: 1.5),
      ),
    ],
  );
  Widget _sellerAvatar(String imageUrl) {
    const placeholder = ColoredBox(
      color: Colors.brown,
      child: Icon(Icons.person, color: AppColors.primary),
    );
    return ClipOval(
      child: SizedBox.square(
        dimension: 56,
        child: imageUrl.isEmpty
            ? placeholder
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}
