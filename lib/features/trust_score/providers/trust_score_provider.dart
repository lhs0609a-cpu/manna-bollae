import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';
import '../../../core/constants/app_constants.dart';

class TrustScoreProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TrustScore? _trustScore;
  bool _isLoading = false;
  String? _error;

  TrustScore? get trustScore => _trustScore;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 신뢰 지수 로드
  Future<void> loadTrustScore(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _trustScore = TrustScore.fromMap(userData['trustScore'] ?? {});
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '신뢰 지수를 불러오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 일일 퀘스트 완료
  Future<bool> completeDailyQuest(String userId, String questText) async {
    try {
      // 최소 글자 수 확인
      if (questText.length < AppConstants.questMinLength) {
        _error = '최소 ${AppConstants.questMinLength}자 이상 작성해주세요';
        notifyListeners();
        return false;
      }

      if (questText.length > AppConstants.questMaxLength) {
        _error = '최대 ${AppConstants.questMaxLength}자까지 작성 가능합니다';
        notifyListeners();
        return false;
      }

      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();
      final userData = userDoc.data()!;
      final trustScore = TrustScore.fromMap(userData['trustScore'] ?? {});

      // 오늘 이미 완료했는지 확인
      final today = DateTime.now();
      final lastQuestDate = trustScore.lastQuestDate;

      if (lastQuestDate != null &&
          lastQuestDate.year == today.year &&
          lastQuestDate.month == today.month &&
          lastQuestDate.day == today.day) {
        _error = '오늘은 이미 퀘스트를 완료했습니다';
        notifyListeners();
        return false;
      }

      // 연속 로그인 체크
      int newStreak = 1;
      if (lastQuestDate != null) {
        final difference = today.difference(lastQuestDate).inDays;
        if (difference == 1) {
          // 연속
          newStreak = trustScore.questStreak + 1;
        }
      }

      // 7일 연속 보너스
      double bonusScore = 0.0;
      if (newStreak == 7) {
        bonusScore = AppConstants.trustScoreSevenDayBonus;
      }

      // 점수 업데이트
      final double newScore =
          (trustScore.score + AppConstants.trustScoreDailyQuest + bonusScore)
              .clamp(0.0, 100.0);

      final updatedTrustScore = trustScore.copyWith(
        score: newScore,
        dailyQuestStreak: newStreak,
        consecutiveLoginDays:
            trustScore.consecutiveLoginDays > newStreak
                ? trustScore.consecutiveLoginDays
                : newStreak,
        lastQuestDate: today,
      );

      await userRef.update({
        'trustScore': updatedTrustScore.toMap(),
      });

      _trustScore = updatedTrustScore;
      notifyListeners();

      return true;
    } catch (e) {
      _error = '퀘스트 완료에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 인증 완료 처리
  Future<bool> completeVerification(
    String userId,
    String verificationType,
    double scoreGain,
  ) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();
      final userData = userDoc.data()!;
      final trustScore = TrustScore.fromMap(userData['trustScore'] ?? {});

      // 이미 완료한 인증인지 확인
      if (trustScore.badges.contains(verificationType)) {
        _error = '이미 완료한 인증입니다';
        notifyListeners();
        return false;
      }

      // 점수 업데이트
      final double newScore = (trustScore.score + scoreGain).clamp(0.0, 100.0);
      final newBadges = [...trustScore.badges, verificationType];

      final updatedTrustScore = trustScore.copyWith(
        score: newScore,
        badges: newBadges,
      );

      await userRef.update({
        'trustScore': updatedTrustScore.toMap(),
      });

      _trustScore = updatedTrustScore;
      notifyListeners();

      return true;
    } catch (e) {
      _error = '인증 처리에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 전화번호 인증
  Future<bool> verifyPhoneNumber(String userId, String phoneNumber) async {
    // TODO: 실제 전화번호 인증 로직 구현
    // 현재는 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));

    return await completeVerification(
      userId,
      'phone_verified',
      AppConstants.trustScorePhoneVerification,
    );
  }

  /// 비디오 인증
  Future<bool> verifyVideo(String userId, String videoPath) async {
    // TODO: 실제 비디오 업로드 및 검수 로직 구현
    // 현재는 시뮬레이션
    await Future.delayed(const Duration(seconds: 2));

    return await completeVerification(
      userId,
      'video_verified',
      AppConstants.trustScoreVideoVerification,
    );
  }

  /// 범죄기록 조회
  Future<bool> checkCriminalRecord(String userId) async {
    // TODO: 실제 범죄기록 조회 API 연동
    // 현재는 시뮬레이션
    await Future.delayed(const Duration(seconds: 2));

    return await completeVerification(
      userId,
      'criminal_record_clear',
      AppConstants.trustScoreCriminalCheck,
    );
  }

  /// 학교폭력 기록 조회
  Future<bool> checkSchoolViolence(String userId) async {
    // TODO: 실제 학교폭력 기록 조회 API 연동
    // 현재는 시뮬레이션
    await Future.delayed(const Duration(seconds: 2));

    return await completeVerification(
      userId,
      'school_violence_clear',
      AppConstants.trustScoreSchoolViolenceCheck,
    );
  }

  /// 직업 인증
  Future<bool> verifyOccupation(String userId, String documentPath) async {
    // TODO: 실제 서류 업로드 및 검수 로직 구현
    // 현재는 시뮬레이션
    await Future.delayed(const Duration(seconds: 2));

    return await completeVerification(
      userId,
      'occupation_verified',
      AppConstants.trustScoreOccupationVerification,
    );
  }

  /// 학력 인증
  Future<bool> verifyEducation(String userId, String documentPath) async {
    // TODO: 실제 서류 업로드 및 검수 로직 구현
    // 현재는 시뮬레이션
    await Future.delayed(const Duration(seconds: 2));

    return await completeVerification(
      userId,
      'education_verified',
      AppConstants.trustScoreEducationVerification,
    );
  }

  /// 레벨 가져오기
  String getLevel(int score) {
    if (score >= 80) return AppConstants.trustScoreLevelsByScore[80]!;
    if (score >= 60) return AppConstants.trustScoreLevelsByScore[60]!;
    if (score >= 40) return AppConstants.trustScoreLevelsByScore[40]!;
    if (score >= 20) return AppConstants.trustScoreLevelsByScore[20]!;
    return AppConstants.trustScoreLevelsByScore[0]!;
  }

  /// VIP 자격 확인
  bool isVIPEligible(int trustScore, double heartTemperature) {
    return trustScore >= AppConstants.vipRequiredTrustScore &&
        heartTemperature >= AppConstants.vipRequiredTemperature;
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
