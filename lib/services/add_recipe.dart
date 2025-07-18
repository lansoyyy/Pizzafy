import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/utils/const.dart';

Future addRecipe(name, desc, cooktime, image) async {
  final docUser = FirebaseFirestore.instance.collection('Recipe').doc();

  final json = {
    'name': name,
    'desc': desc,
    'cooktime': cooktime,
    'image': image,
    'id': docUser.id,
    'userId': userId,
    'dateTime': DateTime.now(),
  };

  await docUser.set(json);
}
