import 'package:edupass/core/models/lookup.dart';
import 'package:edupass/core/models/pickupRequest.dart';
import 'package:edupass/core/models/student.dart';
import 'package:edupass/core/models/user.dart';

import 'http_client.dart';

class ApiService {
  final ApiHttpClient _http;

  ApiService(this._http);

  // ---------- Students ----------
  Future<List<StudentApi>> getStudents() async {
    final data = await _http.get('/student/all');
    return (data as List).map((e) => StudentApi.fromJson(e)).toList();
    // NOTE: If backend returns {data: []}, adjust accordingly.
  }

  Future<StudentApi> getStudent(int id) async {
    final data = await _http.get('/student/get/$id');
    return StudentApi.fromJson(data);
  }

  Future<StudentApi> addStudent(StudentApi body) async {
    final data = await _http.post('/student/add', body: body.toJson());
    return StudentApi.fromJson(data);
  }

  Future<StudentApi> updateStudent(int id, StudentApi body) async {
    final data = await _http.put('/student/update/$id', body: body.toJson());
    return StudentApi.fromJson(data);
  }

  Future<void> deleteStudent(int id) async {
    await _http.delete('/student/delete/$id');
  }

  // ---------- Users ----------
  Future<List<UserApi>> getUsers() async {
    final data = await _http.get('/user/all');
    return (data as List).map((e) => UserApi.fromJson(e)).toList();
  }

  Future<UserApi> addUser(UserApi user) async {
    final data = await _http.post('/user/add', body: user.toJson());
    return UserApi.fromJson(data);
  }

  Future<UserApi> updateUser(int id, Map<String, dynamic> patch) async {
    final data = await _http.patch('/user/update/$id', body: patch);
    return UserApi.fromJson(data);
  }

  Future<void> deleteUser(int id) async {
    await _http.delete('/user/delete/$id');
  }

  // ---------- Requests ----------
  Future<List<PickupRequestApi>> getRequests({int? studentId}) async {
    final data = await (studentId == null
        ? _http.get('/requests/all')
        : _http.get('/requests', query: {'student': '$studentId'}));
    return (data as List).map((e) => PickupRequestApi.fromJson(e)).toList();
  }

  Future<PickupRequestApi> addRequest(PickupRequestApi req) async {
    final data = await _http.post('/requests/add', body: req.toJson());
    return PickupRequestApi.fromJson(data);
  }

  Future<PickupRequestApi> updateRequestStatus(int id, int statusId) async {
    // Sends a raw JSON number: 9
    final data = await _http.patch(
      '/requests/update-status/$id',
      body: statusId, // <-- int, NOT {'statusId': statusId}
    );
    return PickupRequestApi.fromJson(data as Map<String, dynamic>);
  }

  Future<PickupRequestApi> updateRequestStatusAuto(int id, int statusId) async {
    try {
      return await updateRequestStatus(id, statusId);
    } on ApiException catch (e) {
      if (e.statusCode == 400) {
        final data = await _http.patch(
          '/requests/update-status/$id',
          body: {'statusId': statusId}, // fallback shape
        );
        return PickupRequestApi.fromJson(data as Map<String, dynamic>);
      }
      rethrow;
    }
  }

  Future<void> deleteRequest(int id) async {
    await _http.delete('/requests/delete/$id');
  }

  // ---------- Lookup ----------
  Future<List<LookupDomain>> getLookupDomains() async {
    final data = await _http.get('/lookup-domain/all');
    return (data as List).map((e) => LookupDomain.fromJson(e)).toList();
  }

  Future<List<LookupDomainDetail>> getLookupDomainDetails() async {
    final data = await _http.get('/lookup-domain-detail/all');
    return (data as List).map((e) => LookupDomainDetail.fromJson(e)).toList();
  }

  Future<LookupDomain> getLookupDomainById(int id) async {
    final data = await _http.get('/lookup-domain/get/$id');
    return LookupDomain.fromJson(data as Map<String, dynamic>);
  }

  // Optional: advanced search for details (admin/debug)
  Future<List<Map<String, dynamic>>> lookupDetailsAdvancedSearchRawSql(
    String sql,
  ) async {
    final data = await _http.post(
      '/lookup-domain-detail/advancedSearch',
      body: {'query': sql},
    );
    // backend shape may vary; return raw maps or modelize if needed
    return (data as List).cast<Map<String, dynamic>>();
  }
}
