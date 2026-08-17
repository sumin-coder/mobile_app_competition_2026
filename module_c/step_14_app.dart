import '../module_a/step_08_auth.dart';
import 'step_05_app_state.dart';
import 'step_13_shell.dart';
import 'step_07_ui.dart';

Widget vinylGrooveApp(AppState state) => ModuleAStateScope(
  state: state,
  child: ModuleBStateScope(
    state: state,
    child: ModuleCStateScope(
      state: state,
      child: AuthApp(
        title: 'Vinyl Groove',
        state: state,
        home: const MainShell(),
        signedOut: const LoginScreen(),
      ),
    ),
  ),
);
