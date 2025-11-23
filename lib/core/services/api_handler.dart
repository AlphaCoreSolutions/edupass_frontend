// lib/core/services/api_handler.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:edupass/core/models/authorized_person.dart';
import 'package:edupass/core/models/bus.dart';
import 'package:edupass/core/models/bus_enrollment.dart';
import 'package:edupass/core/models/lookup.dart';
import 'package:edupass/core/models/pickupRequest.dart';
import 'package:edupass/core/models/student.dart';
import 'package:edupass/core/models/user.dart';

import 'http_client.dart';

class ApiService {
  final ApiHttpClient _http;

  ApiService(this._http);

  /// Pass null to remove the Authorization header.
  void setAuthToken(String? token) {
    _http.setToken(token);
  }

  /// Expects backend to return: { "token": "...", "user": { ...UserApi... } }
  /// Returns (token, user) so caller can persist & route by role.
  Future<(String token, UserApi user)> login(
    String username,
    String password,
  ) async {
    final resp =
        await _http.post(
              '/auth/login',
              body: {'username': username, 'password': password},
            )
            as Map<String, dynamic>;

    // Support a couple of naming variants just in case:
    final token =
        (resp['token'] ?? resp['accessToken'] ?? resp['jwt'] ?? resp['bearer'])
            as String;

    final userJson =
        (resp['user'] ?? resp['profile'] ?? resp['account'])
            as Map<String, dynamic>;

    final user = UserApi.fromJson(userJson);
    return (token, user);
  }

  // ===========================================================================
  // STUDENTS
  // ===========================================================================

  /// GET /student/all
  Future<List<StudentApi>> getStudents() async {
    final data = await _http.get('/student/all');
    return (data as List).map((e) => StudentApi.fromJson(e)).toList();
  }

  /// GET /student/get/{id}
  Future<StudentApi> getStudent(int id) async {
    final data = await _http.get('/student/get/$id');
    return StudentApi.fromJson(data);
  }

  /// POST /student/add
  Future<StudentApi> addStudent(StudentApi body) async {
    final data = await _http.post('/student/add', body: body.toJson());
    return StudentApi.fromJson(data);
  }

  /// PUT /student/update/{id}
  Future<StudentApi> updateStudent(int id, StudentApi body) async {
    final data = await _http.put('/student/update/$id', body: body.toJson());
    return StudentApi.fromJson(data);
  }

  /// DELETE /student/delete/{id}
  Future<void> deleteStudent(int id) async {
    await _http.delete('/student/delete/$id');
  }

  // ===========================================================================
  // USERS (including supervisor search)
  // ===========================================================================

  /// NOTE: Some backends expose /user/all; others use /users. Keep both helpers.

  /// GET /user/all  (legacy)
  Future<List<UserApi>> getUsers() async {
    final data = await _http.get('/user/all');
    return (data as List).map((e) => UserApi.fromJson(e)).toList();
  }

  /// GET /users?roleId=4  (preferred if available)
  Future<List<UserApi>> getUsersByRole({int? roleId}) async {
    final data = await _http.get(
      '/users',
      query: roleId == null ? null : {'roleId': '$roleId'},
    );
    return (data as List).map((e) => UserApi.fromJson(e)).toList();
  }

  /// POST /user/add (legacy)
  Future<UserApi> addUser(UserApi user) async {
    final data = await _http.post('/user/add', body: user.toJson());
    return UserApi.fromJson(data);
  }

  /// PATCH /user/update/{id} (legacy)
  Future<UserApi> updateUser(int id, Map<String, dynamic> patch) async {
    final data = await _http.patch('/user/update/$id', body: patch);
    return UserApi.fromJson(data);
  }

  /// DELETE /user/delete/{id} (legacy)
  Future<void> deleteUser(int id) async {
    await _http.delete('/user/delete/$id');
  }

  /// POST /user/advancedSearch
  /// Backend expects a *raw JSON string* (e.g. `"select * from Users where roleId = 4"`).
  /// Use `raw: true` to avoid double encoding.
  Future<List<Map<String, dynamic>>> searchUsers(String sql) async {
    final data = await _http.post(
      '/user/advancedSearch',
      body: jsonEncode(sql), // "\"select * from Users where roleId = 4\""
      raw: true,
    );
    return (data as List).cast<Map<String, dynamic>>();
  }

  // ===========================================================================
  // PICKUP REQUESTS
  // ===========================================================================

  /// GET /requests/all  or  GET /requests?student={id}
  Future<List<PickupRequestApi>> getRequests({int? studentId}) async {
    final data = await (studentId == null
        ? _http.get('/requests/all')
        : _http.get('/requests', query: {'student': '$studentId'}));
    return (data as List).map((e) => PickupRequestApi.fromJson(e)).toList();
  }

  /// POST /requests/add
  Future<PickupRequestApi> addRequest(PickupRequestApi req) async {
    final data = await _http.post('/requests/add', body: req.toJson());
    return PickupRequestApi.fromJson(data);
  }

  /// PATCH /requests/update-status/{id}
  /// Primary shape preferred by some backends: raw number body (e.g., 9)
  Future<PickupRequestApi> updateRequestStatus(int id, int statusId) async {
    final data = await _http.patch(
      '/requests/update-status/$id',
      body: statusId, // int -> jsonEncode -> "9"  OK
    );
    return PickupRequestApi.fromJson(data as Map<String, dynamic>);
  }

  /// Fallback version: if the API requires { "statusId": 9 } instead.
  Future<PickupRequestApi> updateRequestStatusAuto(int id, int statusId) async {
    try {
      return await updateRequestStatus(id, statusId);
    } on ApiException catch (e) {
      if (e.statusCode == 400) {
        final data = await _http.patch(
          '/requests/update-status/$id',
          body: {'statusId': statusId},
        );
        return PickupRequestApi.fromJson(data as Map<String, dynamic>);
      }
      rethrow;
    }
  }

  /// DELETE /requests/delete/{id}
  Future<void> deleteRequest(int id) async {
    await _http.delete('/requests/delete/$id');
  }

  // ===========================================================================
  // BUSES
  // ===========================================================================

  /// GET /buses?neighborhood=Al%20Nada
  Future<List<BusApi>> getBuses({String? neighborhood}) async {
    final data = await _http.get(
      '/buses',
      query: neighborhood == null ? null : {'neighborhood': neighborhood},
    );
    return (data as List).map((e) => BusApi.fromJson(e)).toList();
  }

  /// POST /buses
  Future<BusApi> createBus(BusApi bus) async {
    final data = await _http.post('/buses', body: bus.toJson());
    return BusApi.fromJson(data);
  }

  /// PUT /buses/{id}
  Future<BusApi> updateBus(int id, BusApi bus) async {
    final data = await _http.put('/buses/$id', body: bus.toJson());
    return BusApi.fromJson(data);
  }

  /// DELETE /buses/{id}
  Future<void> deleteBus(int id) async {
    await _http.delete('/buses/$id');
  }

  // ===========================================================================
  // BUS ENROLLMENTS
  // ===========================================================================

  /// GET /bus/enrollments?parentUserId=77
  Future<List<BusEnrollmentApi>> listEnrollments({int? parentUserId}) async {
    final data = await _http.get(
      '/bus/enrollments',
      query: parentUserId == null ? null : {'parentUserId': '$parentUserId'},
    );
    return (data as List).map((e) => BusEnrollmentApi.fromJson(e)).toList();
  }

  /// POST /bus/enrollments
  /// { studentId, busId, requestedById }
  Future<BusEnrollmentApi> createEnrollment({
    required int studentId,
    required int busId,
    required int requestedById,
  }) async {
    final body = {
      'studentId': studentId,
      'busId': busId,
      'requestedById': requestedById,
    };
    final data = await _http.post('/bus/enrollments', body: body);
    return BusEnrollmentApi.fromJson(data);
  }

  /// PATCH /bus/enrollments/{id}/approve
  Future<void> approveEnrollment(int id) async {
    await _http.patch('/bus/enrollments/$id/approve');
  }

  /// PATCH /bus/enrollments/{id}/reject
  Future<void> rejectEnrollment(int id) async {
    await _http.patch('/bus/enrollments/$id/reject');
  }

  /// PATCH /bus/enrollments/{id}/completePayment
  /// body: { paymentRef: "TXN-..." }
  Future<void> completePayment(int id, String paymentRef) async {
    await _http.patch(
      '/bus/enrollments/$id/completePayment',
      body: {'paymentRef': paymentRef},
    );
  }

  /// PATCH /bus/enrollments/{id}/cancel
  Future<void> cancelEnrollment(int id) async {
    await _http.patch('/bus/enrollments/$id/cancel');
  }

  // ===========================================================================
  // AUTHORIZED PICKUPS
  // ===========================================================================

  /// GET /authorized?parentUserId=77
  Future<List<AuthorizedPickupPersonApi>> getAuthorized({
    int? parentUserId,
  }) async {
    final data = await _http.get(
      '/authorized',
      query: parentUserId == null ? null : {'parentUserId': '$parentUserId'},
    );
    return (data as List)
        .map((e) => AuthorizedPickupPersonApi.fromJson(e))
        .toList();
  }

  /// POST /authorized
  Future<AuthorizedPickupPersonApi> addAuthorized(
    AuthorizedPickupPersonApi person,
  ) async {
    final data = await _http.post('/authorized', body: person.toJson());
    return AuthorizedPickupPersonApi.fromJson(data);
  }

  /// DELETE /authorized/{id}
  Future<void> deleteAuthorized(int id) async {
    await _http.delete('/authorized/$id');
  }

  // ===========================================================================
  // LOOKUP DOMAINS (new endpoints) + legacy support
  // ===========================================================================

  /// GET /lookup?domain=requestStatus
  Future<List<Map<String, dynamic>>> getLookupByDomain(String domain) async {
    final data = await _http.get('/lookup', query: {'domain': domain});
    return (data as List).cast<Map<String, dynamic>>();
  }

  /// GET /lookup/all
  Future<List<Map<String, dynamic>>> getAllLookups() async {
    final data = await _http.get('/lookup/all');
    return (data as List).cast<Map<String, dynamic>>();
  }

  // --- Legacy lookup endpoints (keep for compatibility) ---

  /// GET /lookup-domain/all
  Future<List<LookupDomain>> getLookupDomains() async {
    final data = await _http.get('/lookup-domain/all');
    return (data as List).map((e) => LookupDomain.fromJson(e)).toList();
  }

  /// GET /lookup-domain-detail/all
  Future<List<LookupDomainDetail>> getLookupDomainDetails() async {
    final data = await _http.get('/lookup-domain-detail/all');
    return (data as List).map((e) => LookupDomainDetail.fromJson(e)).toList();
  }

  /// GET /lookup-domain/get/{id}
  Future<LookupDomain> getLookupDomainById(int id) async {
    final data = await _http.get('/lookup-domain/get/$id');
    return LookupDomain.fromJson(data as Map<String, dynamic>);
  }

  /// POST /lookup-domain-detail/advancedSearch
  Future<List<Map<String, dynamic>>> lookupDetailsAdvancedSearchRawSql(
    String sql,
  ) async {
    final data = await _http.post(
      '/lookup-domain-detail/advancedSearch',
      body: {'query': sql},
    );
    return (data as List).cast<Map<String, dynamic>>();
  }

  // ===========================================================================
  // REPORTS (CSV/Excel) - Bilingual
  // ===========================================================================

  /// POST /reports/export?type=bus|requests&format=csv|excel&lang=en|ar
  /// body: optional filters (see spec)
  ///
  /// NOTE: If the backend returns a binary file (bytes), your ApiHttpClient must
  /// support bypassing JSON decode and returning `response.bodyBytes`.
  /// Add something like `expectBinary: true` in the http client and branch there.
  Future<Uint8List> exportReport({
    required String type, // "bus" | "requests"
    required String format, // "csv" | "excel"
    required String lang, // "en" | "ar"
    Map<String, dynamic>? body,
  }) async {
    // TODO: Update ApiHttpClient.post to support `expectBinary: true`
    // and return Uint8List from res.bodyBytes directly.
    //
    // Example once http client supports it:
    // final bytes = await _http.postBytes(
    //   '/reports/export?type=$type&format=$format&lang=$lang',
    //   body: body ?? {},
    // );
    // return bytes;

    // Temporary placeholder to make the method compile:
    throw UnimplementedError(
      'Hook binary pipeline in ApiHttpClient (expectBinary: true) and return bytes here.',
    );
  }
}
