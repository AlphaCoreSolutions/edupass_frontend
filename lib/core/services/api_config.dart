// lib/core/services/api_config.dart
import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    final isAndroid = Platform.isAndroid;
    final host = isAndroid ? '10.0.2.2' : 'localhost';
    // Use HTTPS if your backend is definitely listening on 7257 and reachable
    return 'https://$host:7257';
    // If you hit timeouts/cert issues in dev, switch to: return 'http://$host:5000';
  }

  static Map<String, String> jsonHeaders({String? token}) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}
