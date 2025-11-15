import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edupass/core/state/app_state.dart';
import 'package:edupass/core/models/bus_enrollment.dart';

class SupervisorBusAssignScreen extends StatelessWidget {
  const SupervisorBusAssignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final students = app.students;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Students to Bus / إسناد الطلاب للحافلة'),
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (_, i) {
          final s = students[i];
          final assigned = app.busIdsOfStudent(s.id);
          return Card(
            child: ListTile(
              title: Text(s.name),
              subtitle: Text(
                'Grade ${s.grade} • #${s.id}\nAssigned: ${assigned.isEmpty ? '—' : assigned.map((id) => app.buses.firstWhere((b) => b.id == id).name).join(', ')}',
              ),
              isThreeLine: true,
              trailing: DropdownButton<int>(
                hint: const Text('Select Bus'),
                value: assigned.isNotEmpty ? assigned.first : null,
                items: app.buses
                    .map(
                      (b) => DropdownMenuItem(value: b.id, child: Text(b.name)),
                    )
                    .toList(),
                onChanged: (busId) async {
                  if (busId == null) return;
                  final existingIndex = app.busEnrollments.indexWhere(
                    (e) => e.studentId == s.id && e.busId == busId,
                  );
                  if (existingIndex == -1) {
                    await app.parentRequestJoinBus(
                      studentId: s.id,
                      busId: busId,
                      parentUserId: 0,
                    );
                    final newEnrollId = app.busEnrollments.last.id;
                    await app.completePaymentAndAssign(
                      enrollmentId: newEnrollId,
                      paymentRef: 'SupervisorAssign',
                    );
                  } else {
                    final ex = app.busEnrollments[existingIndex];
                    app.busEnrollments[existingIndex] = ex.copyWith(
                      status: BusJoinStatus.paid,
                      paymentRef: 'SupervisorAssign',
                    );
                    await app.saveBusEnrollments();
                    // ignore: invalid_use_of_protected_member
                    app.notifyListeners();
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
