// lib/features/auth/views/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/state/app_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/models/detail_ids.dart'; // role detail IDs
import '../../../core/models/user.dart'; // UserApi

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // optional: preload lookups to localize roles/statuses ASAP
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadLookups();
    });
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
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

  Future<void> _login() async {
    final tr = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final app = context.read<AppState>();
      // This should call your backend: POST /auth/login -> returns token + user
      final UserApi me = await app.loginWithPassword(
        _username.text.trim(),
        _password.text,
      );

      // Save user id + role locally (AppState can also do this internally)
      await app.setCurrentUserId(me.id);
      await app.loginAsRoleId(me.roleId);

      if (!mounted) return;
      _routeForRole(context, me.roleId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr.invalidCredentials)));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tr = AppLocalizations.of(context)!;

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
                          Text(tr.pleaseLogin).animate().fadeIn().slideY(
                            begin: 0.5,
                            delay: 200.ms,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Login form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _username,
                              decoration: InputDecoration(
                                labelText: tr.username,
                                prefixIcon: const Icon(Icons.person_outline),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? tr.required
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _password,
                              decoration: InputDecoration(
                                labelText: tr.password,
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              obscureText: _obscure,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? tr.required : null,
                              onFieldSubmitted: (_) => _login(),
                            ),
                          ],
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Login button
                      FilledButton.icon(
                        onPressed: _login,
                        icon: const Icon(Icons.login),
                        label: Text(tr.login),
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 8),

                      // Gate shortcut
                      OutlinedButton.icon(
                        onPressed: () => context.go('/gate'),
                        icon: const Icon(Icons.door_front_door),
                        label: Text(tr.roleGate),
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 24),

                      // Language switcher
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
                        ).animate().fadeIn(delay: 500.ms),
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
