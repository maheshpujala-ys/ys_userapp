import 'package:flutter/material.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';

class Amenity {
  final String id;
  final String name;
  final String timings;
  final String capacity;
  final IconData icon;
  final bool isAvailable;

  const Amenity({
    required this.id,
    required this.name,
    required this.timings,
    required this.capacity,
    required this.icon,
    required this.isAvailable,
  });
}

class AmenitiesBookingScreen extends StatelessWidget {
  const AmenitiesBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Amenity> amenities = [
      const Amenity(
        id: 'am-1',
        name: 'Olympic Swimming Pool',
        timings: '06:00 AM - 10:00 PM',
        capacity: 'Max 25 persons slot',
        icon: Icons.pool_rounded,
        isAvailable: true,
      ),
      const Amenity(
        id: 'am-2',
        name: 'Fitness Center & Gym',
        timings: '05:30 AM - 11:00 PM',
        capacity: 'Open access for residents',
        icon: Icons.fitness_center_rounded,
        isAvailable: true,
      ),
      const Amenity(
        id: 'am-3',
        name: 'Tennis & Pickleball Court',
        timings: '06:00 AM - 09:00 PM',
        capacity: 'Book court in 1hr slots',
        icon: Icons.sports_tennis_rounded,
        isAvailable: true,
      ),
      const Amenity(
        id: 'am-4',
        name: 'Grand Banquet Hall',
        timings: 'By Event Booking',
        capacity: 'Max 200 guests',
        icon: Icons.celebration_rounded,
        isAvailable: false,
      ),
      const Amenity(
        id: 'am-5',
        name: 'Indoor Badminton Court',
        timings: '06:00 AM - 10:00 PM',
        capacity: '2 Wooden Courts',
        icon: Icons.sports_tennis_outlined,
        isAvailable: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Society Amenities'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: amenities.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final amenity = amenities[index];

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
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(amenity.icon, color: AppColors.primaryDark, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              amenity.name,
                              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              amenity.timings,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    AppStatusPill(
                      label: amenity.isAvailable ? 'AVAILABLE' : 'BOOKED OUT',
                      type: amenity.isAvailable ? StatusType.success : StatusType.error,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(amenity.capacity, style: const TextStyle(fontSize: 12, color: AppColors.textMutedLight)),
                    ElevatedButton(
                      onPressed: amenity.isAvailable
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Reserved slot for ${amenity.name}!')),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        minimumSize: const Size(0, 34),
                      ),
                      child: const Text('Reserve Slot', style: TextStyle(fontSize: 12)),
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
