// Module A 상태 주입, 인증 분기, 앱 테마를 결합하는 최상위 위젯입니다.

import 'step_05_app_state.dart';
import 'step_08_auth.dart';
import 'step_13_shell.dart';
import 'step_07_ui.dart';

Widget moduleAApp(ModuleAAppState state) => ModuleAStateScope(
  state: state,
  child: AuthApp(
    title: 'Vinyl Groove - Module A',
    state: state,
    home: const ModuleAShell(),
    signedOut: const LoginScreen(),
  ),
);
