import 'package:flutter/material.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';

class WalletTransaction {
  final String id;
  final String title;
  final String category; // Parking, EV, Service, Society
  final String date;
  final double amount;
  final bool isDebit;

  const WalletTransaction({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.isDebit,
  });
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _balance = 4850.0;

  final List<WalletTransaction> _transactions = [
    const WalletTransaction(
      id: 'TXN-9021',
      title: 'EV Charging Session (Bay B2)',
      category: 'EV Charging',
      date: 'Today, 11:45 AM',
      amount: 276.0,
      isDebit: true,
    ),
    const WalletTransaction(
      id: 'TXN-9014',
      title: 'Wallet Top Up (UPI Auto-credit)',
      category: 'Top Up',
      date: 'Yesterday, 04:30 PM',
      amount: 2000.0,
      isDebit: false,
    ),
    const WalletTransaction(
      id: 'TXN-8992',
      title: 'Parking Spot B2-45 Reservation',
      category: 'Parking',
      date: '01 Sep 2026',
      amount: 80.0,
      isDebit: true,
    ),
    const WalletTransaction(
      id: 'TXN-8840',
      title: 'Eco Car Wash & Vacuuming',
      category: 'Vehicle Care',
      date: '28 Aug 2026',
      amount: 499.0,
      isDebit: true,
    ),
  ];

  void _showTopUpModal() {
    final amountCtrl = TextEditingController(text: '1000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Text('Top Up YellowSpot Wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Amount (₹)',
                prefixText: '₹ ',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [500, 1000, 2000, 5000].map((amt) {
                return ActionChip(
                  label: Text('₹$amt'),
                  onPressed: () => amountCtrl.text = amt.toString(),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  final added = double.tryParse(amountCtrl.text) ?? 0;
                  if (added <= 0) return;
                  setState(() {
                    _balance += added;
                    _transactions.insert(
                      0,
                      WalletTransaction(
                        id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
                        title: 'Wallet Instant Top Up (UPI)',
                        category: 'Top Up',
                        date: 'Just now',
                        amount: added,
                        isDebit: false,
                      ),
                    );
                  });
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully loaded ₹$added to YellowSpot Wallet!')),
                  );
                },
                icon: const Icon(Icons.add_card_rounded),
                label: const Text('Proceed with UPI / Card'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('YellowSpot Wallet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Available Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(
                    '₹${_balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showTopUpModal,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add Money'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Recent Transactions',
              style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final txn = _transactions[index];

                return AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: txn.isDebit ? AppColors.errorContainer : AppColors.successContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              txn.isDebit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                              color: txn.isDebit ? AppColors.errorDark : AppColors.successDark,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                txn.title,
                                style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                '${txn.category} • ${txn.date}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '${txn.isDebit ? '-' : '+'}₹${txn.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: txn.isDebit ? AppColors.errorDark : AppColors.successDark,
                        ),
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
}
