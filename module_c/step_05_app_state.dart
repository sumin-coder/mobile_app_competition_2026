import 'package:flutter/foundation.dart';
import '../module_a/step_02_api.dart';
import '../module_a/step_04_state.dart';
import '../module_b/step_02_api.dart';
import '../module_b/step_04_state.dart';
import 'step_02_api.dart';
import 'step_04_state.dart';

class AppState extends ChangeNotifier
    with ModuleAState, ModuleBState, ModuleCState {
  AppState({
    required this.moduleARepository,
    required this.moduleBRepository,
    required this.moduleCRepository,
  });

  @override
  final ModuleARepository moduleARepository;
  @override
  final ModuleBRepository moduleBRepository;
  @override
  final ModuleCRepository moduleCRepository;

  Future<void> initialize() => initializeModuleB();

  @override
  Future<void> loadAddedModules() =>
      Future.wait([startModuleB(), startModuleC()]);

  @override
  void clearAddedModules() {
    clearModuleB();
    clearModuleC();
  }

  @override
  void dispose() {
    disposeModuleB();
    super.dispose();
  }
}
