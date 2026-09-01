import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/features/admin/data/admin_operations_repository.dart';
import 'package:yellowspotuser/features/admin/domain/admin_models.dart';
import 'package:yellowspotuser/features/admin/smart_cards/screens/add_smart_card_screen.dart';

final adminSmartCardsProvider = FutureProvider<List<AdminSmartCardItem>>((ref) async {
  final repo = ref.watch(adminOperationsRepositoryProvider);
  return repo.getSmartCards();
});

class SmartCardsScreen extends ConsumerWidget {
  const SmartCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(adminSmartCardsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Smart Cards & RFID Access'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card_rounded),
            tooltip: 'Issue Card',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const AddSmartCardScreen(),
            ),
          ),
        ],
      ),
      body: cardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(child: Text('No smart cards issued yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final card = cards[index];
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
                            const Icon(Icons.credit_card_rounded, color: AppColors.primaryDark, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              card.cardUid,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        AppStatusPill(
                          label: card.status.name.toUpperCase(),
                          type: card.status == SmartCardStatus.active
                              ? StatusType.success
                              : StatusType.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Assigned to: ${card.residentName} (${card.unit})',
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: card.permissions.map((p) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(p, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Last Gate: ${card.lastUsedGate}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                ref.read(adminOperationsRepositoryProvider).updateSmartCardStatus(
                                      card.id,
                                      card.status == SmartCardStatus.active
                                          ? SmartCardStatus.suspended
                                          : SmartCardStatus.active,
                                    );
                                ref.invalidate(adminSmartCardsProvider);
                              },
                              child: Text(
                                card.status == SmartCardStatus.active ? 'Suspend' : 'Activate',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
