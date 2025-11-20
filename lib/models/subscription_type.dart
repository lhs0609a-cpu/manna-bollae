/// 구독 유형 enum
enum SubscriptionType {
  free,
  basic,
  premium,
  vip_basic,
  vip_premium,
  vip_platinum,
}

extension SubscriptionTypeExtension on SubscriptionType {
  /// enum 값을 문자열로 변환
  String toValue() {
    switch (this) {
      case SubscriptionType.free:
        return 'free';
      case SubscriptionType.basic:
        return 'basic';
      case SubscriptionType.premium:
        return 'premium';
      case SubscriptionType.vip_basic:
        return 'vip_basic';
      case SubscriptionType.vip_premium:
        return 'vip_premium';
      case SubscriptionType.vip_platinum:
        return 'vip_platinum';
    }
  }

  /// 문자열을 enum 값으로 변환
  static SubscriptionType fromValue(String value) {
    switch (value) {
      case 'free':
        return SubscriptionType.free;
      case 'basic':
        return SubscriptionType.basic;
      case 'premium':
        return SubscriptionType.premium;
      case 'vip_basic':
        return SubscriptionType.vip_basic;
      case 'vip_premium':
        return SubscriptionType.vip_premium;
      case 'vip_platinum':
        return SubscriptionType.vip_platinum;
      default:
        return SubscriptionType.free;
    }
  }

  /// VIP 구독 여부
  bool get isVip {
    return this == SubscriptionType.vip_basic ||
        this == SubscriptionType.vip_premium ||
        this == SubscriptionType.vip_platinum;
  }

  /// 프리미엄급 구독 여부 (VIP 프리미엄 이상)
  bool get isPremium {
    return this == SubscriptionType.vip_premium ||
        this == SubscriptionType.vip_platinum;
  }
}
