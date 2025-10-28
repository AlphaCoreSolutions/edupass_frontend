// lib/features/parent/widgets/request_dialog.dart
import 'package:edupass/core/models/pickupRequest.dart';
import 'package:edupass/core/models/student.dart';
import 'package:edupass/core/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/app_state.dart';
import '../../../core/models/lookup.dart';
import '../../../core/models/domain_ids.dart';
import '../../../core/models/detail_ids.dart';
import '../../../l10n/app_localizations.dart';

void showRequestDialog({
  required BuildContext context,
  required StudentApi student,
  required bool isEarlyLeave,
}) {
  showDialog(
    context: context,
    builder: (_) => RequestDialog(student: student, isEarlyLeave: isEarlyLeave),
  );
}

class RequestDialog extends StatefulWidget {
  final StudentApi student;
  final bool isEarlyLeave;

  const RequestDialog({
    super.key,
    required this.student,
    required this.isEarlyLeave,
  });

  @override
  State<RequestDialog> createState() => _RequestDialogState();
}

class _RequestDialogState extends State<RequestDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedReasonId; // LookupDomainDetailId for PickupReason
  final _noteController = TextEditingController(); // optional local note
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final appState = context.read<AppState>();
    final tr = AppLocalizations.of(context)!;

    // Resolve IDs (from lookups)
    final pendingId = appState.findDetailIdByEnglish(
      DomainIds.requestStatus,
      'Pending',
    );
    final earlyLeaveId = appState.findDetailIdByEnglish(
      DomainIds.requestType,
      'Early Leave',
    );
    final normalDismissalId = appState.findDetailIdByEnglish(
      DomainIds.requestType,
      'Normal Dismissal',
    );

    if (pendingId == null ||
        earlyLeaveId == null ||
        normalDismissalId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr.lookupsNotReady)));
      return;
    }

    // Prevent duplicate pending per student
    final hasActivePending = appState.requests.any(
      (r) => r.studentId == widget.student.id && r.statusId == pendingId,
    );
    if (hasActivePending) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr.alreadyHasPending)));
      return;
    }

    // Early Leave → reason recommended (backend optional; UX wise require)
    if (widget.isEarlyLeave && _selectedReasonId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr.selectReason)));
      return;
    }

    // Determine requestedById (must be a user id). If you have real auth, use it.
    // Fallback: use currentUserId if set; else first Parent user; else 0.
    int requestedById =
        appState.currentUserId ??
        (appState.users
            .firstWhere(
              (u) => u.roleId == DetailIds.parent,
              orElse: () =>
                  UserApi(id: 0, name: 'Parent', roleId: DetailIds.parent),
            )
            .id);

    final requestTypeId = widget.isEarlyLeave
        ? earlyLeaveId
        : normalDismissalId;

    final newRequest = PickupRequestApi(
      id: 0, // server will assign
      studentId: widget.student.id,
      requestTypeId: requestTypeId,
      requestedById: requestedById,
      time: DateTime.now().toUtc(), // ISO UTC
      statusId: pendingId,
      reasonId: _selectedReasonId,
      attachmentUrl: null, // add later if you support file upload
      exitTime: null,
    );

    setState(() => _submitting = true);
    try {
      await appState.addRequest(newRequest); // ✅ posts to backend now
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr.requestSent)));
    } catch (e) {
      // Surface backend error
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr.requestFailed)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final appState = context.watch<AppState>();

    // Reasons (PickupReason domain)
    final List<LookupDomainDetail> reasons = appState.detailsOfDomain(
      DomainIds.pickupReasons,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(
          widget.isEarlyLeave ? tr.requestEarlyLeave : tr.requestDismissal,
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${tr.studentName}: ${widget.student.name}'),
              const SizedBox(height: 16),

              if (widget.isEarlyLeave) ...[
                DropdownButtonFormField<int>(
                  value: _selectedReasonId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: tr.reason,
                    border: const OutlineInputBorder(),
                  ),
                  items: reasons.map((d) {
                    final label = appState.detailName(d.lookupDomainDetailId);
                    return DropdownMenuItem(
                      value: d.lookupDomainDetailId,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedReasonId = val),
                  validator: (val) => val == null ? tr.requiredField : null,
                ),
                const SizedBox(height: 12),

                // Optional note (kept local for now)
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: tr.noteOptional,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitting ? null : () => Navigator.pop(context),
            child: Text(tr.cancel),
          ),
          ElevatedButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(_submitting ? tr.sending : tr.send),
          ),
        ],
      ),
    );
  }
}
