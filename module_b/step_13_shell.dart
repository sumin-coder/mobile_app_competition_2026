import '../module_a/step_12_module_a.dart';
import 'step_09_favorites.dart';
import 'step_12_features.dart';
import 'step_07_ui.dart';

class ModuleBShell extends StatefulWidget {
  const ModuleBShell({super.key});

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

  Widget build(BuildContext context) => AppShell(
    index: page,
    pages: [
      HomeScreen(onExplore: explore, features: moduleBFeatures()),
      ExploreScreen(
        key: ValueKey(exploreKey),
        genreSeed: genre,
        features: moduleBFeatures(),
      ),
      const FavoritesScreen(),
    ],
    select: select,
    destinations: [
      appDestination('home', '홈'),
      appDestination('search', '탐색'),
      appDestination('heart', '관심상품'),
    ],
  );
}
