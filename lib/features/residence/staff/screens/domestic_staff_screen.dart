import 'package:flutter/material.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';

class StaffMember {
  final String name;
  final String role; // Maid, Driver, Cook, Gardener
  final String phone;
  final String passId;
  final bool isInside;
  final String lastEntryTime;

  const StaffMember({
    required this.name,
    required this.role,
    required this.phone,
    required this.passId,
    required this.isInside,
    required this.lastEntryTime,
  });
}

class DomesticStaffScreen extends StatelessWidget {
  const DomesticStaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<StaffMember> staffList = [
      const StaffMember(
        name: 'Sunita Devi',
        role: 'Housekeeping / Maid',
        phone: '+91 98111 22334',
        passId: 'STF-4021',
        isInside: true,
        lastEntryTime: 'Entered today at 08:15 AM (Gate 1)',
      ),
      const StaffMember(
        name: 'Mohan Lal',
        role: 'Personal Driver',
        phone: '+91 98222 33445',
        passId: 'STF-3089',
        isInside: false,
        lastEntryTime: 'Exited yesterday at 07:30 PM (Gate 2)',
      ),
      const StaffMember(
        name: 'Anjali Sharma',
        role: 'Cook / Chef',
        phone: '+91 98333 44556',
        passId: 'STF-5012',
        isInside: false,
        lastEntryTime: 'Expected today at 05:00 PM',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Domestic Staff'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: staffList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final staff = staffList[index];

          return AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(
                            staff.name[0],
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              staff.name,
                              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              staff.role,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    AppStatusPill(
                      label: staff.isInside ? 'INSIDE SOCIETY' : 'OUTSIDE',
                      type: staff.isInside ? StatusType.success : StatusType.neutral,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pass ID: ${staff.passId}', style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                    Text(staff.phone, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  staff.lastEntryTime,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
