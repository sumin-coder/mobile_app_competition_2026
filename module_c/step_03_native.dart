import 'package:flutter/services.dart';

enum PhotoSource { camera, gallery }

class Native {
  static const _channel = MethodChannel('vinyl/native');

  static Future<String?> pickPhoto(PhotoSource source) =>
      _channel.invokeMethod<String>('pickPhoto', source.name);
}
