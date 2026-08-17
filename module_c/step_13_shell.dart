import '../module_a/step_12_module_a.dart';
import '../module_b/step_12_module_b.dart';
import 'step_12_module_c.dart';
import 'step_07_ui.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int page = 0, exploreKey = 0;
  String? genre;
  void explore(String? value) => setState(() {
    page = 1;
    genre = value;
    exploreKey++;
  });
  Future<void> add() async {
    await context.openPage<bool>(const AddProductScreen());
  }

  void select(int value) {
    if (value == 2) {
      add();
      return;
    }
    if (page == 3 && value != 3) {
      context.moduleB.commitFavoriteChanges();
    }
    setState(() => page = value);
  }

  Widget build(BuildContext context) {
    final pages = [
          HomeScreen(onExplore: explore),
          ExploreScreen(key: ValueKey(exploreKey), genreSeed: genre),
          const SizedBox(),
          const FavoritesScreen(),
          const ProfileScreen(),
        ],
        destinations = [
          _nav('home', '홈'),
          _nav('search', '탐색'),
          NavigationDestination(
            icon: _addButton(),
            selectedIcon: _addButton(),
            label: '',
            tooltip: '상품 등록',
          ),
          _nav('heart', '관심상품'),
          _nav('mypage', '마이페이지'),
        ];
    return Scaffold(
      body: IndexedStack(index: page, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: select,
        destinations: destinations,
      ),
    );
  }
}

NavigationDestination _nav(String icon, String label) =>
    NavigationDestination(icon: AssetIcon(commonIcon(icon)), label: label);

Widget _addButton() => Container(
  key: const Key('add-navigation-button'),
  width: 48,
  height: 38,
  decoration: const BoxDecoration(
    color: AppColors.primary,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 3)),
    ],
  ),
  child: const Icon(Icons.add, size: 28, color: AppColors.onPrimary),
);
