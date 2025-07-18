import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/services/cart_service.dart';
import 'package:recipe_app/utils/colors.dart';
import 'package:recipe_app/widgets/text_widget.dart';

class UserOrdersTab extends StatefulWidget {
  const UserOrdersTab({super.key});

  @override
  State<UserOrdersTab> createState() => _UserOrdersTabState();
}

class _UserOrdersTabState extends State<UserOrdersTab> {
  String selectedStatus = 'All';

  final List<String> statusOptions = ['All', 'Pending', 'Accepted', 'Rejected'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Status Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: selectedStatus,
              isExpanded: true,
              underline: Container(),
              items: statusOptions.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: TextWidget(
                    text: status,
                    fontSize: 16,
                    fontFamily: 'Regular',
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedStatus = newValue!;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          // Orders List
          Expanded(
            child: StreamBuilder(
              stream: CartService.getUserOrders(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading orders'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orders = snapshot.data?.docs ?? [];

                // Filter orders by status
                final filteredOrders = selectedStatus == 'All'
                    ? orders
                    : orders.where((order) {
                        final orderData = order.data() as Map<String, dynamic>;
                        final status = orderData['status'] ?? 'pending';
                        return status.toLowerCase() ==
                            selectedStatus.toLowerCase();
                      }).toList();

                if (filteredOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selectedStatus == 'All'
                              ? Icons.shopping_bag_outlined
                              : Icons.filter_list,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        TextWidget(
                          text: selectedStatus == 'All'
                              ? 'No orders yet.'
                              : 'No $selectedStatus orders.',
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order =
                        filteredOrders[index].data() as Map<String, dynamic>;
                    final items = order['items'] as List<dynamic>? ?? [];
                    final total = order['totalAmount'] ?? 0;
                    final status = order['status'] ?? 'pending';
                    final orderNumber = order['orderNumber'] ?? '';
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextWidget(
                                  text: 'Order #$orderNumber',
                                  fontSize: 16,
                                  fontFamily: 'Bold',
                                  color: primary,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: status == 'accepted'
                                        ? Colors.green
                                        : status == 'rejected'
                                            ? Colors.red
                                            : Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextWidget(
                                    text: status.toUpperCase(),
                                    fontSize: 12,
                                    fontFamily: 'Bold',
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...items.map((item) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Image.network(item['recipeImage'],
                                          fit: BoxFit.cover),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextWidget(
                                        text:
                                            '${item['recipeName']} x${item['quantity']}',
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextWidget(
                                      text: 'P${item['recipePrice']}',
                                      fontSize: 14,
                                      color: primary,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextWidget(
                                  text: 'Total:',
                                  fontSize: 14,
                                  fontFamily: 'Bold',
                                ),
                                TextWidget(
                                  text: 'P${total.toStringAsFixed(2)}',
                                  fontSize: 16,
                                  fontFamily: 'Bold',
                                  color: primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
