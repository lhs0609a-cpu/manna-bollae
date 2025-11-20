enum RewardType {
  superLikes,      // 슈퍼 라이크
  premium,         // 프리미엄 일수
  boost,           // 부스트 시간(분)
  heartTemperature, // 하트온도
  vip,             // VIP 등급
  cash,            // 현금 포인트
  badge,           // 뱃지
}

class ReferralReward {
  final int milestone; // 몇 명 초대 시
  final String title;
  final String description;
  final List<RewardItem> rewards;
  final String icon;
  final bool isSpecial; // 특별 보상 여부

  const ReferralReward({
    required this.milestone,
    required this.title,
    required this.description,
    required this.rewards,
    required this.icon,
    this.isSpecial = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'milestone': milestone,
      'title': title,
      'description': description,
      'rewards': rewards.map((r) => r.toJson()).toList(),
      'icon': icon,
      'isSpecial': isSpecial,
    };
  }

  factory ReferralReward.fromJson(Map<String, dynamic> json) {
    return ReferralReward(
      milestone: json['milestone'],
      title: json['title'],
      description: json['description'],
      rewards: (json['rewards'] as List)
          .map((r) => RewardItem.fromJson(r))
          .toList(),
      icon: json['icon'],
      isSpecial: json['isSpecial'] ?? false,
    );
  }
}

class RewardItem {
  final RewardType type;
  final int amount;
  final String label;

  const RewardItem({
    required this.type,
    required this.amount,
    required this.label,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'amount': amount,
      'label': label,
    };
  }

  factory RewardItem.fromJson(Map<String, dynamic> json) {
    return RewardItem(
      type: RewardType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      amount: json['amount'],
      label: json['label'],
    );
  }
}

// 보상 데이터 정의
class ReferralRewardData {
  static List<ReferralReward> get allRewards => [
        // 1명 초대
        ReferralReward(
          milestone: 1,
          title: '첫 친구',
          description: '친구 1명 초대 성공!',
          icon: '🎁',
          rewards: [
            RewardItem(
              type: RewardType.superLikes,
              amount: 3,
              label: '슈퍼 라이크 3개',
            ),
            RewardItem(
              type: RewardType.heartTemperature,
              amount: 1,
              label: '하트온도 +1.0',
            ),
          ],
        ),

        // 3명 초대
        ReferralReward(
          milestone: 3,
          title: '친구왕',
          description: '친구 3명 초대 달성!',
          icon: '👑',
          rewards: [
            RewardItem(
              type: RewardType.premium,
              amount: 7,
              label: '프리미엄 7일',
            ),
            RewardItem(
              type: RewardType.superLikes,
              amount: 10,
              label: '슈퍼 라이크 10개',
            ),
            RewardItem(
              type: RewardType.badge,
              amount: 1,
              label: '"친구왕" 뱃지',
            ),
          ],
        ),

        // 5명 초대
        ReferralReward(
          milestone: 5,
          title: '인플루언서',
          description: '친구 5명 초대 달성!',
          icon: '⭐',
          isSpecial: true,
          rewards: [
            RewardItem(
              type: RewardType.premium,
              amount: 30,
              label: '프리미엄 30일',
            ),
            RewardItem(
              type: RewardType.vip,
              amount: 1,
              label: 'VIP 등급 업그레이드',
            ),
            RewardItem(
              type: RewardType.cash,
              amount: 10000,
              label: '10,000 포인트',
            ),
          ],
        ),

        // 10명 초대
        ReferralReward(
          milestone: 10,
          title: '전도사',
          description: '친구 10명 초대 달성!',
          icon: '🏆',
          isSpecial: true,
          rewards: [
            RewardItem(
              type: RewardType.vip,
              amount: 999,
              label: '평생 VIP',
            ),
            RewardItem(
              type: RewardType.superLikes,
              amount: 50,
              label: '매월 슈퍼 라이크 50개 자동 지급',
            ),
            RewardItem(
              type: RewardType.cash,
              amount: 50000,
              label: '50,000 포인트',
            ),
          ],
        ),

        // 20명 초대
        ReferralReward(
          milestone: 20,
          title: '앰버서더',
          description: '친구 20명 초대 달성!',
          icon: '💎',
          isSpecial: true,
          rewards: [
            RewardItem(
              type: RewardType.premium,
              amount: 999,
              label: '평생 프리미엄',
            ),
            RewardItem(
              type: RewardType.boost,
              amount: 999999,
              label: '무제한 부스트',
            ),
            RewardItem(
              type: RewardType.cash,
              amount: 100000,
              label: '100,000 포인트',
            ),
          ],
        ),
      ];

  // 신규 가입자 환영 보상
  static List<RewardItem> get newUserRewards => [
        RewardItem(
          type: RewardType.premium,
          amount: 3,
          label: '프리미엄 3일',
        ),
        RewardItem(
          type: RewardType.superLikes,
          amount: 5,
          label: '슈퍼 라이크 5개',
        ),
        RewardItem(
          type: RewardType.boost,
          amount: 60,
          label: '부스트 1시간',
        ),
      ];
}
