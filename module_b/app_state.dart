import 'package:flutter/foundation.dart';
import '../module_a/api.dart';
import '../module_a/state.dart';
import 'api.dart';
import 'state.dart';

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
