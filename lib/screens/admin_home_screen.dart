import 'package:flutter/material.dart';
import 'package:recipe_app/screens/tabs/admin/add_recipe_screen.dart';
import 'package:recipe_app/screens/auth/login_screen.dart';

import 'package:recipe_app/screens/tabs/admin/home_tab.dart';
import 'package:recipe_app/screens/tabs/admin/my_recipe_tab.dart';
import 'package:recipe_app/screens/tabs/users/profile_tab.dart';
import 'package:recipe_app/utils/colors.dart';
import 'package:recipe_app/widgets/logout_widget.dart';
import 'package:recipe_app/widgets/text_widget.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomeTab(),
    MyRecipeTab(),
    // const FavoritesTab(),
    // const ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              backgroundColor: primary,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AddRecipeScreen()));
              },
            )
          : null,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primary,
        title: TextWidget(
          text: 'Pizzafy',
          fontSize: 18,
          color: Colors.white,
        ),
        actions: [
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
            label: 'My Menu',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.favorite),
          //   label: 'Favorites',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person),
          //   label: 'Profile',
          // ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
