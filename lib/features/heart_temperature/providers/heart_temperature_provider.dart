import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../models/user_model.dart';
import '../../../core/constants/app_constants.dart';

/// 온도 변경 이벤트 타입
enum TemperatureChangeType {
  positiveReview, // 긍정 리뷰
  negativeReview, // 부정 리뷰
  report, // 신고
}

/// 온도 변경 이력
class TemperatureHistory {
  final String id;
  final String userId; // 온도 변경 대상 사용자
  final String fromUserId; // 리뷰/신고를 한 사용자
  final TemperatureChangeType type;
  final double change; // 변경량 (+1.0, -3.0, -10.0)
  final String? reason; // 사유
  final DateTime timestamp;

  TemperatureHistory({
    required this.id,
    required this.userId,
    required this.fromUserId,
    required this.type,
    required this.change,
    this.reason,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'fromUserId': fromUserId,
      'type': type.name,
      'change': change,
      'reason': reason,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory TemperatureHistory.fromMap(Map<String, dynamic> map) {
    return TemperatureHistory(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      type: TemperatureChangeType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TemperatureChangeType.positiveReview,
      ),
      change: (map['change'] ?? 0).toDouble(),
      reason: map['reason'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class HeartTemperatureProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  HeartTemperature? _heartTemperature;
  List<TemperatureHistory> _history = [];
  bool _isLoading = false;
  String? _error;

  HeartTemperature? get heartTemperature => _heartTemperature;
  List<TemperatureHistory> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 온도 로드
  Future<void> loadHeartTemperature(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _heartTemperature =
            HeartTemperature.fromMap(userData['heartTemperature'] ?? {});
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '온도 정보를 불러오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 온도 변경 이력 로드
  Future<void> loadHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('temperature_history')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      _history = snapshot.docs
          .map((doc) => TemperatureHistory.fromMap(doc.data()))
          .toList();

      notifyListeners();
    } catch (e) {
      _error = '온도 이력을 불러오는데 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 긍정 리뷰 작성
  Future<bool> submitPositiveReview(
    String fromUserId,
    String toUserId,
    String? reason,
  ) async {
    try {
      // 이미 리뷰를 남겼는지 확인
      final existing = await _firestore
          .collection('temperature_history')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('userId', isEqualTo: toUserId)
          .where('type', whereIn: [
        TemperatureChangeType.positiveReview.name,
        TemperatureChangeType.negativeReview.name
      ]).get();

      if (existing.docs.isNotEmpty) {
        _error = '이미 이 사용자에게 리뷰를 남겼습니다';
        notifyListeners();
        return false;
      }

      // 온도 변경
      await _changeTemperature(
        fromUserId: fromUserId,
        toUserId: toUserId,
        type: TemperatureChangeType.positiveReview,
        change: AppConstants.heartTempPositiveReview,
        reason: reason,
      );

      return true;
    } catch (e) {
      _error = '리뷰 작성에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 부정 리뷰 작성
  Future<bool> submitNegativeReview(
    String fromUserId,
    String toUserId,
    String reason,
  ) async {
    try {
      if (reason.trim().isEmpty) {
        _error = '사유를 입력해주세요';
        notifyListeners();
        return false;
      }

      // 이미 리뷰를 남겼는지 확인
      final existing = await _firestore
          .collection('temperature_history')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('userId', isEqualTo: toUserId)
          .where('type', whereIn: [
        TemperatureChangeType.positiveReview.name,
        TemperatureChangeType.negativeReview.name
      ]).get();

      if (existing.docs.isNotEmpty) {
        _error = '이미 이 사용자에게 리뷰를 남겼습니다';
        notifyListeners();
        return false;
      }

      // 온도 변경
      await _changeTemperature(
        fromUserId: fromUserId,
        toUserId: toUserId,
        type: TemperatureChangeType.negativeReview,
        change: AppConstants.heartTempNegativeReview,
        reason: reason,
      );

      return true;
    } catch (e) {
      _error = '리뷰 작성에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 신고하기
  Future<bool> submitReport(
    String fromUserId,
    String toUserId,
    String reason,
  ) async {
    try {
      if (reason.trim().isEmpty) {
        _error = '신고 사유를 입력해주세요';
        notifyListeners();
        return false;
      }

      // 온도 변경
      await _changeTemperature(
        fromUserId: fromUserId,
        toUserId: toUserId,
        type: TemperatureChangeType.report,
        change: AppConstants.heartTempReport,
        reason: reason,
      );

      return true;
    } catch (e) {
      _error = '신고 처리에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 온도 변경 처리
  Future<void> _changeTemperature({
    required String fromUserId,
    required String toUserId,
    required TemperatureChangeType type,
    required double change,
    String? reason,
  }) async {
    // 이력 저장
    final historyId = _uuid.v4();
    final history = TemperatureHistory(
      id: historyId,
      userId: toUserId,
      fromUserId: fromUserId,
      type: type,
      change: change,
      reason: reason,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection('temperature_history')
        .doc(historyId)
        .set(history.toMap());

    // 사용자 온도 업데이트
    final userRef = _firestore.collection('users').doc(toUserId);
    final userDoc = await userRef.get();
    final userData = userDoc.data()!;
    final heartTemp = HeartTemperature.fromMap(userData['heartTemperature'] ?? {});

    final newTemp = (heartTemp.temperature + change).clamp(
      AppConstants.heartTempMin,
      AppConstants.heartTempMax,
    );

    final updatedHeartTemp = heartTemp.copyWith(
      temperature: newTemp,
    );

    await userRef.update({
      'heartTemperature': updatedHeartTemp.toMap(),
    });

    // 현재 사용자의 온도라면 업데이트
    if (toUserId == _heartTemperature?.temperature.toString()) {
      _heartTemperature = updatedHeartTemp;
      notifyListeners();
    }
  }

  /// 레벨 가져오기
  String getLevel(double temperature) {
    if (temperature >= 60) return AppConstants.heartTempLevels[60]!;
    if (temperature >= 40) return AppConstants.heartTempLevels[40]!;
    if (temperature >= 20) return AppConstants.heartTempLevels[20]!;
    if (temperature >= 10) return AppConstants.heartTempLevels[10]!;
    return AppConstants.heartTempLevels[0]!;
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
