import 'package:dio/dio.dart';

class AdminRepository {
  final Dio _dio;

  AdminRepository(this._dio);

  Future<Map<String, dynamic>> getDashboardData() async {
    // In a real app, you'd fetch this data from your API
    await Future.delayed(const Duration(seconds: 1));
    return {
      'residents': 480,
      'vehicles': 650,
      'parking': 78,
      'pending': 5,
    };
  }

   Future<List<Map<String, dynamic>>> getEntryExitData() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'vehicleNumber': 'KA-01-AB-1234',
        'unit': 'Unit B-1204',
        'owner': 'Rajesh Kumar',
        'isEntry': true,
        'timestamp': '2 min ago',
      },
      {
        'vehicleNumber': 'TN-09-CD-5678',
        'unit': 'Unit A-305',
        'owner': 'Priya Sharma',
        'isEntry': false,
        'timestamp': '5 min ago',
      },
    ];
  }

  Future<List<Map<String, dynamic>>> getRequestsData() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'userName': 'John Doe',
        'unit': 'Unit B-1506',
        'requestType': 'Join Request',
        'timestamp': '2 hours ago',
      },
       {
        'userName': 'Jane Smith',
        'unit': 'Unit A-405',
        'requestType': 'Vehicle Addition',
        'timestamp': '3 hours ago',
      },
    ];
  }

  Future<Map<String, dynamic>> getSecurityData() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'activeCameras': '24/28',
      'securityAlerts': 3,
      'recordingHours': '168h',
      'storageUsed': 85,
      'incidents': 12,
      'systemStatus': 'SECURE',
    };
  }

  Future<List<Map<String, dynamic>>> getActivityData() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      {
        'title': 'Visitor pass generated',
        'subtitle': 'Unit B-1204',
        'timestamp': '5 min ago',
      },
      {
        'title': 'New vehicle registered',
        'subtitle': 'Unit A-305',
        'timestamp': '15 min ago',
      },
    ];
  }
}
