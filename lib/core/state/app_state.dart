// lib/core/state/app_state.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edupass/core/models/domain_ids.dart';
import 'package:edupass/core/models/detail_ids.dart';

import 'package:edupass/core/models/lookup.dart';
import 'package:edupass/core/models/pickupRequest.dart';
import 'package:edupass/core/models/student.dart';
import 'package:edupass/core/models/user.dart';

import 'package:edupass/core/models/bus.dart';
import 'package:edupass/core/models/bus_enrollment.dart';
import 'package:edupass/core/models/authorized_person.dart';
import 'package:edupass/core/models/door_event.dart';

import 'package:edupass/core/services/api_handler.dart';
import 'package:edupass/core/services/http_client.dart';

class AppState extends ChangeNotifier {
  // Use devInsecure for local backend with self-signed certs
  final ApiService api = ApiService(ApiHttpClient.devInsecure());
  AppState({String? token}) {
    // If constructed with a token (optional), inject it
    if (token != null && token.isNotEmpty) {
      _authToken = token;
      api.setAuthToken(token);
    }
  }

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
  // Auth / Session (IDs + Token)
  // =========================
  int? _currentRoleId; // LookupDomainDetailId (UserRole domain)
  int? _currentUserId; // Logged-in user id (UserApi.id)
  String? _authToken; // Bearer

  int? get currentRoleId => _currentRoleId;
  int? get currentUserId => _currentUserId;
  String? get authToken => _authToken;

  bool get isParent => _currentRoleId == DetailIds.parent;
  bool get isSupervisor => _currentRoleId == DetailIds.supervisor;
  bool get isAdmin => _currentRoleId == DetailIds.admin;
  bool get isLoggedIn => _authToken != null && _currentUserId != null;

  static const _kKeyRole = 'currentRoleId';
  static const _kKeyUser = 'currentUserId';
  static const _kKeyTok = 'authToken';

  /// Real login with username/password
  Future<UserApi> loginWithPassword(String username, String password) async {
    final (token, user) = await api.login(username, password);
    // Persist token and user info
    _authToken = token;
    _currentUserId = user.id;
    _currentRoleId = user.roleId;

    api.setAuthToken(token);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kKeyTok, token);
      await prefs.setInt(_kKeyUser, user.id);
      await prefs.setInt(_kKeyRole, user.roleId);
    } catch (_) {
      /* ignore */
    }

    return user;
  }

  /// Retains dev convenience: login by role only
  Future<void> loginAsRoleId(int roleDetailId) async {
    _currentRoleId = roleDetailId;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kKeyRole, roleDetailId);
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
      await prefs.setInt(_kKeyUser, userId);
    } catch (_) {
      /* ignore */
    }
  }

  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(_kKeyTok)) {
        _authToken = prefs.getString(_kKeyTok);
        api.setAuthToken(_authToken);
      }
      if (prefs.containsKey(_kKeyRole)) {
        _currentRoleId = prefs.getInt(_kKeyRole);
      }
      if (prefs.containsKey(_kKeyUser)) {
        _currentUserId = prefs.getInt(_kKeyUser);
      }
      notifyListeners();
    } catch (_) {
      /* ignore */
    }
  }

  Future<void> logout() async {
    _currentRoleId = null;
    _currentUserId = null;
    _authToken = null;
    api.setAuthToken(null); // clear auth header
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kKeyRole);
      await prefs.remove(_kKeyUser);
      await prefs.remove(_kKeyTok);
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
      // Optional: local fallback (not implemented)
    }
  }

  Future<void> addStudent(StudentApi s) async {
    final created = await api.addStudent(s);
    // Upsert with server object (id from backend)
    final i = students.indexWhere((x) => x.id == created.id);
    if (i == -1) {
      students.add(created);
    } else {
      students[i] = created;
    }
    notifyListeners();
  }

  // =========================
  // Users (API-backed)
  // =========================
  List<UserApi> users = [];

  Future<void> loadUsers() async {
    // Prefer the legacy /user/all for your current backend
    users = await api.getUsers();
    notifyListeners();
  }

  Future<void> addUser(UserApi user) async {
    final created = await api.addUser(user);
    users.add(created);
    notifyListeners();
  }

  Future<void> updateUser(int id, UserApi updated) async {
    // Use patch if you want to push to backend; current UI not editing users
    // await api.updateUser(id, updated.toJson());
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

  /// Advanced search (SQL string) → returns typed users
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
          debugPrint('[searchUsers]   sample row: ${raw.first}');
        }
      }
      final parsed = raw.map((m) => UserApi.fromJson(m)).toList();
      if (kDebugMode) {
        final roleCounts = <int, int>{};
        for (final u in parsed) {
          roleCounts[u.roleId] = (roleCounts[u.roleId] ?? 0) + 1;
        }
        debugPrint(
          '[searchUsers] ✔ parsed=${parsed.length} • roleCounts=$roleCounts',
        );
      }
      return parsed;
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
    final created = await api.addRequest(request); // POST /requests/add
    requests.add(created);
    notifyListeners();
    await saveRequests();
  }

  /// Cancel (delete)
  Future<void> cancelRequest(int requestId) async {
    try {
      await api.deleteRequest(requestId);
    } catch (_) {
      /* optimistic */
    }
    requests.removeWhere((r) => r.id == requestId);
    notifyListeners();
    await saveRequests();
  }

  /// Update status (raw number primary shape; auto fallback inside api)
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
  // Buses + Enrollment + Authorized + Door
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
    try {
      // Primary: fetch from backend
      buses = await api.getBuses();
      await saveBuses();
    } catch (e) {
      // Fallback to cache
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kBusesKey);
      if (raw != null) {
        try {
          final list = (jsonDecode(raw) as List)
              .map((e) => BusApi.fromJson(e as Map<String, dynamic>))
              .toList();
          buses = list;
        } catch (_) {
          /* ignore */
        }
      }
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

  /// Create/Update bus via backend; keep same UI call
  Future<void> addOrUpdateBus(BusApi bus) async {
    try {
      // If bus.id appears in our cache, treat as update; else create
      final idx = buses.indexWhere((b) => b.id == bus.id);
      BusApi server;
      if (idx == -1 || bus.id <= 0) {
        server = await api.createBus(bus); // POST /buses
      } else {
        server = await api.updateBus(bus.id, bus); // PUT /buses/{id}
      }

      // Upsert locally with server response (authoritative id)
      final i2 = buses.indexWhere((b) => b.id == server.id);
      if (i2 == -1) {
        buses.add(server);
      } else {
        buses[i2] = server;
      }
      notifyListeners();
      await saveBuses();
    } catch (e) {
      // If backend not ready, retain local flow as fallback
      final i = buses.indexWhere((b) => b.id == bus.id);
      if (i == -1) {
        buses.add(bus);
      } else {
        buses[i] = bus;
      }
      notifyListeners();
      await saveBuses();
    }
  }

  Future<void> deleteBus(int busId) async {
    try {
      await api.deleteBus(busId);
    } catch (_) {
      /* optimistic */
    }
    buses.removeWhere((b) => b.id == busId);
    // cascade unenrollments for this bus
    busEnrollments.removeWhere((e) => e.busId == busId);
    notifyListeners();
    await saveBuses();
    await saveBusEnrollments();
  }

  // ---- Bus Enrollments ----
  Future<void> loadBusEnrollments({int? parentUserId}) async {
    try {
      // API supports filtering by parentUserId, but admins need all
      busEnrollments = await api.listEnrollments(parentUserId: parentUserId);
      await saveBusEnrollments();
    } catch (e) {
      // Fallback to cache
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kEnrollKey);
      if (raw != null) {
        try {
          busEnrollments = (jsonDecode(raw) as List)
              .map((e) => BusEnrollmentApi.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (_) {
          /* ignore */
        }
      }
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

  int _nextLocalEnrollId() => busEnrollments.isEmpty
      ? 1
      : (busEnrollments.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);

  /// Parent initiates an enrollment (backend)
  Future<BusEnrollmentApi> parentRequestJoinBus({
    required int studentId,
    required int busId,
    required int parentUserId,
  }) async {
    try {
      final created = await api.createEnrollment(
        studentId: studentId,
        busId: busId,
        requestedById: parentUserId,
      );
      // Upsert locally
      final i = busEnrollments.indexWhere((x) => x.id == created.id);
      if (i == -1) {
        busEnrollments.add(created);
      } else {
        busEnrollments[i] = created;
      }
      notifyListeners();
      await saveBusEnrollments();
      return created;
    } catch (_) {
      // Fallback local (offline/dev)
      final e = BusEnrollmentApi(
        id: _nextLocalEnrollId(),
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
  }

  Future<void> supervisorApproveEnrollment(int enrollmentId) async {
    try {
      await api.approveEnrollment(enrollmentId);
    } catch (_) {
      /* optimistic */
    }
    final i = busEnrollments.indexWhere((x) => x.id == enrollmentId);
    if (i == -1) return;
    busEnrollments[i] = busEnrollments[i].copyWith(
      status: BusJoinStatus.approvedAwaitingPayment,
    );
    notifyListeners();
    await saveBusEnrollments();
  }

  Future<void> rejectEnrollment(int enrollmentId) async {
    try {
      await api.rejectEnrollment(enrollmentId);
    } catch (_) {
      /* optimistic */
    }
    final i = busEnrollments.indexWhere((x) => x.id == enrollmentId);
    if (i == -1) return;
    busEnrollments[i] = busEnrollments[i].copyWith(
      status: BusJoinStatus.rejected,
    );
    notifyListeners();
    await saveBusEnrollments();
  }

  /// Payment completion marks "paid" (active)
  Future<void> completePaymentAndAssign({
    required int enrollmentId,
    required String paymentRef,
  }) async {
    try {
      await api.completePayment(enrollmentId, paymentRef);
    } catch (_) {
      /* optimistic */
    }
    final i = busEnrollments.indexWhere((x) => x.id == enrollmentId);
    if (i == -1) return;
    busEnrollments[i] = busEnrollments[i].copyWith(
      status: BusJoinStatus.paid,
      paymentRef: paymentRef,
    );
    notifyListeners();
    await saveBusEnrollments();
  }

  Future<void> cancelEnrollment(int enrollmentId) async {
    try {
      await api.cancelEnrollment(enrollmentId);
    } catch (_) {
      /* optimistic */
    }
    final i = busEnrollments.indexWhere((x) => x.id == enrollmentId);
    if (i == -1) return;
    busEnrollments[i] = busEnrollments[i].copyWith(
      status: BusJoinStatus.cancelled,
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

  // ---- Authorized People ----
  List<AuthorizedPickupPersonApi> authorizedForStudent(int studentId) =>
      authorizedPeople.where((p) => p.studentId == studentId).toList();

  Future<void> loadAuthorizedPeople({int? parentUserId}) async {
    try {
      // Use filter if parent mode; admins see all (null)
      authorizedPeople = await api.getAuthorized(
        parentUserId: parentUserId ?? _currentUserId,
      );
      await saveAuthorizedPeople();
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kAuthPeopleKey);
      if (raw != null) {
        try {
          authorizedPeople = (jsonDecode(raw) as List)
              .map(
                (e) => AuthorizedPickupPersonApi.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList();
        } catch (_) {
          /* ignore */
        }
      }
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

  Future<void> addAuthorizedPerson(AuthorizedPickupPersonApi p) async {
    try {
      final created = await api.addAuthorized(p);
      final i = authorizedPeople.indexWhere((x) => x.id == created.id);
      if (i == -1) {
        authorizedPeople.add(created);
      } else {
        authorizedPeople[i] = created;
      }
    } catch (_) {
      // Fallback local upsert (dev/offline)
      final i = authorizedPeople.indexWhere((x) => x.id == p.id);
      if (i == -1) {
        authorizedPeople.add(p);
      } else {
        authorizedPeople[i] = p;
      }
    }
    notifyListeners();
    await saveAuthorizedPeople();
  }

  Future<void> removeAuthorizedPerson(int id) async {
    try {
      await api.deleteAuthorized(id);
    } catch (_) {
      /* optimistic */
    }
    authorizedPeople.removeWhere((x) => x.id == id);
    notifyListeners();
    await saveAuthorizedPeople();
  }

  // ---- Door Events (Local only) ----
  int _nextDoorId() => doorEvents.isEmpty
      ? 1
      : (doorEvents.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);

  Future<void> loadDoorEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kDoorKey);
    if (raw != null) {
      try {
        doorEvents = (jsonDecode(raw) as List)
            .map((e) => DoorEventApi.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        /* ignore */
      }
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
      loadBusEnrollments(
        parentUserId: isParent ? _currentUserId : null, // parents see mine
      ),
      loadAuthorizedPeople(parentUserId: isParent ? _currentUserId : null),
      loadDoorEvents(), // local
    ]);
  }
}
