import 'package:cloud_firestore/cloud_firestore.dart';

/// 일일 질문 모델
class DailyQuestion {
  final int day; // 1-30일
  final String category; // 카테고리
  final String question; // 질문
  final QuestionType type; // 질문 타입
  final List<String> options; // 선택지 (객관식인 경우)
  final int rewardPoints; // 답변 시 획득 포인트
  final String? placeholder; // 주관식인 경우 힌트
  final bool isRequired; // 필수 여부
  final String profileField; // 프로필에 저장될 필드명

  DailyQuestion({
    required this.day,
    required this.category,
    required this.question,
    required this.type,
    this.options = const [],
    this.rewardPoints = 10,
    this.placeholder,
    this.isRequired = true,
    required this.profileField,
  });

  factory DailyQuestion.fromMap(Map<String, dynamic> map) {
    return DailyQuestion(
      day: map['day'] ?? 1,
      category: map['category'] ?? '',
      question: map['question'] ?? '',
      type: QuestionTypeExtension.fromString(map['type'] ?? 'single_choice'),
      options: List<String>.from(map['options'] ?? []),
      rewardPoints: map['rewardPoints'] ?? 10,
      placeholder: map['placeholder'],
      isRequired: map['isRequired'] ?? true,
      profileField: map['profileField'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'category': category,
      'question': question,
      'type': type.value,
      'options': options,
      'rewardPoints': rewardPoints,
      'placeholder': placeholder,
      'isRequired': isRequired,
      'profileField': profileField,
    };
  }
}

/// 사용자의 질문 답변
class QuestionAnswer {
  final int day;
  final String answer; // 답변 (문자열 또는 JSON)
  final DateTime answeredAt;
  final int earnedPoints;

  QuestionAnswer({
    required this.day,
    required this.answer,
    required this.answeredAt,
    required this.earnedPoints,
  });

  factory QuestionAnswer.fromMap(Map<String, dynamic> map) {
    return QuestionAnswer(
      day: map['day'] ?? 1,
      answer: map['answer'] ?? '',
      answeredAt: (map['answeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      earnedPoints: map['earnedPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'answer': answer,
      'answeredAt': Timestamp.fromDate(answeredAt),
      'earnedPoints': earnedPoints,
    };
  }
}

/// 사용자의 30일 온보딩 진행 상황
class OnboardingProgress {
  final DateTime startDate; // 시작일
  final int currentDay; // 현재 진행 중인 날 (1-30)
  final Map<String, QuestionAnswer> answers; // 답변 ('day_index' 형식)
  final int totalPoints; // 누적 포인트
  final int consecutiveDays; // 연속 답변일
  final bool isCompleted; // 30일 완료 여부

  OnboardingProgress({
    required this.startDate,
    this.currentDay = 1,
    this.answers = const {},
    this.totalPoints = 0,
    this.consecutiveDays = 0,
    this.isCompleted = false,
  });

  /// 완성도 (0-100%) - 총 90개 질문 기준 (하루 3개씩 30일)
  double get completionRate => (answers.length / 90 * 100).clamp(0, 100);

  /// 오늘 답변했는지 여부 (3개 모두 답변했는지)
  bool get hasAnsweredToday {
    int count = 0;
    for (int i = 0; i < 3; i++) {
      final key = '${currentDay}_$i';
      if (answers.containsKey(key)) {
        count++;
      }
    }
    return count >= 3;
  }

  /// 다음 질문까지 남은 시간 (초)
  int get secondsUntilNextQuestion {
    final now = DateTime.now();
    final tomorrow8am = DateTime(now.year, now.month, now.day + 1, 8);
    return tomorrow8am.difference(now).inSeconds;
  }

  factory OnboardingProgress.fromMap(Map<String, dynamic> map) {
    final answersMap = <String, QuestionAnswer>{};
    if (map['answers'] != null) {
      (map['answers'] as Map<String, dynamic>).forEach((key, value) {
        answersMap[key] = QuestionAnswer.fromMap(value);
      });
    }

    return OnboardingProgress(
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      currentDay: map['currentDay'] ?? 1,
      answers: answersMap,
      totalPoints: map['totalPoints'] ?? 0,
      consecutiveDays: map['consecutiveDays'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    final answersMap = <String, dynamic>{};
    answers.forEach((key, value) {
      answersMap[key] = value.toMap();
    });

    return {
      'startDate': Timestamp.fromDate(startDate),
      'currentDay': currentDay,
      'answers': answersMap,
      'totalPoints': totalPoints,
      'consecutiveDays': consecutiveDays,
      'isCompleted': isCompleted,
    };
  }

  OnboardingProgress copyWith({
    DateTime? startDate,
    int? currentDay,
    Map<String, QuestionAnswer>? answers,
    int? totalPoints,
    int? consecutiveDays,
    bool? isCompleted,
  }) {
    return OnboardingProgress(
      startDate: startDate ?? this.startDate,
      currentDay: currentDay ?? this.currentDay,
      answers: answers ?? this.answers,
      totalPoints: totalPoints ?? this.totalPoints,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// 질문 타입
enum QuestionType {
  singleChoice, // 단일 선택
  multipleChoice, // 다중 선택
  text, // 주관식
  slider, // 슬라이더 (숫자)
  date, // 날짜
}

extension QuestionTypeExtension on QuestionType {
  String get value {
    switch (this) {
      case QuestionType.singleChoice:
        return 'single_choice';
      case QuestionType.multipleChoice:
        return 'multiple_choice';
      case QuestionType.text:
        return 'text';
      case QuestionType.slider:
        return 'slider';
      case QuestionType.date:
        return 'date';
    }
  }

  static QuestionType fromString(String value) {
    switch (value) {
      case 'single_choice':
        return QuestionType.singleChoice;
      case 'multiple_choice':
        return QuestionType.multipleChoice;
      case 'text':
        return QuestionType.text;
      case 'slider':
        return QuestionType.slider;
      case 'date':
        return QuestionType.date;
      default:
        return QuestionType.singleChoice;
    }
  }
}
