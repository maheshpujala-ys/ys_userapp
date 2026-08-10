import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/smart_cards/data/smart_cards_remote_data_source.dart';
import 'package:yellowspotuser/features/admin/smart_cards/screens/add_smart_card_screen.dart';

/// Admin-side list of smart cards / tags. Pulls from GET /api/v1/smart_cards.
class SmartCardsListScreen extends ConsumerWidget {
  const SmartCardsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(smartCardsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Cards')),
      body: cards.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(smartCardsListProvider),
        ),
        data: (rows) {
          if (rows.isEmpty) return const _EmptyState();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(smartCardsListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _SmartCardTile(
                card: rows[i],
                onEdit: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => AddSmartCardScreen(existing: rows[i]),
                  );
                  ref.invalidate(smartCardsListProvider);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal[400],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Smart Card'),
        onPressed: () async {
          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddSmartCardScreen(),
          );
          ref.invalidate(smartCardsListProvider);
        },
      ),
    );
  }
}

class _SmartCardTile extends StatelessWidget {
  const _SmartCardTile({required this.card, required this.onEdit});

  final SmartCardSummary card;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final type = card.cardType;
    final allocation = card.allocationStatus;
    final serial = card.serialNumber;
    final location = card.locationName;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[50],
                child: Icon(Icons.credit_card_outlined,
                    color: Colors.blue[700]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            card.cardNumber.isEmpty
                                ? '(no number)'
                                : card.cardNumber,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _StatusChip(active: card.isActive),
                      ],
                    ),
                    if (serial != null && serial.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text('Serial: $serial',
                          style: TextStyle(
                              color: Colors.grey[700], fontSize: 13)),
                    ],
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (type != null && type.isNotEmpty)
                          _MetaChip(label: type, color: Colors.indigo),
                        if (allocation != null && allocation.isNotEmpty)
                          _MetaChip(
                            label: _allocationLabel(allocation),
                            color: _isAllocated(allocation)
                                ? Colors.orange
                                : Colors.green,
                          ),
                      ],
                    ),
                    if (location != null && location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(location,
                                style: TextStyle(
                                    color: Colors.grey[700], fontSize: 12),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Backend stores allocation as a single char: `Y` = Allocated, `N` = Available.
/// Accepts the legacy long-form strings too, for robustness.
bool _isAllocated(String raw) {
  final v = raw.trim().toUpperCase();
  return v == 'Y' || v == 'ALLOCATED';
}

String _allocationLabel(String raw) {
  return _isAllocated(raw) ? 'Allocated' : 'Available';
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: active ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: TextStyle(
          color: active ? Colors.green[700] : Colors.red[700],
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.credit_card_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text('No smart cards yet',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Tap "Add Smart Card" to issue the first one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
