// lib/core/state/app_state.dart
import 'dart:convert';
import 'package:edupass/core/models/pickupRequest.dart';
import 'package:edupass/core/models/student.dart';
import 'package:edupass/core/models/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edupass/core/models/domain_ids.dart';
import 'package:edupass/core/models/detail_ids.dart';

import 'package:edupass/core/models/lookup.dart';

import 'package:edupass/core/services/api_handler.dart';
import 'package:edupass/core/services/http_client.dart';

class AppState extends ChangeNotifier {
  // Use devInsecure for local backend with self-signed certs
  final ApiService api = ApiService(ApiHttpClient.devInsecure());
  AppState({String? token});

  // =========================
  // Locale
  // =========================
  Locale _locale = const Locale('ar');
  Locale get locale => _locale;
  void setLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }

  // =========================
  // Auth / Session (IDs)
  // =========================
  int? _currentRoleId; // LookupDomainDetailId (UserRole domain)
  int? _currentUserId; // Logged-in user id (UserApi.id)

  int? get currentRoleId => _currentRoleId;
  int? get currentUserId => _currentUserId;

  bool get isParent => _currentRoleId == DetailIds.parent;
  bool get isSupervisor => _currentRoleId == DetailIds.supervisor;
  bool get isAdmin => _currentRoleId == DetailIds.admin;

  /// Login by backend role detailId. Example: Parent=3, Supervisor=4, Admin=5.
  Future<void> loginAsRoleId(int roleDetailId) async {
    _currentRoleId = roleDetailId;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentRoleId', roleDetailId);
    } catch (_) {
      /* ignore */
    }
  }

  /// Optionally set the current authenticated user id (UserApi.id)
  Future<void> setCurrentUserId(int userId) async {
    _currentUserId = userId;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentUserId', userId);
    } catch (_) {
      /* ignore */
    }
  }

  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('currentRoleId')) {
        _currentRoleId = prefs.getInt('currentRoleId');
      }
      if (prefs.containsKey('currentUserId')) {
        _currentUserId = prefs.getInt('currentUserId');
      }
      notifyListeners();
    } catch (_) {
      /* ignore */
    }
  }

  Future<void> logout() async {
    _currentRoleId = null;
    _currentUserId = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentRoleId');
      await prefs.remove('currentUserId');
    } catch (_) {
      /* ignore */
    }
  }

  // =========================
  // Lookups (Domains & Details)
  // =========================
  final Map<int, LookupDomain> _domains = {}; // domainId -> domain
  final Map<int, String> _detailAr = {}; // detailId -> Arabic
  final Map<int, String> _detailEn = {}; // detailId -> English

  bool get lookupsLoaded =>
      _domains.containsKey(DomainIds.gender) &&
      _domains.containsKey(DomainIds.userRole) &&
      _domains.containsKey(DomainIds.requestType) &&
      _domains.containsKey(DomainIds.requestStatus) &&
      _domains.containsKey(DomainIds.pickupReasons);

  Future<void> loadLookups() async {
    final ids = <int>[
      DomainIds.gender,
      DomainIds.userRole,
      DomainIds.requestType,
      DomainIds.requestStatus,
      DomainIds.pickupReasons,
      // DomainIds.gradeLevel, DomainIds.schoolShift, DomainIds.notificationType, DomainIds.vehicleType,
    ];
    for (final id in ids) {
      final domain = await api.getLookupDomainById(id);
      _domains[id] = domain;
      for (final d in domain.domainDetails) {
        _detailAr[d.lookupDomainDetailId] = d.detailNameArabic;
        _detailEn[d.lookupDomainDetailId] = d.detailNameEnglish;
      }
    }
    notifyListeners();
  }

  List<LookupDomainDetail> detailsOfDomain(int domainId) {
    return _domains[domainId]?.domainDetails ?? const [];
  }

  /// Localized detail name from detailId
  String detailName(int detailId) {
    return (_locale.languageCode == 'ar'
            ? _detailAr[detailId]
            : _detailEn[detailId]) ??
        '-';
  }

  /// Find detailId by **English** name within a domain
  int? findDetailIdByEnglish(int domainId, String englishName) {
    final list = detailsOfDomain(domainId);
    final match = list.where(
      (d) => d.detailNameEnglish.toLowerCase() == englishName.toLowerCase(),
    );
    if (match.isEmpty) return null;
    return match.first.lookupDomainDetailId;
  }

  // =========================
  // Students (API-backed)
  // =========================
  List<StudentApi> students = [];

  Future<void> loadStudents() async {
    try {
      students = await api.getStudents(); // GET /student/all
      notifyListeners();
    } catch (e) {
      // Optional: keep a local fallback if you have one
    }
  }

  Future<void> addStudent(StudentApi s) async {
    await api.addStudent(s); // enable when backend is ready
    students.add(s);
    notifyListeners();
  }

  // =========================
  // Users (API-backed)
  // =========================
  List<UserApi> users = [];

  Future<void> loadUsers() async {
    users = await api.getUsers();
    notifyListeners();
  }

  Future<void> addUser(UserApi user) async {
    await api.addUser(user);
    users.add(user);
    notifyListeners();
  }

  Future<void> updateUser(int id, UserApi updated) async {
    // await api.updateUser(id, updated);
    final i = users.indexWhere((u) => u.id == id);
    if (i != -1) {
      users[i] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteUser(int id) async {
    await api.deleteUser(id);
    users.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  String? userNameById(int userId) {
    final u = users.firstWhere(
      (e) => e.id == userId,
      orElse: () => UserApi(id: -1, name: '', roleId: DetailIds.parent),
    );
    return u.id == -1 ? null : u.name;
  }

  // =========================
  // Requests (API-backed + Cache)
  // =========================
  List<PickupRequestApi> requests = [];

  static const _kRequestsCacheKey = 'requests_cache';

  // lib/core/state/app_state.dart (inside AppState)

  Future<void> loadRequests() async {
    // ✅ Real backend
    try {
      requests = await api.getRequests(); // GET /requests/all
      notifyListeners();
      await saveRequests(); // keep local cache fresh
    } catch (e) {
      // Fallback to cache if API fails
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kRequestsCacheKey);
      if (raw != null) {
        try {
          final decoded = jsonDecode(raw) as List;
          requests = decoded
              .map((m) => PickupRequestApi.fromJson(m as Map<String, dynamic>))
              .toList();
          notifyListeners();
        } catch (_) {
          /* ignore */
        }
      }
    }
  }

  Future<void> saveRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = requests.map((r) => r.toJson()).toList();
    await prefs.setString(_kRequestsCacheKey, jsonEncode(jsonList));
  }

  /// Add a new pickup request (posts to backend then updates local state)
  Future<void> addRequest(PickupRequestApi request) async {
    try {
      // ✅ Post to backend; server may override id/exitTime/etc.
      final created = await api.addRequest(request); // POST /requests/add

      // Update local state with the server response
      requests.add(created);
      notifyListeners();

      // Persist cache for offline
      await saveRequests();
    } catch (e) {
      // If backend fails, rethrow so UI can display an error
      rethrow;
    }
  }

  /// Cancel (delete) a pending request
  Future<void> cancelRequest(int requestId) async {
    try {
      await api.deleteRequest(requestId);
    } catch (_) {
      // ignore API errors for optimistic UX
    }
    requests.removeWhere((r) => r.id == requestId);
    notifyListeners();
    await saveRequests();
  }

  /// Update request status (e.g. Approved/Rejected/Completed)
  Future<void> updateRequestStatus({
    required int requestId,
    required int newStatusId,
    DateTime? exitTimeUtc,
  }) async {
    try {
      await api.updateRequestStatus(requestId, newStatusId);
    } catch (_) {
      // ignore API errors for optimistic UX
    }

    final i = requests.indexWhere((r) => r.id == requestId);
    if (i != -1) {
      final old = requests[i];
      requests[i] = old.copyWith(
        statusId: newStatusId,
        exitTime: exitTimeUtc ?? (old.exitTime),
      );
      notifyListeners();
      await saveRequests();
    }
  }

  Future<void> updateRequestStatusId(int requestId, int statusDetailId) async {
    final server = await api.updateRequestStatusAuto(requestId, statusDetailId);

    final i = requests.indexWhere((r) => r.id == requestId);
    if (i == -1) return;
    requests[i] = server; // trust server (includes exitTime if completed)
    notifyListeners();
    await saveRequests();
  }

  Future<void> clearRequests() async {
    requests.clear();
    notifyListeners();
    await saveRequests();
  }

  // =========================
  // Bulk loaders
  // =========================
  Future<void> loadAll() async {
    await Future.wait([
      loadLookups(),
      loadStudents(),
      loadUsers(),
      loadRequests(),
    ]);
  }
}
