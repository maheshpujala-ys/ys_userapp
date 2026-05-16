import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/smart_cards/data/smart_cards_remote_data_source.dart';

/// One-shot "Add / Edit Smart Card" submission state.
class AddSmartCardController extends StateNotifier<AsyncValue<void>> {
  AddSmartCardController(this._dataSource)
      : super(const AsyncValue.data(null));

  final SmartCardsRemoteDataSource _dataSource;

  static final provider = StateNotifierProvider.autoDispose<
      AddSmartCardController, AsyncValue<void>>((ref) {
    return AddSmartCardController(
        ref.watch(smartCardsRemoteDataSourceProvider));
  });

  Future<bool> submit(SmartCardCreateRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _dataSource.createSmartCard(request));
    return !state.hasError;
  }

  Future<bool> update(int smartCardId, SmartCardCreateRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _dataSource.updateSmartCard(smartCardId, request));
    return !state.hasError;
  }
}
