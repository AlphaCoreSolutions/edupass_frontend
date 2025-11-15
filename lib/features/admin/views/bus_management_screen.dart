// lib/features/admin/views/bus_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edupass/core/state/app_state.dart';
import 'package:edupass/core/models/bus.dart';
import 'package:edupass/core/models/user.dart'; // UserApi
import 'package:edupass/l10n/app_localizations.dart';

class BusManagementScreen extends StatefulWidget {
  const BusManagementScreen({super.key});
  @override
  State<BusManagementScreen> createState() => _BusManagementScreenState();
}

class _BusManagementScreenState extends State<BusManagementScreen> {
  final _formKey = GlobalKey<FormState>();

  // form controllers
  final _name = TextEditingController();
  final _neigh = TextEditingController();
  final _route = TextEditingController();
  final _pickup = TextEditingController(text: '14:30'); // return home
  final _drop = TextEditingController(text: '06:45'); // go to school
  final _fee = TextEditingController(text: '150');
  final _supervisorId = TextEditingController(
    text: '',
  ); // kept in sync by dropdown

  // selected weekdays (stored as EN codes)
  final Set<String> _days = {'Sun', 'Mon', 'Tue', 'Wed', 'Thu'};

  // edit mode
  int? _editingBusId;

  // supervisor dropdown state
  int? _selectedSupervisorId;
  List<_UserOption> _supervisors = [];
  bool _loadingSupervisors = false;
  String? _supervisorsError;

  // helpers
  int _nextId(AppState s) => s.buses.isEmpty
      ? 1
      : (s.buses.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSupervisors());
  }

  @override
  void dispose() {
    _name.dispose();
    _neigh.dispose();
    _route.dispose();
    _pickup.dispose();
    _drop.dispose();
    _fee.dispose();
    _supervisorId.dispose();
    super.dispose();
  }

  // compact error text like: "ApiException(400)"
  String _shortError(String raw) {
    final s = raw.replaceAll('\n', ' ').trim();
    final match = RegExp(r'ApiException\(\d+\)').firstMatch(s);
    if (match != null) return match.group(0)!;
    final httpIdx = s.indexOf('http');
    final core = httpIdx > 0 ? s.substring(0, httpIdx).trim() : s;
    return core.length > 80 ? '${core.substring(0, 80)}…' : core;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tr = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(tr.busManageTitle), centerTitle: true),
        body: CustomScrollView(
          slivers: [
            // List header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.directions_bus_filled_outlined),
                    const SizedBox(width: 8),
                    Text(
                      '${tr.addedBuses} (${app.buses.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bus list
            if (app.buses.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: _EmptyState(
                    icon: Icons.directions_bus_outlined,
                    title: tr.noBuses,
                    subtitle: tr.addBusHint,
                  ),
                ),
              )
            else
              SliverList.builder(
                itemCount: app.buses.length,
                itemBuilder: (_, i) {
                  final b = app.buses[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _loadForEdit(b),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CircleAvatar(
                                child: Icon(Icons.directions_bus),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            b.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        _Pill(
                                          text: b.neighborhood.isEmpty
                                              ? '-'
                                              : b.neighborhood,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        _InfoPill(
                                          icon: Icons.calendar_today_outlined,
                                          text: _prettyDays(b.weekdays),
                                        ),
                                        _InfoPill(
                                          icon: Icons.school_outlined,
                                          text:
                                              '${tr.busGoTime} ${b.dropoffTime}',
                                        ),
                                        _InfoPill(
                                          icon: Icons.home_outlined,
                                          text:
                                              '${tr.busReturnTime} ${b.pickupTime}',
                                        ),
                                        _InfoPill(
                                          icon: Icons.badge_outlined,
                                          text:
                                              '${tr.supervisorId}: #${b.supervisorUserId}',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.payments_outlined,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${b.monthlyFee.toStringAsFixed(0)} ${tr.monthlyFeeShort}',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                children: [
                                  IconButton(
                                    tooltip: tr.edit,
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => _loadForEdit(b),
                                  ),
                                  IconButton(
                                    tooltip: tr.delete,
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final ok = await _confirmDelete(
                                        context,
                                        b.name,
                                      );
                                      if (ok == true)
                                        context.read<AppState>().deleteBus(
                                          b.id,
                                        );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Form header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Row(
                  children: [
                    Icon(
                      _editingBusId == null
                          ? Icons.add_road_outlined
                          : Icons.edit_road_outlined,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _editingBusId == null ? tr.addBus : tr.editBus,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_editingBusId != null) ...[
                      const SizedBox(width: 8),
                      _Tag(text: tr.editMode),
                    ],
                  ],
                ),
              ),
            ),

            // Form
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
                          TextFormField(
                            controller: _name,
                            decoration: InputDecoration(
                              labelText: tr.busName,
                              prefixIcon: const Icon(
                                Icons.directions_bus_filled,
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? tr.required
                                : null,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _neigh,
                            decoration: InputDecoration(
                              labelText: tr.neighborhood,
                              prefixIcon: const Icon(
                                Icons.location_on_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _route,
                            decoration: InputDecoration(
                              labelText: tr.routeDescription,
                              prefixIcon: const Icon(Icons.alt_route_outlined),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 12),

                          // Days chips
                          Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: weekdayOptions(tr).entries.map((e) {
                                final code = e.key; // "Sun"
                                final label = e.value; // localized
                                final sel = _days.contains(code);
                                return ChoiceChip(
                                  label: Text(label),
                                  selected: sel,
                                  onSelected: (v) => setState(
                                    () => v
                                        ? _days.add(code)
                                        : _days.remove(code),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _drop,
                                  readOnly: true,
                                  onTap: () => _pickTime(_drop),
                                  decoration: InputDecoration(
                                    labelText: tr.goTimeLabel,
                                    prefixIcon: const Icon(
                                      Icons.school_outlined,
                                    ),
                                  ),
                                  validator: _validateTime,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _pickup,
                                  readOnly: true,
                                  onTap: () => _pickTime(_pickup),
                                  decoration: InputDecoration(
                                    labelText: tr.returnTimeLabel,
                                    prefixIcon: const Icon(Icons.home_outlined),
                                  ),
                                  validator: _validateTime,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _fee,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: tr.monthlyFee,
                                    prefixIcon: const Icon(
                                      Icons.payments_outlined,
                                    ),
                                    suffixText: tr.currencySarShort,
                                  ),
                                  validator: (v) {
                                    final n = double.tryParse(v?.trim() ?? '');
                                    if (n == null || n < 0)
                                      return tr.invalidValue;
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),

                              // ==== Supervisor dropdown (no manual entry) ====
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (_loadingSupervisors)
                                      InputDecorator(
                                        decoration: InputDecoration(
                                          labelText: tr.busSupervisorId,
                                          prefixIcon: const Icon(
                                            Icons.badge_outlined,
                                          ),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: LinearProgressIndicator(),
                                        ),
                                      )
                                    else
                                      DropdownButtonFormField<int>(
                                        value:
                                            _supervisors.any(
                                              (o) =>
                                                  o.id == _selectedSupervisorId,
                                            )
                                            ? _selectedSupervisorId
                                            : null, // ensure value in items
                                        decoration: InputDecoration(
                                          labelText: tr.busSupervisorId,
                                          prefixIcon: const Icon(
                                            Icons.badge_outlined,
                                          ),
                                        ),
                                        items: _supervisors
                                            .map(
                                              (u) => DropdownMenuItem<int>(
                                                value: u.id,
                                                child: Text(
                                                  '${u.label} (#${u.id})',
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (v) {
                                          setState(() {
                                            _selectedSupervisorId = v;
                                            _supervisorId.text = (v ?? 0)
                                                .toString();
                                          });
                                        },
                                        validator: (v) {
                                          if (!_loadingSupervisors &&
                                              (_supervisors.isEmpty ||
                                                  v == null)) {
                                            return tr
                                                .required; // force a choice
                                          }
                                          return null;
                                        },
                                        isExpanded: true,
                                      ),

                                    // error / helper row
                                    if (_supervisorsError != null) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          TextButton.icon(
                                            onPressed: _loadSupervisors,
                                            icon: const Icon(Icons.refresh),
                                            label: Text(tr.refresh),
                                          ),
                                          const Spacer(),
                                          const Icon(
                                            Icons.error_outline,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              _shortError(_supervisorsError!),
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 12.5,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ] else if (!_loadingSupervisors &&
                                        _supervisors.isEmpty) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          TextButton.icon(
                                            onPressed: _loadSupervisors,
                                            icon: const Icon(Icons.refresh),
                                            label: Text(tr.refresh),
                                          ),
                                          const Spacer(),
                                          Text(
                                            tr.noResults, // add to ARB: "لا توجد بيانات"
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  icon: Icon(
                                    _editingBusId == null
                                        ? Icons.add_circle_outline
                                        : Icons.save_outlined,
                                  ),
                                  label: Text(
                                    _editingBusId == null
                                        ? tr.addBus
                                        : tr.saveChanges,
                                  ),
                                  onPressed: () async {
                                    if (!_formKey.currentState!.validate())
                                      return;
                                    if (_days.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(tr.selectOperatingDays),
                                        ),
                                      );
                                      return;
                                    }
                                    final app = context.read<AppState>();
                                    final bus = BusApi(
                                      id: _editingBusId ?? _nextId(app),
                                      name: _name.text.trim(),
                                      neighborhood: _neigh.text.trim(),
                                      routeDescription: _route.text.trim(),
                                      weekdays: _days.toList(),
                                      pickupTime: _pickup.text.trim(),
                                      dropoffTime: _drop.text.trim(),
                                      monthlyFee:
                                          double.tryParse(_fee.text.trim()) ??
                                          0,
                                      supervisorUserId:
                                          _selectedSupervisorId ?? 0,
                                    );
                                    await app.addOrUpdateBus(bus);
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          _editingBusId == null
                                              ? tr.addedSuccess
                                              : tr.savedSuccess,
                                        ),
                                      ),
                                    );
                                    _clearForm();
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.clear_all_outlined),
                                  label: Text(tr.clearForm),
                                  onPressed: _clearForm,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  // ==== Load supervisors from API (typed: List<UserApi>) ====
  Future<void> _loadSupervisors() async {
    setState(() {
      _loadingSupervisors = true;
      _supervisorsError = null;
    });

    try {
      final app = context.read<AppState>();
      final List<UserApi> res = await app.searchUsers(
        'select * from Users where roleId = 4',
      );

      final opts =
          res
              .where((u) => u.roleId == 4)
              .map((u) => _UserOption(u.id, u.name))
              .toList()
            ..sort(
              (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
            );

      // keep current selection (edit) even if not returned
      final int? initial = int.tryParse(_supervisorId.text.trim());
      if (initial != null && !opts.any((o) => o.id == initial)) {
        opts.insert(0, _UserOption(initial, '#$initial'));
      }

      setState(() {
        _supervisors = opts;
        // ensure value is one of items or null
        _selectedSupervisorId =
            (initial != null && opts.any((o) => o.id == initial))
            ? initial
            : (opts.isNotEmpty ? opts.first.id : null);
        _supervisorId.text = _selectedSupervisorId?.toString() ?? '';
      });
    } catch (e) {
      setState(() {
        _supervisorsError = _shortError(e.toString());
        _supervisors = []; // no items when error
        _selectedSupervisorId = null; // keep value consistent with items
        _supervisorId.text = '';
      });
    } finally {
      if (mounted) setState(() => _loadingSupervisors = false);
    }
  }

  // ==== Helpers ====

  Future<void> _pickTime(TextEditingController controller) async {
    final now = TimeOfDay.now();
    final parts = controller.text.split(':');
    TimeOfDay initial = now;
    if (parts.length == 2) {
      final h = int.tryParse(parts[0]) ?? now.hour;
      final m = int.tryParse(parts[1]) ?? now.minute;
      initial = TimeOfDay(hour: h, minute: m);
    }
    final tr = AppLocalizations.of(context)!;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: tr.pickTime,
      builder: (ctx, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked != null) {
      final hh = picked.hour.toString().padLeft(2, '0');
      final mm = picked.minute.toString().padLeft(2, '0');
      controller.text = '$hh:$mm';
      setState(() {});
    }
  }

  String? _validateTime(String? v) {
    final tr = AppLocalizations.of(context)!;
    final s = v?.trim() ?? '';
    final re = RegExp(r'^\d{2}:\d{2}$');
    if (!re.hasMatch(s)) return tr.invalidTimeFormat;
    final hh = int.tryParse(s.substring(0, 2)) ?? -1;
    final mm = int.tryParse(s.substring(3, 5)) ?? -1;
    if (hh < 0 || hh > 23 || mm < 0 || mm > 59) return tr.invalidTime;
    return null;
  }

  Future<bool?> _confirmDelete(BuildContext context, String name) async {
    final tr = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr.deleteBusTitle),
        content: Text(tr.deleteBusConfirm(name)),
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

  void _loadForEdit(BusApi b) {
    final tr = AppLocalizations.of(context)!;
    setState(() {
      _editingBusId = b.id;
      _name.text = b.name;
      _neigh.text = b.neighborhood;
      _route.text = b.routeDescription;
      _pickup.text = b.pickupTime;
      _drop.text = b.dropoffTime;
      _fee.text = b.monthlyFee.toStringAsFixed(0);
      _supervisorId.text = b.supervisorUserId.toString();
      _days
        ..clear()
        ..addAll(b.weekdays);

      // sync dropdown
      _selectedSupervisorId = b.supervisorUserId;
      if (_supervisors.isNotEmpty &&
          !_supervisors.any((o) => o.id == b.supervisorUserId)) {
        _supervisors = [
          _UserOption(b.supervisorUserId, '#${b.supervisorUserId}'),
          ..._supervisors,
        ];
      }
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(tr.loadedForEdit)));
  }

  void _clearForm() {
    setState(() {
      _editingBusId = null;
      _name.clear();
      _neigh.clear();
      _route.clear();
      _pickup.text = '14:30';
      _drop.text = '06:45';
      _fee.text = '150';
      _selectedSupervisorId = null; // force re-pick
      _supervisorId.text = '';
      _days
        ..clear()
        ..addAll({'Sun', 'Mon', 'Tue', 'Wed', 'Thu'});
    });
  }

  String _prettyDays(List<String> codes) {
    final tr = AppLocalizations.of(context)!;
    final opts = weekdayOptions(tr);
    final labels = codes.map((c) => opts[c] ?? c).toList();
    return labels.join('، ');
  }
}

// ====== helpers / UI bits ======

class _UserOption {
  final int id;
  final String label;
  const _UserOption(this.id, this.label);
}

Map<String, String> weekdayOptions(AppLocalizations tr) => {
  'Sun': tr.weekdaySun,
  'Mon': tr.weekdayMon,
  'Tue': tr.weekdayTue,
  'Wed': tr.weekdayWed,
  'Thu': tr.weekdayThu,
  'Fri': tr.weekdayFri,
  'Sat': tr.weekdaySat,
};

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoPill({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 14), const SizedBox(width: 6), Text(text)],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const _EmptyState({required this.icon, required this.title, this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
