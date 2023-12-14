import 'package:authenticationapp/home/home_page.dart';
import 'package:authenticationapp/model/meal_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:authenticationapp/navigation/CustomNavigationBar.dart';

class AddMealWidget extends StatefulWidget {
  final String categoryId;

  AddMealWidget({required this.categoryId});

  @override
  _AddMealWidgetState createState() => _AddMealWidgetState();
}

class _AddMealWidgetState extends State<AddMealWidget> {
  late Future<List<MealItem>> _meals;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _idCategoryController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _meals = fetchDataMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Meal'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Meal Name'),
          ),
          TextField(
            controller: _priceController,
            decoration: InputDecoration(labelText: 'Price'),
          ),
          TextField(
            controller: _idCategoryController,
            decoration: InputDecoration(labelText: 'Category ID'),
          ),
          TextField(
            controller: _areaController,
            decoration: InputDecoration(labelText: 'Area'),
          ),
          TextField(
            controller: _tagsController,
            decoration: InputDecoration(labelText: 'Tags'),
          ),
          TextField(
            controller: _imageController,
            decoration: InputDecoration(labelText: 'Image Source'),
          ),
          TextField(
            controller: _instructionsController,
            decoration: InputDecoration(labelText: 'Instructions'),
          ),
          ElevatedButton(
            onPressed: () {
              addMeal(
                  _nameController.text,
                  _idCategoryController.text,
                  _areaController.text,
                  _tagsController.text,
                  _imageController.text,
                  _instructionsController.text,
                  _priceController.text);
            },
            child: Text('Add Meal'),
          ),
          Expanded(
            child: FutureBuilder<List<MealItem>>(
              future: _meals,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<MealItem> meals = snapshot.data ?? [];

                  return ListView.builder(
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      MealItem meal = meals[index];
                      return ListTile(
                        title: Text(meal.nameMeal),
                        subtitle: Text('Category: ${meal.idCategory}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _showUpdateFormDialog(meal);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _showDeleteConfirmationDialog(meal);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }

  Future<void> addMeal(String name, String price, String idCategory,
      String area, String image, String tags, String instructions) async {
    // Validate inputs
    if (name.isEmpty || idCategory.isEmpty || price.isEmpty) {
      // Show an error message or handle validation as needed
      return;
    }
    try {
      // Send the new meal data to your server
      final response = await http.post(
        Uri.parse('http://localhost:3000/meals'),
        body: {
          'strMeal': name,
          'strPrice': price,
          'idCategory': idCategory,
          'strArea': area,
          'strTags': tags,
          'strImageSource': image,
          'strInstructions': instructions,
        },
      );

      if (response.statusCode == 201) {
        // After successfully adding the meal, fetch the updated list of meals
        _meals = fetchDataMeals();

        setState(() {
          _nameController.clear();
          _priceController.clear();
          _idCategoryController.clear();
          _areaController.clear();
          _tagsController.clear();
          _imageController.clear();
          _instructionsController.clear();
        });
      } else {
        print('Failed to add meal: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to add meal: $e');
    }
  }

  void _showUpdateFormDialog(MealItem meal) {
    _nameController.text = meal.nameMeal;
    _priceController.text = meal.priceMeal;
    _idCategoryController.text = meal.idCategory;
    _areaController.text = meal.areaMeal;
    _tagsController.text = meal.tagsMeal;
    _imageController.text = meal.imageMeal;
    _instructionsController.text = meal.instruMeal;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Meal'),
          content: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Meal Name'),
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
              ),
              // Add other fields as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                updateMeal(meal.idMeal);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void updateMeal(String mealId) async {
    // Implement the logic to send an update request to your server
    // You can use http.put or http.patch based on your server's API
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/meals/$mealId'),
        body: {
          'strMeal': _nameController.text,
          'strPrice': _priceController.text,
       
        },
      );

      if (response.statusCode == 200) {
        _meals = fetchDataMeals();
        // Optionally display a success message
      } else {
        print('Failed to update meal: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to update meal: $e');
    }
  }

  void _showDeleteConfirmationDialog(MealItem meal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${meal.nameMeal}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteMeal(meal.idMeal);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void deleteMeal(String mealId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/meals/$mealId'),
      );

      if (response.statusCode == 200) {
        _meals = fetchDataMeals();
      } else {
        print('Failed to delete meal: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to delete meal: $e');
    }
  }
}
