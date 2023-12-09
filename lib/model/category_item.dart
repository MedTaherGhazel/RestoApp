class CategoryItem {
  final String idCategory;
  final String nameCategory;
  final String DescCategory;


  CategoryItem({
    required this.idCategory,
    required this.nameCategory,
    required this.DescCategory,

  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      idCategory: json['idCategory'] ?? '',
      nameCategory: json['strCategory'] ?? '',
      DescCategory: json['strCategoryDescription'] ?? '',
    );
  }
}
