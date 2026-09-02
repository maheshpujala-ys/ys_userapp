import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/core/widgets/section_header.dart';
import 'package:yellowspotuser/features/emergency/screens/emergency_sos_sheet.dart';
import 'package:yellowspotuser/features/services/application/services_controller.dart';

class QuickServicesScreen extends ConsumerWidget {
  const QuickServicesScreen({super.key});

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesState = ref.watch(ServicesController.provider);
    final size = MediaQuery.of(context).size;
    final gridAspectRatio = size.width < 360 ? 0.7 : 0.85;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Services & Utilities'),
      ),
      body: servicesState.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeaturedServices(context, data['featuredServices'] ?? []),
              const SizedBox(height: 20),
              _buildOtherServices(context, gridAspectRatio),
              const SizedBox(height: 20),
              _buildRecentTransactions(context, data['recentTransactions'] ?? []),
              const SizedBox(height: 20),
              _buildEmergencyServices(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _buildFeaturedServices(BuildContext context, List<Map<String, dynamic>> services) {
    return Row(
      children: services.map((service) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: AppCard(
              padding: const EdgeInsets.all(14),
              onTap: () => _showSnackbar(context, '${service['title']} Selected'),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      service['title'] == 'EV Charging' ? Icons.ev_station_rounded : Icons.receipt_long_rounded,
                      size: 24,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    service['title'],
                    style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 13),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service['subtitle'],
                    style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 11),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOtherServices(BuildContext context, double aspectRatio) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        title: Text(
          'Society Utilities & Bills',
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
              childAspectRatio: aspectRatio,
              children: [
                _buildOtherServiceIcon(Icons.phone_android_rounded, 'Mobile Recharge', Colors.blue),
                _buildOtherServiceIcon(Icons.tv_rounded, 'DTH Cable', Colors.purple),
                _buildOtherServiceIcon(Icons.lightbulb_outline_rounded, 'Electricity', Colors.amber),
                _buildOtherServiceIcon(Icons.water_drop_outlined, 'Water Meter', Colors.cyan),
                _buildOtherServiceIcon(Icons.local_fire_department_outlined, 'Piped Gas', Colors.deepOrange),
                _buildOtherServiceIcon(Icons.credit_card_rounded, 'FastTag Topup', Colors.indigo),
                _buildOtherServiceIcon(Icons.shield_outlined, 'Society Dues', Colors.teal),
                _buildOtherServiceIcon(Icons.wifi_rounded, 'Broadband', Colors.green),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOtherServiceIcon(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 6),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, height: 1.1, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context, List<Map<String, dynamic>> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Recent Activity'),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transactions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            final bool isSuccess = transaction['success'] == true;

            return AppCard(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSuccess ? AppColors.successContainer : AppColors.errorContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSuccess ? Icons.check_rounded : Icons.close_rounded,
                          size: 16,
                          color: isSuccess ? AppColors.successDark : AppColors.errorDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(transaction['title'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(transaction['subtitle'], style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(transaction['amount'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 2),
                      AppStatusPill(
                        label: isSuccess ? 'Success' : 'Failed',
                        type: isSuccess ? StatusType.success : StatusType.error,
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmergencyServices(BuildContext context) {
    return AppCard(
      color: AppColors.errorContainer.withValues(alpha: 0.35),
      borderColor: AppColors.error.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🚨 Security & Emergency Contacts',
                style: AppTextStyles.titleSmall.copyWith(color: AppColors.errorDark, fontWeight: FontWeight.w800),
              ),
              IconButton(
                onPressed: () => EmergencySosSheet.show(context),
                icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.errorDark),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEmergencyChip('Main Security', 'Ext. 100', Icons.local_police_outlined),
              _buildEmergencyChip('Medical Desk', 'Ext. 108', Icons.monitor_heart_outlined),
              _buildEmergencyChip('Lift Alarm', 'Ext. 102', Icons.elevator_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyChip(String title, String phone, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.errorDark, size: 20),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
        Text(phone, style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
      ],
    );
  }
}
