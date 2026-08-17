import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'step_00_app_theme.dart';
import 'step_01_models.dart';
import 'step_04_state.dart';

const genres = [
  'ROCK',
  'JAZZ',
  'POP',
  'HIPHOP',
  'ELECTRONIC',
  'CLASSICAL',
  'RNB_SOUL',
  'ETC',
];
const conditions = ['M', 'NM', 'VG+', 'VG', 'G'];
const allConditions = ['SS', 'M', 'NM', 'EX', 'VG+', 'VG', 'G'];
final _thousandsPattern = RegExp(r'\B(?=(\d{3})+(?!\d))');
const vGap4 = SizedBox(height: 4),
    vGap6 = SizedBox(height: 6),
    vGap8 = SizedBox(height: 8),
    vGap12 = SizedBox(height: 12),
    vGap14 = SizedBox(height: 14),
    vGap20 = SizedBox(height: 20),
    vGap26 = SizedBox(height: 26),
    vGap28 = SizedBox(height: 28),
    hGap8 = SizedBox(width: 8),
    hGap12 = SizedBox(width: 12);
String commonIcon(String name) => 'assets/Common/002. icons/$name.png';
String moduleIcon(String module, String name) =>
    'assets/Module $module/002. icons/$name.png';
String genreIcon(String genre) => moduleIcon(
  'A',
  genre == 'HIPHOP' ? 'hip-hop' : genre.toLowerCase().replaceAll('_', '-'),
);
Widget AssetIcon(String path, {double size = 24, Color? color}) => Builder(
  builder: (context) => Image.asset(
    path,
    width: size,
    height: size,
    color: color ?? IconTheme.of(context).color ?? Colors.white,
  ),
);

String genreLabel(String value) =>
    const {
      'ROCK': 'Rock',
      'JAZZ': 'Jazz',
      'POP': 'Pop',
      'HIPHOP': 'Hip-Hop',
      'ELECTRONIC': 'Electronic',
      'CLASSICAL': 'Classical',
      'RNB_SOUL': 'R&B/Soul',
      'ETC': '기타',
    }[value] ??
    value;
String tradeLabel(String value) =>
    const {'DIRECT': '직거래', 'DELIVERY': '택배', 'BOTH': '둘 다'}[value] ?? value;
String conditionLabel(String value) => value == 'M' ? 'Mint' : value;
String conditionDescription(String value) =>
    const {
      'SS': '미개봉 새상품. 완벽한 상태입니다.',
      'M': 'Mint. 개봉했으나 새것과 다름없는 완벽한 상태입니다.',
      'NM': 'Near Mint. 거의 새것에 가까운 상태로, 미세한 사용감만 있습니다.',
      'EX': 'Excellent. 전체적으로 깨끗하며, 약간의 사용감이 있습니다.',
      'VG+': 'Very Good Plus. 양호한 상태로, 재생에 문제가 없습니다.',
      'VG': 'Very Good. 사용감이 있으나 재생에 큰 문제가 없습니다.',
      'G': 'Good. 사용감이 많으나 재생은 가능합니다.',
    }[value] ??
    '';
String conditionSummary(String value) =>
    const {
      'SS': '미개봉 새상품',
      'M': 'Mint - 완벽한 상태',
      'NM': 'Near Mint - 거의 새것',
      'EX': 'Excellent - 약간의 사용감',
      'VG+': 'Very Good+ - 양호',
      'VG': 'Very Good - 사용감 있음',
      'G': 'Good - 재생 가능',
    }[value] ??
    '';
String formatWon(int value) =>
    '₩${value.toString().replaceAllMapped(_thousandsPattern, (_) => ',')}';

extension PageNavigation on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  ThemeData get theme => Theme.of(this);
  ScaffoldMessengerState get messages => ScaffoldMessenger.of(this);
  Future<T?> openPage<T>(Widget page) =>
      Navigator.push<T>(this, MaterialPageRoute(builder: (_) => page));
  void closePage<T>([T? result]) => Navigator.pop(this, result);
  Future<bool> guard(Future<void> Function() action) async {
    try {
      await action();
      return true;
    } on AppException catch (error) {
      if (mounted) notify(error.message);
      return false;
    }
  }

  void notify(String message, {SnackBarAction? action}) {
    messages
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }
}

extension WidgetLayout on Widget {
  Widget pad(EdgeInsetsGeometry value) => Padding(padding: value, child: this);
  Widget padAll(double value) => pad(EdgeInsets.all(value));
  Widget safe() => SafeArea(child: this);
}

Widget AppPage({
  required String title,
  required Widget body,
  List<Widget>? actions,
  bool back = true,
}) => Scaffold(
  appBar: AppBar(
    title: Text(title),
    actions: actions,
    automaticallyImplyLeading: back,
  ),
  body: body,
);

Widget RefreshPage<T>({
  required String title,
  required LoadStatus status,
  required List<T> items,
  required String error,
  required Future<void> Function() refresh,
  required Widget empty,
  required Widget Function(List<T>) content,
  List<Widget>? actions,
  bool scrollLoading = true,
}) => AppPage(
  title: title,
  actions: actions,
  body: RefreshIndicator(
    onRefresh: refresh,
    child: switch ((status, items)) {
      (LoadStatus.initial || LoadStatus.loading, _) =>
        scrollLoading
            ? scrollState(const Center(child: CircularProgressIndicator()))
            : const Center(child: CircularProgressIndicator()),
      (LoadStatus.error, _) => scrollState(
        ErrorState(message: error, onRetry: refresh),
      ),
      (_, []) => scrollState(empty),
      _ => content(items),
    },
  ),
);

void disposeControllers(Iterable<TextEditingController> controllers) {
  for (final controller in controllers) {
    controller.dispose();
  }
}

List<TextInputFormatter> digits([int? maxLength]) => [
  FilteringTextInputFormatter.digitsOnly,
  if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
];
Widget singleLine(String text, {TextStyle? style}) =>
    Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: style);

Widget fixedHeight(double height, Widget child) =>
    SizedBox(height: height, child: child);
Widget scrollState(Widget child) =>
    ListView(children: [fixedHeight(600, child)]);
Widget loadState({
  required LoadStatus status,
  required bool empty,
  required String error,
  required VoidCallback retry,
  required Widget emptyView,
  required Widget Function() success,
  double height = 350,
}) => switch (status) {
  LoadStatus.initial || LoadStatus.loading => fixedHeight(
    height,
    const Center(child: CircularProgressIndicator()),
  ),
  LoadStatus.error => fixedHeight(
    height,
    ErrorState(message: error, onRetry: retry),
  ),
  _ when empty => fixedHeight(height, emptyView),
  _ => success(),
};
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = '확인',
}) => showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => context.closePage(false),
        child: const Text('취소'),
      ),
      FilledButton(
        onPressed: () => context.closePage(true),
        child: Text(confirmLabel),
      ),
    ],
  ),
).then((confirmed) => confirmed ?? false);

Widget SubmitButton({
  Key? key,
  required String label,
  required bool busy,
  required VoidCallback onPressed,
  Color? backgroundColor,
}) => ElevatedButton(
  key: key,
  style: backgroundColor == null
      ? null
      : ElevatedButton.styleFrom(backgroundColor: backgroundColor),
  onPressed: busy ? null : onPressed,
  child: busy
      ? const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : Text(label),
);

Widget AppField({
  required TextEditingController controller,
  required String hint,
  String? label,
  IconData? icon,
  Widget? prefix,
  Widget? suffix,
  FormFieldValidator<String>? validator,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  bool obscureText = false,
  TextInputAction action = TextInputAction.next,
  ValueChanged<String>? onSubmitted,
  int? minLines,
  int? maxLines = 1,
  Key? fieldKey,
}) {
  final input = TextFormField(
    key: fieldKey,
    controller: controller,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    obscureText: obscureText,
    textInputAction: action,
    onFieldSubmitted: onSubmitted,
    validator: validator,
    minLines: minLines,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: prefix ?? (icon == null ? null : Icon(icon)),
      suffixIcon: suffix,
    ),
  );
  if (label == null) return input;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.bold),
      vGap6,
      input,
    ],
  );
}

Widget PasswordField({
  required TextEditingController controller,
  required String hint,
  required bool obscure,
  required VoidCallback onToggle,
  required FormFieldValidator<String> validator,
  TextInputAction action = TextInputAction.next,
  ValueChanged<String>? onSubmitted,
  Key? fieldKey,
}) => AppField(
  fieldKey: fieldKey,
  controller: controller,
  hint: hint,
  prefix: AssetIcon(moduleIcon('A', 'lock')).padAll(14),
  obscureText: obscure,
  action: action,
  onSubmitted: onSubmitted,
  validator: validator,
  suffix: IconButton(
    onPressed: onToggle,
    icon: AssetIcon(moduleIcon('A', obscure ? 'visibility-off' : 'visibility')),
  ),
);

Widget BrandLogo({double height = 45, bool centered = false}) => Align(
  alignment: centered ? Alignment.center : Alignment.centerLeft,
  child: Image.asset(
    'assets/Common/001. simbol/${centered ? 'logo_horizontal' : 'logo_vertical'}.png',
    height: height,
    fit: BoxFit.contain,
  ),
);

Widget AppHeader({
  required int notificationCount,
  VoidCallback? onNotification,
}) => Row(
  children: [
    Expanded(child: BrandLogo()),
    IconButton(
      onPressed: onNotification,
      icon: Badge(
        isLabelVisible: notificationCount > 0,
        label: Text(notificationCount > 9 ? '9+' : '$notificationCount'),
        child: AssetIcon(commonIcon('notification')),
      ),
    ),
  ],
);

Widget MarketSearch({
  VoidCallback? onScan,
  TextEditingController? controller,
  VoidCallback? onTap,
  Key? fieldKey,
}) => TextField(
  key: fieldKey,
  controller: controller,
  readOnly: onTap != null,
  onTap: onTap,
  decoration: InputDecoration(
    hintText: '앨범명, 아티스트 검색',
    prefixIcon: const Icon(Icons.search, size: 30),
    suffixIcon: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (controller?.text.isNotEmpty == true)
          IconButton(
            onPressed: controller!.clear,
            icon: const Icon(Icons.close),
          ),
        if (onScan != null)
          IconButton(
            onPressed: onScan,
            icon: AssetIcon(moduleIcon('B', 'barcode-scan')),
          ),
      ],
    ),
  ),
);

Widget GenreGrid({required ValueChanged<String> onTap}) => GridView.count(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  crossAxisCount: 4,
  childAspectRatio: 1.45,
  crossAxisSpacing: 10,
  mainAxisSpacing: 10,
  children: [
    for (final g in genres)
      InkWell(
        onTap: () => onTap(g),
        borderRadius: BorderRadius.circular(9),
        child: Container(
          decoration: AppDecor.rounded(
            radius: 9,
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AssetIcon(genreIcon(g), size: 23, color: AppColors.primary),
              vGap4,
              Text(genreLabel(g), style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
  ],
);

Widget ProductImage({
  required Product product,
  double borderRadius = 8,
  BoxFit fit = BoxFit.cover,
}) => AlbumImage(
  path: product.albumImage,
  name: product.albumName,
  borderRadius: borderRadius,
  fit: fit,
);

Widget AlbumImage({
  required String path,
  required String name,
  double borderRadius = 0,
  BoxFit fit = BoxFit.cover,
}) {
  final fallback = AlbumCoverFallback(name);
  Widget load(ImageProvider image) =>
      Image(image: image, fit: fit, errorBuilder: (_, _, _) => fallback);
  final image = switch (path) {
    final value when value.startsWith('http') => load(NetworkImage(value)),
    final value when value.startsWith('assets/') => load(AssetImage(value)),
    final value when value.isNotEmpty => load(FileImage(File(value))),
    _ => fallback,
  };
  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: ColoredBox(
      color: AppColors.albumBackground,
      child: SizedBox.expand(child: image),
    ),
  );
}

Widget AlbumCoverFallback(String albumName) => ColoredBox(
  key: const Key('api-album-fallback'),
  color: AppColors.albumBackground,
  child: Stack(
    alignment: Alignment.center,
    children: [
      const Icon(Icons.album, size: 48, color: AppColors.albumForeground),
      Align(
        alignment: Alignment.bottomCenter,
        child: ColoredBox(
          color: Colors.black54,
          child: RichText(
            key: const Key('fallback-album-name'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: albumName,
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
      ),
    ],
  ),
);

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.onTap,
    this.favorite,
    this.width,
    super.key,
  });
  final Product product;
  final VoidCallback onTap;
  final Widget? favorite;
  final double? width;
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        child: ColoredBox(
          color: AppColors.surfaceHigh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ProductImage(product: product, borderRadius: 0),
                    ),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: InfoBadge(product.condition),
                    ),
                    if (favorite != null)
                      Positioned(right: 4, top: 4, child: favorite!),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  singleLine(
                    product.albumName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  singleLine(product.artist, style: AppTextStyles.caption),
                  const SizedBox(height: 3),
                  Text(formatWon(product.price), style: AppTextStyles.price),
                ],
              ).pad(const EdgeInsets.fromLTRB(8, 8, 8, 10)),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget InfoBadge(String text) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
  decoration: AppDecor.rounded(color: Colors.black87, radius: 5),
  child: Text(text, style: AppTextStyles.smallBold),
);

Widget ProductListCard({
  required Product product,
  required Widget details,
  required VoidCallback onTap,
  Widget? trailing,
}) => Card(
  child: ListTile(
    onTap: onTap,
    leading: SizedBox.square(
      dimension: 80,
      child: ProductImage(product: product),
    ),
    title: singleLine(product.albumName),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(product.artist), vGap4, details],
    ),
    trailing: trailing,
  ),
);

Widget EmptyState({
  required IconData icon,
  required String title,
  required String subtitle,
}) => Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 55),
      vGap12,
      Text(title, style: AppTextStyles.section),
      Text(subtitle, textAlign: TextAlign.center),
    ],
  ).padAll(24),
);

Widget ErrorState({required String message, required VoidCallback onRetry}) =>
    Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
