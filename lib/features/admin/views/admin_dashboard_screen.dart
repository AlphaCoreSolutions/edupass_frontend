// lib/features/admin/views/admin_dashboard_screen.dart
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:edupass/core/models/pickupRequest.dart';
import 'package:edupass/core/models/student.dart';
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
  String? selectedStudentName;
  int? selectedStatusId;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tr = AppLocalizations.of(context)!;

    // API-backed lists exposed by AppState
    final students = appState.students; // List<StudentApi>
    final requests = appState.requests; // List<PickupRequestApi>

    // Filtered list
    final filteredRequests = requests.where((r) {
      final student = _findStudentOrNull(students, r.studentId);
      final matchesStudent =
          selectedStudentName == null || (student?.name == selectedStudentName);
      final matchesStatus =
          selectedStatusId == null || r.statusId == selectedStatusId;
      return matchesStudent && matchesStatus;
    }).toList();

    // Stats
    final pendingId = appState.findDetailIdByEnglish(
      DomainIds.requestStatus,
      'Pending',
    );
    final pending = filteredRequests
        .where((r) => r.statusId == pendingId)
        .length;

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
              onPressed: () => _exportCsv(context, filteredRequests, appState),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildFilters(context, appState),
              const SizedBox(height: 16),
              _StatCard(label: tr.totalStudents, value: students.length),
              _StatCard(
                label: tr.totalRequests,
                value: filteredRequests.length,
              ),
              _StatCard(label: tr.pendingRequests, value: pending),
              const SizedBox(height: 16),

              Text(
                tr.statsChart,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 220,
                child: _RequestPieChart(requests: filteredRequests),
              ),
              const SizedBox(height: 24),

              Text(
                tr.requestLog,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (filteredRequests.isEmpty)
                Center(child: Text(tr.noRequestsYet))
              else
                ...filteredRequests.reversed.map((r) {
                  final student = _findStudentOrNull(students, r.studentId);
                  final studentName = student?.name ?? '-';
                  final typeName = appState.detailName(r.requestTypeId);
                  final statusName = appState.detailName(r.statusId);

                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(studentName),
                    subtitle: Text(
                      '$typeName • $statusName'
                      '${r.exitTime != null ? ' • ${tr.exit}: ${_formatTime(r.exitTime!)}' : ''}',
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, AppState appState) {
    // Fallback strings to avoid missing ARB keys (replace with tr.* when you add them)
    final labelFilters = 'الفلاتر';
    final labelSelectStudent = 'اختر الطالب';
    final labelStatus = 'الحالة';
    final labelReset = 'إعادة تعيين';

    // status list from lookups
    final statusDetails = appState.detailsOfDomain(DomainIds.requestStatus);

    // unique student names
    final names = appState.students.map((s) => s.name).toSet().toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelFilters, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedStudentName,
                hint: Text(labelSelectStudent),
                items: names
                    .map(
                      (name) =>
                          DropdownMenuItem(value: name, child: Text(name)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => selectedStudentName = value),
                isExpanded: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: selectedStatusId,
                hint: Text(labelStatus),
                items: statusDetails
                    .map(
                      (d) => DropdownMenuItem(
                        value: d.lookupDomainDetailId,
                        child: Text(
                          appState.detailName(d.lookupDomainDetailId),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedStatusId = value),
                isExpanded: true,
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                selectedStudentName = null;
                selectedStatusId = null;
              }),
              icon: const Icon(Icons.clear),
              tooltip: labelReset,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _exportCsv(
    BuildContext context,
    List<PickupRequestApi> requests,
    AppState appState,
  ) async {
    final tr = AppLocalizations.of(context)!;

    final headers = ['Student Name', 'Type', 'Status', 'Time'];
    final rows = requests.map((r) {
      final student = _findStudentOrNull(appState.students, r.studentId);
      final type = appState.detailName(r.requestTypeId);
      final status = appState.detailName(r.statusId);
      return [student?.name ?? '-', type, status, _formatTime(r.time)];
    }).toList();

    final csv = const ListToCsvConverter().convert([headers, ...rows]);

    final dir = await getExternalStorageDirectory();
    if (dir == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed')), // add ARB later
        );
      }
      return;
    }

    final perm = await Permission.storage.request();
    if (!perm.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission denied')), // add ARB later
        );
      }
      return;
    }

    final file = File('${dir.path}/requests_export.csv');
    await file.writeAsString(csv);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr.exportSuccess)));
    }
  }

  StudentApi? _findStudentOrNull(List<StudentApi> list, int id) {
    for (final s in list) {
      if (s.id == id) return s;
    }
    return null;
  }

  String _formatTime(DateTime time) =>
      '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.bar_chart),
        title: Text(label),
        trailing: Text(
          '$value',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    final total = requests.length.toDouble();
    if (total == 0) {
      return Center(child: Text(AppLocalizations.of(context)!.noRequestsYet));
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
        return Colors.grey;
    }
  }
}
