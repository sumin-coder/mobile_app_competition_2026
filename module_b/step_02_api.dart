import '../../module_a/step_02_api.dart';
import '../../module_a/step_01_models.dart';
import 'step_01_models.dart';
class ModuleBApi extends ModuleAApi {
  ModuleBApi(super.client);
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
String normalizeBarcode(String barcode) {
  final digits = barcode.replaceAll(RegExp(r'\D'), '');
  return digits.length < 13 ? digits.padLeft(13, '0') : digits;
}
