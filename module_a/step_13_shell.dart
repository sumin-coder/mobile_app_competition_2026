import 'step_11_home.dart';
import 'step_10_explore.dart';
import 'step_07_ui.dart';

class ModuleAShell extends StatefulWidget {
  const ModuleAShell({super.key});

  @override
  State<ModuleAShell> createState() => _ModuleAShellState();
}

class _ModuleAShellState extends State<ModuleAShell> {
  int page = 0;
  int exploreKey = 0;
  String? genre;

  void explore(String? value) => setState(() {
    page = 1;
    genre = value;
    exploreKey++;
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: page,
      children: [
        HomeScreen(onExplore: explore, moduleBEnabled: false),
        ExploreScreen(
          key: ValueKey(exploreKey),
          genreSeed: genre,
          moduleBEnabled: false,
        ),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: page,
      onDestinationSelected: (value) => setState(() => page = value),
      destinations: [_destination('home', '홈'), _destination('search', '탐색')],
    ),
  );
}

NavigationDestination _destination(String icon, String label) =>
    NavigationDestination(icon: AssetIcon(commonIcon(icon)), label: label);
