import 'package:flutter/material.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/features/auth/screens/profile_screen.dart';
import 'package:yellowspotuser/features/ev_charging/screens/ev_charging_screen.dart';
import 'package:yellowspotuser/features/home/screens/home_dashboard_screen.dart';
import 'package:yellowspotuser/features/parking/screens/parking_hub_screen.dart';
import 'package:yellowspotuser/features/residence/access_pass/screens/digital_access_pass_screen.dart';
import 'package:yellowspotuser/features/residence/screens/residence_hub_screen.dart';
import 'package:yellowspotuser/features/residence/visitors/screens/visitor_management_screen.dart';
import 'package:yellowspotuser/features/services/screens/services_hub_screen.dart';
import 'package:yellowspotuser/features/vehicles/screens/my_garage_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> screens = [
      HomeDashboardScreen(
        onNavigateTab: (index) => _onItemTapped(index),
        onInviteGuest: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const VisitorManagementScreen()),
        ),
        onAccessPass: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DigitalAccessPassScreen()),
        ),
        onMyGarage: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MyGarageScreen()),
        ),
        onEvCharging: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EvChargingScreen()),
        ),
      ),
      const ParkingHubScreen(),
      const ServicesHubScreen(),
      const ResidenceHubScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_parking_outlined),
            selectedIcon: Icon(Icons.local_parking_rounded),
            label: 'Parking',
          ),
          NavigationDestination(
            icon: Icon(Icons.car_repair_outlined),
            selectedIcon: Icon(Icons.car_repair_rounded),
            label: 'Services',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment_rounded),
            label: 'Residence',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
