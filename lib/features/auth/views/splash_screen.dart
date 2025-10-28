// lib/features/auth/views/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edupass/core/state/app_state.dart';
import 'package:edupass/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;
  late AnimationController _dotsController;
  bool _bootstrapped = false; // ✅ ensure we don’t run twice

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _iconController.forward();
      _textController.forward();
      _dotsController.repeat(reverse: true);
      _bootstrapOnce();
    });
  }

  Future<void> _bootstrapOnce() async {
    if (_bootstrapped) return;
    _bootstrapped = true;

    final app = context.read<AppState>();

    try {
      // Load lookups if needed
      if (!app.lookupsLoaded) {
        await app.loadLookups();
      }

      // Preload users/students/requests as needed (only if empty, to prevent extra notify loops)
      if (app.users.isEmpty) await app.loadUsers();
      if (app.students.isEmpty) await app.loadStudents();
      if (app.requests.isEmpty) await app.loadRequests();

      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // small grace for UX
    } catch (_) {
      // Optional: show a snackbar / ignore
    }

    if (!mounted) return;
    context.go('/'); // go to login
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              FadeTransition(
                opacity: _iconController,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _iconController,
                      curve: Curves.easeOutBack,
                    ),
                  ),
                  child: const Icon(Icons.school, size: 100),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              FadeTransition(
                opacity: _textController,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0.0, 0.5),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _textController,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: Text(
                    tr.schoolAppTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Dots
              AnimatedBuilder(
                animation: _dotsController,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final interval = Interval(i * 0.33, (i + 1) * 0.33);
                      final scaleValue = Tween<double>(
                        begin: 1.0,
                        end: 1.4,
                      ).transform(interval.transform(_dotsController.value));
                      final fadeValue = Tween<double>(
                        begin: 0.3,
                        end: 1.0,
                      ).transform(interval.transform(_dotsController.value));
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Opacity(
                          opacity: fadeValue,
                          child: Transform.scale(
                            scale: scaleValue,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
