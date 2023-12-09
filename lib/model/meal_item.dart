class MealItem {
  final String idMeal;
  final String nameMeal;
  final String idCategory;
  final String areaMeal;
  final String tagsMeal;
  final String imageMeal;
    final String instruMeal;
        final String priceMeal;



  MealItem({
    required this.idMeal,
    required this.nameMeal,
    required this.idCategory,
    required this.areaMeal,
    required this.tagsMeal,
    required this.imageMeal,
        required this.instruMeal,
                required this.priceMeal,


  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      idMeal: json['idMeal'] ?? '',
      nameMeal: json['strMeal'] ?? '',
      idCategory: json['idCategory'] ?? '',
      areaMeal: json['strArea'] ?? '',
      tagsMeal: json['strTags'] ?? '',
      imageMeal: json['strImageSource'] ?? '',
      instruMeal: json['strInstructions'] ?? '',
      priceMeal: json['strPrice'] ?? '',



    );
  }
}
