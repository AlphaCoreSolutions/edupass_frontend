// lib/features/parent/views/parent_requests_screen.dart
import 'package:edupass/core/models/pickupRequest.dart';
import 'package:edupass/core/models/student.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/state/app_state.dart';

import '../../../l10n/app_localizations.dart';

class ParentRequestsScreen extends StatelessWidget {
  const ParentRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tr = AppLocalizations.of(context)!;

    final List<PickupRequestApi> requests = appState.requests;
    final List<StudentApi> students = appState.students;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: requests.isEmpty
            ? Center(child: Text(tr.noRequestsYet))
            : ListView.builder(
                itemCount: requests.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, index) {
                  // show latest first
                  final r = requests[requests.length - 1 - index];
                  final student = students.firstWhere(
                    (s) => s.id == r.studentId,
                    orElse: () => StudentApi(
                      id: 0,
                      name: tr.unknown, // add to ARB if you like
                      grade: '-',
                      idNumber: '-',
                      genderId: 0,
                      imagePath: '',
                    ),
                  );

                  final typeName = appState.detailName(r.requestTypeId);
                  final statusName = appState.detailName(r.statusId);

                  return Animate(
                    effects: const [FadeEffect(), SlideEffect()],
                    child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.receipt_long),
                        title: Text(student.name),
                        subtitle: Text('$typeName - $statusName'),
                        trailing: Text(_formatTime(r.time)),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _formatTime(DateTime time) =>
      '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
}
