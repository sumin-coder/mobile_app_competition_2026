import 'package:flutter/foundation.dart';
import '../module_a/api.dart';
import '../module_a/state.dart';
import '../module_b/api.dart';
import '../module_b/state.dart';
import 'api.dart';
import 'state.dart';

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
