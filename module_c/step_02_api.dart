import 'dart:convert';
import 'dart:io';
import '../module_a/step_02_api.dart';
import '../module_a/step_01_models.dart';
import 'step_01_models.dart';

abstract interface class ModuleCRepository {
  Future<Product> addProduct(ProductDraft draft);
  Future<List<Product>> getMyProducts();
  Future<void> deleteProduct(int id);
}

class CumulativeModuleAApi extends ModuleAApi {
  CumulativeModuleAApi(super.client);

  Future<AuthSession> login(String email, String password) async {
    try {
      return saveSession(await loginRequest('/auth/login/v2', email, password));
    } on AppException catch (error) {
      if (error.statusCode != 404 && error.statusCode != 405) rethrow;
      return super.login(email, password);
    }
  }
}

class ModuleCApi implements ModuleCRepository {
  ModuleCApi(this.client);
  final ApiClient client;

  Future<Product> addProduct(ProductDraft draft) async {
    late final List<int> bytes;
    try {
      bytes = await File(draft.imagePath).readAsBytes();
    } on FileSystemException {
      throw const AppException('상품 이미지를 불러오지 못했습니다.');
    }
    final mimeType = switch (draft.imagePath.split('.').last.toLowerCase()) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
    final uploadData = client.map(
      await client.request(
        'POST',
        '/upload/image',
        body: {
          'image': 'data:$mimeType;base64,${base64Encode(bytes)}',
          'type': 'ALBUM',
        },
      ),
    );
    final imageUrl =
        uploadData['url'] as String? ?? uploadData['imageUrl'] as String? ?? '';
    return client.product(
      await client.request('POST', '/products', body: draft.json(imageUrl)),
    );
  }

  Future<List<Product>> getMyProducts() async =>
      client.products(await client.request('GET', '/products/me'));

  Future<void> deleteProduct(int id) => client.send('DELETE', '/products/$id');
}
