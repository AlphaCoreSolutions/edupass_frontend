// lib/features/auth/views/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/state/app_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/models/detail_ids.dart'; // backend role IDs
import '../../../core/models/user.dart'; // UserApi

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  int _selectedRoleId = DetailIds.parent; // default tab = Parent
  UserApi? _selectedUser;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    final appState = context.read<AppState>();
    try {
      await appState.loadLookups(); // optional, but good to have early
      await appState.loadUsers(); // load users for picker
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _routeForRole(BuildContext context, int roleId) {
    switch (roleId) {
      case DetailIds.parent:
        context.go('/parent');
        break;
      case DetailIds.supervisor:
        context.go('/supervisor');
        break;
      case DetailIds.admin:
        context.go('/admin');
        break;
      default:
        context.go('/');
    }
  }

  Future<void> _loginWithUser(BuildContext context, UserApi user) async {
    final appState = context.read<AppState>();
    await appState.loginAsRoleId(user.roleId);
    appState.setCurrentUserId(user.id);
    _routeForRole(context, user.roleId);
  }

  Future<void> _loginWithRoleOnly(BuildContext context, int roleId) async {
    final appState = context.read<AppState>();
    await appState.loginAsRoleId(roleId);
    appState.setCurrentUserId(-1); // anonymous / no user selected
    _routeForRole(context, roleId);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tr = AppLocalizations.of(context)!;

    final users = appState.users;
    final filteredUsers = users
        .where((u) => u.roleId == _selectedRoleId)
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      Column(
                        children: [
                          Icon(
                            Icons.school,
                            size: 100,
                            color: Colors.teal,
                          ).animate().fadeIn().scale(),
                          const SizedBox(height: 16),
                          Text(
                            'EduPass',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                          ).animate().fadeIn().slideY(begin: 0.5),
                          const SizedBox(height: 8),
                          Text(tr.loginSelectRole).animate().fadeIn().slideY(
                            begin: 0.5,
                            delay: 200.ms,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Role segmented selector
                      _RoleSegmented(
                        value: _selectedRoleId,
                        onChanged: (v) {
                          setState(() {
                            _selectedRoleId = v;
                            _selectedUser = null;
                          });
                        },
                      ).animate().fadeIn(delay: 250.ms),

                      const SizedBox(height: 12),

                      // Users dropdown (filtered by role)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.teal,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<UserApi>(
                                  value: _selectedUser,
                                  isExpanded: true,
                                  hint: Text(tr.selectUser),
                                  items: filteredUsers
                                      .map(
                                        (u) => DropdownMenuItem(
                                          value: u,
                                          child: Text(u.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (u) =>
                                      setState(() => _selectedUser = u),
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: tr.refresh,
                              onPressed: () async {
                                setState(() => _loading = true);
                                try {
                                  await context.read<AppState>().loadUsers();
                                } finally {
                                  if (mounted) setState(() => _loading = false);
                                }
                              },
                              icon: const Icon(Icons.refresh, size: 18),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 350.ms),

                      const SizedBox(height: 12),

                      // Login buttons
                      ElevatedButton.icon(
                        onPressed: _selectedUser == null
                            ? null
                            : () => _loginWithUser(context, _selectedUser!),
                        icon: const Icon(Icons.login),
                        label: Text(tr.login),
                      ).animate().fadeIn(delay: 450.ms),

                      const SizedBox(height: 8),

                      TextButton(
                        onPressed: () =>
                            _loginWithRoleOnly(context, _selectedRoleId),
                        child: Text(tr.continueWithoutAccount),
                      ).animate().fadeIn(delay: 550.ms),

                      const SizedBox(height: 16),

                      // Gate (no login role)
                      OutlinedButton.icon(
                        onPressed: () => context.go('/gate'),
                        icon: const Icon(Icons.door_front_door),
                        label: Text(tr.roleGate),
                      ).animate().fadeIn(delay: 650.ms),

                      const SizedBox(height: 24),

                      // Language switcher (compact)
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.language,
                                size: 16,
                                color: Colors.teal,
                              ),
                              const SizedBox(width: 8),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<Locale>(
                                  value: appState.locale,
                                  icon: const Icon(Icons.expand_more, size: 16),
                                  style: const TextStyle(fontSize: 13),
                                  borderRadius: BorderRadius.circular(10),
                                  items: [
                                    DropdownMenuItem(
                                      value: const Locale('ar'),
                                      child: Text(tr.languageArabic),
                                    ),
                                    DropdownMenuItem(
                                      value: const Locale('en'),
                                      child: Text(tr.languageEnglish),
                                    ),
                                  ],
                                  onChanged: (locale) {
                                    if (locale != null)
                                      appState.setLocale(locale);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 750.ms),
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _RoleSegmented extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _RoleSegmented({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, c) {
        return Row(
          children: [
            _seg(
              context,
              label: tr.roleParent,
              selected: value == DetailIds.parent,
              onTap: () => onChanged(DetailIds.parent),
            ),
            const SizedBox(width: 8),
            _seg(
              context,
              label: tr.roleSupervisor,
              selected: value == DetailIds.supervisor,
              onTap: () => onChanged(DetailIds.supervisor),
            ),
            const SizedBox(width: 8),
            _seg(
              context,
              label: tr.roleAdmin,
              selected: value == DetailIds.admin,
              onTap: () => onChanged(DetailIds.admin),
            ),
          ],
        );
      },
    );
  }

  Widget _seg(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.teal : Colors.teal.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.teal.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
