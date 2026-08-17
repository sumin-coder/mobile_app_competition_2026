import 'package:flutter/widgets.dart';
import 'step_02_api.dart';
import 'step_01_models.dart';

enum LoadStatus { initial, loading, success, empty, error }

typedef ListStateUpdate<T> =
    void Function(LoadStatus status, String? error, List<T>? data);

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

class StateScope<T extends ChangeNotifier> extends InheritedNotifier<T> {
  const StateScope({required T state, required super.child, super.key})
    : super(notifier: state);

  static T watch<T extends ChangeNotifier>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StateScope<T>>();
    assert(scope != null, 'StateScope<$T> was not found.');
    return scope!.notifier!;
  }
}

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
