// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lp_app/module_c/main.dart' as app;
import 'package:lp_app/module_b/native.dart';

export 'package:flutter/material.dart';
export 'package:flutter_test/flutter_test.dart';

void formTest(String name, WidgetTesterCallback body) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(name, body);
}

extension Flow on WidgetTester {
  Future<void> tapWait(Finder target) async {
    await tap(target);
    await pumpAndSettle();
  }

  Future<void> enterWait(Finder target, String text) async {
    await enterText(target, text);
    await pumpAndSettle();
  }

  Future<void> write(
    String key,
    String text, {
    bool revealField = false,
  }) async {
    final field = find.byKey(Key(key));
    if (revealField) await reveal(field);
    await enterWait(field, text);
    expect(find.text(text), findsOneWidget);
  }

  Future<void> choose(Iterable<String> values) async {
    for (final value in values) {
      final chip = find.byKey(Key('filter_$value'));
      await tapWait(chip);
      expect(widget<ChoiceChip>(chip).selected, isTrue);
    }
  }

  void see(String text) => expect(find.text(text), findsOneWidget);
  void miss(String text) => expect(find.text(text), findsNothing);

  Future<void> step(int no, String action, Future<void> Function() run) async {
    debugPrint('[STEP No.$no] $action');
    await run();
    await pumpAndSettle();
    await pump(const Duration(seconds: 5));
  }

  Future<void> login(String email, String password) async {
    for (final (key, text) in [
      ('login_email', email),
      ('login_password', password),
    ]) {
      await enterText(find.byKey(Key(key)), text);
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await pumpAndSettle();
    final button = find.byKey(const Key('login_button'));
    await ensureVisible(button);
    await tap(button);
    await pumpAndSettle();
  }

  Future<void> reveal(
    Finder finder, {
    bool reverse = false,
    bool first = false,
  }) async {
    for (var i = 0; i < 8 && finder.evaluate().isEmpty; i++) {
      final down = reverse || first && i < 4;
      await drag(
        first ? find.byType(ListView).first : find.byType(ListView).last,
        Offset(0, down ? 300 : -300),
      );
      await pumpAndSettle();
    }
    expect(finder, findsOneWidget);
    await ensureVisible(finder);
    await pumpAndSettle();
  }
}

Future<void> startApp(WidgetTester tester) async {
  FavoriteStorage.memory = {};
  await app.startModuleCApp('');
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('login_button')), findsOneWidget);
}
