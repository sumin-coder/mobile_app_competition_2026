import 'dart:async';
import 'package:flutter/widgets.dart';
import '../module_a/step_01_models.dart';
import '../module_a/step_04_state.dart';
import 'step_02_api.dart';
import 'step_01_models.dart';
import 'step_03_native.dart';

mixin ModuleBState on ChangeNotifier {
  ModuleBRepository get moduleBRepository;
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

  Future<void> refreshNotifications({bool silent = false}) async {
    final activeSession = session;
    if (!silent) {
      notificationStatus = LoadStatus.loading;
      notifyListeners();
    }
    try {
      final data = await moduleBRepository.getNotifications();
      if (session != activeSession) return;
      notifications = data;
      notificationStatus = data.isEmpty ? LoadStatus.empty : LoadStatus.success;
      notificationError = null;
    } on Object catch (error) {
      if (session != activeSession) return;
      notificationStatus = LoadStatus.error;
      notificationError = error is AppException
          ? error.message
          : '데이터를 불러오지 못했습니다.';
    } finally {
      notifyListeners();
    }
  }

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

class ModuleBStateScope extends InheritedNotifier<ChangeNotifier> {
  const ModuleBStateScope({
    required ChangeNotifier state,
    required super.child,
    super.key,
  }) : super(notifier: state);

  static ModuleBState of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ModuleBStateScope>();
    assert(scope != null, 'ModuleBStateScope was not found.');
    return scope!.notifier! as ModuleBState;
  }
}

extension ModuleBContext on BuildContext {
  ModuleBState get moduleB => ModuleBStateScope.of(this);
}

extension<T> on Set<T> {
  void toggle(T value) => add(value) ? null : remove(value);
}
