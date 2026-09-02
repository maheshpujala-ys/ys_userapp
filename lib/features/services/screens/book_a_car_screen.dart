import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/core/widgets/section_header.dart';

class BookACarScreen extends ConsumerWidget {
  const BookACarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Car & Rides'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPromoBanner(context),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Quick Ride Booking'),
            _buildRideSharingGrid(context),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Car Rentals in Society'),
            _buildCarRentalCard(context),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Buy, Sell & Verify Cars'),
            _buildCarPlatformList(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      color: isDark ? AppColors.surfaceElevatedDark : AppColors.primaryContainer,
      borderColor: AppColors.primary,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '🎉 First Ride Free!',
                      style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 8),
                    const AppStatusPill(label: 'COUPON', type: StatusType.primary),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Get up to ₹100 off on your first doorstep cab booking',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PROMO: YELLOWFIRST',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.card_giftcard_rounded, size: 42, color: AppColors.primaryDark),
        ],
      ),
    );
  }

  Widget _buildRideSharingGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildRideServiceCard(name: 'Uber', subtitle: 'Doorstep Pick', icon: Icons.local_taxi_rounded, iconColor: Colors.black87),
        _buildRideServiceCard(name: 'Ola Cabs', subtitle: 'Prime & Mini', icon: Icons.directions_car_rounded, iconColor: Colors.green),
        _buildRideServiceCard(name: 'Rapido', subtitle: 'Bike & Auto', icon: Icons.motorcycle_rounded, iconColor: AppColors.primaryDark),
        _buildRideServiceCard(name: 'inDrive', subtitle: 'Bid your fare', icon: Icons.handshake_outlined, iconColor: AppColors.info),
      ],
    );
  }

  Widget _buildRideServiceCard({
    required String name,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onTap: () {},
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCarRentalCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.infoContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.car_rental_rounded, color: AppColors.infoDark, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Self-Drive Society Rentals', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  Text(
                    'Cars parked in Basement 1 for instant booking',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildRentalChip('Zoomcar • 5 Cars', Colors.green),
              const SizedBox(width: 8),
              _buildRentalChip('Revv • 3 SUVs', Colors.deepPurple),
              const SizedBox(width: 8),
              _buildRentalChip('MyChoize', Colors.blue),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildRentalChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildCarPlatformList(BuildContext context) {
    return Column(
      children: [
        _buildCarPlatformCard(name: 'Spinny Assured', subtitle: '200-Point Inspection • 1 Yr Warranty', icon: Icons.verified_outlined, color: Colors.indigo),
        const SizedBox(height: 8),
        _buildCarPlatformCard(name: 'Cars24 Doorstep', subtitle: 'Instant Valuation & Society Pickup', icon: Icons.swap_horiz_outlined, color: Colors.deepOrange),
        const SizedBox(height: 8),
        _buildCarPlatformCard(name: 'CarDekho Expert', subtitle: 'New Car Pricing, On-Road Quotes & Reviews', icon: Icons.manage_search_outlined, color: Colors.blue),
      ],
    );
  }

  Widget _buildCarPlatformCard({
    required String name,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () {},
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMutedLight),
        ],
      ),
    );
  }
}
