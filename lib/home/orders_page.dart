
import 'package:authenticationapp/home/home_page.dart';
import 'package:authenticationapp/model/order_item.dart';
import 'package:authenticationapp/navigation/CustomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../theme/theme.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  static List<OrderItem> orderedMeals = [];

  static Future<void> initializeOrderedMeals() async {
    orderedMeals = (await fetchOrders()).cast<OrderItem>();
  }

  static Future<List<Map<String, dynamic>>> fetchOrders() async {
    final response = await http.get(Uri.parse('http://localhost:3000/orders'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      List<Map<String, dynamic>> ordersList = [];

      for (var item in jsonList) {
        if (item is Map<String, dynamic>) {
          ordersList.add(item);
        }
      }

      return ordersList;
    } else {
      throw Exception('Failed to load ordered meals: ${response.statusCode}');
    }
  }

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  Future<void> _refreshOrders() async {
    await OrdersPage.initializeOrderedMeals();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    OrdersPage.initializeOrderedMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 22, top: 30, right: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomAppBar(),
              const SizedBox(height: 25),
              Text(
                'Your Orders',
                style: AppTheme.tileLarge,
              ),
              const SizedBox(height: 28),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshOrders,
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: OrdersPage.fetchOrders(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
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
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            final orderItem =
                                OrderItem.fromJson(snapshot.data![index]);

                            // Use a custom Card widget to display order details
                            return OrderCard(
                              orderItem: orderItem,
                              onDelete: () async {
                                await _deleteOrder(orderItem.idOrder);
                                await _refreshOrders();
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }

  Future<void> _deleteOrder(String orderId) async {
    final response =
        await http.delete(Uri.parse('http://localhost:3000/orders/$orderId'));

    if (response.statusCode == 200) {
      print('Order deleted successfully.');
    } else {
      throw Exception('Failed to delete order: ${response.statusCode}');
    }
  }

  
}

class OrderCard extends StatelessWidget {
  final OrderItem orderItem;
  final VoidCallback onDelete;

  const OrderCard({Key? key, required this.orderItem, required this.onDelete})
      : super(key: key);

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this order?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                onDelete();
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(orderItem.photoOrder,
              height: 100, width: 100, fit: BoxFit.cover),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(orderItem.nameOrder,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Quantity: ${orderItem.quantityOrder}'),
                  Text('Price: ${orderItem.priceOrder}'),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () {
                _showDeleteConfirmationDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Delete Order',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
