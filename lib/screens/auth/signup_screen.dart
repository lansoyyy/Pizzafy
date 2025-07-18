import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/screens/auth/login_screen.dart';
import 'package:recipe_app/screens/user_home_screen.dart';
import 'package:recipe_app/services/add_user.dart';
import 'package:recipe_app/services/auth_service.dart';
import 'package:recipe_app/utils/colors.dart';
import 'package:recipe_app/widgets/button_widget.dart';
import 'package:recipe_app/widgets/text_widget.dart';
import 'package:recipe_app/widgets/textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/widgets/toast_widget.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final number = TextEditingController();
  final address = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 25,
                ),
                const Text(
                  'Signup',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
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
                TextFieldWidget(
                  hasValidator: false,
                  hint: 'Enter delivery address',
                  borderColor: Colors.grey,
                  label: 'Delivery Address',
                  controller: address,
                  maxLine: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a delivery address';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    TextFieldWidget(
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
                ButtonWidget(
                  label: 'Register',
                  onPressed: () {
                    register(context);
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      text: "Already have an account?",
                      fontSize: 12,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: TextWidget(
                        color: primary,
                        fontFamily: 'Bold',
                        text: "Login",
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  register(context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text, password: password.text);

      addUser(name.text, email.text, number.text, address.text);

      // Save login state for auto login
      await AuthService.saveUserLoginState(email.text, false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const UserHomeScreen()),
      );
      showToast("Registered Successfully!");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showToast('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        showToast('The email address is not valid.');
      } else {
        showToast(e.toString());
      }
    } on Exception catch (e) {
      showToast("An error occurred: $e");
    }
  }
}
