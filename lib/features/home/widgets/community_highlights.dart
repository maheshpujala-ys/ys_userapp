import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/core/widgets/section_header.dart';
import 'package:yellowspotuser/features/home/application/home_controller.dart';
import 'package:yellowspotuser/features/home/models/community_notice.dart';

class CommunityHighlights extends ConsumerWidget {
  final VoidCallback? onExploreCommunity;

  const CommunityHighlights({super.key, this.onExploreCommunity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticesAsync = ref.watch(communityHighlightsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Community Updates',
          actionLabel: 'Notices & Events',
          onAction: onExploreCommunity,
        ),
        noticesAsync.when(
          data: (notices) {
            if (notices.isEmpty) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              height: 155,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: notices.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final notice = notices[index];

                  StatusType type = StatusType.neutral;
                  String tag = 'Notice';
                  if (notice.priority == NoticePriority.urgent) {
                    type = StatusType.warning;
                    tag = 'Urgent Notice';
                  } else if (notice.priority == NoticePriority.event) {
                    type = StatusType.info;
                    tag = 'Upcoming Event';
                  } else if (notice.priority == NoticePriority.emergency) {
                    type = StatusType.error;
                    tag = 'Alert';
                  }

                  return AppCard(
                    width: 290,
                    padding: const EdgeInsets.all(14),
                    onTap: onExploreCommunity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppStatusPill(label: tag, type: type),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    notice.timestamp,
                                    style: const TextStyle(fontSize: 10, color: AppColors.textMutedLight),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notice.title,
                              style: AppTextStyles.titleSmall.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notice.description,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Text(
                          'Posted by ${notice.author}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 140,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
