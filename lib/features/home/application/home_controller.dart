import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/home/data/home_repository.dart';
import 'package:yellowspotuser/features/home/models/activity_item.dart';
import 'package:yellowspotuser/features/home/models/community_notice.dart';
import 'package:yellowspotuser/features/residential/domain/vehicle.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return MockHomeRepository();
});

final todayActivitiesProvider = FutureProvider<List<ActivityItem>>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getTodayActivities();
});

final primaryVehicleProvider = FutureProvider<Vehicle?>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getPrimaryVehicle();
});

final communityHighlightsProvider = FutureProvider<List<CommunityNotice>>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getCommunityHighlights();
});
