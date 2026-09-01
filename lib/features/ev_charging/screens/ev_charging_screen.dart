import 'package:flutter/material.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';

class EvStation {
  final String id;
  final String name;
  final String location;
  final String powerOutput;
  final String connectorType;
  final bool isAvailable;
  final double ratePerKwh;

  const EvStation({
    required this.id,
    required this.name,
    required this.location,
    required this.powerOutput,
    required this.connectorType,
    required this.isAvailable,
    required this.ratePerKwh,
  });
}

class EvChargingScreen extends StatefulWidget {
  const EvChargingScreen({super.key});

  @override
  State<EvChargingScreen> createState() => _EvChargingScreenState();
}

class _EvChargingScreenState extends State<EvChargingScreen> {
  bool _isCharging = true;
  final double _currentPercent = 68.0;
  final double _kwhConsumed = 18.4;
  final double _cost = 276.0;

  final List<EvStation> _stations = [
    const EvStation(
      id: 'EV-01',
      name: 'Bay B2 - Supercharger 01',
      location: 'Basement 2 (Pillar 44)',
      powerOutput: '60 kW DC Fast',
      connectorType: 'CCS Type 2',
      isAvailable: false, // Currently connected
      ratePerKwh: 15.0,
    ),
    const EvStation(
      id: 'EV-02',
      name: 'Bay B2 - AC Fast Charger 02',
      location: 'Basement 2 (Pillar 46)',
      powerOutput: '22 kW AC',
      connectorType: 'Type 2 Gun',
      isAvailable: true,
      ratePerKwh: 11.5,
    ),
    const EvStation(
      id: 'EV-03',
      name: 'Bay B1 - Two Wheeler EV Port 01',
      location: 'Basement 1 (Two Wheeler Zone)',
      powerOutput: '3.3 kW AC',
      connectorType: 'Universal 16A',
      isAvailable: true,
      ratePerKwh: 9.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart EV Charging Bay'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Live Charging Monitor Card
            if (_isCharging) ...[
              AppCard(
                color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF0FDF4),
                borderColor: AppColors.success,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt_rounded, color: AppColors.successDark, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Live Charging Session',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                          ],
                        ),
                        AppStatusPill(label: 'CHARGING (${_currentPercent.toInt()}%)', type: StatusType.success),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _currentPercent / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildEvStat('Energy Added', '${_kwhConsumed.toStringAsFixed(1)} kWh'),
                        _buildEvStat('Charging Speed', '48.2 kW'),
                        _buildEvStat('Est. Cost', '₹${_cost.toStringAsFixed(0)}'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _isCharging = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Charging session stopped and billed to YellowSpot Wallet.')),
                          );
                        },
                        icon: const Icon(Icons.stop_circle_outlined, color: AppColors.error),
                        label: const Text('Stop Charging Session', style: TextStyle(color: AppColors.error)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            Text(
              'Available Charging Stations in Palm Meadows',
              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final station = _stations[index];

                return AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            station.name,
                            style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
                          ),
                          AppStatusPill(
                            label: station.isAvailable ? 'AVAILABLE' : 'IN USE',
                            type: station.isAvailable ? StatusType.success : StatusType.neutral,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        station.location,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${station.powerOutput} • ${station.connectorType}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '₹${station.ratePerKwh}/kWh',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMutedLight)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
