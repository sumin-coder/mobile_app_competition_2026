import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'step_02_api.dart';
import 'step_04_state.dart';
import 'step_06_widgets.dart';
import 'step_08_auth.dart';
import 'step_13_shell.dart';
const defaultBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://api.vinylgroove.com',
);
Future<void> main() => startModuleA();
Widget competitionApp(String title, ChangeNotifier state, Widget home) =>
    AuthApp(
      title: title,
      state: state,
      home: home,
      signedOut: const LoginScreen(),
    );
String resolveBaseUrl(String value) =>
    value.trim().isEmpty ? defaultBaseUrl : value;
Future<void> launchApp(
  Widget app, [
  Future<void> Function()? initialize,
]) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(app);
  await initialize?.call();
}
Future<void> startModuleA([String baseUrl = defaultBaseUrl]) {
  final client = ApiClient(baseUrl: resolveBaseUrl(baseUrl));
  final state = ModuleAAppState(ModuleAApi(client));
  return launchApp(
    competitionApp('Vinyl Groove - Module A', state, const ModuleAShell()),
  );
}
class ModuleAAppState extends ChangeNotifier with ModuleAState {
  ModuleAAppState(this.moduleARepository);
  final ModuleAApi moduleARepository;
}
