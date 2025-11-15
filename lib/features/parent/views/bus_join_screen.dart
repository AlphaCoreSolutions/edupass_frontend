// lib/features/parent/views/parent_bus_join_screen.dart
import 'package:edupass/core/models/bus.dart';
import 'package:edupass/core/models/bus_enrollment.dart';
import 'package:edupass/core/state/app_state.dart';
import 'package:edupass/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParentBusJoinScreen extends StatelessWidget {
  final int parentUserId; // pass the logged-in user id
  const ParentBusJoinScreen({super.key, required this.parentUserId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tr = AppLocalizations.of(context)!;

    final buses = app.buses;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${tr.parentBusesTitle} / ${tr.parentBusesSubtitle}'),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (buses.isEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      tr.noBuses,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            else
              ...buses.map(
                (b) => _BusCard(
                  bus: b,
                  canRequest: true,
                  onTapJoin: () => _pickStudentAndRequestFlow(context, b),
                ),
              ),
            const SizedBox(height: 16),
            _EnrollmentsList(parentUserId: parentUserId),
          ],
        ),
      ),
    );
  }

  /// Full flow: pick student → confirm → send request.
  Future<void> _pickStudentAndRequestFlow(
    BuildContext context,
    BusApi bus,
  ) async {
    final app = context.read<AppState>();
    final tr = AppLocalizations.of(context)!;

    // Safely get only this parent's students if such API exists; otherwise use all students.
    List<dynamic> _studentsForParent(AppState app, int parentUserId) {
      try {
        final dyn = app as dynamic;
        final fn = dyn.studentsOfParent; // may not exist
        if (fn is Function) {
          final res = fn(parentUserId);
          if (res is List) return res;
        }
      } catch (_) {
        // ignore and fall back
      }
      return app.students; // fallback
    }

    final List<dynamic> kidsDynamic = _studentsForParent(app, parentUserId);

    // Filter to eligible students (not already pending/awaiting/paid on THIS bus)
    bool hasBlockingEnrollment(int studentId) {
      return app.busEnrollments.any(
        (e) =>
            e.busId == bus.id &&
            e.studentId == studentId &&
            (e.status == BusJoinStatus.pending ||
                e.status == BusJoinStatus.approvedAwaitingPayment ||
                e.status == BusJoinStatus.paid),
      );
    }

    final eligibleStudents = kidsDynamic
        .where((s) => !hasBlockingEnrollment((s as dynamic).id as int))
        .toList();

    final studentId = await showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              height: 4,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  tr.studentName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (eligibleStudents.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  'لا يوجد طلاب مؤهلون لإرسال طلب جديد لهذه الحافلة.',
                  style: const TextStyle(color: Colors.black54),
                ),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: eligibleStudents.map((s) {
                    final st = s as dynamic;
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(st.name as String),
                      subtitle: Text('${tr.grade}: ${st.grade}'),
                      onTap: () => Navigator.of(sheetCtx).pop(st.id as int),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (studentId == null) return;

    // Double-check duplicates before confirming
    final hasDuplicate = app.busEnrollments.any(
      (e) =>
          e.busId == bus.id &&
          e.studentId == studentId &&
          (e.status == BusJoinStatus.pending ||
              e.status == BusJoinStatus.approvedAwaitingPayment ||
              e.status == BusJoinStatus.paid),
    );
    if (hasDuplicate) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تقديم طلب سابق لهذه الحافلة لهذا الطالب.'),
          ),
        );
      }
      return;
    }

    // Confirm dialog with summary
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr.requestJoinBus),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ConfirmRow(icon: Icons.directions_bus, text: bus.name),
            const SizedBox(height: 6),
            _ConfirmRow(
              icon: Icons.location_on_outlined,
              text: bus.neighborhood,
            ),
            const SizedBox(height: 6),
            _ConfirmRow(
              icon: Icons.calendar_today_outlined,
              text: bus.weekdays.join('، '),
            ),
            const SizedBox(height: 6),
            _ConfirmRow(
              icon: Icons.home_outlined,
              text: '${tr.busReturnTime} ${bus.pickupTime}',
            ),
            const SizedBox(height: 6),
            _ConfirmRow(
              icon: Icons.school_outlined,
              text: '${tr.busGoTime} ${bus.dropoffTime}',
            ),
            const SizedBox(height: 6),
            _ConfirmRow(
              icon: Icons.payments_outlined,
              text:
                  '${bus.monthlyFee.toStringAsFixed(0)} ${tr.monthlyFeeShort}',
            ),
            const SizedBox(height: 12),
            const Text(
              'هل تريد إرسال طلب الانضمام؟',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr.requestJoinBus),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final e = await app.parentRequestJoinBus(
        studentId: studentId,
        busId: bus.id,
        parentUserId: parentUserId,
      );

      if (context.mounted) {
        // If you added the ARB with a placeholder: requestSent({id})
        // use this:
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr.requestSent(e.id))));
        // If your ARB is a plain string (no placeholder), use:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${tr.requestSent} (#${e.id})')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر إرسال الطلب. حاول مرة أخرى.')),
        );
      }
    }
  }
}

class _BusCard extends StatelessWidget {
  final BusApi bus;
  final bool canRequest;
  final VoidCallback onTapJoin;

  const _BusCard({
    required this.bus,
    required this.canRequest,
    required this.onTapJoin,
  });

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: canRequest ? onTapJoin : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(child: Icon(Icons.directions_bus)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + neighborhood chip
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            bus.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        _Pill(
                          text: bus.neighborhood.isEmpty
                              ? '-'
                              : bus.neighborhood,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Details pills
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _InfoPill(
                          icon: Icons.calendar_today_outlined,
                          text: bus.weekdays.join('، '),
                        ),
                        _InfoPill(
                          icon: Icons.home_outlined,
                          text: '${tr.busReturnTime} ${bus.pickupTime}',
                        ),
                        _InfoPill(
                          icon: Icons.school_outlined,
                          text: '${tr.busGoTime} ${bus.dropoffTime}',
                        ),
                        _InfoPill(
                          icon: Icons.payments_outlined,
                          text:
                              '${bus.monthlyFee.toStringAsFixed(0)} ${tr.monthlyFeeShort}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // CTA
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.icon(
                        onPressed: canRequest ? onTapJoin : null,
                        icon: const Icon(Icons.hail_outlined),
                        label: Text(tr.requestJoinBus),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnrollmentsList extends StatelessWidget {
  final int parentUserId;
  const _EnrollmentsList({required this.parentUserId});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final app = context.watch<AppState>();

    // Sort and filter to this parent's requests
    final sorted = [...app.busEnrollments]
      ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    final mine = sorted.where((e) => e.requestedById == parentUserId).toList();

    // ---- Responsive sizing ----
    final screenW = MediaQuery.of(context).size.width;

    // wider cards on larger screens
    final double itemW = screenW >= 700
        ? 420
        : screenW >= 560
        ? 380
        : screenW >= 420
        ? 340
        : screenW - 56; // account for page padding + card margins

    // taller list height to avoid inner scroll
    final double listH = screenW < 380
        ? 440
        : screenW < 560
        ? 400
        : 360;

    String _fmtDate(DateTime dt) {
      final y = dt.year.toString();
      final mo = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$y/$mo/$d $h:$m';
    }

    (Color, String) _statusColorLabel(BusJoinStatus status) {
      switch (status) {
        case BusJoinStatus.pending:
          return (Colors.orange, tr.statusPending);
        case BusJoinStatus.approvedAwaitingPayment:
          return (Colors.blue, tr.statusAwaitingPayment);
        case BusJoinStatus.paid:
          return (Colors.green, tr.statusActive);
        case BusJoinStatus.rejected:
          return (Colors.red, tr.statusRejected);
        case BusJoinStatus.cancelled:
          return (Colors.grey, tr.statusCancelled);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mine.isNotEmpty) ...[
          Text(
            tr.myBusRequests,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: listH,
          child: mine.isEmpty
              ? Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: Text(tr.noRequestsYet)),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: mine.length,
                  itemBuilder: (_, i) {
                    final e = mine[i];
                    final b = app.buses.firstWhere(
                      (x) => x.id == e.busId,
                      orElse: () => app.buses.isNotEmpty
                          ? app.buses.first
                          : const BusApi(
                              id: -1,
                              name: '—',
                              neighborhood: '-',
                              routeDescription: '-',
                              weekdays: [],
                              pickupTime: '-',
                              dropoffTime: '-',
                              monthlyFee: 0,
                              supervisorUserId: 0,
                            ),
                    );
                    final student = app.students.firstWhere(
                      (s) => s.id == e.studentId,
                    );
                    final (color, label) = _statusColorLabel(e.status);

                    return SizedBox(
                      width: itemW,
                      child: Card(
                        margin: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top: header + status
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        child: Icon(
                                          Icons.directions_bus_outlined,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          b.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(.08),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: color.withOpacity(.5),
                                      ),
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Middle: rich info (no inner scroll)
                                  if (e.status == BusJoinStatus.paid) ...[
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        _InfoPill(
                                          icon: Icons.person,
                                          text: student.name,
                                        ),
                                        _InfoPill(
                                          icon: Icons.location_on_outlined,
                                          text: b.neighborhood.isEmpty
                                              ? '-'
                                              : b.neighborhood,
                                        ),
                                        _InfoPill(
                                          icon: Icons.calendar_today_outlined,
                                          text: b.weekdays.join('، '),
                                        ),
                                        _InfoPill(
                                          icon: Icons.school_outlined,
                                          text:
                                              '${tr.busGoTime} ${b.dropoffTime}',
                                        ),
                                        _InfoPill(
                                          icon: Icons.home_outlined,
                                          text:
                                              '${tr.busReturnTime} ${b.pickupTime}',
                                        ),
                                        _InfoPill(
                                          icon: Icons.payments_outlined,
                                          text:
                                              '${b.monthlyFee.toStringAsFixed(0)} ${tr.monthlyFeeShort}',
                                        ),
                                        _InfoPill(
                                          icon: Icons.badge_outlined,
                                          text:
                                              '${tr.supervisorId}: #${b.supervisorUserId}',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      // “Active since” using requestedAt as a proxy
                                      '${tr.statusActive} • ${_fmtDate(e.requestedAt)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ] else if (e.status ==
                                      BusJoinStatus
                                          .approvedAwaitingPayment) ...[
                                    Text(
                                      tr.statusAwaitingPayment,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ] else ...[
                                    Text(
                                      tr.noAction,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              // Bottom: action or note
                              if (e.status ==
                                  BusJoinStatus.approvedAwaitingPayment)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      await context
                                          .read<AppState>()
                                          .completePaymentAndAssign(
                                            enrollmentId: e.id,
                                            paymentRef:
                                                'PAY-${DateTime.now().millisecondsSinceEpoch}',
                                          );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(tr.paymentActivated),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.payments_outlined),
                                    label: Text(tr.payAndActivate),
                                  ),
                                )
                              else
                                Text(
                                  tr.noAction,
                                  style: const TextStyle(color: Colors.white),
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
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ConfirmRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
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
