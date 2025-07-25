import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:recipe_app/screens/details_screen.dart';
import 'package:recipe_app/utils/colors.dart';
import 'package:recipe_app/utils/const.dart';
import 'package:recipe_app/widgets/text_widget.dart';
import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;
import 'package:recipe_app/services/cart_service.dart';

class MyRecipeTab extends StatefulWidget {
  bool? isUser;

  MyRecipeTab({
    this.isUser = false,
  });

  @override
  State<MyRecipeTab> createState() => _MyRecipeTabState();
}

class _MyRecipeTabState extends State<MyRecipeTab> {
  final searchController = TextEditingController();
  String nameSearched = '';

  @override
  Widget build(BuildContext context) {
    if (widget.isUser == true) {
      // Show user orders
      return Padding(
        padding: const EdgeInsets.all(20.0),
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
            if (orders.isEmpty) {
              return const Center(child: Text('No orders yet.'));
            }
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index].data() as Map<String, dynamic>;
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
                        TextWidget(
                          text: 'Order #$orderNumber',
                          fontSize: 16,
                          fontFamily: 'Bold',
                          color: primary,
                        ),
                        const SizedBox(height: 8),
                        TextWidget(
                          text: 'Status: $status',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        ...items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
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
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(100)),
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: TextFormField(
                  style: const TextStyle(
                      color: Colors.black, fontFamily: 'Regular', fontSize: 14),
                  onChanged: (value) {
                    setState(() {
                      nameSearched = value;
                    });
                  },
                  decoration: const InputDecoration(
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      hintText: 'Search Pizza',
                      hintStyle: TextStyle(fontFamily: 'Regular', fontSize: 18),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                      )),
                  controller: searchController,
                ),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Recipe')
                  .where('userId', isEqualTo: userId)
                  .where('name',
                      isGreaterThanOrEqualTo:
                          toBeginningOfSentenceCase(nameSearched))
                  .where('name',
                      isLessThan: '${toBeginningOfSentenceCase(nameSearched)}z')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return const Center(child: Text('Error'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                        child: CircularProgressIndicator(
                      color: Colors.black,
                    )),
                  );
                }

                final data = snapshot.requireData;
                return Expanded(
                  child: ListView.builder(
                    itemCount: data.docs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => DetailsScreen(
                                      isUser: true,
                                      id: data.docs[index].id,
                                    )));
                          },
                          child: Card(
                            child: SizedBox(
                              width: double.infinity,
                              height: 175,
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 125,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                              data.docs[index]['image'])),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(
                                          10,
                                        ),
                                        topRight: Radius.circular(
                                          10,
                                        ),
                                      ),
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            TextWidget(
                                              text: data.docs[index]['name'],
                                              fontSize: 18,
                                              fontFamily: 'Bold',
                                              color: primary,
                                            ),
                                            TextWidget(
                                              text: data.docs[index]['desc'],
                                              fontSize: 12,
                                              fontFamily: 'Regular',
                                            ),
                                          ],
                                        ),
                                        TextWidget(
                                          text: data.docs[index]['cooktime'],
                                          fontSize: 28,
                                          fontFamily: 'Bold',
                                          color: primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              })
        ],
      ),
    );
  }
}
