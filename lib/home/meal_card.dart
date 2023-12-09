import 'dart:ui';

import 'package:flutter/material.dart';

import '../common/widgets/custom_button.dart';
import '../detail/details_page.dart';
import '../model/meal_item.dart';
import '../theme/theme.dart';


class MealCard extends StatelessWidget {
  final MealItem mealItem;
  final int index;
  MealCard({
    Key? key,
    required this.mealItem,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(mealItem: mealItem),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 22),
        child: Container(
          padding: const EdgeInsets.all(9),
          width: 140,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(23)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xff282C34),
                Color(0xff10131A),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  SizedBox(
                    height: 180,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Image.network(
                          mealItem.imageMeal, // Assuming your MealItem has an 'image' property
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 5,
                        sigmaY: 5,
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        width: 50,
                        height: 25,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Icon(
                              Icons.star,
                              color: AppTheme.reviewIconColor,
                              size: 15,
                            ),
                            Text(
                              mealItem.tagsMeal,
                              style: AppTheme.reviewRatting,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(mealItem.nameMeal, style: AppTheme.cardTitleSmall),
              const SizedBox(height: 3),
              const Spacer(),
              Row(
                children: [
                  Row(
                    children: [
                      Text('\$', style: AppTheme.priceCurrencySmall),
                      const SizedBox(width: 3),
                      Text(
                        mealItem.priceMeal,
                        style: AppTheme.priceValueSmall,
                      ),
                    ],
                  ),
                  const Spacer(),
                  CustomButton(
                    onTap: () {},
                    height: 31,
                    width: 34,
                    color: AppTheme.buttonBackground1Color,
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 18,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
