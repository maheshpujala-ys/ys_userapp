import 'package:flutter/material.dart';

enum NotificationCategory {
  all,
  important,
  parking,
  security,
  visitors,
  vehicles,
  services,
  society,
  payments,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timestamp;
  final NotificationCategory category;
  final IconData icon;
  final Color iconColor;
  final bool isRead;
  final String? actionRoute;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.category,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
    this.actionRoute,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      category: category,
      icon: icon,
      iconColor: iconColor,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute,
    );
  }
}
