import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/features/admin/data/admin_operations_repository.dart';
import 'package:yellowspotuser/features/admin/domain/admin_models.dart';

final adminAuditLogsProvider = FutureProvider<List<AdminAuditLogItem>>((ref) async {
  final repo = ref.watch(adminOperationsRepositoryProvider);
  return repo.getAuditLogs();
});

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditLogsAsync = ref.watch(adminAuditLogsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return auditLogsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return const Center(child: Text('No audit logs recorded yet.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: logs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final log = logs[index];
            return AppCard(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.security_rounded, size: 16, color: AppColors.primaryDark),
                          const SizedBox(width: 6),
                          Text(
                            log.operatorName,
                            style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      AppStatusPill(
                        label: log.result,
                        type: log.result == 'SUCCESS'
                            ? StatusType.success
                            : (log.result == 'OVERRIDE' ? StatusType.warning : StatusType.error),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Role: ${log.operatorRole.name}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    log.action,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Target: ${log.target}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Audit ID: ${log.id}',
                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.textMutedLight),
                      ),
                      Text(
                        '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight, fontWeight: FontWeight.bold),
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
      error: (err, _) => Center(child: Text('Error loading audit log: $err')),
    );
  }
}
