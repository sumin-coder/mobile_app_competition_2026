import '../../module_a/step_09_product_detail.dart';
import 'step_03_native.dart';
import 'step_07_ui.dart';
Future<void> openBarcodeSearch(BuildContext context) async {
  final code = await context.openPage<String>(const BarcodeScreen());
  if (code == null || !context.mounted) return;
  await context.guard(() async {
    final p = await context.moduleB.findByBarcode(code);
    if (!context.mounted) return;
    p == null
        ? context.notify('바코드 "$code"에 해당하는 상품을 찾을 수 없습니다.')
        : await openProductDetail(
            context,
            p.id,
            actionsBuilder: moduleBProductDetailActions,
          );
  });
}
class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({super.key});
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}
class _BarcodeScreenState extends State<BarcodeScreen> {
  late final scanner = NativeBarcodeController()
    ..onDetected = finish
    ..onError = cameraError;
  bool done = false, ready = false;
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => startCamera());
  }
  Future<void> startCamera() async {
    final granted = await scanner.start();
    if (!mounted) return;
    if (!granted) {
      context.notify('카메라 권한이 필요합니다. 설정에서 권한을 허용해주세요.');
      return context.closePage();
    }
    setState(() => ready = true);
  }
  void cameraError() {
    if (!mounted || done) return;
    context.notify('카메라를 시작할 수 없습니다. 잠시 후 다시 시도해주세요.');
    context.closePage();
  }
  void finish(String? value) {
    if (done || value == null || value.isEmpty) return;
    done = true;
    context.closePage(value);
  }
  Future<void> manual() async {
    final input = TextEditingController();
    String? error;
    final value = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('바코드 직접 입력'),
          content: TextField(
            controller: input,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: digits(13),
            decoration: AppDecor.input(
              'EAN-13 또는 EAN-8',
            ).copyWith(errorText: error),
          ),
          actions: [
            TextButton(onPressed: context.closePage, child: const Text('취소')),
            FilledButton(
              onPressed: () {
                if (input.text.length != 8 && input.text.length != 13) {
                  setDialogState(() => error = '바코드는 8자리 또는 13자리 숫자로 입력해주세요.');
                  return;
                }
                context.closePage(input.text);
              },
              child: const Text('검색'),
            ),
          ],
        ),
      ),
    );
    input.dispose();
    finish(value);
  }
  void dispose() {
    scanner.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        ColoredBox(
          color: AppColors.surface,
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 92,
              child: Stack(
                children: [
                  Positioned(
                    left: 4,
                    top: 4,
                    child: IconButton(
                      onPressed: context.closePage,
                      icon: const Icon(Icons.close, size: 28),
                    ),
                  ),
                  const Align(
                    alignment: Alignment(0, -.45),
                    child: Text('바코드 검색', style: AppTextStyles.bold),
                  ),
                  const Align(
                    alignment: Alignment(0, .62),
                    child: Text(
                      '상품의 바코드를 화면 중앙에 맞춰주세요',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (ready)
                const AndroidView(viewType: 'vinyl/barcode_camera')
              else
                const Center(child: CircularProgressIndicator()),
              const CustomPaint(painter: _ScanPainter()),
            ],
          ),
        ),
        ColoredBox(
          color: AppColors.surface,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 116,
              child: Center(
                child: TextButton.icon(
                  onPressed: manual,
                  icon: AssetIcon(moduleIcon('B', 'barcode-scan')),
                  label: const Text(
                    '직접 입력',
                    style: TextStyle(color: AppColors.muted, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
class _ScanPainter extends CustomPainter {
  const _ScanPainter();
  void paint(Canvas canvas, Size size) {
    final box = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * .7,
      height: size.width * .54,
    );
    final shade = Paint()..color = Colors.black.withValues(alpha: .5);
    canvas.drawPath(
      Path()
        ..addRect(Offset.zero & size)
        ..addRect(box)
        ..fillType = PathFillType.evenOdd,
      shade,
    );
    final gold = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    const l = 22.0;
    for (final p in [
      box.topLeft,
      box.topRight,
      box.bottomLeft,
      box.bottomRight,
    ]) {
      final sx = p.dx == box.left ? 1.0 : -1.0,
          sy = p.dy == box.top ? 1.0 : -1.0;
      canvas.drawPath(
        Path()
          ..moveTo(p.dx, p.dy + sy * l)
          ..lineTo(p.dx, p.dy)
          ..lineTo(p.dx + sx * l, p.dy),
        gold,
      );
    }
    canvas.drawLine(
      Offset(box.left + 8, box.center.dy),
      Offset(box.right - 8, box.center.dy),
      Paint()..color = AppColors.primary.withValues(alpha: .55),
    );
  }
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
