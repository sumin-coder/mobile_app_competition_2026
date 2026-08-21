import 'package:flutter/services.dart';
class FavoriteStorage {
  static const _channel = MethodChannel('vinyl/native');
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
class NativeBarcodeController {
  static const _channel = MethodChannel('vinyl/native');
  ValueChanged<String>? onDetected;
  VoidCallback? onError;
  Future<bool> start() async {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'barcodeDetected':
          final value = call.arguments as String?;
          if (value?.isNotEmpty == true) onDetected?.call(value!);
        case 'barcodeError':
          onError?.call();
      }
    });
    return await _channel.invokeMethod<bool>('cameraPermission') ?? false;
  }
  void dispose() => _channel.setMethodCallHandler(null);
}
