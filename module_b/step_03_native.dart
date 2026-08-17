import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FavoriteStorage {
  static const _channel = MethodChannel('vinyl/native');

  @visibleForTesting
  static Map<String, List<String>>? memory;

  static Future<List<String>> strings(String key) async =>
      memory?[key] ??
      List<String>.from(
        await _channel.invokeMethod('getStrings', key) ?? const [],
      );

  static Future<void> saveStrings(String key, List<String> value) async {
    if (memory case final store?) {
      store[key] = value;
    } else {
      await _channel.invokeMethod('saveStrings', {'key': key, 'value': value});
    }
  }
}
