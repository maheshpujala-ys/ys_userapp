import 'package:flutter/material.dart';

enum ActivityCategory {
  parking,
  visitor,
  service,
  delivery,
  gate,
  society,
}

class ActivityItem {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final ActivityCategory category;
  final IconData icon;
  final Color color;
  final String status;
  final VoidCallback? onTap;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.category,
    required this.icon,
    required this.color,
    required this.status,
    this.onTap,
  });
}
