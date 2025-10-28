// lib/features/shared/views/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // لدعم اللغة العربية
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اختر نوع المستخدم'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              RoleCard(
                icon: Icons.family_restroom,
                title: 'ولي الأمر / السائق',
                onTap: () => context.go('/parent'),
              ),
              const SizedBox(height: 16),
              RoleCard(
                icon: Icons.school,
                title: 'المعلمة / المشرفة',
                onTap: () => context.go('/supervisor'),
              ),
              const SizedBox(height: 16),
              RoleCard(
                icon: Icons.admin_panel_settings,
                title: 'الإدارة',
                onTap: () => context.go('/admin'),
              ),
              RoleCard(
                icon: Icons.shield,
                title: 'بوابة المدرسة',
                onTap: () => context.go('/gate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 36),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
