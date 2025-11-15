// lib/features/school/views/gate_supervisor_screen.dart
import 'package:edupass/core/models/pickupRequest.dart';
import 'package:edupass/core/models/student.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:edupass/l10n/app_localizations.dart';
import 'package:edupass/core/state/app_state.dart';
import 'package:edupass/core/models/detail_ids.dart'; // ✅ contains approved=9, completed=11

class GateSupervisorScreen extends StatelessWidget {
  const GateSupervisorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final appState = context.watch<AppState>();

    // ✅ filter approved by statusId
    final approvedRequests = appState.requests
        .where((r) => r.statusId == DetailIds.approved)
        .toList();

    final students = appState.students;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
          title: Text('📍 ${tr.gateTitle}'),
          centerTitle: true,
        ),
        body: approvedRequests.isEmpty
            ? Center(child: Text(tr.gateNoStudents))
            : ListView.builder(
                itemCount: approvedRequests.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, index) {
                  final PickupRequestApi request = approvedRequests[index];

                  final StudentApi student = students.firstWhere(
                    (s) => s.id == request.studentId,
                    orElse: () => StudentApi(
                      id: 0,
                      name: tr.unknown,
                      grade: 'N/A',
                      idNumber: '',
                      genderId: 0,
                      imagePath: '',
                    ),
                  );

                  final typeName = appState.detailName(request.requestTypeId);
                  final statusName = appState.detailName(request.statusId);

                  return Animate(
                    effects: const [FadeEffect(), SlideEffect()],
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.person),
                        ),
                        title: Text(
                          student.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${tr.grade}: ${student.grade}'),
                            Text('${tr.requestType}: $typeName'),
                            Text('${tr.requestStatus}: $statusName'),
                          ],
                        ),
                        trailing: ElevatedButton.icon(
                          onPressed: () async {
                            final choice =
                                await showModalBottomSheet<
                                  Map<String, dynamic>
                                >(
                                  context: context,
                                  builder: (sheetCtx) {
                                    final auth = appState.authorizedForStudent(
                                      student.id,
                                    );
                                    final studentBusIds = appState
                                        .busIdsOfStudent(student.id);
                                    return SafeArea(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(
                                              Icons.person_outline,
                                            ),
                                            title: const Text(
                                              'Parent / ولي الأمر',
                                            ), // using inline label to avoid l10n changes
                                            onTap: () =>
                                                Navigator.pop(sheetCtx, {
                                                  'type': 0,
                                                  'id': request.requestedById,
                                                }),
                                          ),
                                          if (auth.isNotEmpty)
                                            const Divider(height: 1),
                                          ...auth.map(
                                            (p) => ListTile(
                                              leading: const Icon(
                                                Icons.verified_user_outlined,
                                              ),
                                              title: Text(
                                                'Authorized: ${p.fullName}',
                                              ),
                                              subtitle: Text(p.phone),
                                              onTap: () => Navigator.pop(
                                                sheetCtx,
                                                {'type': 1, 'id': p.id},
                                              ),
                                            ),
                                          ),
                                          if (studentBusIds.isNotEmpty)
                                            const Divider(height: 1),
                                          ...studentBusIds.map((bid) {
                                            final b = appState.buses.firstWhere(
                                              (x) => x.id == bid,
                                              orElse: () =>
                                                  appState.buses.first,
                                            );
                                            return ListTile(
                                              leading: const Icon(
                                                Icons.directions_bus_outlined,
                                              ),
                                              title: Text('Bus: ${b.name}'),
                                              onTap: () => Navigator.pop(
                                                sheetCtx,
                                                {'type': 2, 'id': bid},
                                              ),
                                            );
                                          }),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    );
                                  },
                                );

                            if (choice == null) return;

                            try {
                              // complete the pickup request
                              await appState.updateRequestStatusId(
                                request.id,
                                DetailIds.completed, // ✅ Completed = 11
                              );

                              // log who picked the student
                              await appState.logDoorExit(
                                studentId: student.id,
                                pickedByType: choice['type'] as int,
                                pickedById: choice['id'] as int?,
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      tr.gateExitSuccess(student.name),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              debugPrint('❌ Error update status: $e');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(tr.gateExitError)),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.door_back_door),
                          label: Text(tr.exitDone),
                        ),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/scan'),
          icon: const Icon(Icons.qr_code_scanner),
          label: Text(tr.scanQR),
        ),
      ),
    );
  }
}
