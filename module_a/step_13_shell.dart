import 'step_11_home.dart';
import 'step_10_explore.dart';
import 'step_07_ui.dart';
List<Widget> marketPages(
  ValueChanged<String?> explore,
  int key,
  String? genre, [
  ModuleAFeatures features = emptyModuleAFeatures,
]) => [
  HomeScreen(onExplore: explore, features: features),
  ExploreScreen(key: ValueKey(key), genreSeed: genre, features: features),
];
class ModuleAShell extends StatefulWidget {
  const ModuleAShell({super.key});
  State<ModuleAShell> createState() => _ModuleAShellState();
}
class _ModuleAShellState extends State<ModuleAShell>
    with ExploreShellState<ModuleAShell> {
  Widget build(BuildContext context) => AppShell(
    index: page,
    pages: marketPages(explore, exploreKey, genre),
    select: (value) => setState(() => page = value),
    destinations: [appDestination('home', '홈'), appDestination('search', '탐색')],
  );
}
