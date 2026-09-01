import 'package:flutter/material.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/features/residential/domain/vehicle.dart';

class MyGarageScreen extends StatefulWidget {
  const MyGarageScreen({super.key});

  @override
  State<MyGarageScreen> createState() => _MyGarageScreenState();
}

class _MyGarageScreenState extends State<MyGarageScreen> {
  final List<Map<String, dynamic>> _garageVehicles = [
    {
      'vehicle': Vehicle(
        number: 'TS 09 EQ 4821',
        make: 'Hyundai',
        model: 'Creta SX (O) Turbo',
        parkingSlot: 'Basement 1 - Slot 42',
      ),
      'isPrimary': true,
      'isEv': false,
      'insuranceExpiry': 'Valid until Oct 2027',
      'pucExpiry': 'Valid until Mar 2027',
    },
    {
      'vehicle': Vehicle(
        number: 'TS 09 EV 9900',
        make: 'Tata',
        model: 'Nexon EV Empowered+',
        parkingSlot: 'Basement 2 - Slot 14 (EV Bay)',
      ),
      'isPrimary': false,
      'isEv': true,
      'insuranceExpiry': 'Valid until Aug 2028',
      'pucExpiry': 'Exempt (EV)',
    },
    {
      'vehicle': Vehicle(
        number: 'TS 09 BE 1122',
        make: 'Ather',
        model: '450X Gen 3 (Electric Scooter)',
        parkingSlot: 'Two Wheeler Bay 08',
      ),
      'isPrimary': false,
      'isEv': true,
      'insuranceExpiry': 'Valid until Dec 2026',
      'pucExpiry': 'Exempt (EV)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Garage & Vehicles'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle registration request submitted to society admin.')),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black87,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Vehicle', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: _garageVehicles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = _garageVehicles[index];
          final Vehicle vehicle = item['vehicle'] as Vehicle;
          final bool isPrimary = item['isPrimary'] as bool;
          final bool isEv = item['isEv'] as bool;

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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isEv ? AppColors.successContainer : AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEv ? Icons.electric_car_rounded : Icons.directions_car_filled_rounded,
                            color: isEv ? AppColors.successDark : AppColors.primaryDark,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${vehicle.make} ${vehicle.model}',
                              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              vehicle.registrationNumber,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (isPrimary)
                      const AppStatusPill(label: 'PRIMARY', type: StatusType.primary)
                    else if (isEv)
                      const AppStatusPill(label: 'EV READY', type: StatusType.success),
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
                        const Text('Parking Allocation', style: TextStyle(fontSize: 10, color: AppColors.textMutedLight)),
                        Text(
                          vehicle.parkingSlot ?? 'Slot Unallocated',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Insurance Status', style: TextStyle(fontSize: 10, color: AppColors.textMutedLight)),
                        Text(
                          item['insuranceExpiry'] as String,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success),
                        ),
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
}
