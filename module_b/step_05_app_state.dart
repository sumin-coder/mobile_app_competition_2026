import 'package:flutter/foundation.dart';
import '../module_a/step_02_api.dart';
import '../module_a/step_04_state.dart';
import 'step_02_api.dart';
import 'step_04_state.dart';

class ModuleBAppState extends ChangeNotifier with ModuleAState, ModuleBState {
  ModuleBAppState({
    required this.moduleARepository,
    required this.moduleBRepository,
  });

  @override
  final ModuleARepository moduleARepository;

  @override
  final ModuleBRepository moduleBRepository;

  Future<void> initialize() => initializeModuleB();

  @override
  Future<void> loadAddedModules() => startModuleB();

  @override
  void clearAddedModules() => clearModuleB();

  @override
  void dispose() {
    disposeModuleB();
    super.dispose();
  }
}
