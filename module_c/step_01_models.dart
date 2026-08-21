typedef ProductDraft = ({
  String albumName,
  String artist,
  String genre,
  String condition,
  int price,
  String tradeMethod,
  String imagePath,
  String description,
  String barcode,
});
extension ProductDraftData on ProductDraft {
  Map<String, dynamic> json([String? image]) => {
    'albumName': albumName,
    'artist': artist,
    'genre': genre,
    'condition': condition,
    'price': price,
    'tradeMethod': tradeMethod,
    'albumImage': image ?? imagePath,
    if (barcode.isNotEmpty) 'barcode': barcode,
    if (description.isNotEmpty) 'description': description,
  };
}
