// 관심상품 ID를 Android 네이티브 저장소에 보관하고 테스트 메모리 저장소도 지원합니다.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FavoriteStorage {
  static const _channel = MethodChannel('vinyl/native');

  @visibleForTesting
  static Map<String, List<String>>? memory;

  static Future<List<String>> strings(String key) async => memory == null
      ? List<String>.from(
          await _channel.invokeMethod('getStrings', key) ?? const [],
        )
      : memory![key] ?? const [];

  static Future<void> saveStrings(String key, List<String> value) async {
    if (memory case final store?) {
      store[key] = value;
    } else {
      await _channel.invokeMethod('saveStrings', {'key': key, 'value': value});
    }
  }
}
