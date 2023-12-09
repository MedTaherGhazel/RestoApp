import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/meal_item.dart';
import 'home_page.dart';

class MealController extends GetxController {
  RxList<MealItem> menuItems = RxList<MealItem>();
  List<MealItem> selectedMealItems = [];

  Future<List<MealItem>> fetchDataMeals(String categoryId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/meals?idCategory=$categoryId'));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => MealItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load meals: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load meals: $e');
    }
  }

  @override
  Future<void> onInit() async {
    try {
      selectedMealItems = await fetchDataMeals("1");
      menuItems.assignAll(selectedMealItems);
    } catch (e) {
      print('Error during initialization: $e');
    } finally {
      super.onInit();
    }
  }

  Future<void> onMenuOptionTapped(int index) async {
    final category = HomePage.menuSections[index].idCategory;
    try {
      selectedMealItems = await fetchDataMeals(category);
      menuItems.assignAll(selectedMealItems);
    } catch (e) {
      print('Error during menu option tapped: $e');
    }
  }
}

