import 'package:flutter/material.dart';
import 'package:recipe_app/screens/tabs/admin/add_recipe_screen.dart';
import 'package:recipe_app/screens/auth/login_screen.dart';

import 'package:recipe_app/screens/tabs/admin/home_tab.dart';
import 'package:recipe_app/screens/tabs/users/user_orders_tab.dart';
import 'package:recipe_app/screens/tabs/users/profile_tab.dart';
import 'package:recipe_app/utils/colors.dart';
import 'package:recipe_app/widgets/logout_widget.dart';
import 'package:recipe_app/widgets/text_widget.dart';
import 'package:recipe_app/screens/cart_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomeTab(
      isUser: true,
    ),
    UserOrdersTab(),
    // const FavoritesTab(),
    const ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primary,
        title: TextWidget(
          text: 'Pizzafy',
          fontSize: 18,
          color: Colors.white,
        ),
        actions: [
          if (true) // Always show for users
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
              icon: const Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
            ),
          IconButton(
            onPressed: () {
              logout(context, const LoginScreen());
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'My Orders',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.favorite),
          //   label: 'Favorites',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
