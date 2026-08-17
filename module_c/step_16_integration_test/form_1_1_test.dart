import 'package:lp_app/module_a/step_06_widgets.dart';
import 'flow.dart';

void main() => formTest('FORM 1.1 로그인·탐색·관심상품 자동화 테스트', (tester) async {
  await tester.step(1, '애플리케이션 실행', () async {
    await startApp(tester);
  });
  await tester.step(2, '잘못된 이메일 형식으로 로그인 시도', () async {
    await tester.login('invalid-email', 'Test1234!');
    tester.see('올바른 이메일 형식을 입력해주세요.');
  });
  await tester.step(3, '입력 필드 초기화 후 짧은 비밀번호로 로그인 시도', () async {
    await tester.login('test@example.com', '123');
    tester.see('비밀번호는 6자 이상이어야 합니다.');
  });
  await tester.step(4, '입력 필드 초기화 후 정상 값으로 로그인 시도', () async {
    await tester.login('test@example.com', 'Test1234!');
    tester.see('홈');
  });
  await tester.step(5, '하단 네비게이션의 "탐색" 탭 클릭', () async {
    await tester.tap(find.text('탐색'));
  });
  await tester.step(6, '장르 필터 순차 클릭', () async {
    await tester.choose(['ROCK', 'JAZZ']);
  });
  await tester.step(7, '음반 상태 필터 순차 클릭', () async {
    await tester.choose(['NM', 'VG+']);
  });
  await tester.step(8, '"접기" 버튼 클릭', () async {
    await tester.tapWait(find.text('접기'));
    tester.see('필터 초기화');
  });
  await tester.step(9, '정렬 드롭다운 선택', () async {
    final dropdown = find.byKey(const Key('sort_dropdown'));
    await tester.reveal(dropdown, first: true);
    await tester.tapWait(dropdown);
    await tester.tap(find.text('인기 매물순').last);
  });
  late Finder card;
  late String album;
  await tester.step(10, '아래로 스크롤하여 15번째 상품 아이템까지 이동', () async {
    for (
      var i = 0;
      i < 8 && find.byType(ProductCard).evaluate().length < 15;
      i++
    ) {
      await tester.drag(find.byType(ListView).last, const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    card = find.byType(ProductCard).at(14);
    album = tester.widget<ProductCard>(card).product.albumName;
    await tester.ensureVisible(card);
    expect(card, findsOneWidget);
  });
  await tester.step(11, '15번째 상품 아이템 클릭', () async {
    await tester.tapWait(card);
    expect(find.byKey(const Key('favorite-button')), findsOneWidget);
  });
  await tester.step(12, '앱바 우측 관심 아이콘 버튼 클릭', () async {
    final heart = find.byKey(const Key('favorite-button'));
    await tester.tapWait(heart);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
  await tester.step(13, '뒤로가기 버튼 클릭 후 하단 네비게이션 "관심상품" 탭 클릭', () async {
    await tester.tapWait(find.byIcon(Icons.arrow_back));
    await tester.tap(find.text('관심상품'));
  });
  await tester.step(14, '등록된 관심 상품 아이템 리스트 표시 확인', () async {
    tester.see(album);
  });
  await tester.step(15, '첫 번째 아이템의 관심 아이콘 버튼 클릭', () async {
    await tester.tapWait(find.byKey(const Key('favorite-button')));
  });
  await tester.step(16, '비활성화 관심 상품 아이템 리스트 표시 확인', () async {
    tester.see(album);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });
  await tester.step(17, '하단 네비게이션 "홈" 탭 클릭', () async {
    await tester.tap(find.text('홈'));
  });
  await tester.step(18, '하단 네비게이션 "관심상품" 탭 클릭', () async {
    await tester.tap(find.text('관심상품'));
  });
  await tester.step(19, '비활성화 관심 상품 아이템 리스트 제거 확인', () async {
    tester.miss(album);
  });
});
