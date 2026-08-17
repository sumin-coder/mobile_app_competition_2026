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

  Future<void> refreshMyProducts() => loadListState(
    moduleCRepository.getMyProducts,
    session: () => session,
    notify: notifyListeners,
    update: (status, error, data) {
      if (data != null) myProducts = data;
      myProductStatus = status;
      if (status != LoadStatus.loading) myProductError = error;
    },
  );

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

class ModuleCStateScope extends StateScope<ModuleCState> {
  const ModuleCStateScope({
    required ChangeNotifier state,
    required super.child,
    super.key,
  }) : super(state: state as ModuleCState);
  static ModuleCState of(BuildContext context) => StateScope.watch(context);
}

extension ModuleCContext on BuildContext {
  ModuleCState get moduleC => ModuleCStateScope.of(this);
}
