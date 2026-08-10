import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/auth/application/auth_controller.dart';
import 'package:yellowspotuser/features/auth/screens/profile_screen.dart';

/// Circular avatar showing the signed-in user's initials (e.g. "MP").
/// Tapping it opens [ProfileScreen] — which is where the Log Out action lives.
///
/// Used in both residential and corporate admin dashboards in place of the
/// old top-right logout icon.
class UserAvatarButton extends ConsumerWidget {
  const UserAvatarButton({
    super.key,
    this.radius = 18,
    this.backgroundColor,
    this.foregroundColor,
  });

  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(AuthController.provider).asData?.value;
    final initials = _initials(user?.name);
    final bg = backgroundColor ?? Colors.yellow[700]!;
    final fg = foregroundColor ?? Colors.black;

    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: initials.isEmpty
            ? Icon(Icons.person, size: radius, color: fg)
            : Text(
                initials,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.8,
                ),
              ),
      ),
    );
  }

  /// "Mahesh Pujala" → "MP"; "Mahesh" → "M"; null/empty → "".
  static String _initials(String? name) {
    if (name == null) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
