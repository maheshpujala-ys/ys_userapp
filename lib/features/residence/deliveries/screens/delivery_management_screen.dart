import 'package:flutter/material.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/core/widgets/empty_state.dart';

enum DeliveryStatus {
  atGate,
  approved,
  heldAtSecurity,
  received,
}

class DeliveryItem {
  final String id;
  final String courierName; // Amazon, Flipkart, Swiggy, Zomato, BlueDart
  final String packageDesc;
  final String deliveryPerson;
  final String gateName;
  final String time;
  DeliveryStatus status;

  DeliveryItem({
    required this.id,
    required this.courierName,
    required this.packageDesc,
    required this.deliveryPerson,
    required this.gateName,
    required this.time,
    required this.status,
  });
}

class DeliveryManagementScreen extends StatefulWidget {
  const DeliveryManagementScreen({super.key});

  @override
  State<DeliveryManagementScreen> createState() => _DeliveryManagementScreenState();
}

class _DeliveryManagementScreenState extends State<DeliveryManagementScreen> {
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

  void _updateStatus(DeliveryItem item, DeliveryStatus newStatus, String actionMessage) {
    setState(() => item.status = newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(actionMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deliveries & Gate Parcels'),
      ),
      body: _deliveries.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.inventory_2_outlined,
              title: 'No Pending Deliveries',
              description: 'When couriers and food deliveries arrive at society gates, you can approve or hold them here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _deliveries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final delivery = _deliveries[index];

                StatusType type = StatusType.neutral;
                String label = 'Received';
                if (delivery.status == DeliveryStatus.atGate) {
                  type = StatusType.warning;
                  label = 'Waiting at Gate';
                } else if (delivery.status == DeliveryStatus.approved) {
                  type = StatusType.info;
                  label = 'Approved for Entry';
                } else if (delivery.status == DeliveryStatus.heldAtSecurity) {
                  type = StatusType.primary;
                  label = 'Held with Security';
                }

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
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.purpleContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.inventory_2_rounded, color: AppColors.purple, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    delivery.courierName,
                                    style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    delivery.packageDesc,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          AppStatusPill(label: label, type: type),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Gate: ${delivery.gateName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          Text(delivery.time, style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (delivery.status == DeliveryStatus.atGate)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _updateStatus(
                                  delivery,
                                  DeliveryStatus.approved,
                                  'Delivery person permitted to enter tower lift lobby.',
                                ),
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text('Approve Entry', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  minimumSize: const Size(0, 36),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _updateStatus(
                                  delivery,
                                  DeliveryStatus.heldAtSecurity,
                                  'Instructed guard to hold parcel at gate desk.',
                                ),
                                icon: const Icon(Icons.shield_outlined, size: 16),
                                label: const Text('Hold at Gate', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  minimumSize: const Size(0, 36),
                                ),
                              ),
                            ),
                          ],
                        )
                      else if (delivery.status == DeliveryStatus.approved || delivery.status == DeliveryStatus.heldAtSecurity)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _updateStatus(
                              delivery,
                              DeliveryStatus.received,
                              'Marked parcel as received.',
                            ),
                            icon: const Icon(Icons.done_all_rounded, size: 16),
                            label: const Text('Mark as Received'),
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
