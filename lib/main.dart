// lib/main.dart
import 'package:edupass/features/admin/views/admin_dashboard_screen.dart';
import 'package:edupass/features/admin/views/bus_enrollment_management_screen.dart';
import 'package:edupass/features/admin/views/user_management_screen.dart';
import 'package:edupass/features/auth/views/login_screen.dart';
import 'package:edupass/features/parent/views/add_student_screen.dart';
import 'package:edupass/features/parent/views/parent_main_screen.dart';
import 'package:edupass/features/school/views/admin_panel_screen.dart';
import 'package:edupass/features/school/views/gate_supervisor_screen.dart';
import 'package:edupass/features/school/views/qr_scan_screen.dart';
import 'package:edupass/features/school/views/smart_display_screen.dart';
import 'package:edupass/features/school/views/supervisor_home_screen.dart';
import 'package:edupass/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/state/app_state.dart';
import 'features/auth/views/splash_screen.dart';

// 🔹 NEW: imports for new feature screens
import 'package:edupass/features/admin/views/bus_management_screen.dart';
import 'package:edupass/features/school/views/supervisor_bus_assign_screen.dart';
import 'package:edupass/features/parent/views/bus_join_screen.dart';
import 'package:edupass/features/parent/views/authorized_people_screen.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  // ❌ Don’t preload here, let Splash do it to avoid double loads + rebuilds
  runApp(
    ChangeNotifierProvider(create: (_) => appState, child: const SchoolApp()),
  );
}

class SchoolApp extends StatefulWidget {
  const SchoolApp({Key? key}) : super(key: key);

  @override
  State<SchoolApp> createState() => _SchoolAppState();
}

class _SchoolAppState extends State<SchoolApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/', builder: (_, __) => const LoginScreen()),

        // Parent area
        GoRoute(path: '/parent', builder: (_, __) => const ParentMainScreen()),
        GoRoute(
          path: '/add-student',
          builder: (_, __) => const AddStudentScreen(),
        ),

        // Supervisor area
        GoRoute(
          path: '/supervisor',
          builder: (_, __) => const SupervisorHomeScreen(),
        ),
        GoRoute(
          path: '/gate',
          builder: (_, __) => const GateSupervisorScreen(),
        ),
        GoRoute(path: '/scan', builder: (_, __) => const GateQrScannerScreen()),
        GoRoute(
          path: '/display',
          builder: (_, __) => const SmartDisplayScreen(),
        ),

        // Admin area
        GoRoute(
          path: '/admin',
          builder: (_, __) => const AdminDashboardScreen(),
        ),
        GoRoute(path: '/panel', builder: (_, __) => const AdminPanelScreen()),
        GoRoute(
          path: '/users',
          builder: (_, __) => const UserManagementScreen(),
        ),

        // 🔹 NEW: Buses and related flows
        GoRoute(
          path: '/buses',
          builder: (_, __) => const BusManagementScreen(),
        ),
        GoRoute(
          path: '/assign-bus',
          builder: (_, __) => const SupervisorBusAssignScreen(),
        ),

        // NOTE: replace the hardcoded `1` with the actual logged-in parent id from your auth state when available.
        GoRoute(
          path: '/parent-buses',
          builder: (_, __) => const ParentBusJoinScreen(parentUserId: 1),
        ),
        GoRoute(
          path: '/auth-people',
          builder: (_, __) => const AuthorizedPeopleScreen(parentUserId: 1),
        ),

        GoRoute(
          path: '/bus-requests',
          builder: (_, __) => const BusEnrollmentManagementScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context
        .watch<AppState>()
        .locale; // rebuilds MaterialApp, not the router
    return MaterialApp.router(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      locale: locale,
      title: 'School Dismissal MVP',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        fontFamily: 'Tajawal',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      routerConfig: _router, // ✅ stable router instance
    );
  }
}
