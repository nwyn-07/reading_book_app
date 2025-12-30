import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reading_book_app/core/services/api/CoreService.dart';
import 'package:reading_book_app/core/services/api/JWT.dart';

class AuthStore extends ChangeNotifier {
  final CoreServices _api = CoreServices.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  bool _loading = true;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _loading;

  Future<void> init() async {
    _setLoading(true);

    try {
      final token = await _storage.read(key: 'access_token');

      if (token == null || JwtDecoder.isExpired(token)) {
        await logout();
        return;
      }

      await fetchMe();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserAvatar(String avatarUrl) async {
    if (_user != null) {
      _user!['avatarUrl'] = avatarUrl;
      notifyListeners();
    }
  }

  Future<void> updateUserName(String fullName) async {
    if (_user != null) {
      _user!['fullName'] = fullName;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);

    try {
      final res = await _api.login(email, password);

      final token = res['accessToken'];
      if (token == null) {
        throw Exception('TOKEN_NOT_FOUND');
      }

      await _storage.write(key: 'access_token', value: token);

      await fetchMe();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    _setLoading(true);

    try {
      await _api.register(email, password, fullName);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMe() async {
    try {
      final res = await _api.me();

      _user = res;
      _isAuthenticated = true;
      notifyListeners();
    } catch (_) {
      await logout();
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');

    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
