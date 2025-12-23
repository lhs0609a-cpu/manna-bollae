import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../models/chat_intimacy_model.dart';

class ChatIntimacyProvider extends ChangeNotifier {
  // userId -> partnerId -> ChatIntimacy
  final Map<String, Map<String, ChatIntimacy>> _intimacies = {};

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 특정 상대방과의 친밀도 가져오기
  ChatIntimacy? getIntimacy(String userId, String partnerId) {
    return _intimacies[userId]?[partnerId];
  }

  /// 친밀도 초기화 (앱 시작 시)
  Future<void> initialize(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final intimacyJson = prefs.getString('chat_intimacy_$userId');

      if (intimacyJson != null) {
        final map = json.decode(intimacyJson) as Map<String, dynamic>;
        _intimacies[userId] = {};

        map.forEach((partnerId, intimacyMap) {
          _intimacies[userId]![partnerId] =
              ChatIntimacy.fromMap(intimacyMap as Map<String, dynamic>);
        });
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '친밀도 데이터를 불러오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 메시지 전송 시 친밀도 업데이트
  Future<void> updateIntimacyOnMessage(
    String userId,
    String partnerId,
  ) async {
    try {
      final now = DateTime.now();
      final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // 기존 친밀도 가져오기 또는 새로 생성
      ChatIntimacy intimacy;
      if (_intimacies[userId] == null) {
        _intimacies[userId] = {};
      }

      if (_intimacies[userId]![partnerId] == null) {
        // 처음 대화하는 경우
        intimacy = ChatIntimacy(
          userId: userId,
          partnerId: partnerId,
          firstChatDate: now,
          lastChatDate: now,
          totalMessageCount: 1,
          consecutiveDays: 1,
          dailyMessageCount: {todayKey: 1},
          intimacyScore: IntimacyScoreRule.firstMessage,
        );
      } else {
        intimacy = _intimacies[userId]![partnerId]!;

        // 오늘 첫 메시지인지 확인
        final isDailyFirst = !intimacy.hasChatToday;

        // 메시지 카운트 업데이트
        final newDailyCount = Map<String, int>.from(intimacy.dailyMessageCount);
        newDailyCount[todayKey] = (newDailyCount[todayKey] ?? 0) + 1;

        // 점수 계산
        int scoreToAdd = IntimacyScoreRule.messagePerCount;

        if (isDailyFirst) {
          scoreToAdd += IntimacyScoreRule.dailyMessage;

          // 연속 대화일 체크
          if (intimacy.isChatConsecutive) {
            final newConsecutiveDays = intimacy.consecutiveDays + 1;
            scoreToAdd += IntimacyScoreRule.consecutiveDayBonus;

            // 7일 연속 보너스
            if (newConsecutiveDays % 7 == 0) {
              scoreToAdd += IntimacyScoreRule.weeklyBonus;
            }

            intimacy = intimacy.copyWith(
              consecutiveDays: newConsecutiveDays,
            );
          } else {
            // 연속 대화 끊김
            intimacy = intimacy.copyWith(
              consecutiveDays: 1,
            );
          }
        }

        final newScore = (intimacy.intimacyScore + scoreToAdd).clamp(0, 1000);
        final newLevel = IntimacyLevelExtension.fromScore(newScore);

        intimacy = intimacy.copyWith(
          lastChatDate: now,
          totalMessageCount: intimacy.totalMessageCount + 1,
          dailyMessageCount: newDailyCount,
          intimacyScore: newScore,
          currentLevel: newLevel,
        );
      }

      _intimacies[userId]![partnerId] = intimacy;
      await _saveIntimacy(userId);

      notifyListeners();
    } catch (e) {
      _error = '친밀도 업데이트에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 친밀도 저장
  Future<void> _saveIntimacy(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = <String, dynamic>{};

      _intimacies[userId]?.forEach((partnerId, intimacy) {
        map[partnerId] = intimacy.toMap();
      });

      final intimacyJson = json.encode(map);
      await prefs.setString('chat_intimacy_$userId', intimacyJson);
    } catch (e) {
      debugPrint('Failed to save intimacy: $e');
    }
  }

  /// 특정 필드가 공개되었는지 확인
  bool isFieldUnlocked(String userId, String partnerId, String fieldPath) {
    final intimacy = getIntimacy(userId, partnerId);
    if (intimacy == null) return false;

    return intimacy.currentLevel.unlockedFields.contains(fieldPath);
  }

  /// 현재 레벨에서 공개된 모든 필드 가져오기
  List<String> getUnlockedFields(String userId, String partnerId) {
    final intimacy = getIntimacy(userId, partnerId);
    if (intimacy == null) return [];

    return intimacy.currentLevel.unlockedFields;
  }

  /// 다음 레벨에서 공개될 필드 미리보기
  List<String> getNextLevelFields(String userId, String partnerId) {
    final intimacy = getIntimacy(userId, partnerId);
    if (intimacy == null) return [];

    final currentFields = intimacy.currentLevel.unlockedFields.toSet();
    IntimacyLevel? nextLevel;

    switch (intimacy.currentLevel) {
      case IntimacyLevel.stranger:
        nextLevel = IntimacyLevel.acquaintance;
        break;
      case IntimacyLevel.acquaintance:
        nextLevel = IntimacyLevel.friend;
        break;
      case IntimacyLevel.friend:
        nextLevel = IntimacyLevel.close;
        break;
      case IntimacyLevel.close:
        nextLevel = IntimacyLevel.intimate;
        break;
      case IntimacyLevel.intimate:
        return []; // 최대 레벨
    }

    final nextFields = nextLevel.unlockedFields.toSet();
    return nextFields.difference(currentFields).toList();
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 영상/음성 통화 시 친밀도 업데이트
  Future<void> updateIntimacyOnVideoCall(
    String userId,
    String partnerId,
  ) async {
    try {
      final now = DateTime.now();

      if (_intimacies[userId] == null) {
        _intimacies[userId] = {};
      }

      ChatIntimacy intimacy;
      if (_intimacies[userId]![partnerId] == null) {
        intimacy = ChatIntimacy(
          userId: userId,
          partnerId: partnerId,
          firstChatDate: now,
          lastChatDate: now,
          totalMessageCount: 0,
          consecutiveDays: 1,
          dailyMessageCount: {},
          intimacyScore: IntimacyScoreRule.videoCall,
        );
      } else {
        intimacy = _intimacies[userId]![partnerId]!;
        final newScore = (intimacy.intimacyScore + IntimacyScoreRule.videoCall).clamp(0, 1000);
        final newLevel = IntimacyLevelExtension.fromScore(newScore);

        intimacy = intimacy.copyWith(
          lastChatDate: now,
          intimacyScore: newScore,
          currentLevel: newLevel,
        );
      }

      _intimacies[userId]![partnerId] = intimacy;
      await _saveIntimacy(userId);

      notifyListeners();
    } catch (e) {
      _error = '친밀도 업데이트에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 테스트용: 친밀도 리셋
  Future<void> resetIntimacy(String userId, String partnerId) async {
    try {
      if (_intimacies[userId] != null) {
        _intimacies[userId]!.remove(partnerId);
        await _saveIntimacy(userId);
        notifyListeners();
      }
    } catch (e) {
      _error = '친밀도 리셋에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 테스트용: 친밀도 점수 직접 설정
  Future<void> setIntimacyScore(
    String userId,
    String partnerId,
    int score,
  ) async {
    try {
      final intimacy = getIntimacy(userId, partnerId);
      if (intimacy != null) {
        final newLevel = IntimacyLevelExtension.fromScore(score);
        final updated = intimacy.copyWith(
          intimacyScore: score,
          currentLevel: newLevel,
        );

        _intimacies[userId]![partnerId] = updated;
        await _saveIntimacy(userId);
        notifyListeners();
      }
    } catch (e) {
      _error = '친밀도 설정에 실패했습니다: $e';
      notifyListeners();
    }
  }
}
