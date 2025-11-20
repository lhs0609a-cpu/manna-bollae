class StreakModel {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastCheckIn;
  final List<DateTime> checkInHistory;
  final Map<int, String> rewards; // 일수별 보상

  StreakModel({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastCheckIn,
    required this.checkInHistory,
    required this.rewards,
  });

  bool get canCheckInToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCheckInDay = DateTime(
      lastCheckIn.year,
      lastCheckIn.month,
      lastCheckIn.day,
    );
    return today.isAfter(lastCheckInDay);
  }

  bool get isStreakBroken {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdayDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final lastCheckInDay = DateTime(
      lastCheckIn.year,
      lastCheckIn.month,
      lastCheckIn.day,
    );
    return lastCheckInDay.isBefore(yesterdayDate);
  }

  String get streakEmoji {
    if (currentStreak >= 30) return '🏆';
    if (currentStreak >= 14) return '💎';
    if (currentStreak >= 7) return '🔥';
    if (currentStreak >= 3) return '⭐';
    return '✨';
  }

  String get streakMessage {
    if (currentStreak >= 30) return '전설의 스트릭! 대단해요!';
    if (currentStreak >= 14) return '2주 연속! 거의 다 왔어요!';
    if (currentStreak >= 7) return '1주일 달성! 축하합니다!';
    if (currentStreak >= 3) return '3일 연속! 계속 가세요!';
    return '시작이 반이에요!';
  }

  factory StreakModel.fromMap(Map<String, dynamic> map) {
    return StreakModel(
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastCheckIn: DateTime.parse(map['lastCheckIn'] ?? DateTime.now().toIso8601String()),
      checkInHistory: (map['checkInHistory'] as List<dynamic>?)
              ?.map((e) => DateTime.parse(e as String))
              .toList() ??
          [],
      rewards: Map<int, String>.from(map['rewards'] ?? {
        3: '매칭권 +1',
        7: '슈퍼 라이크 +2',
        14: '프로필 부스트 24시간',
        30: '황금 뱃지 + 매칭권 +5',
      }),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCheckIn': lastCheckIn.toIso8601String(),
      'checkInHistory': checkInHistory.map((e) => e.toIso8601String()).toList(),
      'rewards': rewards,
    };
  }

  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCheckIn,
    List<DateTime>? checkInHistory,
    Map<int, String>? rewards,
  }) {
    return StreakModel(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      checkInHistory: checkInHistory ?? this.checkInHistory,
      rewards: rewards ?? this.rewards,
    );
  }
}
