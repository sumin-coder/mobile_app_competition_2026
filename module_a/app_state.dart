import 'package:flutter/foundation.dart';
import 'api.dart';
import 'state.dart';

class ModuleAAppState extends ChangeNotifier with ModuleAState {
  ModuleAAppState({required this.moduleARepository});

  @override
  final ModuleARepository moduleARepository;
}
