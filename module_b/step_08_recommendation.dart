import 'dart:async';
import '../module_a/step_09_product_detail.dart';
import 'step_07_ui.dart';

class Recommendation extends StatefulWidget {
  const Recommendation(this.products, {super.key});
  final List<Product> products;
  State<Recommendation> createState() => _RecommendationState();
}

class _RecommendationState extends State<Recommendation>
    with TickerProviderStateMixin {
  late final recordController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  late final armController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final pageController = PageController(
    initialPage: widget.products.length * 1000,
  );
  late final armAngle = Tween<double>(begin: .22, end: 0).animate(
    CurvedAnimation(parent: armController, curve: Curves.easeInOutCubic),
  );
  Timer? timer;
  int page = 0;
  bool changing = false, playing = false;
  void initState() {
    super.initState();
    scheduleNext();
  }

  void didUpdateWidget(covariant Recommendation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (page >= widget.products.length) page = 0;
  }

  void startArmDrag(DragStartDetails details) {
    if (changing) return;
    timer?.cancel();
    recordController.stop();
  }

  void updateArmDrag(DragUpdateDetails details) {
    if (changing) return;
    final delta = details.primaryDelta ?? 0;
    armController.value = (armController.value + delta / 120).clamp(0, 1);
  }

  Future<void> endArmDrag(DragEndDetails details) async {
    if (changing) return;
    await _setPlaying(armController.value >= .55);
  }

  Future<void> _setPlaying(bool value) async {
    timer?.cancel();
    if (playing != value) setState(() => playing = value);
    value ? recordController.repeat() : recordController.stop();
    await (value ? armController.forward() : armController.reverse());
    scheduleNext();
  }

  void scheduleNext() {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 5), next);
  }

  void pageChanged(int index) {
    final nextPage = index % widget.products.length;
    if (page != nextPage) setState(() => page = nextPage);
    if (!changing) playing ? unawaited(moveArm()) : scheduleNext();
  }

  Future<void> next() async {
    if (changing || widget.products.length < 2 || !pageController.hasClients)
      return;
    changing = true;
    timer?.cancel();
    if (playing) await armController.reverse();
    if (!mounted) return;
    await pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    if (!mounted) return;
    if (playing) await armController.forward();
    changing = false;
    scheduleNext();
  }

  Future<void> moveArm() async {
    changing = true;
    timer?.cancel();
    await armController.reverse();
    if (mounted) await armController.forward();
    changing = false;
    if (mounted) scheduleNext();
  }

  void dispose() {
    timer?.cancel();
    recordController.dispose();
    armController.dispose();
    pageController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();
    final product = widget.products[page];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 22, 14, 18),
      decoration: AppDecor.rounded(color: AppColors.filter, radius: 18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: AppDecor.rounded(
              border: Border.all(color: AppColors.primary),
              radius: 20,
            ),
            child: const Text(
              '오늘의 추천 바이닐',
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            '오늘, 이 바이닐은\n어떠세요?',
            textAlign: TextAlign.center,
            style: AppTextStyles.recommendTitle,
          ),
          const SizedBox(height: 5),
          const Text('매일 새롭게 선별한 특별한 한 장', style: AppTextStyles.caption),
          vGap8,
          SizedBox(
            height: 285,
            child: PageView.builder(
              key: const Key('recommendation_player'),
              controller: pageController,
              onPageChanged: pageChanged,
              itemBuilder: (_, index) {
                final album = widget.products[index % widget.products.length],
                    active = album.id == product.id;
                return SizedBox(
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/Module B/003. images/turntable.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(-6, -6),
                        child: RotationTransition(
                          key: active
                              ? const Key('recommendation_record')
                              : null,
                          turns: recordController,
                          child: SizedBox.square(
                            dimension: 210,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    'assets/Module B/003. images/vinyl.png',
                                  ),
                                ),
                                Positioned.fill(
                                  child: Center(
                                    child: Transform.translate(
                                      offset: const Offset(1.5, -2.5),
                                      child: SizedBox.square(
                                        key: ValueKey(album.id),
                                        dimension: 60,
                                        child: ProductImage(
                                          product: album,
                                          borderRadius: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 38,
                        top: -10,
                        width: 145,
                        height: 150,
                        child: Semantics(
                          label: playing
                              ? '톤암을 위로 드래그하면 정지'
                              : '톤암을 아래로 드래그하면 재생',
                          child: GestureDetector(
                            key: active
                                ? const Key('recommendation_tonearm_drag')
                                : null,
                            behavior: HitTestBehavior.opaque,
                            onVerticalDragStart: startArmDrag,
                            onVerticalDragUpdate: updateArmDrag,
                            onVerticalDragEnd: endArmDrag,
                            child: AnimatedBuilder(
                              animation: armAngle,
                              builder: (context, child) => Transform.rotate(
                                key: active
                                    ? const Key('recommendation_tonearm')
                                    : null,
                                angle: armAngle.value,
                                alignment: const Alignment(.63, -.05),
                                child: child,
                              ),
                              child: Image.asset(
                                'assets/Module B/003. images/tonearm.png',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (playing)
            InkWell(
              key: ValueKey('info_${product.id}'),
              onTap: () => openProductDetail(context, product.id),
              child: _productInfo(product),
            ).pad(const EdgeInsets.only(top: 8)),
          vGap8,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.products.length,
              (index) => AnimatedContainer(
                key: ValueKey('recommendation_indicator_$index'),
                duration: const Duration(milliseconds: 250),
                width: index == page ? 18 : 7,
                height: 7,
                margin: const EdgeInsets.all(3),
                decoration: AppDecor.rounded(
                  color: index == page ? AppColors.primary : Colors.grey,
                  radius: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productInfo(Product product) => SizedBox(
    height: 66,
    child: Row(
      children: [
        SizedBox.square(
          dimension: 58,
          child: ProductImage(product: product, borderRadius: 9),
        ),
        hGap12,
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              singleLine(
                product.albumName,
                style: AppTextStyles.recommendAlbum,
              ),
              const SizedBox(height: 2),
              singleLine(product.artist, style: AppTextStyles.recommendArtist),
              Text(
                '${genreLabel(product.genre)} · ${product.condition}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        const Icon(Icons.arrow_forward_ios, size: 18),
      ],
    ),
  );
}
