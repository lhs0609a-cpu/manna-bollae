import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';
import '../../../models/subscription_type.dart';

class SubscriptionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Subscription? _currentSubscription;
  bool _isLoading = false;
  String? _error;

  Subscription? get currentSubscription => _currentSubscription;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 구독 플랜 정보
  static const Map<SubscriptionType, Map<String, dynamic>> planInfo = {
    SubscriptionType.free: {
      'name': '무료',
      'price': 0,
      'duration': '평생',
      'features': [
        '일일 매칭 3회',
        '기본 프로필 열람',
        '채팅 기능',
      ],
    },
    SubscriptionType.basic: {
      'name': '베이직',
      'price': 9900,
      'duration': '월',
      'features': [
        '일일 매칭 5회',
        '상세 프로필 열람',
        '채팅 기능',
        '좋아요 무제한',
      ],
    },
    SubscriptionType.premium: {
      'name': '프리미엄',
      'price': 19900,
      'duration': '월',
      'features': [
        '일일 매칭 10회',
        '전체 프로필 열람',
        '채팅 우선권',
        '좋아요 무제한',
        '매칭 알고리즘 우선',
      ],
    },
    SubscriptionType.vip_basic: {
      'name': 'VIP 베이직',
      'price': 29900,
      'duration': '월',
      'features': [
        '일일 매칭 15회',
        'VIP 배지',
        '전체 프로필 열람',
        '채팅 우선권',
        '좋아요 무제한',
        '매칭 알고리즘 우선',
        '아바타 아이템 10% 할인',
      ],
      'requirements': {
        'trustScore': 60,
        'temperature': 30.0,
      },
    },
    SubscriptionType.vip_premium: {
      'name': 'VIP 프리미엄',
      'price': 49900,
      'duration': '월',
      'features': [
        '일일 매칭 25회',
        'VIP 골드 배지',
        '전체 프로필 열람',
        '채팅 최우선권',
        '좋아요 무제한',
        '매칭 알고리즘 최우선',
        '아바타 아이템 20% 할인',
        '전용 매칭 풀 접근',
      ],
      'requirements': {
        'trustScore': 70,
        'temperature': 40.0,
      },
    },
    SubscriptionType.vip_platinum: {
      'name': 'VIP 플래티넘',
      'price': 99900,
      'duration': '월',
      'features': [
        '일일 매칭 무제한',
        'VIP 플래티넘 배지',
        '전체 프로필 열람',
        '채팅 최우선권',
        '좋아요 무제한',
        '매칭 알고리즘 최우선',
        '아바타 아이템 30% 할인',
        '전용 매칭 풀 접근',
        '프로필 강조 표시',
        '매칭 성공률 2배',
      ],
      'requirements': {
        'trustScore': 80,
        'temperature': 50.0,
      },
    },
  };

  /// 현재 구독 정보 로드
  Future<void> loadSubscription(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _currentSubscription = Subscription.fromMap(userData['subscription']);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '구독 정보를 불러오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 구독 가능 여부 확인 (VIP 자격 확인)
  bool canSubscribe(
    SubscriptionType type,
    int trustScore,
    double temperature,
  ) {
    if (type == SubscriptionType.free ||
        type == SubscriptionType.basic ||
        type == SubscriptionType.premium) {
      return true;
    }

    final requirements = planInfo[type]?['requirements'];
    if (requirements == null) return true;

    final requiredTrustScore = requirements['trustScore'] as int;
    final requiredTemperature = requirements['temperature'] as double;

    return trustScore >= requiredTrustScore &&
        temperature >= requiredTemperature;
  }

  /// 구독 플랜 변경
  Future<bool> changeSubscription({
    required String userId,
    required SubscriptionType newType,
    required int trustScore,
    required double temperature,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // VIP 자격 확인
      if (!canSubscribe(newType, trustScore, temperature)) {
        _error = 'VIP 구독 자격이 부족합니다. 신뢰 지수와 하트 온도를 올려주세요.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 무료 플랜으로 변경할 때는 즉시 적용
      if (newType == SubscriptionType.free) {
        final newSubscription = Subscription(
          type: newType.toValue(),
          startDate: DateTime.now(),
          endDate: null,
          autoRenew: false,
        );

        await _firestore.collection('users').doc(userId).update({
          'subscription': newSubscription.toMap(),
        });

        _currentSubscription = newSubscription;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // 유료 플랜으로 변경 (실제로는 결제 처리가 필요)
      // TODO: 실제 결제 연동 (PG사: 아임포트, 토스페이먼츠 등)
      // 현재는 테스트 모드로 즉시 적용
      final newSubscription = Subscription(
        type: newType.toValue(),
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        autoRenew: true,
      );

      await _firestore.collection('users').doc(userId).update({
        'subscription': newSubscription.toMap(),
      });

      // 구독 히스토리 기록
      await _firestore.collection('subscription_history').add({
        'userId': userId,
        'type': newType.toString(),
        'startDate': newSubscription.startDate,
        'endDate': newSubscription.endDate,
        'price': planInfo[newType]?['price'] ?? 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _currentSubscription = newSubscription;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = '구독 변경에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 자동 갱신 설정 변경
  Future<bool> updateAutoRenew(String userId, bool autoRenew) async {
    try {
      if (_currentSubscription == null) return false;

      final updatedSubscription = _currentSubscription!.copyWith(
        autoRenew: autoRenew,
      );

      await _firestore.collection('users').doc(userId).update({
        'subscription': updatedSubscription.toMap(),
      });

      _currentSubscription = updatedSubscription;
      notifyListeners();

      return true;
    } catch (e) {
      _error = '자동 갱신 설정 변경에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 구독 취소 (다음 결제일까지 유지)
  Future<bool> cancelSubscription(String userId) async {
    try {
      if (_currentSubscription == null) return false;

      final updatedSubscription = _currentSubscription!.copyWith(
        autoRenew: false,
      );

      await _firestore.collection('users').doc(userId).update({
        'subscription': updatedSubscription.toMap(),
      });

      _currentSubscription = updatedSubscription;
      notifyListeners();

      return true;
    } catch (e) {
      _error = '구독 취소에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 남은 일수 계산
  int getDaysRemaining() {
    if (_currentSubscription == null || _currentSubscription!.endDate == null) {
      return 0;
    }

    final remaining =
        _currentSubscription!.endDate!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// VIP 여부 확인
  bool isVIP() {
    if (_currentSubscription == null) return false;

    return _currentSubscription!.type == SubscriptionType.vip_basic ||
        _currentSubscription!.type == SubscriptionType.vip_premium ||
        _currentSubscription!.type == SubscriptionType.vip_platinum;
  }

  /// 구독 혜택 가져오기
  List<String> getSubscriptionFeatures(SubscriptionType type) {
    return List<String>.from(planInfo[type]?['features'] ?? []);
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
