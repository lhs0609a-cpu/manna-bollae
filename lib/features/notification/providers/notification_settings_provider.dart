import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 알림 설정 모델
class NotificationSettings {
  final bool newMatch; // 새 매칭 알림
  final bool newMessage; // 새 메시지 알림
  final bool newLike; // 좋아요 알림
  final bool scoreChange; // 신뢰점수/하트온도 변경 알림
  final bool dailyQuest; // 데일리 퀘스트 알림
  final bool subscription; // 구독 관련 알림
  final bool marketing; // 마케팅 알림
  final bool event; // 이벤트 알림
  final bool pushEnabled; // 푸시 알림 전체 활성화
  final bool soundEnabled; // 알림 소리
  final bool vibrationEnabled; // 진동
  final String quietStartTime; // 방해금지 시작 시간 (예: "22:00")
  final String quietEndTime; // 방해금지 종료 시간 (예: "08:00")
  final bool quietModeEnabled; // 방해금지 모드 활성화

  NotificationSettings({
    this.newMatch = true,
    this.newMessage = true,
    this.newLike = true,
    this.scoreChange = true,
    this.dailyQuest = true,
    this.subscription = true,
    this.marketing = false,
    this.event = true,
    this.pushEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.quietStartTime = '22:00',
    this.quietEndTime = '08:00',
    this.quietModeEnabled = false,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      newMatch: map['newMatch'] ?? true,
      newMessage: map['newMessage'] ?? true,
      newLike: map['newLike'] ?? true,
      scoreChange: map['scoreChange'] ?? true,
      dailyQuest: map['dailyQuest'] ?? true,
      subscription: map['subscription'] ?? true,
      marketing: map['marketing'] ?? false,
      event: map['event'] ?? true,
      pushEnabled: map['pushEnabled'] ?? true,
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      quietStartTime: map['quietStartTime'] ?? '22:00',
      quietEndTime: map['quietEndTime'] ?? '08:00',
      quietModeEnabled: map['quietModeEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'newMatch': newMatch,
      'newMessage': newMessage,
      'newLike': newLike,
      'scoreChange': scoreChange,
      'dailyQuest': dailyQuest,
      'subscription': subscription,
      'marketing': marketing,
      'event': event,
      'pushEnabled': pushEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'quietStartTime': quietStartTime,
      'quietEndTime': quietEndTime,
      'quietModeEnabled': quietModeEnabled,
    };
  }

  NotificationSettings copyWith({
    bool? newMatch,
    bool? newMessage,
    bool? newLike,
    bool? scoreChange,
    bool? dailyQuest,
    bool? subscription,
    bool? marketing,
    bool? event,
    bool? pushEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? quietStartTime,
    String? quietEndTime,
    bool? quietModeEnabled,
  }) {
    return NotificationSettings(
      newMatch: newMatch ?? this.newMatch,
      newMessage: newMessage ?? this.newMessage,
      newLike: newLike ?? this.newLike,
      scoreChange: scoreChange ?? this.scoreChange,
      dailyQuest: dailyQuest ?? this.dailyQuest,
      subscription: subscription ?? this.subscription,
      marketing: marketing ?? this.marketing,
      event: event ?? this.event,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietStartTime: quietStartTime ?? this.quietStartTime,
      quietEndTime: quietEndTime ?? this.quietEndTime,
      quietModeEnabled: quietModeEnabled ?? this.quietModeEnabled,
    );
  }
}

/// 알림 설정 Provider
class NotificationSettingsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationSettings _settings = NotificationSettings();
  bool _isLoading = false;
  String? _error;

  NotificationSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 알림 설정 로드
  Future<void> loadSettings(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notification')
          .get();

      if (doc.exists) {
        _settings = NotificationSettings.fromMap(doc.data()!);
      } else {
        // 기본 설정 저장
        await _saveSettings(userId, _settings);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '알림 설정을 불러오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 알림 설정 저장
  Future<void> _saveSettings(
      String userId, NotificationSettings settings) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('notification')
        .set(settings.toMap());
  }

  /// 푸시 알림 전체 활성화/비활성화
  Future<void> togglePushEnabled(String userId, bool value) async {
    try {
      _settings = _settings.copyWith(pushEnabled: value);
      await _saveSettings(userId, _settings);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 새 매칭 알림 토글
  Future<void> toggleNewMatch(String userId, bool value) async {
    try {
      _settings = _settings.copyWith(newMatch: value);
      await _saveSettings(userId, _settings);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 새 메시지 알림 토글
  Future<void> toggleNewMessage(String userId, bool value) async {
    try {
      _settings = _settings.copyWith(newMessage: value);
      await _saveSettings(userId, _settings);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 좋아요 알림 토글
  Future<void> toggleNewLike(String userId, bool value) async {
    try {
      _settings = _settings.copyWith(newLike: value);
      await _saveSettings(userId, _settings);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 점수 변경 알림 토글
  Future<void> toggleScoreChange(String userId, bool value) async {
    try {
      _settings = _settings.copyWith(scoreChange: value);
      await _saveSettings(userId, _settings);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 데일리 퀘스트 알림 토글
  Future<void> toggleDailyQuest(String userId, bool value) async {
    try {
      _settings = _settings.copyWith(dailyQuest: value);
      await _saveSettings(userId, _settings);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 구독 알림 토글
  Future<void> toggleSubscription(String userId, bool value) async {
    try {
      _settings = _settings.copyWith(subscription: value);
      await _saveSettings(userId, _settings);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 마케팅 알림 토글
  Future<void> toggleMarketing(String userId, bool value) async {
    try {
      _settings = _settings.copyWith(marketing: value);
      await _saveSettings(userId, _settings);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 이벤트 알림 토글
  Future<void> toggleEvent(String userId, bool value) async {
    try {
      _settings = _settings.copyWith(event: value);
      await _saveSettings(userId, _settings);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 알림 소리 토글
  Future<void> toggleSound(String userId, bool value) async {
    try {
      _settings = _settings.copyWith(soundEnabled: value);
      await _saveSettings(userId, _settings);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 진동 토글
  Future<void> toggleVibration(String userId, bool value) async {
    try {
      _settings = _settings.copyWith(vibrationEnabled: value);
      await _saveSettings(userId, _settings);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 방해금지 모드 토글
  Future<void> toggleQuietMode(String userId, bool value) async {
    try {
      _settings = _settings.copyWith(quietModeEnabled: value);
      await _saveSettings(userId, _settings);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 방해금지 시간 설정
  Future<void> setQuietTime(
      String userId, String startTime, String endTime) async {
    try {
      _settings = _settings.copyWith(
        quietStartTime: startTime,
        quietEndTime: endTime,
      );
      await _saveSettings(userId, _settings);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
