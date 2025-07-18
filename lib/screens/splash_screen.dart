import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/services/auth_service.dart';
import 'package:recipe_app/screens/auth/login_screen.dart';
import 'package:recipe_app/screens/user_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    // Add a small delay to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      // Check if user is logged in via get_storage
      final isLoggedIn = await AuthService.isUserLoggedIn();

      if (isLoggedIn) {
        // Check if Firebase user is still valid
        final currentUser = FirebaseAuth.instance.currentUser;
        final storedEmail = AuthService.getStoredUserEmail();

        if (currentUser != null &&
            storedEmail != null &&
            currentUser.email == storedEmail) {
          // Auto login successful - navigate to user home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const UserHomeScreen()),
          );
        } else {
          // Firebase user doesn't match stored user or no current user
          await AuthService.clearUserLoginState();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        // No stored login - go to login screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      // Error occurred - go to login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 300,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Regular',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
