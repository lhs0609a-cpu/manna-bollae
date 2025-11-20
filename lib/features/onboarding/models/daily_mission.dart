enum MissionType {
  text,        // 텍스트 입력
  choice,      // 단일 선택
  multiChoice, // 복수 선택
  photo,       // 사진 업로드
  range,       // 범위 선택 (나이, 키 등)
}

class DailyMission {
  final int day;
  final String category;
  final String title;
  final String question;
  final String? placeholder;
  final MissionType type;
  final List<String>? choices;
  final int? minValue;
  final int? maxValue;
  final int rewardTrustScore;
  final double rewardTemperature;
  final String? icon;

  const DailyMission({
    required this.day,
    required this.category,
    required this.title,
    required this.question,
    this.placeholder,
    required this.type,
    this.choices,
    this.minValue,
    this.maxValue,
    this.rewardTrustScore = 1,
    this.rewardTemperature = 0.1,
    this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'category': category,
      'title': title,
      'question': question,
      'placeholder': placeholder,
      'type': type.toString(),
      'choices': choices,
      'minValue': minValue,
      'maxValue': maxValue,
      'rewardTrustScore': rewardTrustScore,
      'rewardTemperature': rewardTemperature,
      'icon': icon,
    };
  }

  factory DailyMission.fromJson(Map<String, dynamic> json) {
    return DailyMission(
      day: json['day'],
      category: json['category'],
      title: json['title'],
      question: json['question'],
      placeholder: json['placeholder'],
      type: MissionType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      choices: json['choices'] != null
          ? List<String>.from(json['choices'])
          : null,
      minValue: json['minValue'],
      maxValue: json['maxValue'],
      rewardTrustScore: json['rewardTrustScore'] ?? 1,
      rewardTemperature: (json['rewardTemperature'] ?? 0.1).toDouble(),
      icon: json['icon'],
    );
  }
}
