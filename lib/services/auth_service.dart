import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';

class AuthService {
  static final GetStorage _storage = GetStorage();
  static const String _userEmailKey = 'user_email';
  static const String _isAdminKey = 'is_admin';

  // Save user login state (only for regular users, not admin)
  static Future<void> saveUserLoginState(String email, bool isAdmin) async {
    if (!isAdmin) {
      await _storage.write(_userEmailKey, email);
      await _storage.write(_isAdminKey, false);
    }
  }

  // Clear user login state
  static Future<void> clearUserLoginState() async {
    await _storage.remove(_userEmailKey);
    await _storage.remove(_isAdminKey);
  }

  // Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    final email = _storage.read(_userEmailKey);
    final isAdmin = _storage.read(_isAdminKey) ?? false;

    // Only return true if user is logged in and not admin
    return email != null && !isAdmin;
  }

  // Get stored user email
  static String? getStoredUserEmail() {
    return _storage.read(_userEmailKey);
  }

  // Check if current Firebase user matches stored user
  static Future<bool> isCurrentUserValid() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final storedEmail = getStoredUserEmail();

    if (currentUser == null || storedEmail == null) {
      return false;
    }

    return currentUser.email == storedEmail;
  }

  // Initialize get_storage
  static Future<void> init() async {
    await GetStorage.init();
  }
}
