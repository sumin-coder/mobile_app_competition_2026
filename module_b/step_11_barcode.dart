// 카메라로 바코드를 인식하고 일치하는 상품 상세 화면을 엽니다.

import 'package:mobile_scanner/mobile_scanner.dart';
import '../../module_a/step_09_product_detail.dart';
import 'step_07_ui.dart';

// 스캔 화면의 결과를 서버에서 검색해 상품 상세로 이어 줍니다.
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

// MobileScanner의 권한·인식·플래시·카메라 전환 UI를 관리합니다.
class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({super.key});
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  final scanner = MobileScannerController(
    formats: const [BarcodeFormat.ean13, BarcodeFormat.ean8],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool done = false, denied = false;
  void finish(String? value) {
    if (done || value == null || value.isEmpty) return;
    done = true;
    context.closePage(value);
  }

  Future<void> manual() async {
    final input = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('바코드 직접 입력'),
        content: TextField(
          controller: input,
          keyboardType: TextInputType.number,
          inputFormatters: digits(13),
          decoration: AppDecor.input('EAN-13 또는 EAN-8'),
        ),
        actions: [
          TextButton(onPressed: context.closePage, child: const Text('취소')),
          FilledButton(
            onPressed: () => context.closePage(
              input.text.length == 8 || input.text.length == 13
                  ? input.text
                  : null,
            ),
            child: const Text('검색'),
          ),
        ],
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
        SizedBox(
          height: 190,
          child: Stack(
            children: [
              Positioned(
                left: 12,
                top: 20,
                child: IconButton(
                  onPressed: context.closePage,
                  icon: const Icon(Icons.close, size: 32),
                ),
              ),
              const Align(
                alignment: Alignment(0, -.45),
                child: Text('바코드 검색', style: AppTextStyles.section),
              ),
              const Align(
                alignment: Alignment(0, .65),
                child: Text(
                  '상품의 바코드를 화면 중앙에 맞춰주세요',
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: scanner,
                onDetect: (capture) =>
                    finish(capture.barcodes.firstOrNull?.rawValue),
                errorBuilder: (context, error) {
                  if (error.errorCode ==
                          MobileScannerErrorCode.permissionDenied &&
                      !denied) {
                    denied = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      context.notify('카메라 권한이 필요합니다');
                      context.closePage();
                    });
                  }
                  return const SizedBox.shrink();
                },
              ),
              const CustomPaint(painter: _ScanPainter()),
            ],
          ),
        ),
        SizedBox(
          height: 105,
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
      ],
    ).safe(),
  );
}

// 스캐너 중앙의 인식 영역과 모서리 가이드를 그립니다.
class _ScanPainter extends CustomPainter {
  const _ScanPainter();
  void paint(Canvas canvas, Size size) {
    final box = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * .68,
      height: size.width * .4,
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
