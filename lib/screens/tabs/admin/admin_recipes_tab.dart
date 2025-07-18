import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:recipe_app/screens/details_screen.dart';
import 'package:recipe_app/utils/colors.dart';
import 'package:recipe_app/utils/const.dart';
import 'package:recipe_app/widgets/text_widget.dart';
import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;

class AdminRecipesTab extends StatefulWidget {
  const AdminRecipesTab({super.key});

  @override
  State<AdminRecipesTab> createState() => _AdminRecipesTabState();
}

class _AdminRecipesTabState extends State<AdminRecipesTab> {
  final searchController = TextEditingController();
  String nameSearched = '';

  @override
  Widget build(BuildContext context) {
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
                  // .where('userId', isEqualTo: userId)
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
                                      isUser: false, // Admin view
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
