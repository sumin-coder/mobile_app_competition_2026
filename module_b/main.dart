import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../module_a/api.dart';
import 'api.dart';
import 'app.dart';
import 'app_state.dart';

const defaultBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://api.vinylgroove.com',
);

Future<void> main() => startModuleB();

Future<void> startModuleB([String baseUrl = defaultBaseUrl]) async {
  WidgetsFlutterBinding.ensureInitialized();
  final client = ApiClient(
    baseUrl: baseUrl.trim().isEmpty ? defaultBaseUrl : baseUrl,
  );
  final state = ModuleBAppState(
    moduleARepository: ModuleAApi(client),
    moduleBRepository: ModuleBApi(client),
  );
  runApp(moduleBApp(state));
  await Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    state.initialize(),
  ]);
}
