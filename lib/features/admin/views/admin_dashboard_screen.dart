// lib/features/admin/views/admin_dashboard_screen.dart
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:edupass/core/models/pickupRequest.dart';
import 'package:edupass/core/models/student.dart';
import 'package:edupass/core/models/bus.dart';
import 'package:edupass/core/models/bus_enrollment.dart';
import 'package:edupass/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/state/app_state.dart';
import '../../../core/models/domain_ids.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Requests filters
  String? selectedStudentName;
  int? selectedStatusId;

  // Bus analytics filters
  String? selectedNeighborhood;
  int? selectedSupervisorUserId;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tr = AppLocalizations.of(context)!;

    // Base lists
    final students = app.students;
    final requests = app.requests;
    final buses = app.buses;
    final enrollments = app.busEnrollments;

    // ===== Requests section (kept 1st) =====
    final filteredRequests = requests.where((r) {
      final s = _findStudentOrNull(students, r.studentId);
      final okStudent =
          selectedStudentName == null || s?.name == selectedStudentName;
      final okStatus =
          selectedStatusId == null || r.statusId == selectedStatusId;
      return okStudent && okStatus;
    }).toList();

    final pendingId = app.findDetailIdByEnglish(
      DomainIds.requestStatus,
      'Pending',
    );
    final pendingCount = filteredRequests
        .where((r) => r.statusId == pendingId)
        .length;

    // ===== Bus analytics (with filters) =====
    final neighborhoods =
        (buses
            .map((b) => b.neighborhood)
            .where((x) => x.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())));
    final supervisors = buses.map((b) => b.supervisorUserId).toSet().toList()
      ..sort();

    bool busPasses(BusApi b) {
      final hood =
          selectedNeighborhood == null ||
          b.neighborhood == selectedNeighborhood;
      final sup =
          selectedSupervisorUserId == null ||
          b.supervisorUserId == selectedSupervisorUserId;
      return hood && sup;
    }

    final filteredBuses = buses.where(busPasses).toList();

    final perBusPaid = <int, int>{};
    final perBusAwait = <int, int>{};
    for (final b in filteredBuses) {
      perBusPaid[b.id] = 0;
      perBusAwait[b.id] = 0;
    }
    for (final e in enrollments) {
      final b = buses.firstWhere(
        (x) => x.id == e.busId,
        orElse: () => _nullBus,
      );
      if (b.id == -1 || !busPasses(b)) continue;
      if (e.status == BusJoinStatus.paid) {
        perBusPaid[b.id] = (perBusPaid[b.id] ?? 0) + 1;
      } else if (e.status == BusJoinStatus.approvedAwaitingPayment) {
        perBusAwait[b.id] = (perBusAwait[b.id] ?? 0) + 1;
      }
    }

    final busLabels = filteredBuses.map((b) => b.name).toList();
    final paidValues = filteredBuses
        .map((b) => (perBusPaid[b.id] ?? 0).toDouble())
        .toList();
    final awaitValues = filteredBuses
        .map((b) => (perBusAwait[b.id] ?? 0).toDouble())
        .toList();

    int countEnroll(BusJoinStatus s) => enrollments.where((e) {
      final b = buses.firstWhere(
        (x) => x.id == e.busId,
        orElse: () => _nullBus,
      );
      return b.id != -1 && busPasses(b) && e.status == s;
    }).length;

    final busAwaitTotal = countEnroll(BusJoinStatus.approvedAwaitingPayment);
    final busPaidTotal = countEnroll(BusJoinStatus.paid);

    final monthlyRevenue = enrollments
        .where((e) => e.status == BusJoinStatus.paid)
        .where(
          (e) => busPasses(
            buses.firstWhere((b) => b.id == e.busId, orElse: () => _nullBus),
          ),
        )
        .map(
          (e) => buses
              .firstWhere((b) => b.id == e.busId, orElse: () => _nullBus)
              .monthlyFee,
        )
        .fold<double>(0, (a, v) => a + v);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
          title: Text(tr.adminDashboard),
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: tr.exportData,
              onPressed: () =>
                  _exportCsvRequests(context, filteredRequests, app),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (ctx, c) {
            final isTablet = c.maxWidth >= 720;
            final isDesktop = c.maxWidth >= 1100;
            final kpiColumns = isDesktop ? 4 : (isTablet ? 3 : 2);
            final gridItemWidth =
                (c.maxWidth - (12 * (kpiColumns - 1))) / kpiColumns;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Shortcuts row
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _ShortcutCard(
                        icon: Icons.directions_bus_filled_outlined,
                        title: tr.adminShortcutsBusesTitle,
                        subtitle: tr.adminShortcutsBusesSubtitle,
                        onTap: () => context.push('/buses'),
                        width: isTablet ? gridItemWidth : c.maxWidth,
                      ),
                      _ShortcutCard(
                        icon: Icons.assignment_turned_in_outlined,
                        title: tr.adminShortcutsBusRequestsTitle,
                        subtitle: tr.adminShortcutsBusRequestsSubtitle,
                        onTap: () => context.push('/bus-requests'),
                        width: isTablet ? gridItemWidth : c.maxWidth,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ===== Important Section: Requests analytics =====
                  _SectionHeader(title: tr.filtersTitle),
                  _RequestsFilters(
                    names: students.map((s) => s.name).toSet().toList()..sort(),
                    statuses: app.detailsOfDomain(DomainIds.requestStatus),
                    selectedStudentName: selectedStudentName,
                    selectedStatusId: selectedStatusId,
                    onStudent: (v) => setState(() => selectedStudentName = v),
                    onStatus: (v) => setState(() => selectedStatusId = v),
                    onReset: () => setState(() {
                      selectedStudentName = null;
                      selectedStatusId = null;
                    }),
                  ),
                  const SizedBox(height: 12),
                  _KpiGrid(
                    columns: kpiColumns,
                    children: [
                      _KpiCard(
                        label: tr.totalStudents,
                        value: '${students.length}',
                        icon: Icons.people_alt,
                      ),
                      _KpiCard(
                        label: tr.totalRequests,
                        value: '${filteredRequests.length}',
                        icon: Icons.assignment,
                      ),
                      _KpiCard(
                        label: tr.pendingRequests,
                        value: '$pendingCount',
                        icon: Icons.pending_actions,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ChartCard(
                    title: tr.statsChart,
                    height: 240,
                    child: _RequestPieChart(requests: filteredRequests),
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(title: tr.requestLog),
                  const SizedBox(height: 8),
                  if (filteredRequests.isEmpty)
                    Center(child: Text(tr.noRequestsYet))
                  else
                    _ModernList(
                      items: filteredRequests.reversed.map((r) {
                        final s = _findStudentOrNull(students, r.studentId);
                        final type = app.detailName(r.requestTypeId);
                        final status = app.detailName(r.statusId);
                        final extra = r.exitTime != null
                            ? ' • ${tr.exit}: ${_fmtTime(r.exitTime!)}'
                            : '';
                        return _ModernListItem(
                          leadingIcon: Icons.person,
                          title: s?.name ?? '-',
                          subtitle: '$type • $status$extra',
                        );
                      }).toList(),
                    ),

                  // ===== Bus analytics section (below) =====
                  const SizedBox(height: 28),
                  _SectionHeader(title: tr.busesStatsTitle),
                  const SizedBox(height: 6),
                  _BusFilters(
                    neighborhoods: neighborhoods,
                    supervisors: supervisors,
                    selectedNeighborhood: selectedNeighborhood,
                    selectedSupervisorUserId: selectedSupervisorUserId,
                    onNeighborhood: (v) =>
                        setState(() => selectedNeighborhood = v),
                    onSupervisor: (v) =>
                        setState(() => selectedSupervisorUserId = v),
                    onExportCsv: () => _exportCsvBusEnrollments(
                      context: context,
                      appState: app,
                      neighborhood: selectedNeighborhood,
                      supervisorUserId: selectedSupervisorUserId,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _KpiGrid(
                    columns: kpiColumns,
                    children: [
                      _KpiCard(
                        label: tr.busesCountFiltered,
                        value: '${filteredBuses.length}',
                        icon: Icons.directions_bus,
                      ),
                      _KpiCard(
                        label: tr.awaitingPaymentCount,
                        value: '$busAwaitTotal',
                        icon: Icons.payments_outlined,
                      ),
                      _KpiCard(
                        label: tr.paidActiveCount,
                        value: '$busPaidTotal',
                        icon: Icons.verified_outlined,
                      ),
                      _KpiCard(
                        label: tr.estimatedMonthlyRevenue,
                        value:
                            '${monthlyRevenue.toStringAsFixed(0)} ${tr.currencySarShort}',
                        icon: Icons.attach_money,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (busLabels.isEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(child: Text(tr.noBusChartData)),
                      ),
                    ),
                  ] else ...[
                    _ChartCard(
                      title: tr.activeSubscribersPerBus,
                      height: 280,
                      child: _BusBarChart(
                        labels: busLabels,
                        values: paidValues,
                        tooltipPrefix: tr.activeShort,
                        onBarTap: (index) {
                          if (index == null ||
                              index < 0 ||
                              index >= filteredBuses.length)
                            return;
                          _openBusDrillDown(context, filteredBuses[index], app);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ChartCard(
                      title: tr.awaitingPerBus,
                      height: 280,
                      child: _BusBarChart(
                        labels: busLabels,
                        values: awaitValues,
                        tooltipPrefix: tr.awaitingShort,
                        onBarTap: (index) {
                          if (index == null ||
                              index < 0 ||
                              index >= filteredBuses.length)
                            return;
                          _openBusDrillDown(context, filteredBuses[index], app);
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  if (filteredBuses.isNotEmpty)
                    _SectionHeader(title: tr.quickDetails),
                  if (filteredBuses.isNotEmpty)
                    _ModernGrid(
                      columns: isDesktop ? 3 : (isTablet ? 2 : 1),
                      children: filteredBuses.map((b) {
                        final paid = perBusPaid[b.id] ?? 0;
                        final awaiting = perBusAwait[b.id] ?? 0;
                        return _BusMiniCard(
                          bus: b,
                          paid: paid,
                          awaiting: awaiting,
                          onTap: () => _openBusDrillDown(context, b, app),
                          tr: tr,
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openBusDrillDown(BuildContext context, BusApi bus, AppState app) {
    final tr = AppLocalizations.of(context)!;

    final paid = app.busEnrollments
        .where((e) => e.busId == bus.id && e.status == BusJoinStatus.paid)
        .toList();
    final awaiting = app.busEnrollments
        .where(
          (e) =>
              e.busId == bus.id &&
              e.status == BusJoinStatus.approvedAwaitingPayment,
        )
        .toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (ctx, scroll) {
                return SingleChildScrollView(
                  controller: scroll,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(child: Icon(Icons.directions_bus)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bus.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${tr.neighborhood}: ${bus.neighborhood} • ${tr.supervisorId}: #${bus.supervisorUserId}',
                                ),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () => _exportCsvBusEnrollments(
                              context: context,
                              appState: app,
                              neighborhood: bus.neighborhood,
                              supervisorUserId: bus.supervisorUserId,
                            ),
                            icon: const Icon(Icons.download),
                            label: Text(tr.downloadCsv),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoPill(
                            icon: Icons.calendar_today_outlined,
                            text: bus.weekdays.join('، '),
                          ),
                          _InfoPill(
                            icon: Icons.school_outlined,
                            text: '${tr.busGoTime} ${bus.dropoffTime}',
                          ),
                          _InfoPill(
                            icon: Icons.home_outlined,
                            text: '${tr.busReturnTime} ${bus.pickupTime}',
                          ),
                          _InfoPill(
                            icon: Icons.payments_outlined,
                            text:
                                '${bus.monthlyFee.toStringAsFixed(0)} ${tr.monthlyFeeShort}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SubHeader('${tr.activeSubscribers} (${paid.length})'),
                      const SizedBox(height: 6),
                      if (paid.isEmpty)
                        Text(tr.noItems)
                      else
                        _ModernList(
                          items: paid.map((e) {
                            final s = app.students.firstWhere(
                              (x) => x.id == e.studentId,
                              orElse: () => _unknownStudent,
                            );
                            final parent =
                                app.userNameById(e.requestedById) ?? '-';
                            return _ModernListItem(
                              leadingIcon: Icons.verified_user_outlined,
                              title: s.name,
                              subtitle:
                                  '${tr.parent}: $parent • ${tr.reference}: ${e.paymentRef ?? '-'}',
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 12),
                      _SubHeader('${tr.awaitingPayment} (${awaiting.length})'),
                      const SizedBox(height: 6),
                      if (awaiting.isEmpty)
                        Text(tr.noItems)
                      else
                        _ModernList(
                          items: awaiting.map((e) {
                            final s = app.students.firstWhere(
                              (x) => x.id == e.studentId,
                              orElse: () => _unknownStudent,
                            );
                            final parent =
                                app.userNameById(e.requestedById) ?? '-';
                            return _ModernListItem(
                              leadingIcon: Icons.hourglass_bottom,
                              title: s.name,
                              subtitle: '${tr.parent}: $parent',
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ==== Requests CSV ====
  Future<void> _exportCsvRequests(
    BuildContext context,
    List<PickupRequestApi> requests,
    AppState app,
  ) async {
    final tr = AppLocalizations.of(context)!;

    final headers = ['Student Name', 'Type', 'Status', 'Time'];
    final rows = requests.map((r) {
      final s = _findStudentOrNull(app.students, r.studentId);
      final type = app.detailName(r.requestTypeId);
      final status = app.detailName(r.statusId);
      return [s?.name ?? '-', type, status, _fmtTime(r.time)];
    }).toList();

    await _writeCsvFile(context, 'requests_export.csv', [headers, ...rows], tr);
  }

  // ==== Bus Enrollments CSV ====
  Future<void> _exportCsvBusEnrollments({
    required BuildContext context,
    required AppState appState,
    String? neighborhood,
    int? supervisorUserId,
  }) async {
    bool busPasses(BusApi b) {
      final okHood = neighborhood == null || b.neighborhood == neighborhood;
      final okSup =
          supervisorUserId == null || b.supervisorUserId == supervisorUserId;
      return okHood && okSup;
    }

    final rows = <List<dynamic>>[];
    rows.add([
      'Enrollment ID',
      'Student',
      'Parent',
      'Bus',
      'Neighborhood',
      'SupervisorUserId',
      'Status',
      'RequestedAt',
      'PaymentRef',
      'MonthlyFee',
    ]);

    for (final e in appState.busEnrollments) {
      final bus = appState.buses.firstWhere(
        (b) => b.id == e.busId,
        orElse: () => _nullBus,
      );
      if (bus.id == -1 || !busPasses(bus)) continue;
      final s = appState.students.firstWhere(
        (x) => x.id == e.studentId,
        orElse: () => _unknownStudent,
      );
      final parent = appState.userNameById(e.requestedById) ?? '-';

      rows.add([
        e.id,
        s.name,
        parent,
        bus.name,
        bus.neighborhood,
        bus.supervisorUserId,
        e.status.name,
        _fmtDate(e.requestedAt),
        e.paymentRef ?? '',
        bus.monthlyFee,
      ]);
    }

    final tr = AppLocalizations.of(context)!;
    await _writeCsvFile(context, 'bus_enrollments_export.csv', rows, tr);
  }

  // ==== Shared CSV writer ====
  Future<void> _writeCsvFile(
    BuildContext context,
    String filename,
    List<List<dynamic>> rows,
    AppLocalizations tr,
  ) async {
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getExternalStorageDirectory();
    if (dir == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(tr.exportFailed)));
      }
      return;
    }

    final perm = await Permission.storage.request();
    if (!perm.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(tr.permissionDenied)));
      }
      return;
    }

    final file = File('${dir.path}/$filename');
    await file.writeAsString(csv);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr.exportSuccess)));
    }
  }

  // ==== Helpers ====
  StudentApi? _findStudentOrNull(List<StudentApi> list, int id) {
    for (final s in list) {
      if (s.id == id) return s;
    }
    return null;
  }

  String _fmtTime(DateTime t) =>
      '${t.hour}:${t.minute.toString().padLeft(2, '0')}';

  String _fmtDate(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$y/$mo/$d $h:$m';
  }
}

// ======== UI bits ========

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.analytics_outlined),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final double width;
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.width,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: CircleAvatar(child: Icon(icon)),
          title: Text(title),
          subtitle: Text(subtitle),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _RequestsFilters extends StatelessWidget {
  final List<dynamic> statuses;
  final List<String> names;
  final String? selectedStudentName;
  final int? selectedStatusId;
  final ValueChanged<String?> onStudent;
  final ValueChanged<int?> onStatus;
  final VoidCallback onReset;

  const _RequestsFilters({
    required this.statuses,
    required this.names,
    required this.selectedStudentName,
    required this.selectedStatusId,
    required this.onStudent,
    required this.onStatus,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 360,
          child: DropdownButtonFormField<String>(
            value: selectedStudentName,
            hint: Text(tr.selectStudent),
            items: names
                .map((n) => DropdownMenuItem<String>(value: n, child: Text(n)))
                .toList(),
            onChanged: onStudent,
            isExpanded: true,
          ),
        ),
        SizedBox(
          width: 360,
          child: DropdownButtonFormField<int>(
            value: selectedStatusId,
            hint: Text(tr.status),
            items: statuses
                .map<DropdownMenuItem<int>>(
                  (d) => DropdownMenuItem<int>(
                    value: d.lookupDomainDetailId as int,
                    child: Text(
                      context.read<AppState>().detailName(
                        d.lookupDomainDetailId as int,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onStatus,
            isExpanded: true,
          ),
        ),
        IconButton(
          onPressed: onReset,
          icon: const Icon(Icons.clear),
          tooltip: tr.resetFilters,
        ),
      ],
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final int columns;
  final List<Widget> children;
  const _KpiGrid({required this.columns, required this.children});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        const gap = 12.0;
        final width = c.maxWidth;
        final itemW = (width - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: children
              .map((ch) => SizedBox(width: itemW, child: ch))
              .toList(),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final double height;
  final Widget child;
  const _ChartCard({
    required this.title,
    required this.child,
    this.height = 240,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(height: height, child: child),
          ],
        ),
      ),
    );
  }
}

class _ModernList extends StatelessWidget {
  final List<_ModernListItem> items;
  const _ModernList({required this.items});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final it = items[i];
          return ListTile(
            leading: CircleAvatar(child: Icon(it.leadingIcon)),
            title: Text(it.title),
            subtitle: Text(it.subtitle),
          );
        },
      ),
    );
  }
}

class _ModernListItem {
  final IconData leadingIcon;
  final String title;
  final String subtitle;
  _ModernListItem({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
  });
}

class _BusMiniCard extends StatelessWidget {
  final BusApi bus;
  final int paid;
  final int awaiting;
  final VoidCallback onTap;
  final AppLocalizations tr;
  const _BusMiniCard({
    required this.bus,
    required this.paid,
    required this.awaiting,
    required this.onTap,
    required this.tr,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    child: Icon(Icons.directions_bus_outlined),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      bus.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  _Pill(text: bus.neighborhood),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _InfoPill(
                    icon: Icons.verified_outlined,
                    text: '${tr.activeShort}: $paid',
                  ),
                  _InfoPill(
                    icon: Icons.hourglass_bottom,
                    text: '${tr.awaitingShort}: $awaiting',
                  ),
                  _InfoPill(
                    icon: Icons.payments_outlined,
                    text:
                        '${bus.monthlyFee.toStringAsFixed(0)} ${tr.monthlyFeeShort}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoPill({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 14), const SizedBox(width: 6), Text(text)],
      ),
    );
  }
}

class _SubHeader extends StatelessWidget {
  final String text;
  const _SubHeader(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold));
  }
}

class _ModernGrid extends StatelessWidget {
  final int columns;
  final List<Widget> children;
  const _ModernGrid({required this.columns, required this.children});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        const gap = 12.0;
        final width = c.maxWidth;
        final itemW = (width - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: children
              .map((w) => SizedBox(width: itemW, child: w))
              .toList(),
        );
      },
    );
  }
}

class _BusBarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final String tooltipPrefix;
  final ValueChanged<int?>? onBarTap;

  const _BusBarChart({
    required this.labels,
    required this.values,
    required this.tooltipPrefix,
    this.onBarTap,
  });

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty || values.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noBusChartData));
    }

    final groups = <BarChartGroupData>[];
    for (int i = 0; i < labels.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: values[i],
              width: 18,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ],
          showingTooltipIndicators: values[i] > 0 ? [0] : [],
        ),
      );
    }

    return BarChart(
      BarChartData(
        barGroups: groups,
        gridData: FlGridData(show: true, horizontalInterval: 1),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx < 0 || idx >= labels.length) return const SizedBox();
                final short = labels[idx].length <= 12
                    ? labels[idx]
                    : '${labels[idx].substring(0, 12)}…';
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(short, style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchCallback: (event, res) {
            if (event.isInterestedForInteractions &&
                res != null &&
                res.spot != null) {
              onBarTap?.call(res.spot!.touchedBarGroupIndex);
            }
          },
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final name = labels[group.x.toInt()];
              final v = rod.toY.toStringAsFixed(0);
              return BarTooltipItem(
                '$name\n$tooltipPrefix: $v',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RequestPieChart extends StatelessWidget {
  final List<PickupRequestApi> requests;
  const _RequestPieChart({required this.requests});
  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final total = requests.length.toDouble();
    if (total == 0) {
      return Center(child: Text(tr.noRequestsYet));
    }
    final Map<int, int> statusCount = {};
    for (var r in requests) {
      statusCount[r.statusId] = (statusCount[r.statusId] ?? 0) + 1;
    }
    return PieChart(
      PieChartData(
        sections: statusCount.entries.map((entry) {
          final count = entry.value;
          final perc = (count / total) * 100;
          return PieChartSectionData(
            value: count.toDouble(),
            title: '${perc.toStringAsFixed(1)}%',
            color: _statusColor(entry.key),
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }
}

Color _statusColor(int statusId) {
  switch (statusId) {
    case 8:
      return Colors.orange; // Pending
    case 9:
      return Colors.green; // Approved
    case 10:
      return Colors.red; // Rejected
    case 11:
      return Colors.blueGrey; // Completed
    default:
      return Colors.grey; // Fallback
  }
}

// Helper null/unknown
const _nullBus = BusApi(
  id: -1,
  name: '—',
  neighborhood: '-',
  routeDescription: '-',
  weekdays: [],
  pickupTime: '-',
  dropoffTime: '-',
  monthlyFee: 0,
  supervisorUserId: 0,
);

final _unknownStudent = StudentApi(
  id: -1,
  name: '-',
  grade: '-',
  idNumber: '',
  genderId: 0,
  imagePath: '',
);

// Pending case 9: return Colors.green; // Approved case 10: return Colors.red; // Rejected case 11: return Colors.blueGrey; // Completed default: return Colors.grey; } } }}
// NEW: bus filter row widget + export button
class _BusFilters extends StatelessWidget {
  final List<String> neighborhoods;
  final List<int> supervisors;
  final String? selectedNeighborhood;
  final int? selectedSupervisorUserId;
  final ValueChanged<String?> onNeighborhood;
  final ValueChanged<int?> onSupervisor;
  final VoidCallback onExportCsv;

  const _BusFilters({
    required this.neighborhoods,
    required this.supervisors,
    required this.selectedNeighborhood,
    required this.selectedSupervisorUserId,
    required this.onNeighborhood,
    required this.onSupervisor,
    required this.onExportCsv,
  });

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 320,
          child: DropdownButtonFormField<String>(
            value: selectedNeighborhood,
            hint: Text(tr.neighborhood),
            items: neighborhoods
                .map<DropdownMenuItem<String>>(
                  (h) => DropdownMenuItem<String>(value: h, child: Text(h)),
                )
                .toList(),
            onChanged: onNeighborhood,
            isExpanded: true,
          ),
        ),
        SizedBox(
          width: 320,
          child: DropdownButtonFormField<int>(
            value: selectedSupervisorUserId,
            hint: Text(tr.supervisorId),
            items: supervisors
                .map<DropdownMenuItem<int>>(
                  (id) => DropdownMenuItem<int>(value: id, child: Text('#$id')),
                )
                .toList(),
            onChanged: onSupervisor,
            isExpanded: true,
          ),
        ),
        FilledButton.icon(
          onPressed: onExportCsv,
          icon: const Icon(Icons.download),
          label: Text(tr.exportBusCsv),
        ),
      ],
    );
  }
}
