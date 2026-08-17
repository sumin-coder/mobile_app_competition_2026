import 'package:flutter/widgets.dart';
import '../module_a/step_01_models.dart';
import '../module_a/step_04_state.dart';
import 'step_02_api.dart';
import 'step_01_models.dart';

mixin ModuleCState on ChangeNotifier {
  ModuleCRepository get moduleCRepository;
  AuthSession? get session;
  Future<void> refreshProducts({bool silent = false});

  List<Product> myProducts = [];
  LoadStatus myProductStatus = LoadStatus.initial;
  String? myProductError;
  bool isSubmittingProduct = false;

  Future<void> startModuleC() => refreshMyProducts();

  void clearModuleC() {
    myProducts = [];
    myProductStatus = LoadStatus.initial;
  }

  Future<void> refreshMyProducts() async {
    final activeSession = session;
    myProductStatus = LoadStatus.loading;
    notifyListeners();
    try {
      final data = await moduleCRepository.getMyProducts();
      if (session != activeSession) return;
      myProducts = data;
      myProductStatus = data.isEmpty ? LoadStatus.empty : LoadStatus.success;
      myProductError = null;
    } on Object catch (error) {
      if (session != activeSession) return;
      myProductStatus = LoadStatus.error;
      myProductError = error is AppException
          ? error.message
          : '데이터를 불러오지 못했습니다.';
    } finally {
      notifyListeners();
    }
  }

  Future<void> addProduct(ProductDraft draft) async {
    if (isSubmittingProduct) return;
    isSubmittingProduct = true;
    notifyListeners();
    try {
      await moduleCRepository.addProduct(draft);
      await _refreshProductLists();
    } finally {
      isSubmittingProduct = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    await moduleCRepository.deleteProduct(id);
    await _refreshProductLists();
  }

  Future<void> _refreshProductLists() =>
      Future.wait([refreshProducts(silent: true), refreshMyProducts()]);
}

class ModuleCStateScope extends InheritedNotifier<ChangeNotifier> {
  const ModuleCStateScope({
    required ChangeNotifier state,
    required super.child,
    super.key,
  }) : super(notifier: state);

  static ModuleCState of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ModuleCStateScope>();
    assert(scope != null, 'ModuleCStateScope was not found.');
    return scope!.notifier! as ModuleCState;
  }
}

extension ModuleCContext on BuildContext {
  ModuleCState get moduleC => ModuleCStateScope.of(this);
}
