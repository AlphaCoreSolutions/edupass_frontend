// lib/core/services/http_client.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'api_config.dart';

class ApiHttpClient {
  final IOClient _client;
  final String baseUrl;
  final String? token;

  ApiHttpClient._(this._client, {required this.baseUrl, this.token});

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

  Uri _uri(String path, [Map<String, dynamic>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Map<String, String> _headers() => ApiConfig.jsonHeaders(token: token);

  static const _timeout = Duration(seconds: 20);

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final res = await _client
        .get(_uri(path, query), headers: _headers())
        .timeout(_timeout);
    return _decode(res);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final res = await _client
        .post(
          _uri(path),
          headers: _headers(),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(_timeout);
    return _decode(res);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final res = await _client
        .put(
          _uri(path),
          headers: _headers(),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(_timeout);
    return _decode(res);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final res = await _client
        .patch(
          _uri(path),
          headers: _headers(),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(_timeout);
    return _decode(res);
  }

  Future<dynamic> delete(String path) async {
    final res = await _client
        .delete(_uri(path), headers: _headers())
        .timeout(_timeout);
    if (res.statusCode == 204 || res.body.isEmpty) return null;
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(utf8.decode(res.bodyBytes));
    }
    throw ApiException(
      statusCode: res.statusCode,
      body: res.body,
      url: res.request?.url.toString(),
    );
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  final String? url;
  ApiException({required this.statusCode, required this.body, this.url});
  @override
  String toString() => 'ApiException($statusCode) $url\n$body';
}
