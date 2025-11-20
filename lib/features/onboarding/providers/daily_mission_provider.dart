import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/daily_mission.dart';
import '../models/mission_progress.dart';
import '../models/mission_data.dart';

class DailyMissionProvider extends ChangeNotifier {
  MissionProgress _progress = MissionProgress();
  final List<DailyMission> _allMissions = MissionData.all30DayMissions;

  MissionProgress get progress => _progress;
  List<DailyMission> get allMissions => _allMissions;

  DailyMission? get todayMission {
    if (_progress.isCompleted) return null;
    if (!_progress.canDoTodayMission) return null;

    return _allMissions.firstWhere(
      (mission) => mission.day == _progress.currentDay,
      orElse: () => _allMissions.first,
    );
  }

  bool get hasCompletedAllMissions => _progress.isCompleted;

  // 초기 온보딩 완료 여부 (Day 0의 답변이 있으면 완료)
  bool get hasCompletedInitialOnboarding {
    return _progress.answers.containsKey(0);
  }

  // 초기 로드
  Future<void> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? progressJson = prefs.getString('mission_progress');

      if (progressJson != null) {
        final Map<String, dynamic> json = jsonDecode(progressJson);
        _progress = MissionProgress.fromJson(json);
      } else {
        _progress = MissionProgress();
      }

      // 연속 출석 체크
      _checkConsecutiveDays();

      notifyListeners();
    } catch (e) {
      print('⚠️ Failed to load mission progress: $e');
      _progress = MissionProgress();
      notifyListeners();
    }
  }

  // 연속 출석 체크
  void _checkConsecutiveDays() {
    if (_progress.lastCompletedDate == null) return;

    final now = DateTime.now();
    final lastDate = _progress.lastCompletedDate!;
    final difference = now.difference(lastDate).inDays;

    if (difference > 1) {
      // 연속 출석이 끊김
      _progress = _progress.copyWith(consecutiveDays: 0);
    }
  }

  // 미션 완료
  Future<bool> completeMission(int day, dynamic answer) async {
    try {
      if (_progress.completedDays.contains(day)) {
        return false; // 이미 완료한 미션
      }

      final now = DateTime.now();
      final lastDate = _progress.lastCompletedDate;

      // 연속 출석 계산
      int newConsecutiveDays = _progress.consecutiveDays;
      if (lastDate != null) {
        final difference = now.difference(lastDate).inDays;
        if (difference == 1) {
          newConsecutiveDays++;
        } else if (difference > 1) {
          newConsecutiveDays = 1;
        }
      } else {
        newConsecutiveDays = 1;
      }

      // 진행도 업데이트
      final updatedCompletedDays = [..._progress.completedDays, day];
      final updatedAnswers = {..._progress.answers, day: answer};

      _progress = _progress.copyWith(
        currentDay: day + 1,
        lastCompletedDate: now,
        completedDays: updatedCompletedDays,
        answers: updatedAnswers,
        consecutiveDays: newConsecutiveDays,
      );

      // 저장
      await _saveProgress();

      notifyListeners();
      return true;
    } catch (e) {
      print('⚠️ Failed to complete mission: $e');
      return false;
    }
  }

  // 진행도 저장
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String progressJson = jsonEncode(_progress.toJson());
      await prefs.setString('mission_progress', progressJson);
    } catch (e) {
      print('⚠️ Failed to save mission progress: $e');
    }
  }

  // 특정 미션 가져오기
  DailyMission? getMission(int day) {
    try {
      return _allMissions.firstWhere((mission) => mission.day == day);
    } catch (e) {
      return null;
    }
  }

  // 특정 미션의 답변 가져오기
  dynamic getAnswer(int day) {
    return _progress.answers[day];
  }

  // 진행도 초기화 (테스트용)
  Future<void> resetProgress() async {
    _progress = MissionProgress();
    await _saveProgress();
    notifyListeners();
  }

  // 주간별 완료율 계산
  Map<int, double> getWeeklyCompletion() {
    final Map<int, double> weeklyCompletion = {};

    for (int week = 1; week <= 5; week++) {
      final startDay = (week - 1) * 7 + 1;
      final endDay = week * 7;

      final completedInWeek = _progress.completedDays
          .where((day) => day >= startDay && day <= endDay)
          .length;

      weeklyCompletion[week] = (completedInWeek / 7) * 100;
    }

    return weeklyCompletion;
  }

  // 카테고리별 완료율
  Map<String, double> getCategoryCompletion() {
    final Map<String, int> categoryTotal = {};
    final Map<String, int> categoryCompleted = {};

    for (var mission in _allMissions) {
      categoryTotal[mission.category] =
          (categoryTotal[mission.category] ?? 0) + 1;

      if (_progress.completedDays.contains(mission.day)) {
        categoryCompleted[mission.category] =
            (categoryCompleted[mission.category] ?? 0) + 1;
      }
    }

    final Map<String, double> categoryCompletion = {};
    for (var category in categoryTotal.keys) {
      final completed = categoryCompleted[category] ?? 0;
      final total = categoryTotal[category]!;
      categoryCompletion[category] = (completed / total) * 100;
    }

    return categoryCompletion;
  }
}
