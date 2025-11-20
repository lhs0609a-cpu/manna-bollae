import 'gacha_reward.dart';

enum GachaBoxType {
  dailyAttendance,      // 일일 출석
  matchingRoulette,     // 매칭 룰렛
  referralLuckyBox,     // 친구 초대 럭키박스
  missionSlot,          // 미션 슬롯머신
  avatarGacha,          // 아바타 가챠
  destinyMeeting,       // 운명의 만남
  seasonalLimited,      // 시즌 한정
  bingoGacha,           // 빙고 가챠
  levelUpReward,        // 레벨업 보상
  timeBasedMini,        // 시간대별 미니
  activityTreasure,     // 활동 보물상자
  coupleGacha,          // 커플 가챠
}

class GachaBox {
  final String id;
  final GachaBoxType type;
  final String name;
  final String description;
  final String iconUrl;
  final RewardRarity minRarity;
  final RewardRarity maxRarity;
  final Map<RewardRarity, double> rarityProbability; // 확률 (0-100)
  final int cost; // 비용 (0이면 무료)
  final bool isFree;
  final DateTime? expiresAt;

  const GachaBox({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.minRarity,
    required this.maxRarity,
    required this.rarityProbability,
    this.cost = 0,
    this.isFree = true,
    this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'minRarity': minRarity.toString(),
      'maxRarity': maxRarity.toString(),
      'rarityProbability': rarityProbability.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'cost': cost,
      'isFree': isFree,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  factory GachaBox.fromJson(Map<String, dynamic> json) {
    return GachaBox(
      id: json['id'],
      type: GachaBoxType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      name: json['name'],
      description: json['description'],
      iconUrl: json['iconUrl'],
      minRarity: RewardRarity.values.firstWhere(
        (e) => e.toString() == json['minRarity'],
      ),
      maxRarity: RewardRarity.values.firstWhere(
        (e) => e.toString() == json['maxRarity'],
      ),
      rarityProbability: (json['rarityProbability'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          RewardRarity.values.firstWhere((e) => e.toString() == k),
          (v as num).toDouble(),
        ),
      ),
      cost: json['cost'] ?? 0,
      isFree: json['isFree'] ?? true,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
    );
  }
}

class GachaResult {
  final String id;
  final GachaBox box;
  final GachaReward reward;
  final DateTime obtainedAt;
  final bool isNew; // 처음 획득하는 아이템인지

  GachaResult({
    required this.id,
    required this.box,
    required this.reward,
    required this.obtainedAt,
    this.isNew = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'box': box.toJson(),
      'reward': reward.toJson(),
      'obtainedAt': obtainedAt.toIso8601String(),
      'isNew': isNew,
    };
  }

  factory GachaResult.fromJson(Map<String, dynamic> json) {
    return GachaResult(
      id: json['id'],
      box: GachaBox.fromJson(json['box']),
      reward: GachaReward.fromJson(json['reward']),
      obtainedAt: DateTime.parse(json['obtainedAt']),
      isNew: json['isNew'] ?? false,
    );
  }
}

// 가챠 박스 데이터베이스
class GachaBoxData {
  // 일반 등급 박스 (커먼 ~ 레어)
  static GachaBox get normalBox => const GachaBox(
        id: 'normal_box',
        type: GachaBoxType.dailyAttendance,
        name: '일반 상자',
        description: '기본 보상이 들어있는 상자',
        iconUrl: '📦',
        minRarity: RewardRarity.common,
        maxRarity: RewardRarity.rare,
        rarityProbability: {
          RewardRarity.common: 70.0,
          RewardRarity.rare: 30.0,
        },
        isFree: true,
      );

  // 레어 등급 박스 (커먼 ~ 에픽)
  static GachaBox get rareBox => const GachaBox(
        id: 'rare_box',
        type: GachaBoxType.dailyAttendance,
        name: '레어 상자',
        description: '좋은 보상이 들어있는 상자',
        iconUrl: '🎁',
        minRarity: RewardRarity.common,
        maxRarity: RewardRarity.epic,
        rarityProbability: {
          RewardRarity.common: 50.0,
          RewardRarity.rare: 40.0,
          RewardRarity.epic: 10.0,
        },
        isFree: true,
      );

  // 에픽 등급 박스 (레어 ~ 레전더리)
  static GachaBox get epicBox => const GachaBox(
        id: 'epic_box',
        type: GachaBoxType.dailyAttendance,
        name: '에픽 상자',
        description: '훌륭한 보상이 들어있는 상자',
        iconUrl: '✨',
        minRarity: RewardRarity.rare,
        maxRarity: RewardRarity.legendary,
        rarityProbability: {
          RewardRarity.rare: 60.0,
          RewardRarity.epic: 35.0,
          RewardRarity.legendary: 5.0,
        },
        isFree: true,
      );

  // 레전더리 등급 박스 (에픽 ~ 레전더리)
  static GachaBox get legendaryBox => const GachaBox(
        id: 'legendary_box',
        type: GachaBoxType.dailyAttendance,
        name: '레전더리 상자',
        description: '최고의 보상이 들어있는 상자',
        iconUrl: '💎',
        minRarity: RewardRarity.epic,
        maxRarity: RewardRarity.legendary,
        rarityProbability: {
          RewardRarity.epic: 70.0,
          RewardRarity.legendary: 30.0,
        },
        isFree: true,
      );

  // 황금 상자 (7일 연속 출석 보상)
  static GachaBox get goldenBox => const GachaBox(
        id: 'golden_box',
        type: GachaBoxType.dailyAttendance,
        name: '황금 상자',
        description: '7일 연속 출석 보상',
        iconUrl: '🏆',
        minRarity: RewardRarity.legendary,
        maxRarity: RewardRarity.legendary,
        rarityProbability: {
          RewardRarity.legendary: 100.0,
        },
        isFree: true,
      );

  static List<GachaBox> get allBoxes => [
        normalBox,
        rareBox,
        epicBox,
        legendaryBox,
        goldenBox,
      ];
}
