// 상품 등록 폼에서 상태와 API로 전달하는 Module C 입력 모델을 정의합니다.

// 등록 전 상품 정보이며 로컬 이미지 경로까지 포함합니다.
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

// 상품 초안을 서버 요청 본문으로 변환할 때 사용합니다.
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
