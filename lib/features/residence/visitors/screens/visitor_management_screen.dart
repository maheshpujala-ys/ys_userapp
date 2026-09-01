import 'package:flutter/material.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/core/widgets/empty_state.dart';

enum VisitorStatus {
  invited,
  approved,
  arrived,
  inside,
  exited,
  expired,
}

class VisitorItem {
  final String id;
  final String guestName;
  final String phone;
  final String type; // Friend, Delivery, Cab, Contractor, Domestic
  final String vehicleNumber;
  final String validDate;
  final VisitorStatus status;

  const VisitorItem({
    required this.id,
    required this.guestName,
    required this.phone,
    required this.type,
    required this.vehicleNumber,
    required this.validDate,
    required this.status,
  });
}

class VisitorManagementScreen extends StatefulWidget {
  const VisitorManagementScreen({super.key});

  @override
  State<VisitorManagementScreen> createState() => _VisitorManagementScreenState();
}

class _VisitorManagementScreenState extends State<VisitorManagementScreen> {
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

  void _openInviteGuestModal() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final vehicleCtrl = TextEditingController();
    String guestType = 'Friend / Family';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const Text(
                'Invite Guest / Visitor',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Generates an instant pre-approved digital QR pass for gate entry.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Guest Name *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: vehicleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Number (Optional)',
                  prefixIcon: Icon(Icons.directions_car_outlined),
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: guestType,
                decoration: const InputDecoration(
                  labelText: 'Visitor Type',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: ['Friend / Family', 'Delivery', 'Cab / Taxi', 'Contractor / Tech', 'Domestic Help']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) => setModalState(() => guestType = val!),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    setState(() {
                      _visitors.insert(
                        0,
                        VisitorItem(
                          id: 'v-${DateTime.now().millisecondsSinceEpoch}',
                          guestName: nameCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          type: guestType,
                          vehicleNumber: vehicleCtrl.text.trim().isNotEmpty ? vehicleCtrl.text.trim() : 'No Vehicle',
                          validDate: 'Today, Next 4 Hours',
                          status: VisitorStatus.approved,
                        ),
                      );
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Guest Pass Generated & Sent!')),
                    );
                  },
                  icon: const Icon(Icons.qr_code_2_rounded),
                  label: const Text('Generate Digital Pass'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Management'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openInviteGuestModal,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black87,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Invite Guest', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _visitors.isEmpty
          ? EmptyStateWidget(
              icon: Icons.people_outline_rounded,
              title: 'No Visitors Today',
              description: 'Tap the button below to pre-approve and invite a guest or cab.',
              actionLabel: 'Invite Guest',
              onAction: _openInviteGuestModal,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: _visitors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final visitor = _visitors[index];

                StatusType statusType = StatusType.neutral;
                if (visitor.status == VisitorStatus.approved || visitor.status == VisitorStatus.inside) {
                  statusType = StatusType.success;
                } else if (visitor.status == VisitorStatus.invited) {
                  statusType = StatusType.info;
                }

                return AppCard(
                  padding: const EdgeInsets.all(16),
                  onTap: () => _showVisitorPassDetail(context, visitor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.infoContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.person_pin_circle_rounded, color: AppColors.infoDark, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    visitor.guestName,
                                    style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    visitor.type,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          AppStatusPill(label: visitor.status.name.toUpperCase(), type: statusType),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Vehicle', style: TextStyle(fontSize: 10, color: AppColors.textMutedLight)),
                              Text(visitor.vehicleNumber, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Validity', style: TextStyle(fontSize: 10, color: AppColors.textMutedLight)),
                              Text(visitor.validDate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showVisitorPassDetail(BuildContext context, VisitorItem visitor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text(
              'Digital Gate Pass: ${visitor.guestName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.qr_code_2_rounded, size: 140, color: Colors.black),
            ),
            const SizedBox(height: 14),
            Text(
              'Pass Code: YS-VIS-${visitor.id.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 6),
            const Text(
              'Security guard at Gate 1 will scan this pass to allow barrier entry.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
