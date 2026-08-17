import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'module_a/api.dart';
import 'module_a/app.dart';
import 'module_a/app_state.dart';

const defaultBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://api.vinylgroove.com',
);

Future<void> main() => startModuleA();

Future<void> startModuleA([String baseUrl = defaultBaseUrl]) async {
  WidgetsFlutterBinding.ensureInitialized();
  final client = ApiClient(
    baseUrl: baseUrl.trim().isEmpty ? defaultBaseUrl : baseUrl,
  );
  final state = ModuleAAppState(moduleARepository: ModuleAApi(client));
  runApp(moduleAApp(state));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}
