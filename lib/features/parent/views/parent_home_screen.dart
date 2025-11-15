// lib/features/parent/views/parent_home_screen.dart

import 'dart:io';

import 'package:edupass/core/models/bus.dart';
import 'package:edupass/core/models/bus_enrollment.dart';
import 'package:edupass/core/models/pickupRequest.dart';
import 'package:edupass/core/models/student.dart';
import 'package:edupass/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/state/app_state.dart';
import '../../../core/utils/pdf_helper.dart';
import '../widgets/request_dialog.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final students = appState.students; // List<StudentApi>
    final tr = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 🔹 Students come FIRST (as requested)
            if (students.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(tr.noStudents),
                ),
              )
            else
              ...List.generate(
                students.length,
                (index) => Animate(
                  effects: const [FadeEffect(), SlideEffect()],
                  child: StudentCard(student: students[index]),
                ),
              ),

            const SizedBox(height: 16),

            // 🔹 Quick-access actions AFTER student cards
            Animate(
              effects: const [FadeEffect(), SlideEffect()],
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.directions_bus_outlined),
                      ),
                      title: Text(tr.parentBusesTitle),
                      subtitle: Text(tr.parentBusesSubtitle),
                      onTap: () => context.push('/parent-buses'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.verified_user_outlined),
                      ),
                      title: Text(tr.authorizedPeopleTitle),
                      subtitle: Text(tr.authorizedPeopleSubtitle),
                      onTap: () => context.push('/auth-people'),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/add-student'),
          icon: const Icon(Icons.person_add),
          label: Text(tr.addStudent),
        ),
      ),
    );
  }
}

class StudentCard extends StatefulWidget {
  final StudentApi student;

  const StudentCard({super.key, required this.student});

  @override
  State<StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard>
    with TickerProviderStateMixin {
  bool showDetails = true;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tr = AppLocalizations.of(context)!;
    final student = widget.student;

    // Latest request for this student
    final latestRequest = _latestRequestForStudent(
      appState.requests,
      student.id,
    );

    // Last 3 requests (most recent first)
    final studentRequests = appState.requests
        .where((r) => r.studentId == student.id)
        .toList()
        .reversed
        .take(3)
        .toList();

    // Active bus enrollment (paid)
    final activeEnrollment = _activeBusEnrollment(appState, student.id);
    final BusApi? activeBus = activeEnrollment != null
        ? appState.buses.firstWhere(
            (b) => b.id == activeEnrollment.busId,
            orElse: () => _nullBus,
          )
        : null;

    // Authorized pickups count (best-effort dynamic)
    final authorizedCount = _authorizedPeopleCount(appState, student.id);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👤 Header
              Row(
                children: [
                  (student.imagePath?.isNotEmpty == true)
                      ? ClipOval(child: _buildStudentAvatar(context, student))
                      : const CircleAvatar(
                          radius: 26,
                          child: Icon(Icons.person),
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('${tr.grade}: ${student.grade}'),
                        Text('${tr.idNumber}: ${student.idNumber}'),
                        Text(
                          '${tr.gender}: ${appState.detailName(student.genderId)}',
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      showDetails ? Icons.expand_less : Icons.expand_more,
                    ),
                    onPressed: () => setState(() {
                      showDetails = !showDetails;
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 🔘 Primary actions (first thing under header)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.exit_to_app),
                      label: Text(tr.requestDismissal),
                      onPressed: () {
                        showRequestDialog(
                          context: context,
                          student: student,
                          isEarlyLeave: false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.schedule),
                      label: Text(tr.requestEarlyLeave),
                      onPressed: () {
                        showRequestDialog(
                          context: context,
                          student: student,
                          isEarlyLeave: true,
                        );
                      },
                    ),
                  ),
                ],
              ),

              if (showDetails) ...[
                const SizedBox(height: 14),

                // 🚌 Assigned bus (compact)
                if (activeBus != null && activeBus.id != -1)
                  _AssignedBusCompact(
                    bus: activeBus,
                    isActive: true,
                    onManageTap: () => context.push('/parent-buses'),
                  )
                else
                  _NoActiveBusCompact(
                    onManageTap: () => context.push('/parent-buses'),
                  ),

                // 👥 Authorized pickups summary
                _InfoRow(
                  icon: Icons.verified_user_outlined,
                  title: tr.authorizedPeopleTitle,
                  subtitle: tr.authorizedPeopleCount(authorizedCount),
                  actionLabel: tr.manage,
                  onAction: () => context.push('/auth-people'),
                ),

                // ℹ️ Latest request + QR
                if (latestRequest != null) ...[
                  const SizedBox(height: 12),
                  _SectionTitle(text: tr.latestRequest),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _composeLatestText(context, latestRequest),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      QrImageView(
                        data: latestRequest.id.toString(),
                        size: 88,
                        backgroundColor: Colors.white,
                      ).animate().scale(delay: 100.ms),
                    ],
                  ),
                  if (latestRequest.statusId == RequestStatusIds.pending) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 20,
                          color: Colors.orange,
                        ),
                        Text(tr.cancelNotice),
                        TextButton.icon(
                          onPressed: () {
                            context.read<AppState>().cancelRequest(
                              latestRequest.id,
                            );
                            setState(() => showDetails = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(tr.requestCanceled)),
                            );
                          },
                          icon: const Icon(Icons.cancel),
                          label: Text(tr.cancel),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => generateDismissalPdf(
                      context: context,
                      request: latestRequest,
                      student: student,
                    ),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(tr.generatePdf),
                  ),
                ],

                // 🕓 Request History
                if (studentRequests.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _SectionTitle(text: tr.requestHistory),
                  const SizedBox(height: 6),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: studentRequests.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final r = studentRequests[i];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.assignment_outlined),
                          title: Text(
                            '${_typeName(context, r.requestTypeId)} • ${_statusName(context, r.statusId)}',
                          ),
                          subtitle: Text(_formatTime(r.time)),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ===== Helpers =====

  PickupRequestApi? _latestRequestForStudent(
    List<PickupRequestApi> list,
    int studentId,
  ) {
    PickupRequestApi? latest;
    for (final r in list) {
      if (r.studentId != studentId) continue;
      if (latest == null || r.time.isAfter(latest.time)) {
        latest = r;
      }
    }
    return latest;
  }

  BusEnrollmentApi? _activeBusEnrollment(AppState app, int studentId) {
    // Paid = active
    for (final e in app.busEnrollments) {
      if (e.studentId == studentId && e.status == BusJoinStatus.paid) {
        return e;
      }
    }
    return null;
  }

  int _authorizedPeopleCount(AppState app, int studentId) {
    // Best-effort dynamic probing to avoid breaking if model name differs
    try {
      final dynamic maybe = (app as dynamic).authorizedPickups;
      if (maybe is List) {
        int c = 0;
        for (final x in maybe) {
          try {
            final dynamic dx = x;
            if (dx.studentId == studentId) c++;
          } catch (_) {}
        }
        return c;
      }
    } catch (_) {}
    try {
      final dynamic maybe = (app as dynamic).authorizedPeople;
      if (maybe is List) {
        int c = 0;
        for (final x in maybe) {
          try {
            final dynamic dx = x;
            if (dx.studentId == studentId) c++;
          } catch (_) {}
        }
        return c;
      }
    } catch (_) {}
    return 0;
  }

  String _composeLatestText(BuildContext context, PickupRequestApi r) {
    final tr = AppLocalizations.of(context)!;
    final status = _statusName(context, r.statusId);
    final type = _typeName(context, r.requestTypeId);
    final exit = r.exitTime != null
        ? ' • ${tr.exit}: ${_formatTime(r.exitTime!)}'
        : '';
    return '$type • $status$exit';
  }

  String _statusName(BuildContext context, int statusId) {
    final appState = context.read<AppState>();
    return appState.detailName(statusId);
  }

  String _typeName(BuildContext context, int requestTypeId) {
    final appState = context.read<AppState>();
    return appState.detailName(requestTypeId);
  }

  String _formatTime(DateTime time) =>
      '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
}

// ===== ID constants (use your centralized ones if available) =====

class RequestStatusIds {
  static const int pending = 8;
  static const int approved = 9;
  static const int rejected = 10;
  static const int completed = 11;
}

// ===== Small UI bits =====

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
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

/// Compact assigned-bus card: only location + go/return + status
class _AssignedBusCompact extends StatelessWidget {
  final BusApi bus;
  final bool isActive;
  final VoidCallback onManageTap;
  const _AssignedBusCompact({
    required this.bus,
    required this.isActive,
    required this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final statusColor = isActive ? Colors.green : Colors.red;
    final statusLabel = isActive ? tr.active : tr.inactive;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.directions_bus)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          bus.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _StatusChip(label: statusLabel, color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _InfoPill(
                        icon: Icons.location_on_outlined,
                        text: bus.neighborhood.isEmpty
                            ? tr.unknown
                            : bus.neighborhood,
                      ),
                      _InfoPill(
                        icon: Icons.school_outlined,
                        text: '${tr.busGoTime} ${bus.dropoffTime}',
                      ),
                      _InfoPill(
                        icon: Icons.home_outlined,
                        text: '${tr.busReturnTime} ${bus.pickupTime}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: onManageTap, child: Text(tr.manage)),
          ],
        ),
      ),
    );
  }
}

/// Small red inactive card when there is no active bus assignment
class _NoActiveBusCompact extends StatelessWidget {
  final VoidCallback onManageTap;
  const _NoActiveBusCompact({required this.onManageTap});
  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.directions_bus_outlined)),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      tr.noActiveBus, // add to ARB if missing
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatusChip(label: tr.inactive, color: Colors.red),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: onManageTap, child: Text(tr.manage)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _InfoRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: (actionLabel != null && onAction != null)
            ? TextButton(onPressed: onAction, child: Text(actionLabel!))
            : null,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold));
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

Widget _buildStudentAvatar(BuildContext context, StudentApi student) {
  final path = student.imagePath; // may be null or empty
  if (path == null || path.trim().isEmpty) {
    return const CircleAvatar(radius: 26, child: Icon(Icons.person));
  }

  // If you have a base URL for server-hosted images:
  const baseUrl = 'https://localhost:5001/'; // adjust if different

  // Heuristic: local file vs network path
  final isLocalFile =
      path.startsWith('/') ||
      path.startsWith('file://') ||
      path.contains(':\\'); // windows

  final imageWidget = isLocalFile
      ? Image.file(File(path), width: 52, height: 52, fit: BoxFit.cover)
      : Image.network(
          path.startsWith('http') ? path : '$baseUrl$path',
          width: 52,
          height: 52,
          fit: BoxFit.cover,
        );

  return ClipOval(child: imageWidget);
}

// Helper null bus
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
