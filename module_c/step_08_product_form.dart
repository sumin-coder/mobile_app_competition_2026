// 이미지와 상품 정보를 입력·검증해 서버에 등록하는 화면입니다.

import 'dart:io';
import 'package:flutter/services.dart';
import 'step_03_native.dart';
import 'step_07_ui.dart';

// 통합 테스트에서 네이티브 사진 선택을 대체하기 위한 주입 지점입니다.
@visibleForTesting
Future<String?> Function(PhotoSource source)? productImagePickerOverride;

// 하단 등록 버튼, 마이페이지, 내 상품 화면에서 진입하는 상품 등록 폼입니다.
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final form = GlobalKey<FormState>();
  final album = TextEditingController(),
      artist = TextEditingController(),
      price = TextEditingController(),
      barcode = TextEditingController(),
      description = TextEditingController();
  String? image;
  String genre = 'ROCK', condition = 'NM', trade = 'BOTH';
  bool validate = false;
  void dispose() {
    disposeControllers([album, artist, price, barcode, description]);
    super.dispose();
  }

  // 사진 출처를 선택하고 네이티브에서 받은 파일 경로를 폼에 반영합니다.
  Future<void> pickImage() async {
    final source = await showModalBottomSheet<PhotoSource>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (source, icon, label) in const [
            (PhotoSource.camera, Icons.camera_alt, '카메라로 촬영'),
            (PhotoSource.gallery, Icons.photo, '갤러리에서 선택'),
          ])
            ListTile(
              title: Text(label),
              leading: Icon(icon),
              onTap: () => context.closePage(source),
            ),
        ],
      ).safe(),
    );
    if (source == null) return;
    try {
      final picker = productImagePickerOverride;
      final value = picker != null
          ? await picker(source)
          : await Native.pickPhoto(source);
      if (value != null && mounted) setState(() => image = value);
    } on PlatformException {
      if (mounted) context.notify('사진 접근 권한을 확인해주세요.');
    }
  }

  // 전체 입력값과 이미지를 확인한 뒤 Module C 상태를 통해 등록합니다.
  Future<void> submit() async {
    setState(() => validate = true);
    if (!(form.currentState?.validate() ?? false) || image == null) {
      context.notify(
        image == null ? '상품 이미지를 등록해주세요.' : '필수 입력 항목을 모두 확인해주세요.',
      );
      return;
    }
    final success = await context.guard(
      () => context.moduleC.addProduct((
        albumName: album.text.trim(),
        artist: artist.text.trim(),
        genre: genre,
        condition: condition,
        price: int.parse(price.text),
        tradeMethod: trade,
        imagePath: image!,
        description: description.text.trim(),
        barcode: barcode.text.trim(),
      )),
    );
    if (success && mounted) {
      context.notify('상품이 등록되었습니다.');
      context.closePage(true);
    }
  }

  Widget build(BuildContext context) {
    final state = context.moduleC;
    return AppPage(
      title: '상품 등록',
      body: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InkWell(
              key: const Key('product_image_picker'),
              onTap: pickImage,
              child: Container(
                height: 200,
                clipBehavior: Clip.antiAlias,
                decoration: AppDecor.rounded(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.outline),
                ),
                child: image == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: AppColors.muted,
                            size: 34,
                          ),
                          vGap8,
                          Text('상품 이미지를 등록하세요'),
                          Text(
                            '탭하여 카메라 또는 갤러리 선택',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      )
                    : Image.file(File(image!), fit: BoxFit.cover),
              ),
            ),
            if (validate && image == null) errorText('상품 이미지를 등록해주세요.'),
            input(
              album,
              'product_album',
              '앨범명',
              '앨범명을 입력하세요',
              requiredText('앨범명을 입력해주세요.'),
            ),
            input(
              artist,
              'product_artist',
              '아티스트',
              '아티스트를 입력하세요',
              requiredText('아티스트를 입력해주세요.'),
            ),
            select('장르', genres, genre, genreLabel, (value) => genre = value),
            select(
              '음반 상태',
              allConditions,
              condition,
              (value) => value,
              (value) => condition = value,
            ),
            Text(conditionSummary(condition), style: AppTextStyles.caption),
            input(price, 'product_price', '가격', '가격을 입력하세요', (value) {
              final number = int.tryParse(value ?? '');
              if (number == null) return '가격을 입력해주세요.';
              return number >= 1000 ? null : '가격은 1,000원 이상 입력해주세요.';
            }, number: true),
            select(
              '거래 방식',
              const ['DIRECT', 'DELIVERY', 'BOTH'],
              trade,
              tradeLabel,
              (value) => trade = value,
            ),
            input(
              barcode,
              'product_barcode',
              '바코드 번호 (선택)',
              'EAN-13 또는 EAN-8',
              (value) {
                if (value == null || value.isEmpty) return null;
                return value.length == 8 || value.length == 13
                    ? null
                    : '바코드는 8자리 또는 13자리로 입력해주세요.';
              },
              number: true,
              maxLength: 13,
            ),
            AppField(
              fieldKey: const Key('product_description'),
              controller: description,
              label: '상품 설명',
              hint: '상품 설명을 입력하세요',
              minLines: 3,
              maxLines: 5,
              action: TextInputAction.newline,
            ),
            vGap20,
            SubmitButton(
              key: const Key('register_product_button'),
              label: '등록하기',
              busy: state.isSubmittingProduct,
              onPressed: submit,
              backgroundColor: AppColors.productAccent,
            ),
          ],
        ),
      ),
    );
  }

  String? Function(String?) requiredText(String message) =>
      (value) => value?.trim().isEmpty ?? true ? message : null;
  Widget input(
    TextEditingController controller,
    String keyName,
    String label,
    String hint,
    String? Function(String?) validator, {
    bool number = false,
    int? maxLength,
  }) => AppField(
    fieldKey: Key(keyName),
    controller: controller,
    label: label,
    hint: hint,
    validator: validator,
    keyboardType: number ? TextInputType.number : null,
    inputFormatters: number ? digits(maxLength) : null,
  ).pad(const EdgeInsets.only(top: 14));
  Widget select(
    String title,
    List<String> values,
    String selected,
    String Function(String) label,
    ValueChanged<String> changed,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title),
      Wrap(
        spacing: 6,
        children: [
          for (final value in values)
            ChoiceChip(
              label: Text(label(value)),
              selected: selected == value,
              selectedColor: AppColors.productAccent,
              onSelected: (_) => setState(() => changed(value)),
            ),
        ],
      ),
    ],
  ).pad(const EdgeInsets.only(top: 14));
  Widget errorText(String value) => Text(value, style: AppTextStyles.error);
}
