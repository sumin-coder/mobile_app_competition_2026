typedef User = ({int id, String email, String name});

User userFromJson(Map<String, dynamic> json) => (
  id: jsonInt(json['id']),
  email: jsonText(json['email']),
  name: jsonText(json['name']),
);

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

extension ProductSorting on Iterable<Product> {
  List<Product> sortedBy(Comparator<Product> compare) =>
      [...this]..sort(compare);
}

class AppException implements Exception {
  const AppException(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;
  String toString() => message;
}

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
