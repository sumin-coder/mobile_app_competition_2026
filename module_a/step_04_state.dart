// Module A의 인증·상품 상태와 위젯 트리 상태 접근 방식을 관리합니다.

import 'package:flutter/widgets.dart';
import 'step_02_api.dart';
import 'step_01_models.dart';

// 목록 화면에서 로딩, 성공, 빈 상태, 오류를 공통으로 표현합니다.
enum LoadStatus { initial, loading, success, empty, error }

typedef ListStateUpdate<T> =
    void Function(LoadStatus status, String? error, List<T>? data);

// 여러 목록 상태에서 중복되는 비동기 로딩과 오류 처리를 담당합니다.
Future<void> loadListState<T>(
  Future<List<T>> Function() fetch, {
  required Object? Function() session,
  required ListStateUpdate<T> update,
  required VoidCallback notify,
  bool silent = false,
}) async {
  final activeSession = session();
  if (!silent) {
    update(LoadStatus.loading, null, null);
    notify();
  }
  try {
    final data = await fetch();
    if (session() != activeSession) return;
    update(data.isEmpty ? LoadStatus.empty : LoadStatus.success, null, data);
  } on Object catch (error) {
    if (session() != activeSession) return;
    update(
      LoadStatus.error,
      error is AppException ? error.message : '데이터를 불러오지 못했습니다.',
      null,
    );
  } finally {
    notify();
  }
}

// 로그인 세션과 전체 상품 목록을 소유하는 Module A 상태 로직입니다.
mixin ModuleAState on ChangeNotifier {
  ModuleARepository get moduleARepository;
  Future<void> loadAddedModules() async {}
  void clearAddedModules() {}

  AuthSession? session;
  List<Product> products = [];
  LoadStatus productStatus = LoadStatus.initial;
  String? productError;
  bool isAuthenticating = false;

  bool get isLoggedIn => session != null;
  User get user => session!.user;

  Future<void> login(String email, String password) async {
    if (isAuthenticating) return;
    isAuthenticating = true;
    notifyListeners();
    try {
      session = await moduleARepository.login(email, password);
      await Future.wait([refreshProducts(), loadAddedModules()]);
    } finally {
      isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<void> signup(SignupData data) => moduleARepository.signup(data);

  Future<void> logout() async {
    moduleARepository.clearSession();
    session = null;
    products = [];
    productStatus = LoadStatus.initial;
    clearAddedModules();
    notifyListeners();
  }

  Future<void> refreshProducts({bool silent = false}) =>
      _loadProducts(moduleARepository.getProducts, silent: silent);

  Future<List<Product>> searchProducts(String keyword) =>
      moduleARepository.getProducts(keyword);

  Future<void> _loadProducts(
    Future<List<Product>> Function() fetch, {
    bool silent = false,
  }) => loadListState(
    fetch,
    session: () => session,
    silent: silent,
    notify: notifyListeners,
    update: (status, error, data) {
      if (data != null) products = data;
      productStatus = status;
      if (status != LoadStatus.loading) productError = error;
    },
  );
}

// ChangeNotifier를 하위 화면에 전달하는 공통 InheritedNotifier입니다.
class StateScope<T extends ChangeNotifier> extends InheritedNotifier<T> {
  const StateScope({required T state, required super.child, super.key})
    : super(notifier: state);

  static T watch<T extends ChangeNotifier>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StateScope<T>>();
    assert(scope != null, 'StateScope<$T> was not found.');
    return scope!.notifier!;
  }
}

// Module A 상태를 위젯 트리에 주입하고 BuildContext에서 꺼내 씁니다.
class ModuleAStateScope extends StateScope<ModuleAState> {
  const ModuleAStateScope({
    required ChangeNotifier state,
    required super.child,
    super.key,
  }) : super(state: state as ModuleAState);
  static ModuleAState of(BuildContext context) => StateScope.watch(context);
}

extension ModuleAContext on BuildContext {
  ModuleAState get moduleA => ModuleAStateScope.of(this);
}
