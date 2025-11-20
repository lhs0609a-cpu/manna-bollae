import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../models/daily_question_model.dart';
import '../../../data/daily_questions_data.dart';

class DailyQuestionProvider extends ChangeNotifier {
  OnboardingProgress _progress = OnboardingProgress(
    startDate: DateTime.now(),
  );

  bool _isLoading = false;
  String? _error;

  OnboardingProgress get progress => _progress;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 오늘의 질문들 (하루 3개)
  List<DailyQuestion> get todayQuestions {
    if (_progress.isCompleted) return [];

    final questions = <DailyQuestion>[];
    final seed = _progress.startDate.millisecondsSinceEpoch;

    // 하루에 3개 질문 (questionIndex 0, 1, 2)
    for (int i = 0; i < 3; i++) {
      final question = DailyQuestionsData.getQuestionForDayAndIndex(
        _progress.currentDay,
        i,
        seed: seed,
      );
      if (question != null) {
        questions.add(question);
      }
    }

    return questions;
  }

  /// 오늘의 질문 (첫 번째 질문, 호환성 유지)
  DailyQuestion? get todayQuestion {
    final questions = todayQuestions;
    return questions.isNotEmpty ? questions[0] : null;
  }

  /// 오늘 답변한 질문 개수
  int get todayAnsweredCount {
    int count = 0;
    for (int i = 0; i < 3; i++) {
      final key = '${_progress.currentDay}_$i';
      if (_progress.answers.containsKey(key)) {
        count++;
      }
    }
    return count;
  }

  /// 오늘 모든 질문에 답변했는지
  bool get hasAnsweredToday {
    return todayAnsweredCount >= 3;
  }

  /// 진행률 (0-100%)
  double get completionRate => _progress.completionRate;

  /// 다음 질문까지 남은 시간
  String get timeUntilNextQuestion {
    final seconds = _progress.secondsUntilNextQuestion;
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  /// 초기화
  Future<void> initialize(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('onboarding_progress_$userId');

      if (progressJson != null) {
        final map = json.decode(progressJson) as Map<String, dynamic>;
        _progress = OnboardingProgress.fromMap(map);

        // 날짜가 바뀌었는지 확인
        _checkAndUpdateDay();
      } else {
        // 처음 시작하는 경우
        _progress = OnboardingProgress(
          startDate: DateTime.now(),
          currentDay: 1,
        );
        await _saveProgress(userId);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '데이터를 불러오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 날짜 확인 및 업데이트
  void _checkAndUpdateDay() {
    final now = DateTime.now();
    final daysSinceStart = now.difference(_progress.startDate).inDays;

    // 매일 오전 8시가 기준
    final today8am = DateTime(now.year, now.month, now.day, 8);
    final hasPassedToday8am = now.isAfter(today8am);

    int newDay = daysSinceStart + 1;
    if (!hasPassedToday8am && daysSinceStart > 0) {
      newDay = daysSinceStart;
    }

    // 30일 초과하면 30일로 고정
    if (newDay > 30) {
      newDay = 30;
      if (!_progress.isCompleted) {
        _progress = _progress.copyWith(isCompleted: true);
      }
    }

    if (_progress.currentDay != newDay) {
      _progress = _progress.copyWith(currentDay: newDay);
    }
  }

  /// 특정 질문 답변 제출 (하루 3개 중 하나)
  Future<bool> submitAnswer(String userId, String answer, {int questionIndex = 0}) async {
    try {
      if (_progress.isCompleted) {
        _error = '이미 모든 질문을 완료했습니다!';
        notifyListeners();
        return false;
      }

      // 이미 답변한 질문인지 확인
      final key = '${_progress.currentDay}_$questionIndex';
      if (_progress.answers.containsKey(key)) {
        _error = '이미 답변한 질문입니다.';
        notifyListeners();
        return false;
      }

      final question = DailyQuestionsData.getQuestionForDayAndIndex(
        _progress.currentDay,
        questionIndex,
        seed: _progress.startDate.millisecondsSinceEpoch,
      );

      if (question == null) {
        _error = '질문을 찾을 수 없습니다.';
        notifyListeners();
        return false;
      }

      // 답변 저장
      final questionAnswer = QuestionAnswer(
        day: _progress.currentDay,
        answer: answer,
        answeredAt: DateTime.now(),
        earnedPoints: question.rewardPoints,
      );

      final newAnswers = Map<String, QuestionAnswer>.from(_progress.answers);
      newAnswers[key] = questionAnswer;

      // 오늘 3개 질문을 모두 답변했는지 확인
      int answeredToday = 0;
      for (int i = 0; i < 3; i++) {
        if (newAnswers.containsKey('${_progress.currentDay}_$i')) {
          answeredToday++;
        }
      }

      // 연속 답변일 계산 (3개를 모두 답변했을 때만)
      int consecutiveDays = _progress.consecutiveDays;
      int bonusPoints = 0;

      if (answeredToday == 3) {
        if (_progress.currentDay > 1) {
          // 전날도 3개를 모두 답변했는지 확인
          int prevDayAnswered = 0;
          for (int i = 0; i < 3; i++) {
            if (_progress.answers.containsKey('${_progress.currentDay - 1}_$i')) {
              prevDayAnswered++;
            }
          }
          if (prevDayAnswered == 3) {
            consecutiveDays++;
          } else {
            consecutiveDays = 1;
          }
        } else {
          consecutiveDays = 1;
        }

        // 보너스 포인트 (연속 답변 시)
        if (consecutiveDays >= 7) {
          bonusPoints = 50; // 7일 연속 보너스
        } else if (consecutiveDays >= 3) {
          bonusPoints = 20; // 3일 연속 보너스
        }
      }

      _progress = _progress.copyWith(
        answers: newAnswers,
        totalPoints: _progress.totalPoints + question.rewardPoints + bonusPoints,
        consecutiveDays: consecutiveDays,
      );

      await _saveProgress(userId);

      notifyListeners();
      return true;
    } catch (e) {
      _error = '답변 저장에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 진행 상황 저장
  Future<void> _saveProgress(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = json.encode(_progress.toMap());
      await prefs.setString('onboarding_progress_$userId', progressJson);
    } catch (e) {
      debugPrint('Failed to save progress: $e');
    }
  }

  /// 특정 날짜의 답변 가져오기
  QuestionAnswer? getAnswerByDay(int day) {
    return _progress.answers[day];
  }

  /// 특정 날짜의 질문 가져오기 (랜덤)
  DailyQuestion? getQuestionByDay(int day) {
    final seed = _progress.startDate.millisecondsSinceEpoch + day;
    return DailyQuestionsData.getRandomQuestionForDay(day, seed: seed);
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 온보딩 리셋 (테스트용)
  Future<void> resetOnboarding(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_progress_$userId');

      _progress = OnboardingProgress(
        startDate: DateTime.now(),
        currentDay: 1,
      );

      notifyListeners();
    } catch (e) {
      _error = '리셋에 실패했습니다: $e';
      notifyListeners();
    }
  }
}
