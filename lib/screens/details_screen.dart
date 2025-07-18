import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/utils/colors.dart';
import 'package:recipe_app/utils/const.dart';
import 'package:recipe_app/widgets/text_widget.dart';
import 'package:recipe_app/widgets/toast_widget.dart';

class DetailsScreen extends StatefulWidget {
  bool? isUser;
  String id;

  DetailsScreen({
    super.key,
    required this.id,
    this.isUser = false,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: primary,
        title: TextWidget(
          text: 'Pizzafy',
          fontSize: 18,
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: Text('Loading'));
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            dynamic mydata = snapshot.data;
            return Container(
              child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Recipe')
                      .doc(widget.id)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: Text('Loading'));
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Something went wrong'));
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    dynamic data = snapshot.data;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 175,
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(data['image']))),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 300,
                                  child: TextWidget(
                                    align: TextAlign.start,
                                    text: data['name'],
                                    fontSize: 32,
                                    fontFamily: 'Bold',
                                  ),
                                ),
                                Row(
                                  children: [
                                    // IconButton(
                                    //   onPressed: () async {
                                    //     if (mydata['favs']
                                    //         .contains(widget.id)) {
                                    //       FirebaseFirestore.instance
                                    //           .collection('Users')
                                    //           .doc(userId)
                                    //           .update({
                                    //         'favs': FieldValue.arrayRemove(
                                    //             [widget.id]),
                                    //       });
                                    //       showToast('Removed to favorites');
                                    //     } else {
                                    //       FirebaseFirestore.instance
                                    //           .collection('Users')
                                    //           .doc(userId)
                                    //           .update({
                                    //         'favs': FieldValue.arrayUnion(
                                    //             [widget.id]),
                                    //       });

                                    //       showToast('Added to favorites');
                                    //     }
                                    //   },
                                    //   icon: Icon(
                                    //     mydata['favs'].contains(widget.id)
                                    //         ? Icons.favorite
                                    //         : Icons.favorite_border,
                                    //     color: primary,
                                    //     size: 40,
                                    //   ),
                                    // ),
                                    widget.isUser!
                                        ? SizedBox()
                                        : IconButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await FirebaseFirestore.instance
                                                  .collection('Recipe')
                                                  .doc(widget.id)
                                                  .delete();
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                            ),
                                          )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: TextWidget(
                              align: TextAlign.start,
                              maxLines: 50,
                              text: data['desc'],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    );
                  }),
            );
          }),
    );
  }
}
