// Module A의 홈·탐색 탭 전환과 홈에서 탐색으로 이동하는 흐름을 관리합니다.

import 'step_11_home.dart';
import 'step_10_explore.dart';
import 'step_07_ui.dart';

// Module A 단독 실행 시 사용하는 하단 내비게이션 셸입니다.
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
      HomeScreen(onExplore: explore),
      ExploreScreen(
        key: ValueKey(exploreKey),
        genreSeed: genre,
      ),
    ],
    select: (value) => setState(() => page = value),
    destinations: [appDestination('home', '홈'), appDestination('search', '탐색')],
  );
}
