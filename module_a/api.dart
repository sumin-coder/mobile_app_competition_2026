import 'dart:convert';
import 'dart:io';
import 'models.dart';

const networkError = '네트워크 연결을 확인한 후 다시 시도해주세요.';

abstract interface class ModuleARepository {
  Future<AuthSession> login(String email, String password);
  void clearSession();
  Future<void> signup(SignupData data);
  Future<List<Product>> getProducts([String keyword = '']);
  Future<Product> getProduct(int id);
}

class ApiClient {
  ApiClient({required String baseUrl})
    : baseUri = Uri.parse(
        baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl,
      );

  final Uri baseUri;
  final HttpClient _client = HttpClient();
  String? token;

  Future<Object?> request(
    String method,
    String path, {
    Map<String, String> query = const {},
    Map<String, dynamic>? body,
    bool authenticate = true,
  }) async {
    final uri = baseUri.replace(
      path: '${baseUri.path}$path',
      queryParameters: query.isEmpty ? null : query,
    );
    try {
      final request = await _client
          .openUrl(method, uri)
          .timeout(const Duration(seconds: 10));
      request.headers.contentType = ContentType.json;
      if (authenticate && token != null) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      if (body != null) request.write(jsonEncode(body));
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      final text = await utf8.decoder.bind(response).join();
      final json = text.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(text) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errors = json['errors'] as List<dynamic>?;
        final message = errors?.isNotEmpty == true
            ? map(errors!.first)['message'] as String?
            : json['message'] as String?;
        throw AppException(
          message ?? '서버 요청을 처리하지 못했습니다.',
          response.statusCode,
        );
      }
      return json['data'];
    } on AppException {
      rethrow;
    } on Object {
      throw const AppException(networkError);
    }
  }

  Future<void> send(
    String method,
    String path, {
    Map<String, String> query = const {},
  }) async {
    await request(method, path, query: query);
  }

  Map<String, dynamic> map(Object? value) =>
      value is Map<String, dynamic> ? value : <String, dynamic>{};

  List<Map<String, dynamic>> list(Object? value) => value is List
      ? value.whereType<Map<String, dynamic>>().toList()
      : <Map<String, dynamic>>[];

  Product product(Object? value) =>
      Product.fromJson(map(value), baseUri: baseUri);

  List<Product> products(Object? value) => list(
    value is Map<String, dynamic>
        ? value['products'] ?? value['items'] ?? const <Object>[]
        : value,
  ).map(product).toList();
}

class ModuleAApi implements ModuleARepository {
  ModuleAApi(this.client);
  final ApiClient client;

  Future<Object?> loginRequest(String path, String email, String password) =>
      client.request(
        'POST',
        path,
        body: {'email': email, 'password': password},
        authenticate: false,
      );

  AuthSession saveSession(Object? response) {
    final data = client.map(response);
    final token = data['token'] as String? ?? '';
    final userJson = client.map(data['user']);
    if (token.isEmpty || userJson.isEmpty) {
      throw const AppException('로그인 응답 형식이 올바르지 않습니다.');
    }
    final session = (token: token, user: userFromJson(userJson));
    client.token = token;
    return session;
  }

  @override
  Future<AuthSession> login(String email, String password) async =>
      saveSession(await loginRequest('/auth/login', email, password));

  @override
  void clearSession() => client.token = null;

  @override
  Future<void> signup(SignupData data) async {
    await client.request(
      'POST',
      '/auth/signup',
      authenticate: false,
      body: data.json,
    );
  }

  @override
  Future<List<Product>> getProducts([String keyword = '']) async =>
      client.products(
        await client.request(
          'GET',
          '/products',
          query: {
            'page': '1',
            'size': '100',
            'sort': 'recent',
            if (keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
          },
        ),
      );

  @override
  Future<Product> getProduct(int id) async =>
      client.product(await client.request('GET', '/products/$id'));
}
