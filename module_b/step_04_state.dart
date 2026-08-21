import 'dart:async';
import 'package:flutter/widgets.dart';
import '../../module_a/step_01_models.dart';
import '../../module_a/step_04_state.dart';
import 'step_02_api.dart';
import 'step_01_models.dart';
import 'step_03_native.dart';
mixin ModuleBState on ChangeNotifier {
  ModuleBApi get moduleBRepository;
  List<Product> get products;
  AuthSession? get session;
  Timer? _notificationTimer;
  List<PriceNotification> notifications = [];
  final Set<int> favoriteIds = {};
  final Set<int> disabledFavoriteIds = {};
  LoadStatus notificationStatus = LoadStatus.initial;
  String? notificationError;
  bool isUpdatingNotifications = false;
  final Set<int> readingNotificationIds = {};
  int get unreadCount => notifications.where((item) => !item.isRead).length;
  List<Product> get favoriteProducts =>
      products.where((product) => favoriteIds.contains(product.id)).toList();
  Future<void> initializeModuleB() async {
    favoriteIds.addAll(
      (await FavoriteStorage.strings(
        'favorite_ids',
      )).map(int.tryParse).whereType<int>(),
    );
  }
  Future<void> startModuleB() async {
    await refreshNotifications();
    _notificationTimer?.cancel();
    _notificationTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => refreshNotifications(silent: true),
    );
  }
  void clearModuleB() {
    _notificationTimer?.cancel();
    notifications = [];
    disabledFavoriteIds.clear();
    notificationStatus = LoadStatus.initial;
  }
  Future<void> refreshNotifications({bool silent = false}) => loadListState(
    moduleBRepository.getNotifications,
    session: () => session,
    silent: silent,
    notify: notifyListeners,
    update: (status, error, data) {
      if (data != null) notifications = data;
      notificationStatus = status;
      if (status != LoadStatus.loading) notificationError = error;
    },
  );
  Future<void> toggleFavorite(int id) =>
      _setFavorite(id, !favoriteIds.contains(id));
  Future<void> removeFavoriteNow(int id) => _setFavorite(id, false);
  Future<void> restoreFavorite(int id) => _setFavorite(id, true);
  Future<void> _setFavorite(int id, bool selected) => _updateFavorites(() {
    disabledFavoriteIds.remove(id);
    selected ? favoriteIds.add(id) : favoriteIds.remove(id);
  });
  void togglePendingFavorite(int id) {
    disabledFavoriteIds.toggle(id);
    notifyListeners();
    unawaited(_saveFavorites(disabledFavoriteIds));
  }
  Future<void> commitFavoriteChanges() async {
    if (disabledFavoriteIds.isEmpty) return;
    favoriteIds.removeAll(disabledFavoriteIds);
    disabledFavoriteIds.clear();
    notifyListeners();
    await _saveFavorites();
  }
  Future<void> _updateFavorites(VoidCallback update) async {
    update();
    notifyListeners();
    await _saveFavorites();
  }
  Future<void> markNotificationRead(int id) async {
    if (!readingNotificationIds.add(id)) return;
    try {
      await moduleBRepository.readNotification(id);
      for (final item in notifications) {
        if (item.id == id) item.isRead = true;
      }
      notifyListeners();
    } finally {
      readingNotificationIds.remove(id);
    }
  }
  Future<void> markAllNotificationsRead() =>
      _updateNotifications(moduleBRepository.readAllNotifications, () {
        for (final item in notifications) {
          item.isRead = true;
        }
      });
  Future<void> deleteAllNotifications() =>
      _updateNotifications(moduleBRepository.deleteAllNotifications, () {
        notifications = [];
        notificationStatus = LoadStatus.empty;
      });
  Future<void> _updateNotifications(
    Future<void> Function() request,
    VoidCallback update,
  ) async {
    if (isUpdatingNotifications) return;
    isUpdatingNotifications = true;
    try {
      await request();
      update();
      notifyListeners();
    } finally {
      isUpdatingNotifications = false;
    }
  }
  Future<Product?> findByBarcode(String barcode) =>
      moduleBRepository.findByBarcode(normalizeBarcode(barcode));
  Future<void> _saveFavorites([Set<int> excluded = const {}]) async {
    await FavoriteStorage.saveStrings(
      'favorite_ids',
      favoriteIds
          .where((id) => !excluded.contains(id))
          .map((id) => '$id')
          .toList(),
    );
  }
  void disposeModuleB() => _notificationTimer?.cancel();
}
mixin ModuleBLifecycle on ChangeNotifier, ModuleAState, ModuleBState {
  Future<void> initialize() => initializeModuleB();
  Future<void> loadAddedModules() => startModuleB();
  void clearAddedModules() => clearModuleB();
  void dispose() {
    disposeModuleB();
    super.dispose();
  }
}
extension ModuleBContext on BuildContext {
  ModuleBState get moduleB => StateScope.watch<ModuleBState>(
    this,
    'ModuleBStateScope was not found.',
  );
}
extension<T> on Set<T> {
  void toggle(T value) => add(value) ? null : remove(value);
}
