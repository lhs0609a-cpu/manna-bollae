class MissionProgress {
  final int currentDay;
  final DateTime? lastCompletedDate;
  final List<int> completedDays;
  final Map<int, dynamic> answers;
  final int consecutiveDays;
  final DateTime createdAt;

  MissionProgress({
    this.currentDay = 1,
    this.lastCompletedDate,
    List<int>? completedDays,
    Map<int, dynamic>? answers,
    this.consecutiveDays = 0,
    DateTime? createdAt,
  })  : completedDays = completedDays ?? [],
        answers = answers ?? {},
        createdAt = createdAt ?? DateTime.now();

  bool get isCompleted => currentDay > 30;

  bool get canDoTodayMission {
    if (lastCompletedDate == null) return true;

    final today = DateTime.now();
    final lastDate = lastCompletedDate!;

    return today.year != lastDate.year ||
        today.month != lastDate.month ||
        today.day != lastDate.day;
  }

  int get completionPercentage {
    return ((completedDays.length / 30) * 100).round();
  }

  Map<String, dynamic> toJson() {
    return {
      'currentDay': currentDay,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'completedDays': completedDays,
      'answers': answers,
      'consecutiveDays': consecutiveDays,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MissionProgress.fromJson(Map<String, dynamic> json) {
    return MissionProgress(
      currentDay: json['currentDay'] ?? 1,
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'])
          : null,
      completedDays: json['completedDays'] != null
          ? List<int>.from(json['completedDays'])
          : [],
      answers: json['answers'] != null
          ? Map<int, dynamic>.from(json['answers'])
          : {},
      consecutiveDays: json['consecutiveDays'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  MissionProgress copyWith({
    int? currentDay,
    DateTime? lastCompletedDate,
    List<int>? completedDays,
    Map<int, dynamic>? answers,
    int? consecutiveDays,
    DateTime? createdAt,
  }) {
    return MissionProgress(
      currentDay: currentDay ?? this.currentDay,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      completedDays: completedDays ?? this.completedDays,
      answers: answers ?? this.answers,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
