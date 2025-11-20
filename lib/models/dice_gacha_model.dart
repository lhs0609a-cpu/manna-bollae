/// 주사위 등급
enum DiceRarity {
  ssr,  // 🏆 Super Rare: 6-6-6
  sr,   // ⭐ Rare: 같은 숫자 (4-5)
  r,    // 💎 Rare: 같은 숫자 (1-3)
  n,    // ✨ Normal: 두 개 같음
  fail, // 💫 Fail: 모두 다름
}

/// 주사위 가챠 모델
class DiceGachaResult {
  final int dice1;
  final int dice2;
  final int dice3;
  final DateTime rolledAt;
  final bool isJackpot; // 세 주사위가 모두 같은 숫자인지

  DiceGachaResult({
    required this.dice1,
    required this.dice2,
    required this.dice3,
    required this.rolledAt,
  }) : isJackpot = (dice1 == dice2 && dice2 == dice3);

  /// 주사위 등급 계산
  DiceRarity get rarity {
    // 세 개가 모두 같은 경우
    if (dice1 == dice2 && dice2 == dice3) {
      if (dice1 == 6) return DiceRarity.ssr; // 6-6-6
      if (dice1 >= 4) return DiceRarity.sr;  // 4-4-4, 5-5-5
      return DiceRarity.r;                    // 1-1-1, 2-2-2, 3-3-3
    }

    // 두 개가 같은 경우
    if (dice1 == dice2 || dice2 == dice3 || dice1 == dice3) {
      return DiceRarity.n;
    }

    // 모두 다른 경우
    return DiceRarity.fail;
  }

  /// 보너스 매칭 개수 (등급별 차등 지급)
  int get bonusMatches {
    switch (rarity) {
      case DiceRarity.ssr:
        return 10; // 6-6-6: +10 매칭
      case DiceRarity.sr:
        return dice1; // 4-4-4 or 5-5-5: +4 or +5 매칭
      case DiceRarity.r:
        return dice1; // 1-1-1, 2-2-2, 3-3-3: +1, +2, +3 매칭
      case DiceRarity.n:
        return 1; // 두 개 같음: +1 매칭
      case DiceRarity.fail:
        return 0; // 실패: 보상 없음
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'dice1': dice1,
      'dice2': dice2,
      'dice3': dice3,
      'rolledAt': rolledAt.toIso8601String(),
      'isJackpot': isJackpot,
    };
  }

  factory DiceGachaResult.fromMap(Map<String, dynamic> map) {
    return DiceGachaResult(
      dice1: map['dice1'] ?? 1,
      dice2: map['dice2'] ?? 1,
      dice3: map['dice3'] ?? 1,
      rolledAt: DateTime.parse(map['rolledAt']),
    );
  }
}

/// 주사위 가챠 진행 상황
class DiceGachaProgress {
  final String userId;
  final DateTime lastRollDate;
  final int totalRolls;
  final int totalJackpots;
  final int totalBonusMatches;
  final List<DiceGachaResult> recentResults; // 최근 10개 결과

  DiceGachaProgress({
    required this.userId,
    required this.lastRollDate,
    this.totalRolls = 0,
    this.totalJackpots = 0,
    this.totalBonusMatches = 0,
    this.recentResults = const [],
  });

  /// 3분이 지났는지 확인 (다시 굴릴 수 있는지)
  bool get canRollAgain {
    final now = DateTime.now();
    final difference = now.difference(lastRollDate);
    return difference.inMinutes >= 3;
  }

  /// 다음 굴림까지 남은 시간 (초)
  int get secondsUntilNextRoll {
    final now = DateTime.now();
    final difference = now.difference(lastRollDate);
    final minutesPassed = difference.inMinutes;

    if (minutesPassed >= 3) return 0;

    final remainingMinutes = 3 - minutesPassed;
    final remainingSeconds = (remainingMinutes * 60) - (difference.inSeconds % 60);
    return remainingSeconds;
  }

  /// 성공률 (%)
  double get successRate {
    if (totalRolls == 0) return 0.0;
    return (totalJackpots / totalRolls) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'lastRollDate': lastRollDate.toIso8601String(),
      'totalRolls': totalRolls,
      'totalJackpots': totalJackpots,
      'totalBonusMatches': totalBonusMatches,
      'recentResults': recentResults.map((r) => r.toMap()).toList(),
    };
  }

  factory DiceGachaProgress.fromMap(Map<String, dynamic> map) {
    return DiceGachaProgress(
      userId: map['userId'] ?? '',
      lastRollDate: DateTime.parse(map['lastRollDate']),
      totalRolls: map['totalRolls'] ?? 0,
      totalJackpots: map['totalJackpots'] ?? 0,
      totalBonusMatches: map['totalBonusMatches'] ?? 0,
      recentResults: (map['recentResults'] as List?)
              ?.map((r) => DiceGachaResult.fromMap(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  DiceGachaProgress copyWith({
    String? userId,
    DateTime? lastRollDate,
    int? totalRolls,
    int? totalJackpots,
    int? totalBonusMatches,
    List<DiceGachaResult>? recentResults,
  }) {
    return DiceGachaProgress(
      userId: userId ?? this.userId,
      lastRollDate: lastRollDate ?? this.lastRollDate,
      totalRolls: totalRolls ?? this.totalRolls,
      totalJackpots: totalJackpots ?? this.totalJackpots,
      totalBonusMatches: totalBonusMatches ?? this.totalBonusMatches,
      recentResults: recentResults ?? this.recentResults,
    );
  }
}
