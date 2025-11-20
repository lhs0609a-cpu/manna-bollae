class DailyMission {
  final String id;
  final String title;
  final String description;
  final int targetCount;
  final int currentCount;
  final MissionReward reward;
  final MissionType type;
  final bool isCompleted;

  DailyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.targetCount,
    required this.currentCount,
    required this.reward,
    required this.type,
    required this.isCompleted,
  });

  double get progress => currentCount / targetCount;
  bool get canClaim => currentCount >= targetCount && !isCompleted;

  DailyMission copyWith({
    String? id,
    String? title,
    String? description,
    int? targetCount,
    int? currentCount,
    MissionReward? reward,
    MissionType? type,
    bool? isCompleted,
  }) {
    return DailyMission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      reward: reward ?? this.reward,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'reward': reward.toMap(),
      'type': type.name,
      'isCompleted': isCompleted,
    };
  }

  factory DailyMission.fromMap(Map<String, dynamic> map) {
    return DailyMission(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      targetCount: map['targetCount'],
      currentCount: map['currentCount'],
      reward: MissionReward.fromMap(map['reward']),
      type: MissionType.values.firstWhere((e) => e.name == map['type']),
      isCompleted: map['isCompleted'],
    );
  }
}

enum MissionType {
  viewProfiles,
  sendLikes,
  sendMessages,
  writeQuest,
  login,
  completeProfile,
}

class MissionReward {
  final MissionRewardType type;
  final double value;
  final String description;

  MissionReward({
    required this.type,
    required this.value,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'value': value,
      'description': description,
    };
  }

  factory MissionReward.fromMap(Map<String, dynamic> map) {
    return MissionReward(
      type: MissionRewardType.values.firstWhere((e) => e.name == map['type']),
      value: map['value'],
      description: map['description'],
    );
  }
}

enum MissionRewardType {
  trustScore,
  heartTemperature,
  luckyBox,
  coin,
  avatarItem,
}
