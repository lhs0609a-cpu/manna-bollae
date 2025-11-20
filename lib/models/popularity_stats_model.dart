class PopularityStats {
  final int viewersNow;
  final int todayLikes;
  final int todayViews;
  final int profileCompleteness;
  final int ranking;
  final int rankingChange; // 양수면 상승, 음수면 하락
  final DateTime lastUpdated;

  PopularityStats({
    required this.viewersNow,
    required this.todayLikes,
    required this.todayViews,
    required this.profileCompleteness,
    required this.ranking,
    required this.rankingChange,
    required this.lastUpdated,
  });

  String get rankingChangeText {
    if (rankingChange > 0) return '↑ $rankingChange';
    if (rankingChange < 0) return '↓ ${rankingChange.abs()}';
    return '-';
  }

  bool get isRising => rankingChange > 0;
  bool get isFalling => rankingChange < 0;

  PopularityStats copyWith({
    int? viewersNow,
    int? todayLikes,
    int? todayViews,
    int? profileCompleteness,
    int? ranking,
    int? rankingChange,
    DateTime? lastUpdated,
  }) {
    return PopularityStats(
      viewersNow: viewersNow ?? this.viewersNow,
      todayLikes: todayLikes ?? this.todayLikes,
      todayViews: todayViews ?? this.todayViews,
      profileCompleteness: profileCompleteness ?? this.profileCompleteness,
      ranking: ranking ?? this.ranking,
      rankingChange: rankingChange ?? this.rankingChange,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'viewersNow': viewersNow,
      'todayLikes': todayLikes,
      'todayViews': todayViews,
      'profileCompleteness': profileCompleteness,
      'ranking': ranking,
      'rankingChange': rankingChange,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory PopularityStats.fromMap(Map<String, dynamic> map) {
    return PopularityStats(
      viewersNow: map['viewersNow'] ?? 0,
      todayLikes: map['todayLikes'] ?? 0,
      todayViews: map['todayViews'] ?? 0,
      profileCompleteness: map['profileCompleteness'] ?? 0,
      ranking: map['ranking'] ?? 999,
      rankingChange: map['rankingChange'] ?? 0,
      lastUpdated: DateTime.parse(map['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }
}
