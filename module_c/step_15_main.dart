import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../module_a/step_02_api.dart';
import '../module_b/step_02_api.dart';
import 'step_02_api.dart';
import 'step_14_app.dart';
import 'step_05_app_state.dart';

const defaultBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://api.vinylgroove.com',
);

Future<void> main() => startModuleCApp();

Future<void> startModuleCApp([String baseUrl = defaultBaseUrl]) async {
  WidgetsFlutterBinding.ensureInitialized();
  final client = ApiClient(
    baseUrl: baseUrl.trim().isEmpty ? defaultBaseUrl : baseUrl,
  );
  final state = AppState(
    moduleARepository: CumulativeModuleAApi(client),
    moduleBRepository: ModuleBApi(client),
    moduleCRepository: ModuleCApi(client),
  );
  runApp(vinylGrooveApp(state));
  await Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    state.initialize(),
  ]);
}
