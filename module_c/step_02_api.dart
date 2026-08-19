// 상품 등록·내 상품 조회·삭제와 누적 모듈용 로그인 API를 구현합니다.

import 'dart:convert';
import 'dart:io';

import '../module_a/step_01_models.dart';
import '../module_a/step_02_api.dart';
import 'step_01_models.dart';

// Module C 상태가 사용하는 상품 관리 API 계약입니다.
abstract interface class ModuleCRepository {
  Future<Product> addProduct(ProductDraft draft);
  Future<List<Product>> getMyProducts();
  Future<void> deleteProduct(int id);
}

// 누적 앱 서버의 신규 로그인 경로를 우선 사용하고 구버전 서버도 지원합니다.
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

// 이미지 업로드를 포함한 판매 상품 등록과 내 상품 관리를 수행합니다.
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
