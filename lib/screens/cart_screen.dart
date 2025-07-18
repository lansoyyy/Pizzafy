import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/services/cart_service.dart';
import 'package:recipe_app/utils/colors.dart';
import 'package:recipe_app/widgets/text_widget.dart';
import 'package:recipe_app/widgets/toast_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double totalAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: TextWidget(
          text: 'My Cart',
          fontSize: 18,
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: CartService.getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading cart'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final cartItems = snapshot.data?.docs ?? [];

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  TextWidget(
                    text: 'Your cart is empty',
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
            );
          }

          // Calculate total amount
          totalAmount = 0.0;
          for (var item in cartItems) {
            final price = double.tryParse(item['recipePrice'] ?? '0') ?? 0.0;
            final quantity = item['quantity'] ?? 0;
            totalAmount += price * quantity;
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item =
                        cartItems[index].data() as Map<String, dynamic>;
                    final itemId = cartItems[index].id;
                    final quantity = item['quantity'] ?? 0;
                    final price =
                        double.tryParse(item['recipePrice'] ?? '0') ?? 0.0;
                    final itemTotal = price * quantity;

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Item Image
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image:
                                      NetworkImage(item['recipeImage'] ?? ''),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Item Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    text: item['recipeName'] ?? '',
                                    fontSize: 16,
                                    fontFamily: 'Bold',
                                    color: primary,
                                  ),
                                  const SizedBox(height: 4),
                                  TextWidget(
                                    text: 'P${price.toStringAsFixed(2)} each',
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  // Quantity Controls
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          CartService.updateCartItemQuantity(
                                            itemId,
                                            quantity - 1,
                                          );
                                        },
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                        color: primary,
                                        iconSize: 20,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: primary),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: TextWidget(
                                          text: quantity.toString(),
                                          fontSize: 16,
                                          fontFamily: 'Bold',
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          CartService.updateCartItemQuantity(
                                            itemId,
                                            quantity + 1,
                                          );
                                        },
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                        color: primary,
                                        iconSize: 20,
                                      ),
                                      const Spacer(),
                                      TextWidget(
                                        text:
                                            'P${itemTotal.toStringAsFixed(2)}',
                                        fontSize: 16,
                                        fontFamily: 'Bold',
                                        color: primary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Remove Button
                            IconButton(
                              onPressed: () {
                                CartService.removeFromCart(itemId);
                              },
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Total and Checkout Section
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: 'Total:',
                          fontSize: 18,
                          fontFamily: 'Bold',
                        ),
                        TextWidget(
                          text: 'P${totalAmount.toStringAsFixed(2)}',
                          fontSize: 20,
                          fontFamily: 'Bold',
                          color: primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            // Prepare cart items for order
                            final orderItems = cartItems.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return {
                                'recipeId': data['recipeId'],
                                'recipeName': data['recipeName'],
                                'recipeImage': data['recipeImage'],
                                'recipePrice': data['recipePrice'],
                                'quantity': data['quantity'],
                              };
                            }).toList();

                            await CartService.placeOrder(
                                orderItems, totalAmount);
                            showToast('Order placed successfully!');
                            Navigator.pop(context);
                          } catch (e) {
                            showToast('Error placing order: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: TextWidget(
                          text: 'Place Order',
                          fontSize: 18,
                          fontFamily: 'Bold',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
