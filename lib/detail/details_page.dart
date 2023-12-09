import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../common/widgets/custom_button.dart';
import '../common/widgets/custom_icon_button.dart';
import '../model/meal_item.dart';
import '../model/order_item.dart';
import '../theme/theme.dart';

class DetailPage extends StatefulWidget {
  final MealItem mealItem;

  const DetailPage({
    Key? key,
    required this.mealItem,
  }) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int? quantity = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section -> Card Image
              Expanded(
                child: CardImageView(mealItem: widget.mealItem),
              ),
              const SizedBox(height: 30),
              // Section -> Description
              Text(
                'Description',
                style: AppTheme.descriptionTitle,
              ),
              const SizedBox(height: 15),
              Expanded(
                child: DescriptionView(
                  description:
                      widget.mealItem.instruMeal ?? widget.mealItem.instruMeal,
                ),
              ),
              const SizedBox(height: 30),
              const SizedBox(height: 30),

              // Section -> Price
              SizedBox(
                height: 74,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Price',
                          style: AppTheme.priceTitleLarge,
                        ),
                        const Spacer(),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '\$ ',
                                style: AppTheme.priceCurrencyLarge,
                              ),
                              TextSpan(
                                text: widget.mealItem.priceMeal,
                                style: AppTheme.priceValueLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    QuantityW(
                      onQuantityChanged: (newQuantity) {
                        setState(() {
                          quantity = newQuantity;
                        });
                      },
                    ),
                    CustomButton(
                      onTap: () {
                        _placeOrder(widget.mealItem);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Meal added Succesfully'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      width: 168,
                      height: 56,
                      borderRadius: 16,
                      color: AppTheme.buttonBackground1Color,
                      child: Text(
                        'Add to Cart ',
                        style: AppTheme.buttonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Function to place an order
Future<void> _placeOrder(MealItem mealItem) async {
  try {
    // Replace this URL with your actual API endpoint
    final String apiUrl = 'http://localhost:3000/orders';

    // Convert mealItem data to OrderItem object
    OrderItem orderItem = OrderItem(
      idOrder: mealItem.idMeal,
      nameOrder: mealItem.nameMeal,
      photoOrder: mealItem.imageMeal,
      priceOrder: mealItem.priceMeal,
      quantityOrder: '1',
    );

    // Make a POST request
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(orderItem.toJson()),
    );

    if (response.statusCode == 200) {
      print('Order successfully placed!');
    } else {
      print('Failed to place order. Status code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error placing order: $error');
  }
}

class CardImageView extends StatelessWidget {
  final MealItem mealItem;
  const CardImageView({
    super.key,
    required this.mealItem,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.network(
              mealItem.imageMeal,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: CustomIconButton(
            onTap: () {
              Navigator.pop(context);
            },
            width: 38,
            height: 38,
            borderRadius: 10,
            child: const Icon(
              CupertinoIcons.back,
              color: AppTheme.iconColor,
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: CustomIconButton(
            onTap: () {},
            width: 38,
            height: 38,
            borderRadius: 10,
            child: const Icon(
              Icons.favorite,
              color: AppTheme.iconColor,
            ),
          ),
        ),

        // BlurCardView
        BlurCardView(
          mealItem: mealItem,
        ),
      ],
    );
  }
}

class BlurCardView extends StatelessWidget {
  final MealItem mealItem;
  const BlurCardView({
    super.key,
    required this.mealItem,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 4,
          sigmaY: 4,
        ),
        child: Container(
          alignment: Alignment.center,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mealItem.nameMeal,
                            maxLines: 2,
                            style: AppTheme.cardTitleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            mealItem.tagsMeal,
                            style: AppTheme.cardSubtitleLarge,
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        left: 10,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.star,
                      color: AppTheme.reviewIconColor,
                      size: 20,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      mealItem.areaMeal.toString(),
                      style: AppTheme.cardTitleSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DescriptionView extends StatelessWidget {
  final String description;
  const DescriptionView({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: description,
              style: AppTheme.descriptionContent,
            ),
            TextSpan(
              text: ' ...',
              style: AppTheme.descriptionReadMore,
            ),
            TextSpan(
              text: ' Read More',
              style: AppTheme.descriptionReadMore,
            ),
          ],
        ),
      ),
    );
  }
}

class QuantityW extends StatefulWidget {
  final Function(int) onQuantityChanged;

  const QuantityW({Key? key, required this.onQuantityChanged})
      : super(key: key);

  @override
  _QuantityWState createState() => _QuantityWState();
}

class _QuantityWState extends State<QuantityW> {
  int _selectedValue = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Quantity',
          style: AppTheme.priceTitleLarge,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButton<int>(
            value: _selectedValue,
            onChanged: (int? newValue) {
              setState(() {
                _selectedValue = newValue ?? 1;
                widget.onQuantityChanged(_selectedValue);
              });
            },
            dropdownColor: Colors.black,
            style: TextStyle(color: Colors.white),
            items: List.generate(10, (index) => index + 1).map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value', style: TextStyle(fontSize: 20)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
