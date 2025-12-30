import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reading_book_app/core/services/api/JWT.dart';

class FetchApi {
  static final FetchApi _instance = FetchApi._internal();
  factory FetchApi() => _instance;

  FetchApi._internal();

  final _storage = const FlutterSecureStorage();

  /// ======================
  /// Headers
  /// ======================
  Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'access_token');

    final headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    if (token != null && !JwtDecoder.isExpired(token)) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  /// ======================
  /// GET
  /// ======================
  Future<dynamic> get(String url, {Map<String, dynamic>? query}) async {
    final uri = Uri.parse(url).replace(queryParameters: query);
    final res = await http.get(uri, headers: await _headers());
    return _handleResponse(res);
  }

  /// ======================
  /// POST
  /// ======================
  Future<dynamic> post(String url, {Map<String, dynamic>? body}) async {
    final res = await http.post(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  /// ======================
  /// PUT
  /// ======================
  Future<dynamic> put(String url, {dynamic body}) async {
    if (body is http.MultipartRequest) {
      final headers = await _headers();

      headers.remove('Content-Type');

      body.headers.addAll(headers);

      final streamed = await body.send();
      final res = await http.Response.fromStream(streamed);
      return _handleResponse(res);
    }

    final res = await http.put(
      Uri.parse(url),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return _handleResponse(res);
  }

  /// ======================
  /// DELETE
  /// ======================
  Future<dynamic> delete(String url, {Map<String, dynamic>? body}) async {
    final request = http.Request('DELETE', Uri.parse(url));

    request.headers.addAll(await _headers());

    if (body != null) {
      request.body = jsonEncode(body);
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  /// ======================
  /// Response handler
  /// ======================
  dynamic _handleResponse(http.Response res) async {
    if (res.statusCode == 401) {
      await _logout();
      throw Exception("Session expired");
    }

    final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }

    throw Exception(body?['message'] ?? 'API Error (${res.statusCode})');
  }

  /// ======================
  /// Logout
  /// ======================
  Future<void> _logout() async {
    await _storage.delete(key: 'access_token');
  }
}
