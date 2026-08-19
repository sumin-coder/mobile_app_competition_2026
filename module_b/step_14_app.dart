// Module A/B 상태 주입과 인증 분기를 결합하는 Module B 최상위 위젯입니다.

import '../../module_a/step_08_auth.dart';
import 'step_05_app_state.dart';
import 'step_13_shell.dart';
import 'step_07_ui.dart';

Widget moduleBApp(ModuleBAppState state) => ModuleAStateScope(
  state: state,
  child: ModuleBStateScope(
    state: state,
    child: AuthApp(
      title: 'Vinyl Groove - Module B',
      state: state,
      home: const ModuleBShell(),
      signedOut: const LoginScreen(),
    ),
  ),
);
