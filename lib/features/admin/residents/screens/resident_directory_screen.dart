import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/features/admin/data/admin_operations_repository.dart';
import 'package:yellowspotuser/features/admin/domain/admin_models.dart';
import 'package:yellowspotuser/features/admin/residents/screens/add_resident_screen.dart';

final adminResidentsProvider = FutureProvider<List<AdminResidentItem>>((ref) async {
  final repo = ref.watch(adminOperationsRepositoryProvider);
  return repo.getResidents();
});

class ResidentDirectoryScreen extends ConsumerStatefulWidget {
  const ResidentDirectoryScreen({super.key});

  @override
  ConsumerState<ResidentDirectoryScreen> createState() => _ResidentDirectoryScreenState();
}

class _ResidentDirectoryScreenState extends ConsumerState<ResidentDirectoryScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'Owners', 'Tenants'

  @override
  Widget build(BuildContext context) {
    final residentsAsync = ref.watch(adminResidentsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Resident Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Add Resident',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const AddResidentScreen(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search by resident, unit, or phone...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: ['All', 'Owners', 'Tenants'].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        selectedColor: AppColors.primaryContainer,
                        checkmarkColor: Colors.black,
                        onSelected: (_) => setState(() => _selectedFilter = filter),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Resident List
          Expanded(
            child: residentsAsync.when(
              data: (residents) {
                final filtered = residents.where((r) {
                  final matchesSearch = r.name.toLowerCase().contains(_searchQuery) ||
                      r.unit.toLowerCase().contains(_searchQuery) ||
                      r.phone.contains(_searchQuery);

                  if (!matchesSearch) return false;
                  if (_selectedFilter == 'Owners') return r.isOwner;
                  if (_selectedFilter == 'Tenants') return !r.isOwner;
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No residents match the selected criteria.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.name,
                                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                              ),
                              AppStatusPill(
                                label: item.isOwner ? 'Owner' : 'Tenant',
                                type: item.isOwner ? StatusType.success : StatusType.info,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${item.tower} • ${item.unit}',
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMutedLight),
                                  const SizedBox(width: 4),
                                  Text(item.phone, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.directions_car_outlined, size: 14, color: AppColors.textMutedLight),
                                  const SizedBox(width: 4),
                                  Text('${item.vehicleCount} Vehicles', style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.credit_card_outlined, size: 14, color: AppColors.textMutedLight),
                                  const SizedBox(width: 4),
                                  Text('${item.smartCardCount} Cards', style: const TextStyle(fontSize: 12)),
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
              error: (err, _) => Center(child: Text('Error loading directory: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
