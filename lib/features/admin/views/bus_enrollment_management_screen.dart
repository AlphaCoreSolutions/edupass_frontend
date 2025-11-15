// lib/features/admin/views/bus_enrollment_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edupass/core/state/app_state.dart';
import 'package:edupass/core/models/bus_enrollment.dart';
import 'package:edupass/l10n/app_localizations.dart';

class BusEnrollmentManagementScreen extends StatefulWidget {
  const BusEnrollmentManagementScreen({super.key});

  @override
  State<BusEnrollmentManagementScreen> createState() =>
      _BusEnrollmentManagementScreenState();
}

class _BusEnrollmentManagementScreenState
    extends State<BusEnrollmentManagementScreen> {
  // Current status filter
  final ValueNotifier<BusJoinStatus?> _filter = ValueNotifier<BusJoinStatus?>(
    BusJoinStatus.pending,
  );
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _filter.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tr = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr.busRequestsTitle), // "طلبات الانضمام للحافلات"
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: tr.refresh, // add to ARB if missing
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await app.loadBusEnrollments(); // local for now
              },
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (ctx, c) {
            final isWide = c.maxWidth >= 900;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _FiltersCard(
                      filter: _filter,
                      search: _search,
                      isWide: isWide,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: Divider(height: 1)),
                SliverFillRemaining(
                  child: _ListSection(filter: _filter, search: _search),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  final ValueNotifier<BusJoinStatus?> filter;
  final TextEditingController search;
  final bool isWide;

  const _FiltersCard({
    required this.filter,
    required this.search,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr.filtersTitle, // "الفلاتر"
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<BusJoinStatus?>(
              valueListenable: filter,
              builder: (_, current, __) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _statusChip(
                      context,
                      label: tr.busStatusPending, // "قيد المراجعة"
                      status: BusJoinStatus.pending,
                      selected: current == BusJoinStatus.pending,
                      icon: Icons.rule_folder,
                    ),
                    _statusChip(
                      context,
                      label: tr.busStatusApprovedAwaitingPayment,
                      // "موافق عليه بانتظار الدفع"
                      status: BusJoinStatus.approvedAwaitingPayment,
                      selected:
                          current == BusJoinStatus.approvedAwaitingPayment,
                      icon: Icons.payments_outlined,
                    ),
                    _statusChip(
                      context,
                      label: tr.busStatusPaid, // "مفعل (مدفوع)"
                      status: BusJoinStatus.paid,
                      selected: current == BusJoinStatus.paid,
                      icon: Icons.verified_outlined,
                    ),
                    _statusChip(
                      context,
                      label: tr.busStatusRejected, // "مرفوض"
                      status: BusJoinStatus.rejected,
                      selected: current == BusJoinStatus.rejected,
                      icon: Icons.cancel_outlined,
                    ),
                    _statusChip(
                      context,
                      label: tr.busStatusCancelled, // "ملغي"
                      status: BusJoinStatus.cancelled,
                      selected: current == BusJoinStatus.cancelled,
                      icon: Icons.undo_outlined,
                    ),
                    ChoiceChip(
                      label: Text(tr.all), // "الكل"
                      avatar: const Icon(Icons.all_inbox, size: 18),
                      selected: current == null,
                      onSelected: (v) => filter.value = v ? null : filter.value,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText:
                          tr.searchStudentOrBus, // "بحث باسم الطالب / الحافلة"
                      border: const OutlineInputBorder(),
                      isDense: true,
                      filled: true,
                    ),
                    onChanged: (_) {
                      // list listens via setState in section
                      // but we can force rebuild using Inherited (handled below)
                      // do nothing here
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: tr.clear, // "مسح"
                  onPressed: () {
                    search.clear();
                    // No setState here; the list uses ValueListenableBuilder for filter
                    // but search is read in _ListSection via setState wrapper
                    // So we use a small trick:
                    FocusScope.of(context).unfocus();
                    (context as Element).markNeedsBuild();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ChoiceChip _statusChip(
    BuildContext context, {
    required String label,
    required BusJoinStatus status,
    required bool selected,
    required IconData icon,
  }) {
    return ChoiceChip(
      selected: selected,
      onSelected: (v) {
        final notifier = filter;
        notifier.value = v ? status : null;
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}

class _ListSection extends StatefulWidget {
  final ValueNotifier<BusJoinStatus?> filter;
  final TextEditingController search;
  const _ListSection({required this.filter, required this.search});

  @override
  State<_ListSection> createState() => _ListSectionState();
}

class _ListSectionState extends State<_ListSection> {
  @override
  void initState() {
    super.initState();
    widget.filter.addListener(_onFilter);
    widget.search.addListener(_onSearch);
  }

  @override
  void dispose() {
    widget.filter.removeListener(_onFilter);
    widget.search.removeListener(_onSearch);
    super.dispose();
  }

  void _onFilter() => setState(() {});
  void _onSearch() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tr = AppLocalizations.of(context)!;

    // Build view-models
    final items = app.busEnrollments.map((e) {
      final bus = app.buses.firstWhere((b) => b.id == e.busId);
      final student = app.students.firstWhere((s) => s.id == e.studentId);
      final requesterName = app.userNameById(e.requestedById) ?? '-';
      return _RowVM(
        enrollment: e,
        busName: bus.name,
        studentName: student.name,
        parentName: requesterName,
      );
    }).toList();

    // Filter by status
    final filter = widget.filter.value;
    var filtered = filter == null
        ? items
        : items.where((x) => x.enrollment.status == filter).toList();

    // Search by student/bus name
    final q = widget.search.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered.where((x) {
        return x.studentName.toLowerCase().contains(q) ||
            x.busName.toLowerCase().contains(q);
      }).toList();
    }

    if (filtered.isEmpty) {
      return Center(child: Text(tr.noResults)); // "لا توجد نتائج"
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final row = filtered[i];
        final e = row.enrollment;
        return _EnrollmentCard(vm: row, enrollment: e);
      },
    );
  }
}

class _EnrollmentCard extends StatelessWidget {
  final _RowVM vm;
  final BusEnrollmentApi enrollment;
  const _EnrollmentCard({required this.vm, required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.directions_bus_outlined)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vm.busName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('${tr.studentName}: ${vm.studentName}'),
                      Text('${tr.parent}: ${vm.parentName}'),
                    ],
                  ),
                ),
                _StatusPill(status: enrollment.status),
              ],
            ),
            const SizedBox(height: 10),
            // Actions
            _ActionsRow(enrollment: enrollment),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${tr.request} #${enrollment.id} • ${_formatDate(enrollment.requestedAt)}'
                '${enrollment.paymentRef != null ? ' • ${tr.paymentRef}: ${enrollment.paymentRef}' : ''}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$y/$mo/$d $h:$m';
  }
}

class _ActionsRow extends StatelessWidget {
  final BusEnrollmentApi enrollment;
  const _ActionsRow({required this.enrollment});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    if (enrollment.status == BusJoinStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: Text(tr.approve), // "موافقة"
              onPressed: () async {
                await context.read<AppState>().supervisorApproveEnrollment(
                  enrollment.id,
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.cancel_outlined),
              label: Text(tr.reject), // "رفض"
              onPressed: () async {
                await context.read<AppState>().rejectEnrollment(enrollment.id);
              },
            ),
          ),
        ],
      );
    } else if (enrollment.status == BusJoinStatus.approvedAwaitingPayment) {
      return Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              icon: const Icon(Icons.payments_outlined),
              label: Text(tr.activatePaidManually), // "تفعيل يدوي (مدفوع)"
              onPressed: () async {
                final ref = await _askPaymentRef(context);
                if (ref == null) return;
                await context.read<AppState>().completePaymentAndAssign(
                  enrollmentId: enrollment.id,
                  paymentRef: ref,
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.undo_outlined),
              label: Text(tr.rejectAfterApproval), // "رفض بعد الموافقة"
              onPressed: () async {
                await context.read<AppState>().rejectEnrollment(enrollment.id);
              },
            ),
          ),
        ],
      );
    } else {
      return OutlinedButton.icon(
        icon: const Icon(Icons.info_outline),
        label: Text(tr.noAction), // "لا يوجد إجراء"
        onPressed: null,
      );
    }
  }

  Future<String?> _askPaymentRef(BuildContext context) async {
    final tr = AppLocalizations.of(context)!;
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr.paymentRef), // "مرجع الدفع"
        content: TextField(
          controller: c,
          decoration: InputDecoration(
            hintText: tr.paymentRefHint /* "مثال: TXN-12345" */,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.cancel), // "إلغاء"
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              c.text.trim().isEmpty ? null : c.text.trim(),
            ),
            child: Text(tr.save), // "حفظ"
          ),
        ],
      ),
    );
  }
}

class _RowVM {
  final BusEnrollmentApi enrollment;
  final String busName;
  final String studentName;
  final String parentName;
  _RowVM({
    required this.enrollment,
    required this.busName,
    required this.studentName,
    required this.parentName,
  });
}

class _StatusPill extends StatelessWidget {
  final BusJoinStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    final (color, label) = switch (status) {
      BusJoinStatus.pending => (Colors.orange, tr.busStatusPending),
      BusJoinStatus.approvedAwaitingPayment => (
        Colors.blue,
        tr.busStatusApprovedAwaitingPayment,
      ),
      BusJoinStatus.paid => (Colors.green, tr.busStatusPaid),
      BusJoinStatus.rejected => (Colors.red, tr.busStatusRejected),
      BusJoinStatus.cancelled => (Colors.grey, tr.busStatusCancelled),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
