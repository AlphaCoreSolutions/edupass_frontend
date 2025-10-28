// lib/features/parent/views/parent_home_screen.dart

import 'dart:io';

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
        body: students.isEmpty
            ? Center(child: Text(tr.noStudents))
            : ListView.builder(
                itemCount: students.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, index) => Animate(
                  effects: const [FadeEffect(), SlideEffect()],
                  child: StudentCard(student: students[index]),
                ),
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
  bool showRequestDetails = true;

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

    // Last 3 requests for history (most recent first)
    final studentRequests = appState.requests
        .where((r) => r.studentId == student.id)
        .toList()
        .reversed
        .take(3)
        .toList();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👤 Header Info
              Row(
                children: [
                  (student.imagePath!.isNotEmpty)
                      ? ClipOval(child: _buildStudentAvatar(context, student))
                      : const CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.person),
                        ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                      showRequestDetails
                          ? Icons.expand_less
                          : Icons.expand_more,
                    ),
                    onPressed: () => setState(() {
                      showRequestDetails = !showRequestDetails;
                    }),
                  ),
                ],
              ),

              if (latestRequest != null && showRequestDetails) ...[
                const SizedBox(height: 16),

                // 🟢 Latest Request
                Animate(
                  effects: const [FadeEffect(), SlideEffect()],
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${tr.latestRequest}: ${_statusName(context, latestRequest.statusId)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      QrImageView(
                        data: latestRequest.id.toString(),
                        size: 100,
                        backgroundColor: Colors.white,
                      ).animate().scale(delay: 100.ms),
                    ],
                  ),
                ),

                if (latestRequest.statusId == RequestStatusIds.pending) ...[
                  const SizedBox(height: 8),
                  Animate(
                    effects: const [FadeEffect(), SlideEffect()],
                    child: Wrap(
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
                            setState(() => showRequestDetails = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(tr.requestCanceled)),
                            );
                          },
                          icon: const Icon(Icons.cancel),
                          label: Text(tr.cancel),
                        ),
                      ],
                    ),
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

              const SizedBox(height: 10),

              // 📤 Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        showRequestDialog(
                          context: context,
                          student: student,
                          isEarlyLeave: true,
                        );
                      },
                      child: Text(tr.requestEarlyLeave),
                    ),
                  ),
                ],
              ),

              // 🕓 Request History
              if (studentRequests.isNotEmpty && showRequestDetails) ...[
                const SizedBox(height: 16),
                Text(
                  tr.requestHistory,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...studentRequests.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• ${_statusName(context, r.statusId)} - ${_typeName(context, r.requestTypeId)} (${_formatTime(r.time)})',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ===== Helpers (ID-based) =====

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

// ===== ID constants (you likely already have them in DomainIds) =====

/// If you have a central place, you can remove these and import them.
/// These are the backend IDs you shared:
class RequestStatusIds {
  static const int pending = 8;
  static const int approved = 9;
  static const int rejected = 10;
  static const int completed = 11;
}

Widget _buildStudentAvatar(BuildContext context, StudentApi student) {
  final path = student.imagePath; // may be null or empty
  if (path == null || path.trim().isEmpty) {
    return const CircleAvatar(radius: 30, child: Icon(Icons.person));
  }

  // If you have a base URL for server-hosted images:
  const baseUrl = 'https://localhost:5001/'; // adjust if different

  // Heuristic: local file vs network path
  final isLocalFile =
      path.startsWith('/') ||
      path.startsWith('file://') ||
      path.contains(':\\'); // windows

  final imageWidget = isLocalFile
      ? Image.file(File(path), width: 60, height: 60, fit: BoxFit.cover)
      : Image.network(
          path.startsWith('http') ? path : '$baseUrl$path',
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        );

  return ClipOval(child: imageWidget);
}
