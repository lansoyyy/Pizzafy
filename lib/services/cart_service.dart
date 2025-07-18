import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/utils/const.dart';

class CartService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add item to cart
  static Future<void> addToCart(String recipeId, String recipeName,
      String recipeImage, String recipePrice, int quantity) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Check if item already exists in cart
      final cartDoc = await _firestore
          .collection('Cart')
          .where('userId', isEqualTo: user.uid)
          .where('recipeId', isEqualTo: recipeId)
          .get();

      if (cartDoc.docs.isNotEmpty) {
        // Update existing cart item
        await cartDoc.docs.first.reference.update({
          'quantity': FieldValue.increment(quantity),
        });
      } else {
        // Add new cart item
        await _firestore.collection('Cart').add({
          'userId': user.uid,
          'recipeId': recipeId,
          'recipeName': recipeName,
          'recipeImage': recipeImage,
          'recipePrice': recipePrice,
          'quantity': quantity,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  // Get cart items for current user
  static Stream<QuerySnapshot> getCartItems() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    return _firestore
        .collection('Cart')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  // Update cart item quantity
  static Future<void> updateCartItemQuantity(
      String cartItemId, int quantity) async {
    try {
      if (quantity <= 0) {
        await _firestore.collection('Cart').doc(cartItemId).delete();
      } else {
        await _firestore.collection('Cart').doc(cartItemId).update({
          'quantity': quantity,
        });
      }
    } catch (e) {
      print('Error updating cart item: $e');
      rethrow;
    }
  }

  // Remove item from cart
  static Future<void> removeFromCart(String cartItemId) async {
    try {
      await _firestore.collection('Cart').doc(cartItemId).delete();
    } catch (e) {
      print('Error removing from cart: $e');
      rethrow;
    }
  }

  // Clear entire cart
  static Future<void> clearCart() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final cartItems = await _firestore
          .collection('Cart')
          .where('userId', isEqualTo: user.uid)
          .get();

      for (var doc in cartItems.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error clearing cart: $e');
      rethrow;
    }
  }

  // Place order
  static Future<void> placeOrder(
      List<Map<String, dynamic>> cartItems, double totalAmount) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get user data to include address
      final userDoc = await _firestore.collection('Users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final userAddress = userData?['address'] ?? 'No address provided';

      // Create order
      await _firestore.collection('Orders').add({
        'userId': user.uid,
        'userAddress': userAddress,
        'items': cartItems,
        'totalAmount': totalAmount,
        'status': 'pending',
        'orderDate': FieldValue.serverTimestamp(),
        'orderNumber': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      // Clear cart after successful order
      await clearCart();
    } catch (e) {
      print('Error placing order: $e');
      rethrow;
    }
  }

  // Get user orders
  static Stream<QuerySnapshot> getUserOrders() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    return _firestore
        .collection('Orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('orderDate', descending: true)
        .snapshots();
  }
}
