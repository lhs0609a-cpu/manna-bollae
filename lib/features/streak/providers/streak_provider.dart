import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../models/streak_model.dart';

class StreakProvider extends ChangeNotifier {
  StreakModel? _streak;
  bool _isLoading = false;

  StreakModel? get streak => _streak;
  bool get isLoading => _isLoading;

  Future<void> initialize(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final streakData = prefs.getString('streak_$userId');

      if (streakData != null) {
        _streak = StreakModel.fromMap(json.decode(streakData));

        // 스트릭이 끊겼는지 확인
        if (_streak!.isStreakBroken && _streak!.currentStreak > 0) {
          print('⚠️ 스트릭이 끊어졌습니다. 초기화합니다.');
          _streak = _streak!.copyWith(currentStreak: 0);
          await _saveStreak(userId);
        }
      } else {
        // 첫 사용자
        _streak = StreakModel(
          currentStreak: 0,
          longestStreak: 0,
          lastCheckIn: DateTime.now().subtract(const Duration(days: 2)), // 오늘 체크인 가능하도록
          checkInHistory: [],
          rewards: {
            3: '매칭권 +1',
            7: '슈퍼 라이크 +2',
            14: '프로필 부스트 24시간',
            30: '황금 뱃지 + 매칭권 +5',
          },
        );
      }
    } catch (e) {
      print('스트릭 초기화 오류: $e');
      _streak = StreakModel(
        currentStreak: 0,
        longestStreak: 0,
        lastCheckIn: DateTime.now().subtract(const Duration(days: 2)),
        checkInHistory: [],
        rewards: {
          3: '매칭권 +1',
          7: '슈퍼 라이크 +2',
          14: '프로필 부스트 24시간',
          30: '황금 뱃지 + 매칭권 +5',
        },
      );
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> checkIn(String userId) async {
    if (_streak == null) {
      return {
        'success': false,
        'message': '스트릭 정보를 불러올 수 없습니다.',
      };
    }

    if (!_streak!.canCheckInToday) {
      return {
        'success': false,
        'message': '오늘은 이미 체크인했습니다!',
      };
    }

    final now = DateTime.now();
    final newStreak = _streak!.currentStreak + 1;
    final newLongest = newStreak > _streak!.longestStreak ? newStreak : _streak!.longestStreak;

    _streak = _streak!.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastCheckIn: now,
      checkInHistory: [..._streak!.checkInHistory, now],
    );

    await _saveStreak(userId);
    notifyListeners();

    // 보상 확인
    String? reward;
    if (_streak!.rewards.containsKey(newStreak)) {
      reward = _streak!.rewards[newStreak];
    }

    return {
      'success': true,
      'message': '체크인 완료! ${_streak!.currentStreak}일 연속!',
      'streak': newStreak,
      'reward': reward,
      'emoji': _streak!.streakEmoji,
    };
  }

  Future<void> _saveStreak(String userId) async {
    if (_streak == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('streak_$userId', json.encode(_streak!.toMap()));
    } catch (e) {
      print('스트릭 저장 오류: $e');
    }
  }

  // 테스트용: 스트릭 초기화
  Future<void> resetStreak(String userId) async {
    _streak = StreakModel(
      currentStreak: 0,
      longestStreak: _streak?.longestStreak ?? 0,
      lastCheckIn: DateTime.now().subtract(const Duration(days: 2)),
      checkInHistory: [],
      rewards: _streak?.rewards ?? {
        3: '매칭권 +1',
        7: '슈퍼 라이크 +2',
        14: '프로필 부스트 24시간',
        30: '황금 뱃지 + 매칭권 +5',
      },
    );
    await _saveStreak(userId);
    notifyListeners();
  }
}
