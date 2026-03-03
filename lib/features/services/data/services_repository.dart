import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';

class ServicesRepository {
  final Dio _dio;

  ServicesRepository(this._dio);

  static final provider = Provider<ServicesRepository>(
    (ref) => ServicesRepository(ref.watch(dioProvider)),
  );

  // In a real app, you'd fetch this data from your API
  Future<Map<String, dynamic>> getServicesData() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'featuredServices': [
        {
          'title': 'EV Charging',
          'subtitle': 'Find stations',
        },
        {
          'title': 'FASTag Recharge',
          'subtitle': 'Quick recharge',
        },
      ],
      'recentTransactions': [
        {
          'title': 'Mobile Recharge',
          'subtitle': '+91 98765xxxxx',
          'amount': '₹199',
          'success': true,
        },
        {
          'title': 'Electricity Bill',
          'subtitle': 'TSSPDCL',
          'amount': '₹2,450',
          'success': true,
        },
      ],
    };
  }
}
