import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/utils/colors.dart';
import 'package:recipe_app/utils/const.dart';
import 'package:recipe_app/widgets/button_widget.dart';
import 'package:recipe_app/widgets/textfield_widget.dart';
import 'package:recipe_app/widgets/toast_widget.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final number = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
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
          dynamic data = snapshot.data;

          name.text = data['name'].toString();

          number.text = data['number'];
          email.text = data['email'];
          password.text = '*******';
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(
                      Icons.account_circle,
                      color: primary,
                      size: 150,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFieldWidget(
                    hasValidator: false,
                    hint: 'Enter fullname',
                    borderColor: Colors.grey,
                    label: 'Fullname',
                    controller: name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a email';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFieldWidget(
                    inputType: TextInputType.number,
                    hasValidator: false,
                    hint: 'Enter contact number',
                    borderColor: Colors.grey,
                    label: 'Contact Number',
                    controller: number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a email';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFieldWidget(
                    enabled: false,
                    hasValidator: false,
                    hint: 'Enter email',
                    borderColor: Colors.grey,
                    label: 'Email',
                    controller: email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a email';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      TextFieldWidget(
                        enabled: false,
                        hasValidator: false,
                        hint: 'Enter password',
                        showEye: true,
                        borderColor: Colors.grey,
                        label: 'Password',
                        isObscure: true,
                        controller: password,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ButtonWidget(
                      label: 'Update',
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('Users')
                            .doc(userId)
                            .update({
                          'number': number.text,
                          'name': name.text,
                        });

                        showToast('Profile updated!');
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        });
  }
}
