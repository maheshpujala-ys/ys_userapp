import 'package:flutter/material.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';

class EmergencySosSheet extends StatefulWidget {
  const EmergencySosSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EmergencySosSheet(),
    );
  }

  @override
  State<EmergencySosSheet> createState() => _EmergencySosSheetState();
}

class _EmergencySosSheetState extends State<EmergencySosSheet> {
  String? _selectedEmergency;
  bool _isDispatching = false;

  final List<Map<String, dynamic>> _sosTypes = [
    {
      'id': 'security',
      'title': 'Society Security Gate',
      'subtitle': 'Immediate guard dispatch to unit A-1204',
      'icon': Icons.security_rounded,
      'color': AppColors.error,
      'phone': '+91 98765 43210',
    },
    {
      'id': 'medical',
      'title': 'Medical Emergency (Ambulance)',
      'subtitle': 'Dispatches paramedics & informs gate',
      'icon': Icons.medical_services_rounded,
      'color': AppColors.errorDark,
      'phone': '108 / 102',
    },
    {
      'id': 'fire',
      'title': 'Fire & Hazard Alert',
      'subtitle': 'Triggers fire response & building alarms',
      'icon': Icons.local_fire_department_rounded,
      'color': Colors.deepOrange,
      'phone': '101',
    },
    {
      'id': 'police',
      'title': 'Police Emergency',
      'subtitle': 'Immediate law enforcement assist',
      'icon': Icons.local_police_rounded,
      'color': AppColors.infoDark,
      'phone': '100 / 112',
    },
    {
      'id': 'roadside',
      'title': 'Roadside Breakdown SOS',
      'subtitle': 'YellowSpot emergency towing & flat tyre',
      'icon': Icons.car_crash_rounded,
      'color': AppColors.warningDark,
      'phone': 'YellowSpot 24/7 Desk',
    },
  ];

  void _dispatchSos(String id, String title) {
    setState(() => _isDispatching = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _isDispatching = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.errorDark,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'SOS Alert broadcasted to $title! Security team notified.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.emergency_rounded, color: AppColors.error, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Emergency SOS Dispatch',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Sends resident identity & Unit A-1204 location immediately',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          if (_isDispatching)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.error),
                    SizedBox(height: 16),
                    Text(
                      'Broadcasting SOS Alert & Notifying Command Center...',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Text(
              'Select Emergency Type',
              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _sosTypes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _sosTypes[index];
                final isSelected = _selectedEmergency == item['id'];

                return AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  borderColor: isSelected ? AppColors.error : null,
                  color: isSelected ? AppColors.errorContainer.withValues(alpha: 0.2) : null,
                  onTap: () => setState(() => _selectedEmergency = item['id'] as String),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              item['subtitle'] as String,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ignore: deprecated_member_use
                      Radio<String>(
                        value: item['id'] as String,
                        // ignore: deprecated_member_use
                        groupValue: _selectedEmergency,
                        activeColor: AppColors.error,
                        // ignore: deprecated_member_use
                        onChanged: (val) => setState(() => _selectedEmergency = val),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _selectedEmergency == null
                    ? null
                    : () {
                        final selected = _sosTypes.firstWhere((e) => e['id'] == _selectedEmergency);
                        _dispatchSos(selected['id'] as String, selected['title'] as String);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.warning_amber_rounded, size: 20),
                label: const Text(
                  'CONFIRM & BROADCAST SOS',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
}
