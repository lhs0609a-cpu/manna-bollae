class ReferredFriend {
  final String userId;
  final String name;
  final DateTime invitedAt;
  final bool hasSignedUp;
  final bool hasCompletedProfile;
  final bool isActive; // 7일 연속 접속
  final bool hasMatched;
  final bool hasPurchased;

  ReferredFriend({
    required this.userId,
    required this.name,
    required this.invitedAt,
    this.hasSignedUp = false,
    this.hasCompletedProfile = false,
    this.isActive = false,
    this.hasMatched = false,
    this.hasPurchased = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'invitedAt': invitedAt.toIso8601String(),
      'hasSignedUp': hasSignedUp,
      'hasCompletedProfile': hasCompletedProfile,
      'isActive': isActive,
      'hasMatched': hasMatched,
      'hasPurchased': hasPurchased,
    };
  }

  factory ReferredFriend.fromJson(Map<String, dynamic> json) {
    return ReferredFriend(
      userId: json['userId'],
      name: json['name'],
      invitedAt: DateTime.parse(json['invitedAt']),
      hasSignedUp: json['hasSignedUp'] ?? false,
      hasCompletedProfile: json['hasCompletedProfile'] ?? false,
      isActive: json['isActive'] ?? false,
      hasMatched: json['hasMatched'] ?? false,
      hasPurchased: json['hasPurchased'] ?? false,
    );
  }

  ReferredFriend copyWith({
    String? userId,
    String? name,
    DateTime? invitedAt,
    bool? hasSignedUp,
    bool? hasCompletedProfile,
    bool? isActive,
    bool? hasMatched,
    bool? hasPurchased,
  }) {
    return ReferredFriend(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      invitedAt: invitedAt ?? this.invitedAt,
      hasSignedUp: hasSignedUp ?? this.hasSignedUp,
      hasCompletedProfile: hasCompletedProfile ?? this.hasCompletedProfile,
      isActive: isActive ?? this.isActive,
      hasMatched: hasMatched ?? this.hasMatched,
      hasPurchased: hasPurchased ?? this.hasPurchased,
    );
  }
}

class ReferralProgress {
  final String referralCode; // 내 초대 코드
  final List<ReferredFriend> referredFriends; // 초대한 친구 목록
  final int totalReferred; // 총 초대 인원
  final int successfulReferred; // 가입 완료 인원
  final Map<int, bool> claimedRewards; // 수령한 보상 (milestone -> 수령 여부)
  final int totalPoints; // 누적 포인트
  final DateTime createdAt;

  ReferralProgress({
    required this.referralCode,
    List<ReferredFriend>? referredFriends,
    this.totalReferred = 0,
    this.successfulReferred = 0,
    Map<int, bool>? claimedRewards,
    this.totalPoints = 0,
    DateTime? createdAt,
  })  : referredFriends = referredFriends ?? [],
        claimedRewards = claimedRewards ?? {},
        createdAt = createdAt ?? DateTime.now();

  int get completedProfileCount {
    return referredFriends
        .where((friend) => friend.hasCompletedProfile)
        .length;
  }

  int get activeUserCount {
    return referredFriends.where((friend) => friend.isActive).length;
  }

  int get matchedCount {
    return referredFriends.where((friend) => friend.hasMatched).length;
  }

  Map<String, dynamic> toJson() {
    return {
      'referralCode': referralCode,
      'referredFriends': referredFriends.map((f) => f.toJson()).toList(),
      'totalReferred': totalReferred,
      'successfulReferred': successfulReferred,
      'claimedRewards': claimedRewards.map((k, v) => MapEntry(k.toString(), v)),
      'totalPoints': totalPoints,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReferralProgress.fromJson(Map<String, dynamic> json) {
    return ReferralProgress(
      referralCode: json['referralCode'],
      referredFriends: json['referredFriends'] != null
          ? (json['referredFriends'] as List)
              .map((f) => ReferredFriend.fromJson(f))
              .toList()
          : [],
      totalReferred: json['totalReferred'] ?? 0,
      successfulReferred: json['successfulReferred'] ?? 0,
      claimedRewards: json['claimedRewards'] != null
          ? (json['claimedRewards'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(int.parse(k), v as bool))
          : {},
      totalPoints: json['totalPoints'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  ReferralProgress copyWith({
    String? referralCode,
    List<ReferredFriend>? referredFriends,
    int? totalReferred,
    int? successfulReferred,
    Map<int, bool>? claimedRewards,
    int? totalPoints,
    DateTime? createdAt,
  }) {
    return ReferralProgress(
      referralCode: referralCode ?? this.referralCode,
      referredFriends: referredFriends ?? this.referredFriends,
      totalReferred: totalReferred ?? this.totalReferred,
      successfulReferred: successfulReferred ?? this.successfulReferred,
      claimedRewards: claimedRewards ?? this.claimedRewards,
      totalPoints: totalPoints ?? this.totalPoints,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
