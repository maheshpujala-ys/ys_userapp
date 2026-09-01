import 'package:flutter/material.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/features/home/models/activity_item.dart';
import 'package:yellowspotuser/features/home/models/community_notice.dart';
import 'package:yellowspotuser/features/residential/domain/vehicle.dart';

abstract class HomeRepository {
  Future<List<ActivityItem>> getTodayActivities();
  Future<Vehicle?> getPrimaryVehicle();
  Future<List<CommunityNotice>> getCommunityHighlights();
}

class MockHomeRepository implements HomeRepository {
  @override
  Future<List<ActivityItem>> getTodayActivities() async {
    // Simulates realistic repository-level data retrieval
    await Future.delayed(const Duration(milliseconds: 150));
    return [
      ActivityItem(
        id: 'act-1',
        title: 'Parking Spot Reserved',
        subtitle: 'Slot B2-45 • Valid until 8:00 PM',
        time: '10:30 AM',
        category: ActivityCategory.parking,
        icon: Icons.local_parking_rounded,
        color: AppColors.primaryDark,
        status: 'Active',
      ),
      ActivityItem(
        id: 'act-2',
        title: 'Guest Pass Generated',
        subtitle: 'Rahul Sharma (Cab/Visitor) • Approved',
        time: '11:15 AM',
        category: ActivityCategory.visitor,
        icon: Icons.person_pin_circle_rounded,
        color: AppColors.info,
        status: 'Approved',
      ),
      ActivityItem(
        id: 'act-3',
        title: 'Package Arrived at Gate',
        subtitle: 'Amazon Delivery • Held at Security Gate 1',
        time: '09:45 AM',
        category: ActivityCategory.delivery,
        icon: Icons.inventory_2_outlined,
        color: AppColors.purple,
        status: 'Gate Held',
      ),
      ActivityItem(
        id: 'act-4',
        title: 'Car Detailing Scheduled',
        subtitle: 'Eco Wash & Interior Clean • 4:00 PM Today',
        time: '04:00 PM',
        category: ActivityCategory.service,
        icon: Icons.car_repair_rounded,
        color: AppColors.teal,
        status: 'Scheduled',
      ),
    ];
  }

  @override
  Future<Vehicle?> getPrimaryVehicle() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Vehicle(
      number: 'TS 09 EQ 4821',
      make: 'Hyundai',
      model: 'Creta SX (O) Turbo',
      parkingSlot: 'Basement 1 - Slot 42',
    );
  }

  @override
  Future<List<CommunityNotice>> getCommunityHighlights() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return const [
      CommunityNotice(
        id: 'not-1',
        title: 'Scheduled Water Tank Maintenance',
        description: 'Water supply will be temporarily paused between 2:00 PM - 5:00 PM for semi-annual cleaning.',
        timestamp: 'Today, 8:00 AM',
        priority: NoticePriority.urgent,
        author: 'Society Maintenance Board',
      ),
      CommunityNotice(
        id: 'not-2',
        title: 'EV Charging Bay Expansion (Basement 2)',
        description: '6 new 22kW AC fast chargers have been activated and mapped in YellowSpot.',
        timestamp: 'Yesterday',
        priority: NoticePriority.general,
        author: 'Green Energy Committee',
      ),
      CommunityNotice(
        id: 'not-3',
        title: 'Weekend Badminton Tournament Registration',
        description: 'Registrations open in Clubhouse for Singles & Doubles. Reserve your slot via Amenities.',
        timestamp: '2 days ago',
        priority: NoticePriority.event,
        author: 'Sports Committee',
      ),
    ];
  }
}
