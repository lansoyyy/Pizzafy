import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/services/cart_service.dart';
import 'package:recipe_app/utils/colors.dart';
import 'package:recipe_app/widgets/text_widget.dart';
import 'package:recipe_app/widgets/toast_widget.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Orders')
                  .orderBy('orderDate', descending: true)
                  .snapshots(),
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
                              ? Icons.shopping_cart_outlined
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
                    final orderId = filteredOrders[index].id;
                    final orderDate = order['orderDate'] as Timestamp?;
                    final formattedDate = orderDate != null
                        ? '${orderDate.toDate().day}/${orderDate.toDate().month}/${orderDate.toDate().year}'
                        : 'N/A';

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
                            TextWidget(
                              text: 'Date: $formattedDate',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            // Delivery Address
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.blue[700],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextWidget(
                                      text:
                                          'Delivery Address: ${order['userAddress'] ?? 'No address provided'}',
                                      fontSize: 12,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            // Order Items
                            ...items.map((item) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(
                                          item['recipeImage'] ?? '',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.image,
                                                  color: Colors.grey),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextWidget(
                                            text: item['recipeName'] ?? '',
                                            fontSize: 14,
                                            fontFamily: 'Bold',
                                          ),
                                          TextWidget(
                                            text:
                                                'Quantity: ${item['quantity']}',
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ],
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
                                  fontSize: 16,
                                  fontFamily: 'Bold',
                                ),
                                TextWidget(
                                  text: 'P${total.toStringAsFixed(2)}',
                                  fontSize: 18,
                                  fontFamily: 'Bold',
                                  color: primary,
                                ),
                              ],
                            ),
                            // Action Buttons for Pending Orders
                            if (status == 'pending') ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('Orders')
                                              .doc(orderId)
                                              .update({'status': 'accepted'});
                                          showToast('Order accepted!');
                                        } catch (e) {
                                          showToast(
                                              'Error accepting order: $e');
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      child: TextWidget(
                                        text: 'Accept Order',
                                        fontSize: 14,
                                        fontFamily: 'Bold',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('Orders')
                                              .doc(orderId)
                                              .update({'status': 'rejected'});
                                          showToast('Order rejected!');
                                        } catch (e) {
                                          showToast(
                                              'Error rejecting order: $e');
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      child: TextWidget(
                                        text: 'Reject Order',
                                        fontSize: 14,
                                        fontFamily: 'Bold',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
