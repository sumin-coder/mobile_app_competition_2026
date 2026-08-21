import '../module_a/step_02_api.dart';
import '../module_a/step_15_main.dart' as base;
import '../module_b/step_15_main.dart' as module_b;
import 'step_02_api.dart';
import 'step_04_state.dart';
import 'step_13_shell.dart';
Future<void> main() => startModuleCApp();
Future<void> startModuleCApp([String baseUrl = base.defaultBaseUrl]) {
  final state = AppState(
    ModuleCApi(ApiClient(baseUrl: base.resolveBaseUrl(baseUrl))),
  );
  return base.launchApp(
    base.competitionApp('Vinyl Groove', state, const MainShell()),
    state.initialize,
  );
}
class AppState extends module_b.ModuleBAppState with ModuleCState {
  AppState(this.moduleCRepository)
    : super(moduleCRepository, moduleCRepository);
  final ModuleCApi moduleCRepository;
  Future<void> loadAddedModules() =>
      Future.wait([startModuleB(), startModuleC()]);
  void clearAddedModules() {
    clearModuleB();
    clearModuleC();
  }
}
