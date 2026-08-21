import '../../module_a/step_02_api.dart';
import '../../module_a/step_15_main.dart' as base;
import 'step_02_api.dart';
import 'step_04_state.dart';
import 'step_13_shell.dart';
Future<void> main() => startModuleB();
Future<void> startModuleB([String baseUrl = base.defaultBaseUrl]) {
  final client = ApiClient(baseUrl: base.resolveBaseUrl(baseUrl));
  final api = ModuleBApi(client);
  final state = ModuleBAppState(api, api);
  return base.launchApp(
    base.competitionApp('Vinyl Groove - Module B', state, const ModuleBShell()),
    state.initialize,
  );
}
class ModuleBAppState extends base.ModuleAAppState
    with ModuleBState, ModuleBLifecycle {
  ModuleBAppState(super.moduleARepository, this.moduleBRepository);
  final ModuleBApi moduleBRepository;
}
