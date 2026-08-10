import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:yellowspotuser/features/corporate/data/corporate_providers.dart';
import 'package:yellowspotuser/features/corporate/domain/corporate_models.dart';

class DatewiseReportScreen extends ConsumerStatefulWidget {
  const DatewiseReportScreen({super.key});

  @override
  ConsumerState<DatewiseReportScreen> createState() =>
      _DatewiseReportScreenState();
}

class _DatewiseReportScreenState extends ConsumerState<DatewiseReportScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  DayWiseQuery? _query;
  bool _downloading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = _startDate;
  }

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  String _fmtDisplay(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}-${two(d.month)}-${d.year}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) _endDate = _startDate;
      } else {
        _endDate = picked;
        if (_endDate.isBefore(_startDate)) _startDate = _endDate;
      }
    });
  }

  void _runQuery() {
    setState(() {
      _query = DayWiseQuery(
        startDate: _fmt(_startDate),
        endDate: _fmt(_endDate),
      );
    });
  }

  Future<void> _downloadExcel() async {
    final query = _query ??
        DayWiseQuery(
          startDate: _fmt(_startDate),
          endDate: _fmt(_endDate),
        );
    setState(() => _downloading = true);
    try {
      final path = await ref
          .read(corporateRepositoryProvider)
          .downloadDayWiseExcel(query);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text(
            'Downloaded to:\n$path',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          action: SnackBarAction(
            label: 'OPEN',
            onPressed: () async {
              final result = await OpenFilex.open(path);
              if (result.type != ResultType.done && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Cannot open file: ${result.message}')),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Datewise Report',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          _FilterCard(
            startLabel: _fmtDisplay(_startDate),
            endLabel: _fmtDisplay(_endDate),
            onPickStart: () => _pickDate(isStart: true),
            onPickEnd: () => _pickDate(isStart: false),
            onSearch: _runQuery,
            onDownload: _downloading ? null : _downloadExcel,
            downloading: _downloading,
          ),
          Expanded(child: _ReportBody(query: _query)),
        ],
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.startLabel,
    required this.endLabel,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onSearch,
    required this.onDownload,
    required this.downloading,
  });

  final String startLabel;
  final String endLabel;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onSearch;
  final VoidCallback? onDownload;
  final bool downloading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _DateField(
                    label: 'From', value: startLabel, onTap: onPickStart),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DateField(
                    label: 'To', value: endLabel, onTap: onPickEnd),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1E63F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: onSearch,
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Search'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF22A06B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: onDownload,
                  icon: downloading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Excel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(value,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                const Icon(Icons.calendar_today_outlined,
                    size: 14, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportBody extends ConsumerWidget {
  const _ReportBody({required this.query});
  final DayWiseQuery? query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (query == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month_outlined,
                size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text('Pick a date range and tap Search',
                style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    final async = ref.watch(dayWiseReportProvider(query!));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(err.toString(), textAlign: TextAlign.center),
        ),
      ),
      data: (report) => report.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text('No report data',
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            )
          : _ReportList(report: report),
    );
  }
}

class _Totals {
  int allotted = 0,
      txn = 0,
      entry = 0,
      entryVac = 0,
      entryRestricted = 0,
      exit = 0,
      notExited = 0,
      parkingFull = 0,
      autoClose = 0,
      vacant = 0;
  void add(DayWiseRow r) {
    allotted += r.allottedSlots;
    txn += r.totalTransaction;
    entry += r.entryGranted;
    entryVac += r.entryGrantedForVacated;
    entryRestricted += r.entryRestrictedParkingFull;
    exit += r.exitRegistered;
    notExited += r.notExited;
    parkingFull += r.parkingFull;
    autoClose += r.autoClose;
    vacant += r.vacant;
  }
}

class _ReportList extends StatelessWidget {
  const _ReportList({required this.report});
  final DayWiseReport report;

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    String two(int n) => n.toString().padLeft(2, '0');
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${two(d.day)} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final grand = _Totals();
    for (final day in report.days) {
      for (final r in day.rows) {
        grand.add(r);
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      children: [
        for (final day in report.days)
          if (day.rows.isNotEmpty) _DaySection(
              date: _fmtDate(day.reportDate),
              rows: day.rows),
        const SizedBox(height: 4),
        _GrandTotalCard(totals: grand),
      ],
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({required this.date, required this.rows});
  final String date;
  final List<DayWiseRow> rows;

  @override
  Widget build(BuildContext context) {
    final dayTotal = _Totals();
    for (final r in rows) {
      dayTotal.add(r);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
            child: Row(
              children: [
                Icon(Icons.event, size: 14, color: Colors.blue.shade700),
                const SizedBox(width: 6),
                Text(date,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _CompanyCard(row: r),
            ),
          _DayTotalCard(totals: dayTotal),
        ],
      ),
    );
  }
}

class _CompanyCard extends StatefulWidget {
  const _CompanyCard({required this.row});
  final DayWiseRow row;

  @override
  State<_CompanyCard> createState() => _CompanyCardState();
}

class _CompanyCardState extends State<_CompanyCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.row;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.indigo.shade50,
                    child: Text(
                      r.companyName.isEmpty
                          ? '?'
                          : r.companyName[0].toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.companyName.isEmpty ? '—' : r.companyName,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(
                          '${r.allottedSlots} slots · ${r.totalTransaction} transactions',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(
              children: [
                Expanded(
                    child: _MiniStat(
                        label: 'Entry',
                        value: r.entryGranted,
                        color: Colors.green.shade700)),
                Expanded(
                    child: _MiniStat(
                        label: 'Exit',
                        value: r.exitRegistered,
                        color: Colors.orange.shade700)),
                Expanded(
                    child: _MiniStat(
                        label: 'Vacant',
                        value: r.vacant,
                        color: Colors.blue.shade700)),
              ],
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  _DetailRow(
                      label: 'Entry granted (vacated)',
                      value: r.entryGrantedForVacated),
                  _DetailRow(
                      label: 'Entry restricted (full)',
                      value: r.entryRestrictedParkingFull),
                  _DetailRow(label: 'Not exited', value: r.notExited),
                  _DetailRow(label: 'Parking full', value: r.parkingFull),
                  _DetailRow(label: 'Auto close', value: r.autoClose),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade700)),
          Text('$value',
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DayTotalCard extends StatelessWidget {
  const _DayTotalCard({required this.totals});
  final _Totals totals;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text('Day Total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          _TotalChip(label: 'In', value: totals.entry, color: Colors.green),
          const SizedBox(width: 6),
          _TotalChip(label: 'Out', value: totals.exit, color: Colors.orange),
          const SizedBox(width: 6),
          _TotalChip(label: 'Vac', value: totals.vacant, color: Colors.blue),
        ],
      ),
    );
  }
}

class _GrandTotalCard extends StatelessWidget {
  const _GrandTotalCard({required this.totals});
  final _Totals totals;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize_outlined,
                  size: 16, color: Colors.indigo.shade700),
              const SizedBox(width: 6),
              Text('Grand Total',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.indigo.shade900)),
            ],
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.8,
            children: [
              _GrandCell(label: 'Allotted', value: totals.allotted),
              _GrandCell(label: 'Transactions', value: totals.txn),
              _GrandCell(label: 'Entry', value: totals.entry),
              _GrandCell(label: 'Entry (vac)', value: totals.entryVac),
              _GrandCell(label: 'Restricted', value: totals.entryRestricted),
              _GrandCell(label: 'Exit', value: totals.exit),
              _GrandCell(label: 'Not exited', value: totals.notExited),
              _GrandCell(label: 'Parking full', value: totals.parkingFull),
              _GrandCell(label: 'Auto close', value: totals.autoClose),
            ],
          ),
        ],
      ),
    );
  }
}

class _GrandCell extends StatelessWidget {
  const _GrandCell({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$value',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          Text(label,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _TotalChip extends StatelessWidget {
  const _TotalChip({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final int value;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$label $value',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color.shade800)),
    );
  }
}
