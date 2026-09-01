import 'package:flutter/material.dart';
import 'package:yellowspotuser/core/theme/app_colors.dart';
import 'package:yellowspotuser/core/theme/app_text_styles.dart';
import 'package:yellowspotuser/core/widgets/app_card.dart';
import 'package:yellowspotuser/core/widgets/app_status_pill.dart';
import 'package:yellowspotuser/core/widgets/empty_state.dart';

enum TicketStatus {
  submitted,
  assigned,
  inProgress,
  resolved,
  closed,
}

class MaintenanceTicket {
  final String id;
  final String title;
  final String category; // Plumbing, Electrical, Lift, Common Area, Cleaning
  final String description;
  final String createdAt;
  final TicketStatus status;

  const MaintenanceTicket({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.createdAt,
    required this.status,
  });
}

class MaintenanceRequestsScreen extends StatefulWidget {
  const MaintenanceRequestsScreen({super.key});

  @override
  State<MaintenanceRequestsScreen> createState() => _MaintenanceRequestsScreenState();
}

class _MaintenanceRequestsScreenState extends State<MaintenanceRequestsScreen> {
  final List<MaintenanceTicket> _tickets = [
    const MaintenanceTicket(
      id: 'TKT-1082',
      title: 'Water Seepage in Master Bathroom',
      category: 'Plumbing',
      description: 'Slow leakage near drainage pipeline pipe in Unit A-1204.',
      createdAt: 'Today, 09:15 AM',
      status: TicketStatus.assigned,
    ),
    const MaintenanceTicket(
      id: 'TKT-1049',
      title: 'Corridor Light Flickering (Tower A Floor 12)',
      category: 'Electrical',
      description: 'Ceiling LED light outside flat 1204 is intermittent.',
      createdAt: '2 days ago',
      status: TicketStatus.resolved,
    ),
  ];

  void _openNewTicketModal() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'Plumbing';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Raise Maintenance Complaint', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Plumbing', 'Electrical', 'Lift / Elevator', 'Common Area', 'Cleaning', 'Carpentry', 'Other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setModalState(() => category = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Issue Summary *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description & Location Details'),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    setState(() {
                      _tickets.insert(
                        0,
                        MaintenanceTicket(
                          id: 'TKT-${1000 + _tickets.length + 1}',
                          title: titleCtrl.text.trim(),
                          category: category,
                          description: descCtrl.text.trim(),
                          createdAt: 'Just now',
                          status: TicketStatus.submitted,
                        ),
                      );
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ticket submitted to Society Facility Team!')),
                    );
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Submit Ticket'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance & Issues'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewTicketModal,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black87,
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: const Text('Raise Ticket', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _tickets.isEmpty
          ? EmptyStateWidget(
              icon: Icons.build_circle_outlined,
              title: 'No Active Complaints',
              description: 'You can report plumbing, electrical, lift, or society issues directly to management.',
              actionLabel: 'Raise Ticket',
              onAction: _openNewTicketModal,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: _tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ticket = _tickets[index];

                StatusType type = StatusType.neutral;
                if (ticket.status == TicketStatus.resolved || ticket.status == TicketStatus.closed) {
                  type = StatusType.success;
                } else if (ticket.status == TicketStatus.assigned || ticket.status == TicketStatus.inProgress) {
                  type = StatusType.info;
                } else if (ticket.status == TicketStatus.submitted) {
                  type = StatusType.warning;
                }

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
                              Text(ticket.id, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primaryDark)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(ticket.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
                              ),
                            ],
                          ),
                          AppStatusPill(label: ticket.status.name.toUpperCase(), type: type),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ticket.title,
                        style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticket.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reported: ${ticket.createdAt}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
