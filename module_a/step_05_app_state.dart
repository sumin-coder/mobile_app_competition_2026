import 'package:flutter/foundation.dart';
import 'step_02_api.dart';
import 'step_04_state.dart';

class ModuleAAppState extends ChangeNotifier with ModuleAState {
  ModuleAAppState({required this.moduleARepository});

  @override
  final ModuleARepository moduleARepository;
}
