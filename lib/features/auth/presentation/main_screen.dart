import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seapedia_ui_compfest/features/product/presentation/landing_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const LandingScreen(), // Tab 0: Home / Landing
    const Center(child: Text('Search Page')), // Tab 1: Search (Placeholder)
    const Center(child: Text('Cart Page')), // Tab 2: Cart (Placeholder)
    const Center(child: Text('Orders Page')), // Tab 3: Orders (Placeholder)
    const Center(child: Text('Profile Page')), // Tab 4: Profile (Placeholder)
  ];

  void _onTabTapped(int index) {
    if (index == 3 || index == 4) {
      context.push('/login');
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}