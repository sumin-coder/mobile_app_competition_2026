import 'package:flutter/widgets.dart';
import 'api.dart';
import 'models.dart';

enum LoadStatus { initial, loading, success, empty, error }

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
  }) async {
    final activeSession = session;
    if (!silent) {
      productStatus = LoadStatus.loading;
      notifyListeners();
    }
    try {
      final data = await fetch();
      if (session != activeSession) return;
      products = data;
      productStatus = data.isEmpty ? LoadStatus.empty : LoadStatus.success;
      productError = null;
    } on Object catch (error) {
      if (session != activeSession) return;
      productStatus = LoadStatus.error;
      productError = error is AppException ? error.message : '데이터를 불러오지 못했습니다.';
    } finally {
      notifyListeners();
    }
  }
}

class ModuleAStateScope extends InheritedNotifier<ChangeNotifier> {
  const ModuleAStateScope({
    required ChangeNotifier state,
    required super.child,
    super.key,
  }) : super(notifier: state);

  static ModuleAState of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ModuleAStateScope>();
    assert(scope != null, 'ModuleAStateScope was not found.');
    return scope!.notifier! as ModuleAState;
  }
}

extension ModuleAContext on BuildContext {
  ModuleAState get moduleA => ModuleAStateScope.of(this);
}
