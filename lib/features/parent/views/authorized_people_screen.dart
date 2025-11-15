// lib/features/parent/views/authorized_people_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edupass/core/state/app_state.dart';
import 'package:edupass/core/models/authorized_person.dart';
import 'package:edupass/l10n/app_localizations.dart';

class AuthorizedPeopleScreen extends StatefulWidget {
  final int parentUserId;
  const AuthorizedPeopleScreen({super.key, required this.parentUserId});

  @override
  State<AuthorizedPeopleScreen> createState() => _AuthorizedPeopleScreenState();
}

class _AuthorizedPeopleScreenState extends State<AuthorizedPeopleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _nid = TextEditingController();
  int? _studentId;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _nid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final app = context.watch<AppState>();

    // Try to get only the parent's kids if AppState supports it; else fallback to all students.
    List<dynamic> _studentsForParent() {
      try {
        final dyn = app as dynamic;
        final fn = dyn.studentsOfParent;
        if (fn is Function) {
          final res = fn(widget.parentUserId);
          if (res is List) return res;
        }
      } catch (_) {}
      return app.students;
    }

    final students = _studentsForParent();
    final mine = app.authorizedPeople
        .where((p) => p.parentUserId == widget.parentUserId)
        .toList();

    // Make a map id->name for quick lookups
    final idToName = <int, String>{
      for (final s in students)
        (s as dynamic).id as int: (s as dynamic).name as String,
    };

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr.authorizedPeopleTitle),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // List of authorized people
            Expanded(
              child: mine.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_user_outlined,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  tr.authorizedPeopleTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tr.authorizedPeopleSubtitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      itemCount: mine.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final p = mine[i];
                        final studentName =
                            idToName[p.studentId] ?? '#${p.studentId}';
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: const CircleAvatar(
                              child: Icon(Icons.badge_outlined),
                            ),
                            title: Text(p.fullName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('${tr.studentName}: $studentName'),
                                if (p.phone.trim().isNotEmpty)
                                  Text('${tr.phone}: ${p.phone}'),
                                if (p.nationalId.trim().isNotEmpty)
                                  Text('${tr.nationalId}: ${p.nationalId}'),
                              ],
                            ),
                            trailing: IconButton(
                              tooltip: tr.delete,
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                final ok = await _confirmDelete(
                                  context,
                                  p.fullName,
                                  tr,
                                );
                                if (ok == true) {
                                  await context
                                      .read<AppState>()
                                      .removeAuthorizedPerson(p.id);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(tr.deletedSuccess)),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const Divider(height: 1),

            // Add form
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: tr.studentName,
                            prefixIcon: const Icon(Icons.school_outlined),
                          ),
                          value: _studentId,
                          items: students
                              .map(
                                (s) => DropdownMenuItem<int>(
                                  value: (s as dynamic).id as int,
                                  child: Text((s as dynamic).name as String),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _studentId = v),
                          validator: (v) => v == null ? tr.required : null,
                          isExpanded: true,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _name,
                          decoration: InputDecoration(
                            labelText: tr.fullName,
                            prefixIcon: const Icon(Icons.person_outlined),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? tr.required
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: tr.phone,
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _nid,
                          decoration: InputDecoration(
                            labelText: tr.nationalId,
                            prefixIcon: const Icon(Icons.credit_card_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.person_add_alt_1),
                            label: Text(tr.addAuthorizedPerson),
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;
                              final app = context.read<AppState>();

                              // Robust next-id
                              final nextId = app.authorizedPeople.isEmpty
                                  ? 1
                                  : (app.authorizedPeople
                                            .map((e) => e.id)
                                            .reduce((a, b) => a > b ? a : b) +
                                        1);

                              await app.addAuthorizedPerson(
                                AuthorizedPickupPersonApi(
                                  id: nextId,
                                  parentUserId: widget.parentUserId,
                                  studentId: _studentId!,
                                  fullName: _name.text.trim(),
                                  phone: _phone.text.trim(),
                                  nationalId: _nid.text.trim(),
                                ),
                              );

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(tr.addedSuccess)),
                              );

                              _name.clear();
                              _phone.clear();
                              _nid.clear();
                              setState(() {
                                _studentId = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    String name,
    AppLocalizations tr,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr.delete),
        content: Text(tr.deleteConfirmName(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(tr.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(tr.delete),
          ),
        ],
      ),
    );
  }
}
