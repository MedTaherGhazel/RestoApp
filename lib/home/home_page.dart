import 'dart:convert';

import 'package:authenticationapp/login.dart';
import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../common/widgets/custom_container.dart';
import '../common/widgets/custom_icon_button.dart';
import '../model/category_item.dart';
import '../model/meal_item.dart';
import '../navigation/CustomNavigationBar.dart';
import '../theme/theme.dart';
import 'meal_card.dart';
import 'meal_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static List<CategoryItem> menuSections = [];
  static List<MealItem> meals = [];

  static Future<void> initializeMenuSections() async {
    menuSections = await fetchData();
  }

  static Future<List<CategoryItem>> fetchData() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/categories'));
    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body);
      return json.map((item) => CategoryItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    HomePage.initializeMenuSections().then((_) {
      setState(() {
        _activeIndex = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Get.put(MealController());
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 22, top: 30, right: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //title
            children: [
              const CustomAppBar(),
              const SizedBox(height: 25),
              Text(
                'Find the best',
                style: AppTheme.tileLarge,
              ),
              // Text(
              //   'meal for you',
              //   style: AppTheme.tileLarge,
              // ),
              const SizedBox(height: 28),
              const SizedBox(height: 25),
              // Chips
              HomePage.menuSections.isNotEmpty
                  //category
                  ? SizedBox(
                      height: 35,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: HomePage.menuSections.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = HomePage.menuSections[index];
                          bool isActive = _activeIndex == index;
                          return GestureDetector(
                            //category sett
                            onTap: () {
                              setState(() {
                                _activeIndex = index;
                              });
                              Get.find<MealController>()
                                  .onMenuOptionTapped(index);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 27),
                              child: Column(
                                children: [
                                  Text(
                                    item.nameCategory,
                                    style: isActive
                                        ? AppTheme.chipActive
                                        : AppTheme.chipInactive,
                                  ),
                                  const SizedBox(height: 2),
                                  Icon(
                                    Icons.circle,
                                    color: isActive
                                        ? AppTheme.iconActiveColor
                                        : Colors.transparent,
                                    size: 12,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(),

              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    SizedBox(
                      height: 325,
                      child: Obx(() {
                        final mealController = Get.find<MealController>();
                        final menuItems = mealController.menuItems;
                        if (menuItems.isEmpty) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: menuItems.length,
                            itemBuilder: (BuildContext context, int index) {
                              return MealCard(
                                mealItem: menuItems[index],
                                index: index,
                              );
                            },
                          );
                        }
                      }),
                    ),
                    // Recommended meals
                    const SizedBox(height: 25),
                    Text('Recommended for you', style: AppTheme.subtileLarge),
                    const SizedBox(height: 17),
                    SizedBox(height: 325, child: buildRecommendedMeals()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }
}

Future<List<MealItem>> fetchDataMeals() async {
  final response = await http.get(Uri.parse('http://localhost:3000/meals'));
  if (response.statusCode == 200) {
    List<dynamic> json = jsonDecode(response.body);
    return json.map((item) => MealItem.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load meals: ${response.statusCode}');
  }
}

Widget buildRecommendedMeals() {
  return SizedBox(
    height: 325,
    child: FutureBuilder<List<MealItem>>(
      future: fetchDataMeals(),
      builder: (BuildContext context, AsyncSnapshot<List<MealItem>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading meals: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No recommended meals available.'),
          );
        } else {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              final mealItem = snapshot.data![index];
              return MealCard(
                mealItem: mealItem,
                index: index,
              );
            },
          );
        }
      },
    ),
  );
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomIconButton(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LogIn(),
              ),
            );
          },
          width: 45,
          height: 45,
          child: const Icon(
            Icons.logout,
            color: AppTheme.iconColor,
          ),
        ),
        const Spacer(),
        CustomContainer(
          width: 45,
          height: 45,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              'https://media-cdn.tripadvisor.com/media/photo-s/04/af/9b/a0/papas-pizza-of-calhoun.jpg',
              fit: BoxFit.cover,
            ),
          ),
        )
      ],
    );
  }
}
