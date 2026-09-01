import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/features/notifications/models/notification_model.dart';

final notificationsListProvider = StateNotifierProvider<NotificationsNotifier, List<NotificationItem>>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationsNotifier()
      : super([
          const NotificationItem(
            id: 'n-1',
            title: 'Guest Pass Scanned at Gate 1',
            message: 'Rahul Sharma (Cab TS09EQ1234) entered Palm Meadows.',
            timestamp: '10 mins ago',
            category: NotificationCategory.visitors,
            icon: Icons.person_pin_circle_rounded,
            iconColor: AppColors.info,
            isRead: false,
          ),
          const NotificationItem(
            id: 'n-2',
            title: 'Parking Reservation Expiring Soon',
            message: 'Slot B2-45 expires in 30 minutes. Tap to extend.',
            timestamp: '25 mins ago',
            category: NotificationCategory.parking,
            icon: Icons.local_parking_rounded,
            iconColor: AppColors.primaryDark,
            isRead: false,
          ),
          const NotificationItem(
            id: 'n-3',
            title: 'Package Waiting at Main Security',
            message: 'BlueDart courier package received and safely held.',
            timestamp: '1 hour ago',
            category: NotificationCategory.security,
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.purple,
            isRead: true,
          ),
          const NotificationItem(
            id: 'n-4',
            title: 'Society Maintenance Invoice Generated',
            message: 'Monthly maintenance invoice for September is now due.',
            timestamp: 'Yesterday',
            category: NotificationCategory.payments,
            icon: Icons.receipt_long_rounded,
            iconColor: AppColors.success,
            isRead: true,
          ),
          const NotificationItem(
            id: 'n-5',
            title: 'Water Tank Cleaning Notice',
            message: 'Supply paused today from 2:00 PM to 5:00 PM.',
            timestamp: 'Yesterday',
            category: NotificationCategory.society,
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.warningDark,
            isRead: true,
          ),
        ]);

  void markAsRead(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(isRead: true) else item,
    ];
  }

  void markAllAsRead() {
    state = [for (final item in state) item.copyWith(isRead: true)];
  }

  void clearAll() {
    state = [];
  }
}
