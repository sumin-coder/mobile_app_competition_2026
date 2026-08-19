// Module A 저장소와 상태 로직을 결합해 앱에서 사용할 단일 상태 객체를 만듭니다.

import 'package:flutter/foundation.dart';
import 'step_02_api.dart';
import 'step_04_state.dart';

class ModuleAAppState extends ChangeNotifier with ModuleAState {
  ModuleAAppState({required this.moduleARepository});

  final ModuleARepository moduleARepository;
}
