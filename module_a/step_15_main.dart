import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'step_02_api.dart';
import 'step_14_app.dart';
import 'step_05_app_state.dart';

const defaultBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://api.vinylgroove.com',
);

Future<void> main() => startModuleA();

Future<void> startModuleA([String baseUrl = defaultBaseUrl]) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final client = ApiClient(
    baseUrl: baseUrl.trim().isEmpty ? defaultBaseUrl : baseUrl,
  );
  final state = ModuleAAppState(moduleARepository: ModuleAApi(client));
  runApp(moduleAApp(state));
}
