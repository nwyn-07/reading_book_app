import 'dart:io';

import 'package:flutter/material.dart';
import 'package:reading_book_app/core/models/User.dart';
import 'package:reading_book_app/core/services/api/CoreService.dart';

class UserStore extends ChangeNotifier {
  final CoreServices _api = CoreServices.instance;

  User? _currentUser;
  bool _isUpdating = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isUpdating => _isUpdating;
  String? get error => _error;

  /// ✅ FLAG: Store này có fetch profile
  bool get hasFetchProfile => true;

  /// 🔄 FETCH PROFILE (Refresh)
  Future<void> fetchProfile() async {
    try {
      final res = await _api.me();
      _currentUser = User.fromJson(res);
      _error = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch profile error: $e');
      _error = 'Không thể tải thông tin người dùng';
      notifyListeners();
    }
  }

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<bool> updateProfile({String? fullName, File? avatarFile}) async {
    if (_isUpdating) return false;

    if ((fullName == null || fullName.trim().isEmpty) && avatarFile == null) {
      return true;
    }

    _isUpdating = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.updateProfile(
        fullName: fullName?.trim(),
        avatarFile: avatarFile,
      );

      _currentUser = User.fromJson(res);
      _isUpdating = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Update profile error: $e');
      _error = 'Cập nhật thất bại';
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _currentUser = null;
    notifyListeners();
  }
}
