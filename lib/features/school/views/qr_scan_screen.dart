// lib/features/school/views/qr_scan_screen.dart
import 'package:collection/collection.dart';
import 'package:edupass/core/models/detail_ids.dart';
import 'package:edupass/core/models/pickupRequest.dart';
import 'package:edupass/core/models/student.dart';
import 'package:edupass/core/state/app_state.dart';
import 'package:edupass/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class GateQrScannerScreen extends StatefulWidget {
  const GateQrScannerScreen({super.key});

  @override
  State<GateQrScannerScreen> createState() => _GateQrScannerScreenState();
}

class _GateQrScannerScreenState extends State<GateQrScannerScreen> {
  bool _scanned = false;

  Future<void> _handleScan(String code) async {
    if (_scanned) return;
    _scanned = true;

    final tr = AppLocalizations.of(context)!;
    final appState = context.read<AppState>();
    final requestId = int.tryParse(code);

    if (requestId == null) {
      _showError(tr.qrInvalid);
      return;
    }

    final PickupRequestApi? request = appState.requests.firstWhereOrNull(
      (r) => r.id == requestId,
    );

    if (request == null) {
      _showError(tr.qrNotFound);
      return;
    }

    // must be Approved (detailId = 9)
    if (request.statusId != DetailIds.approved) {
      _showError(tr.qrNotApproved);
      return;
    }

    final StudentApi? student = appState.students.firstWhereOrNull(
      (s) => s.id == request.studentId,
    );

    if (student == null) {
      _showError(tr.qrStudentNotFound);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr.qrConfirmExit),
        content: Text(tr.qrConfirmExitMessage(student.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr.confirm),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // set status -> Completed (detailId = 11)
        await appState.updateRequestStatusId(request.id, DetailIds.completed);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr.qrExitSuccess(student.name))),
          );
          Navigator.pop(context);
        }
      } catch (_) {
        _showError(tr.gateExitError);
      }
    } else {
      _scanned = false; // allow re-scan if canceled
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(tr.scanQR),
      ),
      body: Animate(
        effects: const [FadeEffect(), ScaleEffect()],
        child: Stack(
          children: [
            MobileScanner(
              onDetect: (capture) {
                final code = capture.barcodes.first.rawValue;
                if (code != null) _handleScan(code);
              },
            ),
            // optional simple overlay frame
            IgnorePointer(
              child: Center(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 3,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
