// lib/core/state/app_state.dart
import 'dart:convert';
import 'package:edupass/core/models/pickupRequest.dart';
import 'package:edupass/core/models/student.dart';
import 'package:edupass/core/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edupass/core/models/domain_ids.dart';
import 'package:edupass/core/models/detail_ids.dart';

import 'package:edupass/core/models/lookup.dart';

import 'package:edupass/core/services/api_handler.dart';
import 'package:edupass/core/services/http_client.dart';

import 'package:edupass/core/models/bus.dart';
import 'package:edupass/core/models/bus_enrollment.dart';
import 'package:edupass/core/models/authorized_person.dart';
import 'package:edupass/core/models/door_event.dart';

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

  Future<List<UserApi>> searchUsers(String sql) async {
    if (kDebugMode) {
      debugPrint('[searchUsers] ▶ query="$sql"');
    }

    final sw = Stopwatch()..start();
    try {
      final raw = await api.searchUsers(sql);

      if (kDebugMode) {
        debugPrint(
          '[searchUsers] ✔ http OK in ${sw.elapsedMilliseconds}ms • rows=${raw.length}',
        );
        if (raw.isNotEmpty) {
          // printing a single sample row to avoid flooding logs
          debugPrint('[searchUsers]   sample row: ${raw.first}');
        }
      }

      final users = <UserApi>[];
      for (final m in raw) {
        try {
          users.add(UserApi.fromJson(m));
        } catch (e, st) {
          if (kDebugMode) {
            debugPrint('[searchUsers] ⚠ map error: $e\npayload: $m');
            debugPrint('$st');
          }
          rethrow; // fail fast so you see invalid payloads
        }
      }

      if (kDebugMode) {
        final roleCounts = <int, int>{};
        for (final u in users) {
          roleCounts[u.roleId] = (roleCounts[u.roleId] ?? 0) + 1;
        }
        debugPrint(
          '[searchUsers] ✔ parsed=${users.length} • roleCounts=$roleCounts',
        );
      }

      return users;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[searchUsers] ✖ ERROR: $e');
        debugPrint('$st');
      }
      rethrow;
    } finally {
      if (kDebugMode) {
        debugPrint('[searchUsers] ⏱ done in ${sw.elapsedMilliseconds}ms');
      }
    }
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
  // Buses + Enrollment + Authorized + Door (Local cache)
  // =========================
  List<BusApi> buses = [];
  List<BusEnrollmentApi> busEnrollments = [];
  List<AuthorizedPickupPersonApi> authorizedPeople = [];
  List<DoorEventApi> doorEvents = [];

  static const _kBusesKey = 'cache_buses_v1';
  static const _kEnrollKey = 'cache_bus_enrollments_v1';
  static const _kAuthPeopleKey = 'cache_auth_people_v1';
  static const _kDoorKey = 'cache_door_events_v1';

  // ---- Buses ----

  Future<void> loadBuses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kBusesKey);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List)
            .map((e) => BusApi.fromJson(e as Map<String, dynamic>))
            .toList();
        buses = list;
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> saveBuses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kBusesKey,
      jsonEncode(buses.map((e) => e.toJson()).toList()),
    );
  }

  // ---- Bus Enrollments ----
  Future<void> loadBusEnrollments() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kEnrollKey);
    if (raw != null) {
      try {
        busEnrollments = (jsonDecode(raw) as List)
            .map((e) => BusEnrollmentApi.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> saveBusEnrollments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kEnrollKey,
      jsonEncode(busEnrollments.map((e) => e.toJson()).toList()),
    );
  }

  // ---- Authorized People ----
  Future<void> loadAuthorizedPeople() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kAuthPeopleKey);
    if (raw != null) {
      try {
        authorizedPeople = (jsonDecode(raw) as List)
            .map(
              (e) =>
                  AuthorizedPickupPersonApi.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> saveAuthorizedPeople() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kAuthPeopleKey,
      jsonEncode(authorizedPeople.map((e) => e.toJson()).toList()),
    );
  }

  // ---- Door Events ----
  Future<void> loadDoorEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kDoorKey);
    if (raw != null) {
      try {
        doorEvents = (jsonDecode(raw) as List)
            .map((e) => DoorEventApi.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> saveDoorEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kDoorKey,
      jsonEncode(doorEvents.map((e) => e.toJson()).toList()),
    );
  }

  // ========= Buses =========
  Future<void> addOrUpdateBus(BusApi bus) async {
    final i = buses.indexWhere((b) => b.id == bus.id);
    if (i == -1) {
      buses.add(bus);
    } else {
      buses[i] = bus;
    }
    notifyListeners();
    await saveBuses();
  }

  Future<void> deleteBus(int busId) async {
    buses.removeWhere((b) => b.id == busId);
    // cascade unenrollments for this bus
    busEnrollments.removeWhere((e) => e.busId == busId);
    notifyListeners();
    await saveBuses();
    await saveBusEnrollments();
  }

  // ======== Enrollments ========
  int _nextEnrollId() => busEnrollments.isEmpty
      ? 1
      : (busEnrollments.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);

  Future<BusEnrollmentApi> parentRequestJoinBus({
    required int studentId,
    required int busId,
    required int parentUserId,
  }) async {
    final e = BusEnrollmentApi(
      id: _nextEnrollId(),
      studentId: studentId,
      busId: busId,
      requestedById: parentUserId,
      requestedAt: DateTime.now().toUtc(),
      status: BusJoinStatus.pending,
    );
    busEnrollments.add(e);
    notifyListeners();
    await saveBusEnrollments();
    return e;
  }

  Future<void> supervisorApproveEnrollment(int enrollmentId) async {
    final i = busEnrollments.indexWhere((x) => x.id == enrollmentId);
    if (i == -1) return;
    busEnrollments[i] = busEnrollments[i].copyWith(
      status: BusJoinStatus.approvedAwaitingPayment,
    );
    notifyListeners();
    await saveBusEnrollments();
  }

  Future<void> rejectEnrollment(int enrollmentId) async {
    final i = busEnrollments.indexWhere((x) => x.id == enrollmentId);
    if (i == -1) return;
    busEnrollments[i] = busEnrollments[i].copyWith(
      status: BusJoinStatus.rejected,
    );
    notifyListeners();
    await saveBusEnrollments();
  }

  // Mock payment → mark paid (assignment inferred by status)
  Future<void> completePaymentAndAssign({
    required int enrollmentId,
    required String paymentRef,
  }) async {
    final i = busEnrollments.indexWhere((x) => x.id == enrollmentId);
    if (i == -1) return;
    busEnrollments[i] = busEnrollments[i].copyWith(
      status: BusJoinStatus.paid,
      paymentRef: paymentRef,
    );
    notifyListeners();
    await saveBusEnrollments();
  }

  List<int> busIdsOfStudent(int studentId) {
    return busEnrollments
        .where(
          (e) => e.studentId == studentId && e.status == BusJoinStatus.paid,
        )
        .map((e) => e.busId)
        .toList();
  }

  // ===== Authorized People =====
  // ignore: unused_element
  int _nextAuthId() => authorizedPeople.isEmpty
      ? 1
      : (authorizedPeople.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);

  Future<void> addAuthorizedPerson(AuthorizedPickupPersonApi p) async {
    // upsert by id
    final i = authorizedPeople.indexWhere((x) => x.id == p.id);
    if (i == -1) {
      authorizedPeople.add(p);
    } else {
      authorizedPeople[i] = p;
    }
    notifyListeners();
    await saveAuthorizedPeople();
  }

  Future<void> removeAuthorizedPerson(int id) async {
    authorizedPeople.removeWhere((x) => x.id == id);
    notifyListeners();
    await saveAuthorizedPeople();
  }

  List<AuthorizedPickupPersonApi> authorizedForStudent(int studentId) =>
      authorizedPeople.where((p) => p.studentId == studentId).toList();

  // ===== Door Events (البواب) =====
  int _nextDoorId() => doorEvents.isEmpty
      ? 1
      : (doorEvents.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);

  Future<void> logDoorExit({
    required int studentId,
    required int pickedByType, // 0 Parent, 1 Authorized, 2 Bus
    int? pickedById,
    String? note,
  }) async {
    doorEvents.add(
      DoorEventApi(
        id: _nextDoorId(),
        studentId: studentId,
        pickedByType: pickedByType,
        pickedById: pickedById,
        time: DateTime.now().toUtc(),
        note: note,
      ),
    );
    notifyListeners();
    await saveDoorEvents();
  }

  //helpers
  String? findUserNameById(int userId) {
    final u = users.firstWhere(
      (x) => x.id == userId,
      orElse: () => UserApi(id: -1, name: '', roleId: 0),
    );
    return u.id == -1 ? null : u.name;
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
      loadBuses(),
      loadBusEnrollments(),
      loadAuthorizedPeople(),
      loadDoorEvents(),
    ]);
  }
}
