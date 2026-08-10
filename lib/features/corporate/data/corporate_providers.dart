import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/corporate/data/corporate_repository.dart';
import 'package:yellowspotuser/features/corporate/domain/corporate_models.dart';

final corporateRepositoryProvider = Provider<CorporateRepository>(
  (ref) => CorporateRepository(ref.watch(dioProvider)),
);

final corporateDashboardProvider =
    FutureProvider.autoDispose<CorporateDashboardData>((ref) {
  return ref.watch(corporateRepositoryProvider).getDashboardData();
});

final availabilityListProvider =
    FutureProvider.autoDispose<List<AvailabilityRow>>((ref) {
  return ref.watch(corporateRepositoryProvider).getAvailabilityList();
});

final dayWiseReportProvider = FutureProvider.autoDispose
    .family<DayWiseReport, DayWiseQuery>((ref, query) {
  return ref.watch(corporateRepositoryProvider).getDayWiseReport(query);
});
