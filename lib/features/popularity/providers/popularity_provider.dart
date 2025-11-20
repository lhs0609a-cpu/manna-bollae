import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../models/popularity_stats_model.dart';

class PopularityProvider extends ChangeNotifier {
  PopularityStats? _stats;
  Timer? _updateTimer;
  bool _isLoading = false;

  PopularityStats? get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> initialize(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final statsData = prefs.getString('popularity_stats_$userId');

      if (statsData != null) {
        _stats = PopularityStats.fromMap(json.decode(statsData));
      } else {
        // 첫 사용자 - 초기 데이터 생성
        _stats = PopularityStats(
          viewersNow: Random().nextInt(15) + 5, // 5-20명
          todayLikes: Random().nextInt(10) + 3, // 3-13개
          todayViews: Random().nextInt(30) + 10, // 10-40회
          profileCompleteness: 65,
          ranking: Random().nextInt(50) + 20, // 20-70위
          rankingChange: Random().nextInt(21) - 10, // -10 ~ +10
          lastUpdated: DateTime.now(),
        );
        await _saveStats(userId);
      }

      // 실시간 업데이트 시작 (10초마다)
      _startRealTimeUpdates(userId);
    } catch (e) {
      print('인기도 초기화 오류: $e');
      _stats = PopularityStats(
        viewersNow: 0,
        todayLikes: 0,
        todayViews: 0,
        profileCompleteness: 0,
        ranking: 999,
        rankingChange: 0,
        lastUpdated: DateTime.now(),
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  void _startRealTimeUpdates(String userId) {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_stats != null) {
        // 실시간 변화 시뮬레이션
        final random = Random();

        // 현재 보는 사람 수는 자주 변함
        final newViewers = max(0, _stats!.viewersNow + random.nextInt(7) - 3);

        // 가끔 좋아요나 조회수 증가
        final likeIncrease = random.nextInt(10) < 2 ? 1 : 0;
        final viewIncrease = random.nextInt(10) < 3 ? random.nextInt(3) + 1 : 0;

        _stats = _stats!.copyWith(
          viewersNow: newViewers,
          todayLikes: _stats!.todayLikes + likeIncrease,
          todayViews: _stats!.todayViews + viewIncrease,
          lastUpdated: DateTime.now(),
        );

        _saveStats(userId);
        notifyListeners();
      }
    });
  }

  Future<void> incrementLikes(String userId) async {
    if (_stats == null) return;

    _stats = _stats!.copyWith(
      todayLikes: _stats!.todayLikes + 1,
      lastUpdated: DateTime.now(),
    );

    await _saveStats(userId);
    notifyListeners();
  }

  Future<void> incrementViews(String userId) async {
    if (_stats == null) return;

    _stats = _stats!.copyWith(
      todayViews: _stats!.todayViews + 1,
      lastUpdated: DateTime.now(),
    );

    await _saveStats(userId);
    notifyListeners();
  }

  Future<void> updateProfileCompleteness(String userId, int percentage) async {
    if (_stats == null) return;

    _stats = _stats!.copyWith(
      profileCompleteness: percentage,
      lastUpdated: DateTime.now(),
    );

    await _saveStats(userId);
    notifyListeners();
  }

  Future<void> updateRanking(String userId, int newRanking) async {
    if (_stats == null) return;

    final change = _stats!.ranking - newRanking;

    _stats = _stats!.copyWith(
      ranking: newRanking,
      rankingChange: change,
      lastUpdated: DateTime.now(),
    );

    await _saveStats(userId);
    notifyListeners();
  }

  Future<void> _saveStats(String userId) async {
    if (_stats == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('popularity_stats_$userId', json.encode(_stats!.toMap()));
    } catch (e) {
      print('인기도 저장 오류: $e');
    }
  }

  Future<void> resetDailyStats(String userId) async {
    if (_stats == null) return;

    _stats = _stats!.copyWith(
      todayLikes: 0,
      todayViews: 0,
      lastUpdated: DateTime.now(),
    );

    await _saveStats(userId);
    notifyListeners();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
