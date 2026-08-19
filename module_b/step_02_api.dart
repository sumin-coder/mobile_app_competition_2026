// 바코드 검색과 가격 알림에 필요한 Module B 서버 통신을 담당합니다.

import '../../module_a/step_02_api.dart';
import '../../module_a/step_01_models.dart';
import 'step_01_models.dart';

// 상태 로직이 사용하는 Module B API 기능의 계약입니다.
abstract interface class ModuleBRepository {
  Future<Product?> findByBarcode(String barcode);
  Future<List<PriceNotification>> getNotifications();
  Future<void> readNotification(int id);
  Future<void> readAllNotifications();
  Future<void> deleteAllNotifications();
}

// 공통 ApiClient를 이용해 바코드·알림 서버 경로를 호출합니다.
class ModuleBApi implements ModuleBRepository {
  ModuleBApi(this.client);
  final ApiClient client;

  Future<Product?> findByBarcode(String barcode) async {
    final products = client.products(
      await client.request(
        'GET',
        '/products',
        query: {'barcode': normalizeBarcode(barcode)},
      ),
    );
    return products.isEmpty ? null : products.first;
  }

  Future<List<PriceNotification>> getNotifications() async => client
      .list(
        client.map(
          await client.request('GET', '/notifications'),
        )['notifications'],
      )
      .map((json) => PriceNotification.fromJson(json, baseUri: client.baseUri))
      .toList();

  Future<void> readNotification(int id) =>
      client.send('PUT', '/notifications/read', query: {'id': '$id'});

  Future<void> readAllNotifications() =>
      client.send('PUT', '/notifications/read', query: {'all': 'true'});

  Future<void> deleteAllNotifications() =>
      client.send('DELETE', '/notifications');
}

String normalizeBarcode(String barcode) => barcode.trim();
