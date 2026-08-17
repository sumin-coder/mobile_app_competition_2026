// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:lp_app/module_c/step_12_module_c.dart';
import 'package:lp_app/module_c/step_03_native.dart';
import 'flow.dart';

void main() => formTest('FORM 1.2 상품 등록·삭제·로그아웃 자동화 테스트', (tester) async {
  final directory = await Directory.systemTemp.createTemp('vinyl_test_');
  final image = File('${directory.path}/vinyl_sample.png');
  await image.writeAsBytes(
    (await rootBundle.load(
      'assets/Common/001. simbol/app_icon.png',
    )).buffer.asUint8List(),
  );
  productImagePickerOverride = (source) async {
    expect(source, PhotoSource.gallery);
    return image.path;
  };
  addTearDown(() async {
    productImagePickerOverride = null;
    await directory.delete(recursive: true);
  });
  await tester.step(1, '애플리케이션 실행', () async {
    await startApp(tester);
  });
  await tester.step(2, '로그인 시도', () async {
    await tester.login('test@example.com', 'Test1234!');
    tester.see('홈');
  });
  await tester.step(3, '하단 네비게이션 상품 등록 진입 버튼 클릭', () async {
    await tester.tapWait(find.byType(NavigationDestination).at(2));
    tester.see('상품 등록');
  });
  final register = find.byKey(const Key('register_product_button'));
  await tester.step(4, '"등록하기" 버튼 클릭', () async {
    await tester.reveal(register);
    await tester.tapWait(register);
    tester.see('상품 이미지를 등록해주세요.');
  });
  await tester.step(5, '이미지 영역 클릭 후 "갤러리에서 선택" 메뉴 선택하여 이미지 선택', () async {
    final picker = find.byKey(const Key('product_image_picker'));
    await tester.reveal(picker, reverse: true);
    await tester.tapWait(picker);
    await tester.tapWait(find.text('갤러리에서 선택'));
    tester.miss('상품 이미지를 등록하세요');
  });
  await tester.step(6, '앨범명 입력상자 선택 후 앨범명 입력', () async {
    await tester.write('product_album', 'Test Vinyl Album');
  });
  await tester.step(7, '아티스트 입력상자 선택 후 아티스트 입력', () async {
    await tester.write('product_artist', 'Test Artist');
  });
  final price = find.byKey(const Key('product_price'));
  await tester.step(8, '가격 입력 상자 선택 후 가격 입력', () async {
    await tester.reveal(price);
    await tester.enterWait(price, '500');
    tester.see('500');
  });
  await tester.step(9, '상품 설명 상자 선택 후 상품 설명 입력', () async {
    await tester.write(
      'product_description',
      '테스트용 바이닐 앨범입니다.',
      revealField: true,
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  });
  await tester.step(10, '"등록하기" 버튼 클릭', () async {
    await tester.reveal(register);
    await tester.tapWait(register);
    await tester.reveal(price, reverse: true);
    tester.see('가격은 1,000원 이상 입력해주세요.');
  });
  await tester.step(11, '가격 입력 상자 선택 후 새 가격 입력', () async {
    await tester.enterText(price, '45000');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    tester.see('45000');
  });
  await tester.step(12, '"등록하기" 버튼 클릭', () async {
    await tester.reveal(register);
    await tester.tapWait(register);
    tester.see('상품이 등록되었습니다.');
  });
  await tester.step(13, '하단 네비게이션 "마이페이지" 탭 클릭', () async {
    await tester.tap(find.text('마이페이지'));
  });
  await tester.step(14, '"내 등록 상품" 메뉴 클릭', () async {
    await tester.tap(find.text('내 등록 상품'));
  });
  await tester.step(15, '등록된 첫 번째 상품 아이템 리스트 표시 확인', () async {
    tester.see('Test Vinyl Album');
  });
  await tester.step(16, '첫 번째 상품 아이템 삭제 아이콘 버튼 클릭', () async {
    await tester.tapWait(find.byIcon(Icons.delete).first);
    tester.see('Test Vinyl Album을(를) 삭제하시겠습니까?');
  });
  await tester.step(17, '다이얼로그의 "삭제" 버튼 클릭', () async {
    await tester.tap(find.widgetWithText(FilledButton, '삭제'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    tester.see('상품이 삭제되었습니다.');
  });
  await tester.step(18, '등록 상품 목록 빈 상태 확인', () async {
    tester.see('등록된 상품이 없습니다.');
  });
  await tester.step(19, '뒤로가기 버튼 클릭', () async {
    await tester.pageBack();
  });
  await tester.step(20, '"로그아웃" 버튼 클릭', () async {
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tapWait(find.text('로그아웃'));
    tester.see('정말 로그아웃 하시겠습니까?');
  });
  await tester.step(21, '로그아웃 확인 다이얼로그의 "로그아웃" 버튼 클릭', () async {
    await tester.tap(find.widgetWithText(FilledButton, '로그아웃'));
  });
  await tester.step(22, '로그인 화면 정상 표시 확인', () async {
    for (final key in ['login_email', 'login_password']) {
      expect(
        tester.widget<TextFormField>(find.byKey(Key(key))).controller?.text,
        isEmpty,
      );
    }
  });
});
