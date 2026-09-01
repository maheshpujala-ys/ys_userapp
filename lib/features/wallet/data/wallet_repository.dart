import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/wallet/screens/wallet_screen.dart';

abstract class WalletRepository {
  Future<double> getBalance();
  Future<List<WalletTransaction>> getTransactions();
  Future<WalletTransaction> topUp(double amount);
}

class MockWalletRepository implements WalletRepository {
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

  @override
  Future<double> getBalance() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _balance;
  }

  @override
  Future<List<WalletTransaction>> getTransactions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_transactions);
  }

  @override
  Future<WalletTransaction> topUp(double amount) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _balance += amount;
    final txn = WalletTransaction(
      id: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Wallet Instant Top Up (UPI)',
      category: 'Top Up',
      date: 'Just now',
      amount: amount,
      isDebit: false,
    );
    _transactions.insert(0, txn);
    return txn;
  }
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return MockWalletRepository();
});
