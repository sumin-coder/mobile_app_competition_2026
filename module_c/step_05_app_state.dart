// Module A/B/C의 저장소와 상태를 모두 결합한 누적 앱의 단일 상태 객체입니다.

import 'package:flutter/foundation.dart';
import '../module_a/step_02_api.dart';
import '../module_a/step_04_state.dart';
import '../module_b/step_02_api.dart';
import '../module_b/step_04_state.dart';
import 'step_02_api.dart';
import 'step_04_state.dart';

// 로그인 생명주기에 세 모듈의 로딩·정리 작업을 함께 연결합니다.
class AppState extends ChangeNotifier
    with ModuleAState, ModuleBState, ModuleCState, ModuleBLifecycle {
  AppState({
    required this.moduleARepository,
    required this.moduleBRepository,
    required this.moduleCRepository,
  });

  final ModuleARepository moduleARepository;
  final ModuleBRepository moduleBRepository;
  final ModuleCRepository moduleCRepository;

  Future<void> loadAddedModules() =>
      Future.wait([startModuleB(), startModuleC()]);

  void clearAddedModules() {
    clearModuleB();
    clearModuleC();
  }
}
