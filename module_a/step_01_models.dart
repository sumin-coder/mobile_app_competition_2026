// API, 상태, 화면 사이에서 전달되는 Module A 핵심 데이터 모델을 정의합니다.

// 로그인 사용자 정보이며 인증 상태와 마이페이지에서 사용합니다.
typedef User = ({int id, String email, String name});

User userFromJson(Map<String, dynamic> json) => (
  id: jsonInt(json['id']),
  email: jsonText(json['email']),
  name: jsonText(json['name']),
);

// 로그인 응답과 회원가입 요청에 사용하는 인증 데이터입니다.
typedef AuthSession = ({String token, User user});
typedef SignupData = ({
  String email,
  String password,
  String name,
  String phone,
});

extension SignupJson on SignupData {
  Map<String, String> get json => {
    'email': email,
    'password': password,
    'name': name,
    'phone': phone,
  };
}

// 홈, 탐색, 상세 화면이 함께 사용하는 상품 모델입니다.
class Product {
  const Product({
    required this.id,
    required this.albumName,
    required this.artist,
    required this.genre,
    required this.condition,
    required this.price,
    required this.tradeMethod,
    required this.albumImage,
    required this.likeCount,
    required this.createdAt,
    this.description = '',
    this.barcode = '',
    this.sellerName = '',
    this.sellerEmail = '',
    this.sellerProfileImage = '',
    this.conditionDescription = '',
  });

  final int id, price, likeCount;
  final String albumName, artist, genre, condition, tradeMethod, albumImage;
  final DateTime createdAt;
  final String description,
      barcode,
      sellerName,
      sellerEmail,
      sellerProfileImage,
      conditionDescription;

  factory Product.fromJson(Map<String, dynamic> json, {Uri? baseUri}) {
    final seller = json['seller'] as Map<String, dynamic>?;
    return Product(
      id: jsonInt(json['id']),
      albumName: jsonText(json['albumName']),
      artist: jsonText(json['artist']),
      genre: jsonText(json['genre'], 'ETC'),
      condition: jsonText(json['condition'], 'G'),
      price: jsonInt(json['price']),
      tradeMethod: jsonText(json['tradeMethod'], 'BOTH'),
      albumImage: resolveImage(json['albumImage'], baseUri),
      likeCount: jsonInt(json['likeCount']),
      createdAt: jsonDate(json['createdAt']),
      description: jsonText(json['description']),
      barcode: jsonText(json['barcode']),
      sellerName: jsonText(seller?['name']),
      sellerEmail: jsonText(seller?['email']),
      sellerProfileImage: resolveImage(seller?['profileImage'], baseUri),
      conditionDescription: jsonText(json['conditionDescription']),
    );
  }
}

// 상품 목록의 최신순 정렬에 사용하는 편의 확장입니다.
extension ProductSorting on Iterable<Product> {
  List<Product> sortedBy(Comparator<Product> compare) =>
      [...this]..sort(compare);
}

// API 오류를 사용자 메시지와 HTTP 상태 코드로 전달합니다.
class AppException implements Exception {
  const AppException(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;
  String toString() => message;
}

// JSON 값의 타입 차이를 안전하게 흡수하는 공통 변환 함수입니다.
String jsonText(Object? value, [String fallback = '']) =>
    value as String? ?? fallback;

String resolveImage(Object? value, Uri? baseUri) {
  final path = value is String ? value.trim() : '';
  return path.isEmpty ||
          baseUri == null ||
          Uri.tryParse(path)?.hasScheme == true
      ? path
      : baseUri.resolve(path).toString();
}

DateTime jsonDate(Object? value) =>
    DateTime.tryParse(jsonText(value)) ?? DateTime.now();

int jsonInt(Object? value) => switch (value) {
  num value => value.toInt(),
  String value => int.tryParse(value) ?? 0,
  _ => 0,
};
