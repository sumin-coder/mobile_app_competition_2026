import 'dart:async';
import 'step_07_ui.dart';
import 'step_09_product_detail.dart';

enum ProductSort { recent, popular, price }

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    this.genreSeed,
    this.features = const ModuleAFeatures(),
    super.key,
  });
  final String? genreSeed;
  final ModuleAFeatures features;
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final search = TextEditingController(), scroll = ScrollController();
  final genresPicked = <String>{}, conditionsPicked = <String>{};
  Timer? debounce;
  List<Product>? searched;
  RangeValues prices = const RangeValues(1000, 1000000);
  String? trade;
  ProductSort sort = ProductSort.recent;
  bool expanded = true;
  int visible = 12;
  void initState() {
    super.initState();
    if (widget.genreSeed != null) genresPicked.add(widget.genreSeed!);
    search.addListener(searchChanged);
    scroll.addListener(() {
      if (scroll.position.extentAfter < 220) setState(() => visible += 12);
    });
  }

  void dispose() {
    debounce?.cancel();
    search.dispose();
    scroll.dispose();
    super.dispose();
  }

  void searchChanged() {
    debounce?.cancel();
    final keyword = search.text.trim();
    setState(() {
      visible = 12;
      if (keyword.isEmpty) searched = null;
    });
    if (keyword.isEmpty) return;
    debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final products = await context.moduleA.searchProducts(keyword);
        if (mounted && keyword == search.text.trim())
          setState(() => searched = products);
      } on Object catch (error) {
        if (mounted && keyword == search.text.trim())
          context.notify(
            error is AppException ? error.message : '검색 결과를 불러오지 못했습니다.',
          );
      }
    });
  }

  void reset() => setState(() {
    search.clear();
    genresPicked.clear();
    conditionsPicked.clear();
    prices = const RangeValues(1000, 1000000);
    trade = null;
    sort = ProductSort.recent;
    visible = 12;
  });
  List<Product> results(List<Product> source) {
    final q = search.text.trim().toLowerCase();
    return source
        .where(
          (p) =>
              (q.isEmpty ||
                  p.albumName.toLowerCase().contains(q) ||
                  p.artist.toLowerCase().contains(q)) &&
              (genresPicked.isEmpty || genresPicked.contains(p.genre)) &&
              (conditionsPicked.isEmpty ||
                  conditionsPicked.contains(p.condition)) &&
              p.price >= prices.start &&
              p.price <= prices.end &&
              (trade == null || trade == p.tradeMethod),
        )
        .sortedBy(switch (sort) {
          ProductSort.recent => (a, b) => b.createdAt.compareTo(a.createdAt),
          ProductSort.popular => (a, b) => b.likeCount.compareTo(a.likeCount),
          ProductSort.price => (a, b) => a.price.compareTo(b.price),
        });
  }

  Widget build(BuildContext context) {
    final state = context.moduleA;
    final all = results(searched ?? state.products);
    return ListView(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        AppHeader(
          notificationCount:
              widget.features.notificationCount?.call(context) ?? 0,
          onNotification: widget.features.openNotifications == null
              ? null
              : () => widget.features.openNotifications!(context),
        ),
        vGap12,
        MarketSearch(
          fieldKey: const Key('explore_search'),
          controller: search,
          onScan: widget.features.openScanner == null
              ? null
              : () => widget.features.openScanner!(context),
        ),
        vGap14,
        Row(
          children: [
            const Icon(Icons.tune, color: AppColors.muted),
            hGap8,
            const Text('필터', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton(onPressed: reset, child: const Text('필터 초기화')),
          ],
        ),
        if (expanded) ...[
          _filterRow('장르', genres, genresPicked, genreLabel),
          _filterRow('음반 상태', conditions, conditionsPicked, conditionLabel),
          Row(
            children: [
              const SizedBox(
                width: 76,
                child: Text('가격 범위', style: AppTextStyles.caption),
              ),
              _price(formatWon(prices.start.round())),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: RangeSlider(
                    min: 1000,
                    max: 1000000,
                    values: prices,
                    onChanged: (v) => setState(() => prices = v),
                  ),
                ),
              ),
              _price(
                prices.end == 1000000
                    ? '₩1,000,000+'
                    : formatWon(prices.end.round()),
              ),
            ],
          ),
          _singleRow(
            '거래 방식',
            const [null, 'DIRECT', 'DELIVERY', 'BOTH'],
            trade,
            (v) => v == null ? '전체' : tradeLabel(v),
            (v) => setState(() => trade = v),
          ),
        ],
        Center(
          child: TextButton.icon(
            onPressed: () => setState(() => expanded = !expanded),
            label: Text(expanded ? '접기' : '펼치기'),
            iconAlignment: IconAlignment.end,
            icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
          ),
        ),
        const Divider(height: 1),
        Row(
          children: [
            Text('검색 결과 ${all.length}개', style: AppTextStyles.section),
            const Spacer(),
            DropdownButton<ProductSort>(
              key: const Key('sort_dropdown'),
              value: sort,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: ProductSort.recent,
                  child: Text('최신 등록순'),
                ),
                DropdownMenuItem(
                  value: ProductSort.popular,
                  child: Text('인기 매물순'),
                ),
                DropdownMenuItem(
                  value: ProductSort.price,
                  child: Text('최저 가격순'),
                ),
              ],
              onChanged: (v) => setState(() => sort = v ?? ProductSort.recent),
            ),
          ],
        ).pad(const EdgeInsets.symmetric(vertical: 14)),
        _grid(state, all.take(visible).toList()),
      ],
    ).safe();
  }

  Widget _filterRow(
    String title,
    List<String> values,
    Set<String> picked,
    String Function(String) label,
  ) => _filter(title, [
    _chip('전체', picked.isEmpty, () => setState(picked.clear)),
    for (final v in values)
      _chip(
        label(v),
        picked.contains(v),
        () => setState(
          () => picked.contains(v) ? picked.remove(v) : picked.add(v),
        ),
        key: Key('filter_$v'),
      ),
  ], top: true);
  Widget _singleRow<T>(
    String title,
    List<T> values,
    T selected,
    String Function(T) label,
    ValueChanged<T> select,
  ) => _filter(title, [
    for (final v in values) _chip(label(v), v == selected, () => select(v)),
  ]);
  Widget _filter(String title, List<Widget> chips, {bool top = false}) => Row(
    crossAxisAlignment: top
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center,
    children: [
      SizedBox(
        width: 76,
        child: Text(
          title,
          style: AppTextStyles.caption,
        ).pad(EdgeInsets.only(top: top ? 10 : 0)),
      ),
      Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: chips),
        ),
      ),
    ],
  );
  Widget _chip(String text, bool selected, VoidCallback tap, {Key? key}) =>
      ChoiceChip(
        key: key,
        label: Text(text),
        selected: selected,
        backgroundColor: AppColors.filter,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: selected ? AppColors.onPrimary : null),
        shape: const StadiumBorder(),
        side: BorderSide.none,
        onSelected: (_) => tap(),
        showCheckmark: false,
      ).pad(const EdgeInsets.only(right: 7, bottom: 8));
  Widget _price(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
    decoration: AppDecor.rounded(color: AppColors.filter, radius: 20),
    child: Text(
      text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
  Widget _grid(ModuleAState state, List<Product> items) => loadState(
    status: state.productStatus,
    empty: items.isEmpty,
    error: state.productError ?? '상품을 불러오지 못했습니다.',
    retry: state.refreshProducts,
    emptyView: EmptyState(
      icon: Icons.search_off,
      title: '검색 결과가 없습니다.',
      subtitle: '검색어나 필터 조건을 변경해보세요.',
    ),
    success: () => GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 220,
        crossAxisSpacing: 8,
        mainAxisSpacing: 10,
      ),
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
              null,
            ) ??
            ProductCard(product: p, onTap: open);
      },
    ),
  );
}
