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
