import 'gacha_box.dart';
import 'gacha_reward.dart';

class GachaProgress {
  final int totalPulls; // 총 뽑기 횟수
  final int todayPulls; // 오늘 뽑기 횟수
  final Map<String, int> rewardInventory; // 보유 아이템 목록 (reward_id -> count)
  final List<GachaResult> history; // 최근 획득 히스토리
  final DateTime? lastPullAt; // 마지막 뽑기 시간
  final int consecutiveDays; // 연속 출석 일수
  final DateTime? lastAttendanceDate; // 마지막 출석 날짜
  final Map<GachaBoxType, int> pullCountByType; // 타입별 뽑기 횟수
  final Map<RewardRarity, int> obtainedByRarity; // 희귀도별 획득 횟수

  GachaProgress({
    this.totalPulls = 0,
    this.todayPulls = 0,
    Map<String, int>? rewardInventory,
    List<GachaResult>? history,
    this.lastPullAt,
    this.consecutiveDays = 0,
    this.lastAttendanceDate,
    Map<GachaBoxType, int>? pullCountByType,
    Map<RewardRarity, int>? obtainedByRarity,
  })  : rewardInventory = rewardInventory ?? {},
        history = history ?? [],
        pullCountByType = pullCountByType ?? {},
        obtainedByRarity = obtainedByRarity ?? {};

  // 특정 아이템 개수 확인
  int getRewardCount(String rewardId) {
    return rewardInventory[rewardId] ?? 0;
  }

  // 특정 희귀도 획득 횟수
  int getRarityCount(RewardRarity rarity) {
    return obtainedByRarity[rarity] ?? 0;
  }

  // 특정 타입 뽑기 횟수
  int getTypeCount(GachaBoxType type) {
    return pullCountByType[type] ?? 0;
  }

  // 오늘 날짜인지 확인
  bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // 어제 날짜인지 확인
  bool isYesterday(DateTime? date) {
    if (date == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // 연속 출석 체크 가능 여부
  bool canCheckAttendance() {
    if (lastAttendanceDate == null) return true;
    return !isToday(lastAttendanceDate);
  }

  // 연속 출석이 끊겼는지 확인
  bool isStreakBroken() {
    if (lastAttendanceDate == null) return false;
    return !isToday(lastAttendanceDate) && !isYesterday(lastAttendanceDate);
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPulls': totalPulls,
      'todayPulls': todayPulls,
      'rewardInventory': rewardInventory,
      'history': history.map((r) => r.toJson()).toList(),
      'lastPullAt': lastPullAt?.toIso8601String(),
      'consecutiveDays': consecutiveDays,
      'lastAttendanceDate': lastAttendanceDate?.toIso8601String(),
      'pullCountByType': pullCountByType.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'obtainedByRarity': obtainedByRarity.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
    };
  }

  factory GachaProgress.fromJson(Map<String, dynamic> json) {
    return GachaProgress(
      totalPulls: json['totalPulls'] ?? 0,
      todayPulls: json['todayPulls'] ?? 0,
      rewardInventory: json['rewardInventory'] != null
          ? Map<String, int>.from(json['rewardInventory'])
          : {},
      history: json['history'] != null
          ? (json['history'] as List)
              .map((h) => GachaResult.fromJson(h))
              .toList()
          : [],
      lastPullAt: json['lastPullAt'] != null
          ? DateTime.parse(json['lastPullAt'])
          : null,
      consecutiveDays: json['consecutiveDays'] ?? 0,
      lastAttendanceDate: json['lastAttendanceDate'] != null
          ? DateTime.parse(json['lastAttendanceDate'])
          : null,
      pullCountByType: json['pullCountByType'] != null
          ? (json['pullCountByType'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(
                GachaBoxType.values.firstWhere((e) => e.toString() == k),
                v as int,
              ),
            )
          : {},
      obtainedByRarity: json['obtainedByRarity'] != null
          ? (json['obtainedByRarity'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(
                RewardRarity.values.firstWhere((e) => e.toString() == k),
                v as int,
              ),
            )
          : {},
    );
  }

  GachaProgress copyWith({
    int? totalPulls,
    int? todayPulls,
    Map<String, int>? rewardInventory,
    List<GachaResult>? history,
    DateTime? lastPullAt,
    int? consecutiveDays,
    DateTime? lastAttendanceDate,
    Map<GachaBoxType, int>? pullCountByType,
    Map<RewardRarity, int>? obtainedByRarity,
  }) {
    return GachaProgress(
      totalPulls: totalPulls ?? this.totalPulls,
      todayPulls: todayPulls ?? this.todayPulls,
      rewardInventory: rewardInventory ?? this.rewardInventory,
      history: history ?? this.history,
      lastPullAt: lastPullAt ?? this.lastPullAt,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      lastAttendanceDate: lastAttendanceDate ?? this.lastAttendanceDate,
      pullCountByType: pullCountByType ?? this.pullCountByType,
      obtainedByRarity: obtainedByRarity ?? this.obtainedByRarity,
    );
  }
}
