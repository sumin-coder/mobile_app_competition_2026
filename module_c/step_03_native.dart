// 상품 등록 화면의 카메라·갤러리 선택을 네이티브 플랫폼에 요청합니다.

import 'package:flutter/services.dart';

// 선택 가능한 사진 출처를 네이티브 채널에 전달할 값으로 정의합니다.
enum PhotoSource { camera, gallery }

class Native {
  static const _channel = MethodChannel('vinyl/native');

  static Future<String?> pickPhoto(PhotoSource source) =>
      _channel.invokeMethod<String>('pickPhoto', source.name);
}
