// lib/core/services/http_client.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'api_config.dart';

class ApiHttpClient {
  final IOClient _client;
  final String baseUrl;

  // Make token mutable so we can set it after login
  String? _token;
  String? get token => _token;

  ApiHttpClient._(this._client, {required this.baseUrl, String? token})
    : _token = token;

  /// DEV ONLY: allow self-signed on localhost / 10.0.2.2
  factory ApiHttpClient.devInsecure({String? baseUrl, String? token}) {
    final httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) {
      if (!kDebugMode) return false; // never allow in release
      return host == 'localhost' || host == '10.0.2.2';
    };
    return ApiHttpClient._(
      IOClient(httpClient),
      baseUrl: baseUrl ?? ApiConfig.baseUrl,
      token: token,
    );
  }

  /// PRODUCTION: strict TLS (default platform trust)
  factory ApiHttpClient.secure({String? baseUrl, String? token}) {
    return ApiHttpClient._(
      IOClient(HttpClient()),
      baseUrl: baseUrl ?? ApiConfig.baseUrl,
      token: token,
    );
  }

  /// Set/clear bearer token at runtime (e.g., after login/logout)
  void setToken(String? token) {
    _token = token;
    if (kDebugMode) {
      debugPrint(
        token == null
            ? '[HTTP] Authorization token cleared'
            : '[HTTP] Authorization token set (len=${token.length})',
      );
    }
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Map<String, String> _headers([Map<String, String>? override]) {
    final h = ApiConfig.jsonHeaders(token: _token);
    if (override != null) h.addAll(override);
    return h;
  }

  static const _timeout = Duration(seconds: 20);

  // ============ HTTP ============

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    final uri = _uri(path, query);
    if (kDebugMode) debugPrint('[HTTP GET] $uri');
    final res = await _client
        .get(uri, headers: _headers(headers))
        .timeout(_timeout);
    return _decode('GET', uri, null, res);
  }

  /// If [raw] is true and [body] is a String, it will be sent **as-is** (no jsonEncode).
  /// Use this for endpoints expecting a JSON string literal, e.g. `"select * from Users"`.
  Future<dynamic> post(
    String path, {
    Object? body,
    bool raw = false,
    Map<String, String>? headers,
    bool rawStringBody = false, // kept for compatibility; unused
  }) async {
    final uri = _uri(path);
    final encoded = _prepareBody(body, raw: raw);
    if (kDebugMode) {
      debugPrint('[HTTP POST] $uri');
      debugPrint('[HTTP POST] raw=$raw bodyPreview=${_previewBody(encoded)}');
    }
    final res = await _client
        .post(uri, headers: _headers(headers), body: encoded)
        .timeout(_timeout);
    return _decode('POST', uri, encoded, res);
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    bool raw = false,
    Map<String, String>? headers,
  }) async {
    final uri = _uri(path);
    final encoded = _prepareBody(body, raw: raw);
    if (kDebugMode) {
      debugPrint('[HTTP PUT] $uri');
      debugPrint('[HTTP PUT] raw=$raw bodyPreview=${_previewBody(encoded)}');
    }
    final res = await _client
        .put(uri, headers: _headers(headers), body: encoded)
        .timeout(_timeout);
    return _decode('PUT', uri, encoded, res);
  }

  Future<dynamic> patch(
    String path, {
    Object? body,
    bool raw = false,
    Map<String, String>? headers,
  }) async {
    final uri = _uri(path);
    final encoded = _prepareBody(body, raw: raw);
    if (kDebugMode) {
      debugPrint('[HTTP PATCH] $uri');
      debugPrint('[HTTP PATCH] raw=$raw bodyPreview=${_previewBody(encoded)}');
    }
    final res = await _client
        .patch(uri, headers: _headers(headers), body: encoded)
        .timeout(_timeout);
    return _decode('PATCH', uri, encoded, res);
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    final uri = _uri(path, query);
    if (kDebugMode) debugPrint('[HTTP DELETE] $uri');
    final res = await _client
        .delete(uri, headers: _headers(headers))
        .timeout(_timeout);
    if (res.statusCode == 204 || res.body.isEmpty) return null;
    return _decode('DELETE', uri, null, res);
  }

  // ============ helpers ============

  /// Returns a String body ready to send:
  /// - if raw==true and body is String => return as-is
  /// - else if body==null => null
  /// - else jsonEncode(body)
  String? _prepareBody(Object? body, {required bool raw}) {
    if (body == null) return null;
    if (raw && body is String) return body; // already JSON string
    return jsonEncode(body);
  }

  String _previewBody(String? body) {
    if (body == null) return '<null>';
    const max = 200;
    return body.length <= max ? body : '${body.substring(0, max)}…';
  }

  dynamic _decode(String method, Uri uri, String? sentBody, http.Response res) {
    final ok = res.statusCode >= 200 && res.statusCode < 300;
    if (kDebugMode) {
      debugPrint('[HTTP $method RES] $uri • ${res.statusCode}');
      if (!ok) {
        debugPrint('[HTTP $method ERR] body=${_previewBody(res.body)}');
      }
    }
    if (ok) {
      if (res.body.isEmpty) return null;
      return jsonDecode(utf8.decode(res.bodyBytes));
    }
    throw ApiException(
      statusCode: res.statusCode,
      body: res.body,
      url: res.request?.url.toString(),
      method: method,
      requestBodyPreview: _previewBody(sentBody),
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  final String? url;
  final String? method;
  final String? requestBodyPreview;

  ApiException({
    required this.statusCode,
    required this.body,
    this.url,
    this.method,
    this.requestBodyPreview,
  });

  @override
  String toString() {
    final b = body.length > 300 ? '${body.substring(0, 300)}…' : body;
    return 'ApiException($statusCode) $method $url\n$b';
  }
}
