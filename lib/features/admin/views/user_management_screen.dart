import 'package:edupass/core/models/user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/state/app_state.dart';
import '../../../core/models/domain_ids.dart'; // ✅ DomainIds.userRole
import '../../../l10n/app_localizations.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  int? filterRoleId;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tr = AppLocalizations.of(context)!;

    final users =
        appState.users; // List<UserApi> exposed by AppState (see notes)
    final roles = appState.detailsOfDomain(
      DomainIds.userRole,
    ); // lookup details

    final filteredUsers = users.where((u) {
      final matchesRole = filterRoleId == null || u.roleId == filterRoleId;
      final matchesQuery = searchQuery.isEmpty || u.name.contains(searchQuery);
      return matchesRole && matchesQuery;
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => context.canPop() ? context.pop() : context.go('/'),
          ),
          title: Text(tr.userManagement),
          actions: [
            PopupMenuButton<int?>(
              onSelected: (roleId) => setState(() => filterRoleId = roleId),
              itemBuilder: (_) => [
                PopupMenuItem<int?>(value: null, child: Text(tr.all)),
                ...roles.map(
                  (d) => PopupMenuItem<int?>(
                    value: d.lookupDomainDetailId,
                    child: Text(appState.detailName(d.lookupDomainDetailId)),
                  ),
                ),
              ],
              icon: const Icon(Icons.filter_alt),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  labelText: tr.search,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (v) => setState(() => searchQuery = v),
              ),
            ),
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(child: Text(tr.noUsers))
                  : ListView.builder(
                      itemCount: filteredUsers.length,
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (_, index) {
                        final user = filteredUsers[index];
                        final roleName = appState.detailName(user.roleId);

                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(user.name),
                            subtitle: Text('${tr.role}: $roleName'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _editUserDialog(context, user),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await appState.deleteUser(user.id);
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${tr.userDeleted} ${user.name}',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ).animate().fade().slideY(begin: 0.1);
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddUserDialog(context),
          icon: const Icon(Icons.person_add),
          label: Text(tr.addUser),
        ),
      ),
    );
  }

  void _editUserDialog(BuildContext context, UserApi user) {
    final tr = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: user.name);
    int selectedRoleId = user.roleId;
    final appState = context.read<AppState>();
    final roles = appState.detailsOfDomain(DomainIds.userRole);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr.editUser),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: tr.name),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: selectedRoleId,
              onChanged: (roleId) => selectedRoleId = roleId ?? selectedRoleId,
              decoration: InputDecoration(labelText: tr.role),
              items: roles
                  .map(
                    (d) => DropdownMenuItem<int>(
                      value: d.lookupDomainDetailId,
                      child: Text(appState.detailName(d.lookupDomainDetailId)),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = user.copyWith(
                name: nameController.text.trim(),
                roleId: selectedRoleId,
              );
              await context.read<AppState>().updateUser(user.id, updated);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${tr.userUpdated} ${updated.name}')),
              );
            },
            child: Text(tr.save),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final appState = context.read<AppState>();
    final roles = appState.detailsOfDomain(DomainIds.userRole);

    final nameController = TextEditingController();
    int? selectedRoleId = roles.isNotEmpty
        ? roles.first.lookupDomainDetailId
        : null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr.addUser),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: tr.name),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: selectedRoleId,
              onChanged: (roleId) => selectedRoleId = roleId,
              decoration: InputDecoration(labelText: tr.role),
              items: roles
                  .map(
                    (d) => DropdownMenuItem<int>(
                      value: d.lookupDomainDetailId,
                      child: Text(appState.detailName(d.lookupDomainDetailId)),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty || selectedRoleId == null) return;

              final newUser = UserApi(
                id: DateTime.now().millisecondsSinceEpoch, // temporary local id
                name: name,
                roleId: selectedRoleId!,
              );

              await context.read<AppState>().addUser(newUser);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(tr.userAdded)));
            },
            child: Text(tr.add),
          ),
        ],
      ),
    );
  }
}
