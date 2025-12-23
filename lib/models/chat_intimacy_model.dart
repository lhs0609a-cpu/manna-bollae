import 'package:cloud_firestore/cloud_firestore.dart';

/// 채팅 친밀도 모델
/// 꾸준히 대화를 나눈 만큼 상대방의 정보가 점진적으로 공개됨
class ChatIntimacy {
  final String userId; // 내 userId
  final String partnerId; // 상대방 userId
  final DateTime firstChatDate; // 첫 대화 날짜
  final DateTime lastChatDate; // 마지막 대화 날짜
  final int totalMessageCount; // 총 메시지 수
  final int consecutiveDays; // 연속 대화일
  final Map<String, int> dailyMessageCount; // 날짜별 메시지 수 {"2025-01-15": 25}
  final IntimacyLevel currentLevel; // 현재 친밀도 레벨
  final int intimacyScore; // 친밀도 점수 (0-1000)

  ChatIntimacy({
    required this.userId,
    required this.partnerId,
    required this.firstChatDate,
    required this.lastChatDate,
    this.totalMessageCount = 0,
    this.consecutiveDays = 0,
    this.dailyMessageCount = const {},
    this.currentLevel = IntimacyLevel.stranger,
    this.intimacyScore = 0,
  });

  /// 현재 레벨의 진행률 (0-100%)
  double get levelProgress {
    final nextLevelScore = currentLevel.nextLevelScore;
    final currentLevelScore = currentLevel.minScore;

    if (nextLevelScore == null) return 100.0; // 최대 레벨

    return ((intimacyScore - currentLevelScore) / (nextLevelScore - currentLevelScore) * 100)
        .clamp(0, 100);
  }

  /// 다음 레벨까지 필요한 점수
  int get scoreToNextLevel {
    final nextLevelScore = currentLevel.nextLevelScore;
    if (nextLevelScore == null) return 0; // 최대 레벨
    return nextLevelScore - intimacyScore;
  }

  /// 대화 연속 여부 (어제 대화했는지)
  bool get isChatConsecutive {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final yesterdayKey = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    return dailyMessageCount.containsKey(yesterdayKey) &&
           dailyMessageCount[yesterdayKey]! > 0;
  }

  /// 오늘 대화했는지
  bool get hasChatToday {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return dailyMessageCount.containsKey(todayKey) &&
           dailyMessageCount[todayKey]! > 0;
  }

  /// 며칠째 알고 지냈는지
  int get daysKnown {
    return DateTime.now().difference(firstChatDate).inDays + 1;
  }

  factory ChatIntimacy.fromMap(Map<String, dynamic> map) {
    return ChatIntimacy(
      userId: map['userId'] ?? '',
      partnerId: map['partnerId'] ?? '',
      firstChatDate: (map['firstChatDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastChatDate: (map['lastChatDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalMessageCount: map['totalMessageCount'] ?? 0,
      consecutiveDays: map['consecutiveDays'] ?? 0,
      dailyMessageCount: Map<String, int>.from(map['dailyMessageCount'] ?? {}),
      currentLevel: IntimacyLevelExtension.fromScore(map['intimacyScore'] ?? 0),
      intimacyScore: map['intimacyScore'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'partnerId': partnerId,
      'firstChatDate': Timestamp.fromDate(firstChatDate),
      'lastChatDate': Timestamp.fromDate(lastChatDate),
      'totalMessageCount': totalMessageCount,
      'consecutiveDays': consecutiveDays,
      'dailyMessageCount': dailyMessageCount,
      'currentLevel': currentLevel.value,
      'intimacyScore': intimacyScore,
    };
  }

  ChatIntimacy copyWith({
    String? userId,
    String? partnerId,
    DateTime? firstChatDate,
    DateTime? lastChatDate,
    int? totalMessageCount,
    int? consecutiveDays,
    Map<String, int>? dailyMessageCount,
    IntimacyLevel? currentLevel,
    int? intimacyScore,
  }) {
    return ChatIntimacy(
      userId: userId ?? this.userId,
      partnerId: partnerId ?? this.partnerId,
      firstChatDate: firstChatDate ?? this.firstChatDate,
      lastChatDate: lastChatDate ?? this.lastChatDate,
      totalMessageCount: totalMessageCount ?? this.totalMessageCount,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      dailyMessageCount: dailyMessageCount ?? this.dailyMessageCount,
      currentLevel: currentLevel ?? this.currentLevel,
      intimacyScore: intimacyScore ?? this.intimacyScore,
    );
  }
}

/// 친밀도 레벨
enum IntimacyLevel {
  stranger,      // 낯선 사람 (0-99점)
  acquaintance,  // 1주차 - 아는 사람 (100-299점)
  friend,        // 2주차 - 친구 (300-599점)
  close,         // 3주차 - 가까운 사이 (600-899점)
  intimate,      // 4주차 - 친밀한 사이 (900-1000점)
}

extension IntimacyLevelExtension on IntimacyLevel {
  String get value {
    switch (this) {
      case IntimacyLevel.stranger:
        return 'stranger';
      case IntimacyLevel.acquaintance:
        return 'acquaintance';
      case IntimacyLevel.friend:
        return 'friend';
      case IntimacyLevel.close:
        return 'close';
      case IntimacyLevel.intimate:
        return 'intimate';
    }
  }

  String get displayName {
    switch (this) {
      case IntimacyLevel.stranger:
        return '낯선 사람';
      case IntimacyLevel.acquaintance:
        return '아는 사람';
      case IntimacyLevel.friend:
        return '친구';
      case IntimacyLevel.close:
        return '가까운 사이';
      case IntimacyLevel.intimate:
        return '친밀한 사이';
    }
  }

  String get description {
    switch (this) {
      case IntimacyLevel.stranger:
        return '아직 서로에 대해 잘 모르는 사이';
      case IntimacyLevel.acquaintance:
        return '기본 정보를 알 수 있어요';
      case IntimacyLevel.friend:
        return '라이프스타일을 알 수 있어요';
      case IntimacyLevel.close:
        return '상세한 취향을 알 수 있어요';
      case IntimacyLevel.intimate:
        return '모든 정보를 알 수 있어요';
    }
  }

  int get minScore {
    switch (this) {
      case IntimacyLevel.stranger:
        return 0;
      case IntimacyLevel.acquaintance:
        return 100;
      case IntimacyLevel.friend:
        return 300;
      case IntimacyLevel.close:
        return 600;
      case IntimacyLevel.intimate:
        return 900;
    }
  }

  int? get nextLevelScore {
    switch (this) {
      case IntimacyLevel.stranger:
        return 100;
      case IntimacyLevel.acquaintance:
        return 300;
      case IntimacyLevel.friend:
        return 600;
      case IntimacyLevel.close:
        return 900;
      case IntimacyLevel.intimate:
        return null; // 최대 레벨
    }
  }

  /// 이 레벨에서 공개되는 정보 목록
  List<String> get unlockedFields {
    switch (this) {
      case IntimacyLevel.stranger:
        return [];

      case IntimacyLevel.acquaintance:
        // 1주차: 기본 정보
        return [
          'basicInfo.mbti',
          'basicInfo.region',
          'basicInfo.ageRange',
          'basicInfo.bloodType',
          'profile.oneLiner',
          'avatar',
        ];

      case IntimacyLevel.friend:
        // 2주차: 라이프스타일 추가
        return [
          ...IntimacyLevel.acquaintance.unlockedFields,
          'lifestyle.hobbies',
          'lifestyle.exerciseFrequency',
          'lifestyle.travelStyle',
          'lifestyle.hasPet',
          'basicInfo.smoking',
          'basicInfo.drinking',
          'basicInfo.religion',
        ];

      case IntimacyLevel.close:
        // 3주차: 상세 정보 추가
        return [
          ...IntimacyLevel.friend.unlockedFields,
          'appearance.heightRange',
          'appearance.bodyType',
          'detailedInfo.favoriteMusic',
          'detailedInfo.favoriteMovies',
          'detailedInfo.dateStyle',
          'detailedInfo.relationshipView',
        ];

      case IntimacyLevel.intimate:
        // 4주차: VIP 정보 추가 (모든 정보)
        return [
          ...IntimacyLevel.close.unlockedFields,
          'appearance.exactHeight',
          'basicInfo.exactAge',
          'basicInfo.detailedRegion',
          'vipInfo.job',
          'vipInfo.education',
          'vipInfo.salaryRange',
          'vipInfo.marriagePlan',
          'vipInfo.childcarePlan',
          'detailedInfo.voiceRecording',
          'detailedInfo.dailyPhotos',
        ];
    }
  }

  static IntimacyLevel fromString(String value) {
    switch (value) {
      case 'stranger':
        return IntimacyLevel.stranger;
      case 'acquaintance':
        return IntimacyLevel.acquaintance;
      case 'friend':
        return IntimacyLevel.friend;
      case 'close':
        return IntimacyLevel.close;
      case 'intimate':
        return IntimacyLevel.intimate;
      default:
        return IntimacyLevel.stranger;
    }
  }

  static IntimacyLevel fromScore(int score) {
    if (score >= 900) return IntimacyLevel.intimate;
    if (score >= 600) return IntimacyLevel.close;
    if (score >= 300) return IntimacyLevel.friend;
    if (score >= 100) return IntimacyLevel.acquaintance;
    return IntimacyLevel.stranger;
  }
}

/// 친밀도 점수 획득 규칙
class IntimacyScoreRule {
  static const int firstMessage = 10; // 첫 메시지
  static const int dailyMessage = 5; // 하루 첫 메시지
  static const int messagePerCount = 1; // 메시지당 점수
  static const int consecutiveDayBonus = 10; // 연속 대화일 보너스
  static const int weeklyBonus = 50; // 일주일 연속 보너스
  static const int videoCall = 50; // 영상통화 보너스
}
