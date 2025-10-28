// lib/features/parent/views/parent_settings_screen.dart
import 'package:edupass/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/state/app_state.dart';

class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tr = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile
            Animate(
              effects: const [FadeEffect(), SlideEffect()],
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(tr.username),
                subtitle: Text(tr.parentExperimental),
              ),
            ),
            const Divider(),

            // Clear requests (with confirm)
            Animate(
              effects: const [FadeEffect(), SlideEffect()],
              child: ListTile(
                leading: const Icon(Icons.clear_all),
                title: Text(tr.clearRequests),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(tr.clearRequests),
                      content: Text(tr.areYouSure),
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
                    await context.read<AppState>().clearRequests();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr.requestsCleared)),
                      );
                    }
                  }
                },
              ),
            ),

            // Logout
            Animate(
              effects: const [FadeEffect(), SlideEffect()],
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: Text(tr.logout),
                onTap: () {
                  appState.logout();
                  context.go('/');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
