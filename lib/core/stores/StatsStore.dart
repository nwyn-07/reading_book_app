import 'package:flutter/material.dart';
import 'package:reading_book_app/core/services/api/CoreService.dart';

class StatsStore extends ChangeNotifier {
  final CoreServices _core = CoreServices.instance;

  bool _loading = false;
  String? _error;

  Map<String, dynamic>? _dayStats;
  Map<String, dynamic>? _monthStats;
  Map<String, dynamic>? _yearStats;

  /// ======================
  /// GETTERS
  /// ======================
  bool get loading => _loading;
  String? get error => _error;

  Map<String, dynamic>? get dayStats => _dayStats;
  Map<String, dynamic>? get monthStats => _monthStats;
  Map<String, dynamic>? get yearStats => _yearStats;

  /// ======================
  /// INTERNAL
  /// ======================
  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  /// ======================
  /// ACTIONS
  /// ======================

  /// 📊 Stats theo ngày
  Future<void> fetchDayStats() async {
    _setLoading(true);
    _setError(null);

    try {
      _dayStats = await _core.statsDay();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 📊 Stats theo tháng
  Future<void> fetchMonthStats() async {
    _setLoading(true);
    _setError(null);

    try {
      _monthStats = await _core.statsMonth();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 📊 Stats theo năm
  Future<void> fetchYearStats() async {
    _setLoading(true);
    _setError(null);

    try {
      _yearStats = await _core.statsYear();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 📊 Fetch tất cả (dashboard)
  Future<void> fetchAll() async {
    _setLoading(true);
    _setError(null);

    try {
      final results = await Future.wait([
        _core.statsDay(),
        _core.statsMonth(),
        _core.statsYear(),
      ]);

      _dayStats = results[0];
      _monthStats = results[1];
      _yearStats = results[2];
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// 🧹 Clear cache (logout)
  void clear() {
    _dayStats = null;
    _monthStats = null;
    _yearStats = null;
    _error = null;
    notifyListeners();
  }
}
