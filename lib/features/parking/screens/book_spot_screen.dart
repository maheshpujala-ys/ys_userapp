import 'package:flutter/material.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/core/widgets/section_header.dart';

class BookSpotScreen extends StatelessWidget {
  final String mallName;
  final String address;
  final int availableSpots;
  final int totalSpots;

  const BookSpotScreen({
    super.key,
    this.mallName = 'Palm Meadows Tower A',
    this.address = 'Tower A - Basement 1, Hyderabad',
    this.availableSpots = 15,
    this.totalSpots = 50,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reserve Parking Slot'),
        actions: [
          IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          mallName,
                          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      AppStatusPill(
                        label: '$availableSpots Open',
                        type: availableSpots > 5 ? StatusType.success : StatusType.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 16, color: AppColors.success),
                      SizedBox(width: 4),
                      Text('Open 24/7 Access', style: TextStyle(color: AppColors.successDark, fontWeight: FontWeight.w600, fontSize: 12)),
                      SizedBox(width: 16),
                      Icon(Icons.local_parking_rounded, size: 16, color: AppColors.primaryDark),
                      SizedBox(width: 4),
                      Text('Covered Bay', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const SectionHeader(title: 'Reservation Details'),
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'Vehicle Plate', initialValue: 'TS09ER1234')),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdownField(label: 'Duration', items: ['2 hours', '4 hours', '8 hours', 'Full Day'])),
              ],
            ),
            const SizedBox(height: 20),

            _buildPriceBreakdown(isDark),
            const SizedBox(height: 20),

            const SectionHeader(title: 'Add-on Services (Optional)'),
            _buildOptionalServices(),
            const SizedBox(height: 20),

            const SectionHeader(title: 'Payment Method'),
            _buildPaymentOptions(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Parking reservation confirmed!')),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Confirm Reservation • ₹60'),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String initialValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: items.first,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: (_) {},
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown(bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Price Breakdown', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Base reservation fee', style: TextStyle(fontSize: 13)), Text('₹30', style: TextStyle(fontSize: 13))]),
          const SizedBox(height: 6),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Parking duration (2 hrs)', style: TextStyle(fontSize: 13)), Text('₹30', style: TextStyle(fontSize: 13))]),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Payable', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              Text('₹60', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primaryDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionalServices() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        _buildServiceChip(Icons.ev_station_rounded, 'EV Charge', '+₹50'),
        _buildServiceChip(Icons.wash_rounded, 'Eco Wash', '+₹150'),
        _buildServiceChip(Icons.shield_outlined, 'Valet Park', '+₹100'),
      ],
    );
  }

  Widget _buildServiceChip(IconData icon, String label, String price) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryDark),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              Text(price, style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Row(
      children: [
        Expanded(
          child: AppCard(
            borderColor: AppColors.primary,
            padding: const EdgeInsets.all(12.0),
            child: const Column(
              children: [
                Text('Pay Now', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryDark, fontSize: 13)),
                SizedBox(height: 2),
                Text('Instant Pass', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppCard(
            padding: const EdgeInsets.all(12.0),
            child: const Column(
              children: [
                Text('Pay at Exit', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                SizedBox(height: 2),
                Text('Auto FASTag/Wallet', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
