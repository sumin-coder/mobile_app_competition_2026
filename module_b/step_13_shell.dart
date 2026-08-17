import '../module_a/step_12_module_a.dart';
import 'step_09_favorites.dart';
import 'step_07_ui.dart';

class ModuleBShell extends StatefulWidget {
  const ModuleBShell({super.key});

  @override
  State<ModuleBShell> createState() => _ModuleBShellState();
}

class _ModuleBShellState extends State<ModuleBShell> {
  int page = 0;
  int exploreKey = 0;
  String? genre;

  void explore(String? value) => setState(() {
    page = 1;
    genre = value;
    exploreKey++;
  });

  void select(int value) {
    if (page == 2 && value != 2) context.moduleB.commitFavoriteChanges();
    setState(() => page = value);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: page,
      children: [
        HomeScreen(onExplore: explore),
        ExploreScreen(key: ValueKey(exploreKey), genreSeed: genre),
        const FavoritesScreen(),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: page,
      onDestinationSelected: select,
      destinations: [
        _destination('home', '홈'),
        _destination('search', '탐색'),
        _destination('heart', '관심상품'),
      ],
    ),
  );
}

NavigationDestination _destination(String icon, String label) =>
    NavigationDestination(icon: AssetIcon(commonIcon(icon)), label: label);
