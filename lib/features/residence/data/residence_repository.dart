import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/residence/amenities/screens/amenities_booking_screen.dart';
import 'package:yellowspotuser/features/residence/deliveries/screens/delivery_management_screen.dart';
import 'package:yellowspotuser/features/residence/maintenance/screens/maintenance_requests_screen.dart';
import 'package:yellowspotuser/features/residence/staff/screens/domestic_staff_screen.dart';
import 'package:yellowspotuser/features/residence/visitors/screens/visitor_management_screen.dart';

abstract class ResidenceRepository {
  Future<List<VisitorItem>> getVisitors();
  Future<VisitorItem> inviteVisitor({
    required String guestName,
    required String phone,
    required String type,
    required String vehicleNumber,
  });
  Future<List<DeliveryItem>> getDeliveries();
  Future<void> updateDeliveryStatus(String id, DeliveryStatus status);
  Future<List<StaffMember>> getDomesticStaff();
  Future<List<Amenity>> getAmenities();
  Future<List<MaintenanceTicket>> getMaintenanceTickets();
  Future<MaintenanceTicket> createMaintenanceTicket({
    required String title,
    required String category,
    required String description,
  });
}

class MockResidenceRepository implements ResidenceRepository {
  final List<VisitorItem> _visitors = [
    const VisitorItem(
      id: 'v-1',
      guestName: 'Rahul Sharma',
      phone: '+91 98765 12345',
      type: 'Cab / Ride',
      vehicleNumber: 'TS 09 EQ 1234',
      validDate: 'Today, 11:00 AM - 1:00 PM',
      status: VisitorStatus.approved,
    ),
    const VisitorItem(
      id: 'v-2',
      guestName: 'Pooja Verma',
      phone: '+91 91234 56789',
      type: 'Friend / Guest',
      vehicleNumber: 'KA 03 MN 8821',
      validDate: 'Today, 6:00 PM - 10:00 PM',
      status: VisitorStatus.invited,
    ),
    const VisitorItem(
      id: 'v-3',
      guestName: 'Suresh Kumar (AC Tech)',
      phone: '+91 99887 76655',
      type: 'Technician',
      vehicleNumber: 'TS 08 AC 9901',
      validDate: 'Yesterday',
      status: VisitorStatus.exited,
    ),
  ];

  final List<DeliveryItem> _deliveries = [
    DeliveryItem(
      id: 'd-1',
      courierName: 'Amazon India',
      packageDesc: '1 Parcel (Electronics)',
      deliveryPerson: 'Ramesh K. (+91 98765 00112)',
      gateName: 'Security Gate 1',
      time: '15 mins ago',
      status: DeliveryStatus.atGate,
    ),
    DeliveryItem(
      id: 'd-2',
      courierName: 'Swiggy Instamart',
      packageDesc: 'Grocery Bag',
      deliveryPerson: 'Vikas (+91 91234 44332)',
      gateName: 'Gate 2',
      time: '1 hour ago',
      status: DeliveryStatus.approved,
    ),
    DeliveryItem(
      id: 'd-3',
      courierName: 'BlueDart Express',
      packageDesc: 'Document Envelope',
      deliveryPerson: 'Security Guard Shift A',
      gateName: 'Clubhouse Desk',
      time: 'Yesterday',
      status: DeliveryStatus.received,
    ),
  ];

  final List<StaffMember> _staff = const [
    StaffMember(
      name: 'Sunita Devi',
      role: 'Housekeeping / Maid',
      phone: '+91 98111 22334',
      passId: 'STF-4021',
      isInside: true,
      lastEntryTime: 'Entered today at 08:15 AM (Gate 1)',
    ),
    StaffMember(
      name: 'Mohan Lal',
      role: 'Personal Driver',
      phone: '+91 98222 33445',
      passId: 'STF-3089',
      isInside: false,
      lastEntryTime: 'Exited yesterday at 07:30 PM (Gate 2)',
    ),
    StaffMember(
      name: 'Anjali Sharma',
      role: 'Cook / Chef',
      phone: '+91 98333 44556',
      passId: 'STF-5012',
      isInside: false,
      lastEntryTime: 'Expected today at 05:00 PM',
    ),
  ];

  final List<Amenity> _amenities = const [
    Amenity(
      id: 'am-1',
      name: 'Olympic Swimming Pool',
      timings: '06:00 AM - 10:00 PM',
      capacity: 'Max 25 persons slot',
      icon: Icons.pool_rounded,
      isAvailable: true,
    ),
    Amenity(
      id: 'am-2',
      name: 'Fitness Center & Gym',
      timings: '05:30 AM - 11:00 PM',
      capacity: 'Open access for residents',
      icon: Icons.fitness_center_rounded,
      isAvailable: true,
    ),
    Amenity(
      id: 'am-3',
      name: 'Tennis & Pickleball Court',
      timings: '06:00 AM - 09:00 PM',
      capacity: 'Book court in 1hr slots',
      icon: Icons.sports_tennis_rounded,
      isAvailable: true,
    ),
    Amenity(
      id: 'am-4',
      name: 'Grand Banquet Hall',
      timings: 'By Event Booking',
      capacity: 'Max 200 guests',
      icon: Icons.celebration_rounded,
      isAvailable: false,
    ),
    Amenity(
      id: 'am-5',
      name: 'Indoor Badminton Court',
      timings: '06:00 AM - 10:00 PM',
      capacity: '2 Wooden Courts',
      icon: Icons.sports_tennis_outlined,
      isAvailable: true,
    ),
  ];

  final List<MaintenanceTicket> _tickets = [
    const MaintenanceTicket(
      id: 'TKT-1082',
      title: 'Water Seepage in Master Bathroom',
      category: 'Plumbing',
      description: 'Slow leakage near drainage pipeline pipe in Unit A-1204.',
      createdAt: 'Today, 09:15 AM',
      status: TicketStatus.assigned,
    ),
    const MaintenanceTicket(
      id: 'TKT-1049',
      title: 'Corridor Light Flickering (Tower A Floor 12)',
      category: 'Electrical',
      description: 'Ceiling LED light outside flat 1204 is intermittent.',
      createdAt: '2 days ago',
      status: TicketStatus.resolved,
    ),
  ];

  @override
  Future<List<VisitorItem>> getVisitors() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_visitors);
  }

  @override
  Future<VisitorItem> inviteVisitor({
    required String guestName,
    required String phone,
    required String type,
    required String vehicleNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final item = VisitorItem(
      id: 'v-${DateTime.now().millisecondsSinceEpoch}',
      guestName: guestName,
      phone: phone,
      type: type,
      vehicleNumber: vehicleNumber.isNotEmpty ? vehicleNumber : 'No Vehicle',
      validDate: 'Today, Next 4 Hours',
      status: VisitorStatus.approved,
    );
    _visitors.insert(0, item);
    return item;
  }

  @override
  Future<List<DeliveryItem>> getDeliveries() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_deliveries);
  }

  @override
  Future<void> updateDeliveryStatus(String id, DeliveryStatus status) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _deliveries.indexWhere((d) => d.id == id);
    if (index != -1) {
      _deliveries[index].status = status;
    }
  }

  @override
  Future<List<StaffMember>> getDomesticStaff() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _staff;
  }

  @override
  Future<List<Amenity>> getAmenities() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _amenities;
  }

  @override
  Future<List<MaintenanceTicket>> getMaintenanceTickets() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_tickets);
  }

  @override
  Future<MaintenanceTicket> createMaintenanceTicket({
    required String title,
    required String category,
    required String description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final ticket = MaintenanceTicket(
      id: 'TKT-${1000 + _tickets.length + 1}',
      title: title,
      category: category,
      description: description,
      createdAt: 'Just now',
      status: TicketStatus.submitted,
    );
    _tickets.insert(0, ticket);
    return ticket;
  }
}

final residenceRepositoryProvider = Provider<ResidenceRepository>((ref) {
  return MockResidenceRepository();
});
