import 'package:flutter/foundation.dart';
import '../module_a/step_02_api.dart';
import '../module_a/step_04_state.dart';
import '../module_b/step_02_api.dart';
import '../module_b/step_04_state.dart';
import 'step_02_api.dart';
import 'step_04_state.dart';

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
