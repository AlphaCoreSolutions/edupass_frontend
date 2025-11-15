// lib/features/school/views/admin_panel_screen.dart
import 'package:edupass/core/models/pickupRequest.dart';
import 'package:edupass/core/models/student.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:edupass/l10n/app_localizations.dart';
import 'package:edupass/core/state/app_state.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tr = AppLocalizations.of(context)!;

    final List<PickupRequestApi> allRequests = appState.requests;
    final List<StudentApi> students = appState.students;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
          title: Text(tr.adminPanel),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // === Admin actions (top) ===
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.directions_bus_filled_outlined),
                      title: const Text('الحافلات الرسمية / Official Buses'),
                      subtitle: const Text('إدارة الحافلات، الجداول والرسوم'),
                      onTap: () => context.push('/buses'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // === Requests list (below) ===
            Expanded(
              child: allRequests.isEmpty
                  ? Center(child: Text(tr.noRequestsYet))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: allRequests.length,
                      itemBuilder: (_, index) {
                        final req = allRequests[index];

                        final student = students.firstWhere(
                          (s) => s.id == req.studentId,
                          orElse: () => StudentApi(
                            id: -1,
                            name: '-',
                            grade: '-',
                            idNumber: '',
                            genderId: 0,
                            imagePath: '',
                          ),
                        );

                        final requesterName =
                            appState.userNameById(req.requestedById) ?? '-';

                        final typeName = appState.detailName(req.requestTypeId);
                        final statusName = appState.detailName(req.statusId);
                        final reasonName = (req.reasonId != null)
                            ? appState.detailName(req.reasonId!)
                            : null;

                        return Animate(
                          effects: const [FadeEffect(), SlideEffect()],
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              title: Text('${tr.studentName}: ${student.name}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${tr.requestType}: $typeName'),
                                  Text('${tr.requestStatus}: $statusName'),
                                  Text('${tr.requestedBy}: $requesterName'),
                                  if (reasonName != null &&
                                      reasonName.trim().isNotEmpty)
                                    Text('${tr.reason}: $reasonName'),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatDate(req.time),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  if (req.exitTime != null)
                                    Text(
                                      '${tr.exit}: ${_formatDate(req.exitTime!)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
