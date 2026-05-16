import 'package:flutter/material.dart';
import 'package:yellowspotuser/features/services/screens/book_a_car_screen.dart';
import 'package:yellowspotuser/features/services/screens/car_services_screen.dart';
import 'package:yellowspotuser/features/parking/screens/find_your_spot_screen.dart';
import 'package:yellowspotuser/features/auth/screens/profile_screen.dart';
import 'package:yellowspotuser/features/services/screens/quick_services_screen.dart';
import 'package:yellowspotuser/features/residential/screens/residential_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    FindYourSpotScreen(),
    ResidentialScreen(),
    QuickServicesScreen(),
    CarServicesScreen(),
    BookACarScreen(),
    ProfileScreen(),
  ];

  static const List<BottomNavigationBarItem> _navItems =
      <BottomNavigationBarItem>[
    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Find Your Spot'),
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Residential'),
    BottomNavigationBarItem(
        icon: Icon(Icons.miscellaneous_services), label: 'Quick Services'),
    BottomNavigationBarItem(
        icon: Icon(Icons.car_rental), label: 'Car Services'),
    BottomNavigationBarItem(
        icon: Icon(Icons.book_online), label: 'Book a Car'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps each tab's state alive across switches and only paints
      // the visible child — the GoogleMap doesn't get re-created on every tab tap.
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: _navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
