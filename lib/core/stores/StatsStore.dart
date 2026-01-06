import 'package:flutter/material.dart';
import 'package:reading_book_app/core/models/ReadingStatsItem.dart';
import 'package:reading_book_app/core/services/api/CoreService.dart';

class StatsStore extends ChangeNotifier {
  final CoreServices _core = CoreServices.instance;

  bool _loading = false;
  String? _error;

  List<ReadingStatsItem>? _dayStats;
  List<ReadingStatsItem>? _monthStats;
  List<ReadingStatsItem>? _yearStats;

  bool get loading => _loading;
  String? get error => _error;

  List<ReadingStatsItem>? get dayStats => _dayStats;
  List<ReadingStatsItem>? get monthStats => _monthStats;
  List<ReadingStatsItem>? get yearStats => _yearStats;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<void> fetchDayStats() async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _core.statsDay(7);

      _dayStats = result;
    } catch (e, stack) {
      debugPrint('[StatsStore] fetchDayStats → ERROR: $e');
      debugPrintStack(stackTrace: stack);

      _setError(e.toString());
    } finally {
      _setLoading(false);
      debugPrint('[StatsStore] fetchDayStats → END');
    }
  }

  Future<void> fetchMonthStats() async {
    _setLoading(true);
    _setError(null);

    try {
      _monthStats = await _core.statsMonth(7);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchYearStats() async {
    _setLoading(true);
    _setError(null);

    try {
      _yearStats = await _core.statsYear(7);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAll() async {
    _setLoading(true);
    _setError(null);

    try {
      final results = await Future.wait([
        _core.statsDay(7),
        _core.statsMonth(7),
        _core.statsYear(7),
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

  void clear() {
    _dayStats = null;
    _monthStats = null;
    _yearStats = null;
    _error = null;
    notifyListeners();
  }
}
