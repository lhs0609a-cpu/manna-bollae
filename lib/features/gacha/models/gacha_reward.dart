enum RewardRarity {
  common,    // 커먼 (회색)
  rare,      // 레어 (파란색)
  epic,      // 에픽 (보라색)
  legendary, // 레전더리 (황금색)
}

enum RewardItemType {
  superLike,         // 슈퍼 라이크
  boost,             // 부스트
  premium,           // 프리미엄 일수
  heartTemperature,  // 하트온도
  points,            // 포인트
  badge,             // 뱃지
  profileTheme,      // 프로필 테마
  avatarItem,        // 아바타 아이템
  profileFrame,      // 프로필 프레임
  chatEmoticon,      // 채팅 이모티콘
  dateTicket,        // 데이트 티켓
  revealProfile,     // 프로필 공개권
  topExposure,       // 상단 노출
  unlimitedLikes,    // 무제한 좋아요
}

class GachaReward {
  final String id;
  final String name;
  final String description;
  final RewardItemType type;
  final RewardRarity rarity;
  final int amount;
  final String iconUrl;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;

  const GachaReward({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    required this.amount,
    required this.iconUrl,
    this.expiresAt,
    this.metadata,
  });

  // 희귀도에 따른 색상
  String get rarityColor {
    switch (rarity) {
      case RewardRarity.common:
        return '#9E9E9E'; // 회색
      case RewardRarity.rare:
        return '#2196F3'; // 파란색
      case RewardRarity.epic:
        return '#9C27B0'; // 보라색
      case RewardRarity.legendary:
        return '#FFD700'; // 황금색
    }
  }

  String get rarityName {
    switch (rarity) {
      case RewardRarity.common:
        return '커먼';
      case RewardRarity.rare:
        return '레어';
      case RewardRarity.epic:
        return '에픽';
      case RewardRarity.legendary:
        return '레전더리';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString(),
      'rarity': rarity.toString(),
      'amount': amount,
      'iconUrl': iconUrl,
      'expiresAt': expiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory GachaReward.fromJson(Map<String, dynamic> json) {
    return GachaReward(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: RewardItemType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      rarity: RewardRarity.values.firstWhere(
        (e) => e.toString() == json['rarity'],
      ),
      amount: json['amount'],
      iconUrl: json['iconUrl'],
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      metadata: json['metadata'],
    );
  }
}

// 보상 데이터베이스
class GachaRewardData {
  // 커먼 보상
  static List<GachaReward> get commonRewards => [
        GachaReward(
          id: 'common_points_100',
          name: '100 포인트',
          description: '기본 포인트 100개',
          type: RewardItemType.points,
          rarity: RewardRarity.common,
          amount: 100,
          iconUrl: '💰',
        ),
        GachaReward(
          id: 'common_super_like_1',
          name: '슈퍼 라이크 1개',
          description: '특별한 관심 표현',
          type: RewardItemType.superLike,
          rarity: RewardRarity.common,
          amount: 1,
          iconUrl: '⭐',
        ),
        GachaReward(
          id: 'common_heart_temp_05',
          name: '하트온도 +0.5',
          description: '매력도 상승',
          type: RewardItemType.heartTemperature,
          rarity: RewardRarity.common,
          amount: 5,
          iconUrl: '❤️',
        ),
      ];

  // 레어 보상
  static List<GachaReward> get rareRewards => [
        GachaReward(
          id: 'rare_super_like_3',
          name: '슈퍼 라이크 3개',
          description: '3번의 특별한 기회',
          type: RewardItemType.superLike,
          rarity: RewardRarity.rare,
          amount: 3,
          iconUrl: '⭐',
        ),
        GachaReward(
          id: 'rare_boost_1h',
          name: '1시간 부스트',
          description: '프로필 상단 노출',
          type: RewardItemType.boost,
          rarity: RewardRarity.rare,
          amount: 60,
          iconUrl: '🚀',
        ),
        GachaReward(
          id: 'rare_points_500',
          name: '500 포인트',
          description: '포인트 500개',
          type: RewardItemType.points,
          rarity: RewardRarity.rare,
          amount: 500,
          iconUrl: '💰',
        ),
        GachaReward(
          id: 'rare_profile_reveal',
          name: '프로필 공개권',
          description: '좋아요한 사람 확인',
          type: RewardItemType.revealProfile,
          rarity: RewardRarity.rare,
          amount: 1,
          iconUrl: '👀',
        ),
      ];

  // 에픽 보상
  static List<GachaReward> get epicRewards => [
        GachaReward(
          id: 'epic_premium_3d',
          name: '프리미엄 3일',
          description: '3일간 프리미엄 기능',
          type: RewardItemType.premium,
          rarity: RewardRarity.epic,
          amount: 3,
          iconUrl: '👑',
        ),
        GachaReward(
          id: 'epic_super_like_10',
          name: '슈퍼 라이크 10개',
          description: '10번의 특별한 기회',
          type: RewardItemType.superLike,
          rarity: RewardRarity.epic,
          amount: 10,
          iconUrl: '⭐',
        ),
        GachaReward(
          id: 'epic_boost_6h',
          name: '6시간 부스트',
          description: '장시간 상단 노출',
          type: RewardItemType.boost,
          rarity: RewardRarity.epic,
          amount: 360,
          iconUrl: '🚀',
        ),
        GachaReward(
          id: 'epic_badge_special',
          name: '특별 뱃지',
          description: '프로필 특별 뱃지',
          type: RewardItemType.badge,
          rarity: RewardRarity.epic,
          amount: 1,
          iconUrl: '🏅',
        ),
      ];

  // 레전더리 보상
  static List<GachaReward> get legendaryRewards => [
        GachaReward(
          id: 'legendary_premium_7d',
          name: '프리미엄 7일',
          description: '일주일 프리미엄',
          type: RewardItemType.premium,
          rarity: RewardRarity.legendary,
          amount: 7,
          iconUrl: '👑',
        ),
        GachaReward(
          id: 'legendary_unlimited_likes_24h',
          name: '24시간 무제한 좋아요',
          description: '하루 동안 무제한',
          type: RewardItemType.unlimitedLikes,
          rarity: RewardRarity.legendary,
          amount: 24,
          iconUrl: '💝',
        ),
        GachaReward(
          id: 'legendary_top_exposure_24h',
          name: '24시간 최상단 노출',
          description: '하루 종일 1위',
          type: RewardItemType.topExposure,
          rarity: RewardRarity.legendary,
          amount: 24,
          iconUrl: '🌟',
        ),
        GachaReward(
          id: 'legendary_points_5000',
          name: '5000 포인트',
          description: '대량 포인트',
          type: RewardItemType.points,
          rarity: RewardRarity.legendary,
          amount: 5000,
          iconUrl: '💎',
        ),
      ];

  static List<GachaReward> get allRewards => [
        ...commonRewards,
        ...rareRewards,
        ...epicRewards,
        ...legendaryRewards,
      ];
}
