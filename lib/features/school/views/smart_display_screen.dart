// lib/features/school/views/smart_display_screen.dart
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:edupass/core/models/detail_ids.dart';
import 'package:edupass/core/models/pickupRequest.dart';
import 'package:edupass/core/models/student.dart';
import 'package:edupass/core/state/app_state.dart';
import 'package:edupass/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SmartDisplayScreen extends StatefulWidget {
  const SmartDisplayScreen({super.key});

  @override
  State<SmartDisplayScreen> createState() => _SmartDisplayScreenState();
}

class _SmartDisplayScreenState extends State<SmartDisplayScreen> {
  late Timer _refreshTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<int> _previousApprovedIds = [];

  @override
  void initState() {
    super.initState();

    // Initial populate
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());

    // Periodic refresh
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _refresh(),
    );
  }

  Future<void> _refresh() async {
    final appState = context.read<AppState>();

    // If you have a method to fetch latest requests from backend, call it:
    try {
      await appState
          .loadRequests(); // safe if implemented; otherwise it’s a no-op
    } catch (_) {
      /* ignore network/cache errors for display */
    }

    final approved = appState.requests
        .where((r) => r.statusId == DetailIds.approved)
        .toList();

    final currentIds = approved.map((r) => r.id).toList();

    // 🔔 Play sound if new approved requests appear
    final hasNew =
        _previousApprovedIds.isNotEmpty &&
        currentIds.any((id) => !_previousApprovedIds.contains(id));

    if (hasNew) {
      try {
        // Make sure you listed this in pubspec under assets:
        // assets:
        //   - assets/sounds/notification.mp3
        await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
      } catch (_) {
        /* ignore audio failure */
      }
    }

    _previousApprovedIds = currentIds;

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tr = AppLocalizations.of(context)!;

    final List<PickupRequestApi> approvedRequests = appState.requests
        .where((r) => r.statusId == DetailIds.approved)
        .toList();

    final List<StudentApi> students = appState.students;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
          title: Text(
            tr.smartDisplayTitle,
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: approvedRequests.isEmpty
            ? Center(
                child: Text(
                  tr.smartDisplayEmpty,
                  style: const TextStyle(color: Colors.white70),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: approvedRequests.length,
                itemBuilder: (_, index) {
                  final request = approvedRequests[index];
                  final student = students.firstWhereOrNull(
                    (s) => s.id == request.studentId,
                  );

                  final studentName = student?.name ?? tr.unknown;

                  return Animate(
                    effects: const [
                      ScaleEffect(duration: Duration(milliseconds: 400)),
                      FadeEffect(),
                    ],
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 32,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade700,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          studentName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
