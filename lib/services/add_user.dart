import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/utils/const.dart';

Future addUser(name, email, number) async {
  final docUser = FirebaseFirestore.instance.collection('Users').doc(userId);

  final json = {
    'name': name,
    'number': number,
    'email': email,
    'id': docUser.id,
    'isVerified': false,
    'favs': [],
    'profile': '',
  };

  await docUser.set(json);
}
