import 'step_11_home.dart';
import 'step_10_explore.dart';
import 'step_07_ui.dart';

class ModuleAShell extends StatefulWidget {
  const ModuleAShell({super.key});

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

  Widget build(BuildContext context) => AppShell(
    index: page,
    pages: [
      HomeScreen(onExplore: explore, moduleBEnabled: false),
      ExploreScreen(
        key: ValueKey(exploreKey),
        genreSeed: genre,
        moduleBEnabled: false,
      ),
    ],
    select: (value) => setState(() => page = value),
    destinations: [appDestination('home', '홈'), appDestination('search', '탐색')],
  );
}
