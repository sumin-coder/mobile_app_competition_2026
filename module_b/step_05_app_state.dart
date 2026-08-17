import 'package:flutter/foundation.dart';
import '../module_a/step_02_api.dart';
import '../module_a/step_04_state.dart';
import 'step_02_api.dart';
import 'step_04_state.dart';

class ModuleBAppState extends ChangeNotifier
    with ModuleAState, ModuleBState, ModuleBLifecycle {
  ModuleBAppState({
    required this.moduleARepository,
    required this.moduleBRepository,
  });

  final ModuleARepository moduleARepository;
  final ModuleBRepository moduleBRepository;
}
