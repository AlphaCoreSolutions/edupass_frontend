// lib/features/school/views/supervisor_home_screen.dart
import 'package:collection/collection.dart';
import 'package:edupass/core/models/detail_ids.dart';
import 'package:edupass/core/models/pickupRequest.dart';
import 'package:edupass/core/state/app_state.dart';
import 'package:edupass/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SupervisorHomeScreen extends StatelessWidget {
  const SupervisorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tr = AppLocalizations.of(context)!;

    final List<PickupRequestApi> activeRequests = appState.requests
        .where(
          (r) =>
              r.statusId == DetailIds.pending ||
              r.statusId == DetailIds.approved,
        )
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
          title: Text(tr.supervisorTitle),
          actions: [
            IconButton(
              tooltip: tr.refresh, // add "refresh" to l10n if you don't have it
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<AppState>().loadRequests(),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => context.read<AppState>().loadRequests(),
          child: activeRequests.isEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: 120),
                    Center(child: Text(tr.supervisorNoRequests)),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: activeRequests.length,
                  itemBuilder: (_, index) {
                    final request = activeRequests[index];
                    final student = appState.students.firstWhereOrNull(
                      (s) => s.id == request.studentId,
                    );

                    final studentName = student?.name ?? tr.unknown;
                    final studentGrade = student?.grade ?? 'N/A';
                    final studentIdNo = student?.idNumber ?? '-';
                    final studentGender = (student?.genderId == DetailIds.male)
                        ? tr.genderMale
                        : tr.genderFemale;

                    final typeText = appState.detailName(request.requestTypeId);
                    final statusText = appState.detailName(request.statusId);
                    final reasonText = (request.reasonId != null)
                        ? appState.detailName(request.reasonId!)
                        : null;

                    return Animate(
                      effects: const [FadeEffect(), SlideEffect()],
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${tr.studentName}: $studentName',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('${tr.studentGrade}: $studentGrade'),
                              Text('${tr.studentId}: $studentIdNo'),
                              Text('${tr.studentGender}: $studentGender'),
                              const SizedBox(height: 4),
                              Text('${tr.requestType}: $typeText'),
                              if (reasonText != null)
                                Text('${tr.requestReason}: $reasonText'),
                              Text(
                                '${tr.requestStatus}: $statusText',
                                style: TextStyle(
                                  color: _statusColorById(request.statusId),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (request.statusId == DetailIds.pending)
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          context
                                              .read<AppState>()
                                              .updateRequestStatusId(
                                                request.id,
                                                DetailIds.approved,
                                              );
                                        },
                                        icon: const Icon(Icons.check),
                                        label: Text(tr.actionApprove),
                                      ),
                                    ),
                                  if (request.statusId == DetailIds.pending)
                                    const SizedBox(width: 12),
                                  if (request.statusId == DetailIds.pending)
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          context
                                              .read<AppState>()
                                              .updateRequestStatusId(
                                                request.id,
                                                DetailIds.rejected,
                                              );
                                        },
                                        icon: const Icon(Icons.close),
                                        label: Text(tr.actionReject),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                      ),
                                    ),
                                  if (request.statusId == DetailIds.approved)
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          context
                                              .read<AppState>()
                                              .updateRequestStatusId(
                                                request.id,
                                                DetailIds.completed,
                                              );
                                        },
                                        icon: const Icon(Icons.door_back_door),
                                        label: Text(tr.actionComplete),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Color _statusColorById(int statusId) {
    if (statusId == DetailIds.pending) return Colors.orange;
    if (statusId == DetailIds.approved) return Colors.green;
    if (statusId == DetailIds.rejected) return Colors.red;
    if (statusId == DetailIds.completed) return Colors.blueGrey;
    return Colors.grey;
  }
}
