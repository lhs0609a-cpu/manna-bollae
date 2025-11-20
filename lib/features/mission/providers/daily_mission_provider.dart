import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/daily_mission_model.dart';

class DailyMissionProvider extends ChangeNotifier {
  List<DailyMission> _missions = [];
  DateTime? _lastResetDate;

  List<DailyMission> get missions => _missions;
  int get completedCount => _missions.where((m) => m.isCompleted).length;
  int get totalCount => _missions.length;
  double get overallProgress => totalCount > 0 ? completedCount / totalCount : 0.0;

  /// 일일 미션 초기화
  Future<void> initializeMissions() async {
    await _checkAndResetMissions();
    await _loadMissions();
  }

  /// 미션 리셋 확인 (날짜가 바뀌었는지)
  Future<void> _checkAndResetMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetStr = prefs.getString('last_mission_reset');
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    if (lastResetStr != todayStr) {
      // 날짜가 바뀌었으면 미션 리셋
      await _resetMissions();
      await prefs.setString('last_mission_reset', todayStr);
    }
  }

  /// 미션 리셋 (새로운 날)
  Future<void> _resetMissions() async {
    _missions = _createDailyMissions();
    await _saveMissions();
    notifyListeners();
  }

  /// 기본 일일 미션 생성
  List<DailyMission> _createDailyMissions() {
    return [
      DailyMission(
        id: 'view_profiles',
        title: '새로운 프로필 보기',
        description: '오늘 새로운 프로필 5개 보기',
        targetCount: 5,
        currentCount: 0,
        reward: MissionReward(
          type: MissionRewardType.trustScore,
          value: 1.0,
          description: '신뢰 지수 +1',
        ),
        type: MissionType.viewProfiles,
        isCompleted: false,
      ),
      DailyMission(
        id: 'send_likes',
        title: '하트 보내기',
        description: '오늘 하트 3개 보내기',
        targetCount: 3,
        currentCount: 0,
        reward: MissionReward(
          type: MissionRewardType.luckyBox,
          value: 1.0,
          description: '럭키 박스 1개',
        ),
        type: MissionType.sendLikes,
        isCompleted: false,
      ),
      DailyMission(
        id: 'send_messages',
        title: '메시지 보내기',
        description: '오늘 메시지 5개 보내기',
        targetCount: 5,
        currentCount: 0,
        reward: MissionReward(
          type: MissionRewardType.heartTemperature,
          value: 2.0,
          description: '하트 온도 +2',
        ),
        type: MissionType.sendMessages,
        isCompleted: false,
      ),
      DailyMission(
        id: 'write_quest',
        title: '일일 퀘스트 작성',
        description: '오늘의 일일 퀘스트 작성하기',
        targetCount: 1,
        currentCount: 0,
        reward: MissionReward(
          type: MissionRewardType.trustScore,
          value: 0.3,
          description: '신뢰 지수 +0.3',
        ),
        type: MissionType.writeQuest,
        isCompleted: false,
      ),
    ];
  }

  /// 미션 로드
  Future<void> _loadMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final missionsJson = prefs.getString('daily_missions');

    if (missionsJson != null) {
      final List<dynamic> decoded = jsonDecode(missionsJson);
      _missions = decoded.map((m) => DailyMission.fromMap(m)).toList();
    } else {
      _missions = _createDailyMissions();
      await _saveMissions();
    }

    notifyListeners();
  }

  /// 미션 저장
  Future<void> _saveMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final missionsJson = jsonEncode(_missions.map((m) => m.toMap()).toList());
    await prefs.setString('daily_missions', missionsJson);
  }

  /// 미션 진행도 업데이트
  Future<void> updateMissionProgress(MissionType type, {int increment = 1}) async {
    final missionIndex = _missions.indexWhere((m) => m.type == type);

    if (missionIndex != -1) {
      final mission = _missions[missionIndex];

      if (!mission.isCompleted) {
        final newCount = (mission.currentCount + increment).clamp(0, mission.targetCount);
        _missions[missionIndex] = mission.copyWith(currentCount: newCount);

        await _saveMissions();
        notifyListeners();
      }
    }
  }

  /// 미션 완료 (보상 받기)
  Future<bool> claimMissionReward(String missionId) async {
    final missionIndex = _missions.indexWhere((m) => m.id == missionId);

    if (missionIndex != -1) {
      final mission = _missions[missionIndex];

      if (mission.canClaim) {
        _missions[missionIndex] = mission.copyWith(isCompleted: true);
        await _saveMissions();
        notifyListeners();
        return true;
      }
    }

    return false;
  }

  /// 모든 미션 완료 여부
  bool get allMissionsCompleted => _missions.every((m) => m.isCompleted);

  /// 완료 가능한 미션 수
  int get claimableMissionsCount => _missions.where((m) => m.canClaim).length;
}
