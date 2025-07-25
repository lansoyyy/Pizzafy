import 'package:flutter/material.dart';
import 'package:recipe_app/screens/admin_home_screen.dart';
import 'package:recipe_app/screens/auth/login_screen.dart';
import 'package:recipe_app/services/auth_service.dart';

logout(BuildContext context, Widget navigationRoute) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text(
              'Logout Confirmation',
              style:
                  TextStyle(fontFamily: 'QBold', fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Are you sure you want to Logout?',
              style: TextStyle(fontFamily: 'QRegular'),
            ),
            actions: <Widget>[
              MaterialButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Close',
                  style: TextStyle(
                      fontFamily: 'QRegular', fontWeight: FontWeight.bold),
                ),
              ),
              MaterialButton(
                onPressed: () async {
                  // Clear stored login state
                  await AuthService.clearUserLoginState();

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(
                      fontFamily: 'QRegular', fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ));
}
