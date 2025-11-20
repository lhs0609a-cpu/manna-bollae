import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final UserProfile profile;
  final Avatar avatar;
  final TrustScore trustScore;
  final HeartTemperature heartTemperature;
  final Subscription subscription;
  final Safety safety;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.userId,
    required this.profile,
    required this.avatar,
    required this.trustScore,
    required this.heartTemperature,
    required this.subscription,
    required this.safety,
    required this.createdAt,
    required this.updatedAt,
  });

  // Alias for compatibility
  String get id => userId;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: doc.id,
      profile: UserProfile.fromMap(data['profile'] ?? {}),
      avatar: Avatar.fromMap(data['avatar'] ?? {}),
      trustScore: TrustScore.fromMap(data['trustScore'] ?? {}),
      heartTemperature: HeartTemperature.fromMap(data['heartTemperature'] ?? {}),
      subscription: Subscription.fromMap(data['subscription'] ?? {}),
      safety: Safety.fromMap(data['safety'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      userId: data['userId'] ?? '',
      profile: UserProfile.fromMap(data['profile'] ?? {}),
      avatar: Avatar.fromMap(data['avatar'] ?? {}),
      trustScore: TrustScore.fromMap(data['trustScore'] ?? {}),
      heartTemperature: HeartTemperature.fromMap(data['heartTemperature'] ?? {}),
      subscription: Subscription.fromMap(data['subscription'] ?? {}),
      safety: Safety.fromMap(data['safety'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profile': profile.toMap(),
      'avatar': avatar.toMap(),
      'trustScore': trustScore.toMap(),
      'heartTemperature': heartTemperature.toMap(),
      'subscription': subscription.toMap(),
      'safety': safety.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class UserProfile {
  final BasicInfo basicInfo;
  final Lifestyle lifestyle;
  final Appearance appearance;
  final DetailedInfo? detailedInfo; // 친밀도 500 이후
  final VipInfo? vipInfo; // VIP만 열람
  final String oneLiner;
  final Map<String, dynamic>? idealTypeResult;

  UserProfile({
    required this.basicInfo,
    required this.lifestyle,
    required this.appearance,
    this.detailedInfo,
    this.vipInfo,
    required this.oneLiner,
    this.idealTypeResult,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      basicInfo: BasicInfo.fromMap(map['basicInfo'] ?? {}),
      lifestyle: Lifestyle.fromMap(map['lifestyle'] ?? {}),
      appearance: Appearance.fromMap(map['appearance'] ?? {}),
      detailedInfo: map['detailedInfo'] != null
          ? DetailedInfo.fromMap(map['detailedInfo'])
          : null,
      vipInfo: map['vipInfo'] != null
          ? VipInfo.fromMap(map['vipInfo'])
          : null,
      oneLiner: map['oneLiner'] ?? '',
      idealTypeResult: map['idealTypeResult'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'basicInfo': basicInfo.toMap(),
      'lifestyle': lifestyle.toMap(),
      'appearance': appearance.toMap(),
      'detailedInfo': detailedInfo?.toMap(),
      'vipInfo': vipInfo?.toMap(),
      'oneLiner': oneLiner,
      'idealTypeResult': idealTypeResult,
    };
  }
}

class BasicInfo {
  final String name;
  final DateTime birthdate;
  final String ageRange; // "20대 후반"
  final int? exactAge; // 친밀도 1500 이후
  final String gender;
  final String region; // "서울"
  final String? detailedRegion; // 친밀도 1500 이후
  final String mbti;
  final String bloodType;
  final bool smoking;
  final String drinking;
  final String religion;
  final bool firstRelationship;

  BasicInfo({
    required this.name,
    required this.birthdate,
    required this.ageRange,
    this.exactAge,
    required this.gender,
    required this.region,
    this.detailedRegion,
    required this.mbti,
    required this.bloodType,
    required this.smoking,
    required this.drinking,
    required this.religion,
    required this.firstRelationship,
  });

  // Aliases for compatibility
  DateTime get birthDate => birthdate;
  String get oneLiner => ''; // BasicInfo doesn't have oneLiner, it's in UserProfile

  factory BasicInfo.fromMap(Map<String, dynamic> map) {
    return BasicInfo(
      name: map['name'] ?? '',
      birthdate: (map['birthdate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ageRange: map['ageRange'] ?? '',
      exactAge: map['exactAge'],
      gender: map['gender'] ?? '',
      region: map['region'] ?? '',
      detailedRegion: map['detailedRegion'],
      mbti: map['mbti'] ?? '',
      bloodType: map['bloodType'] ?? '',
      smoking: map['smoking'] ?? false,
      drinking: map['drinking'] ?? '',
      religion: map['religion'] ?? '',
      firstRelationship: map['firstRelationship'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'birthdate': Timestamp.fromDate(birthdate),
      'ageRange': ageRange,
      'exactAge': exactAge,
      'gender': gender,
      'region': region,
      'detailedRegion': detailedRegion,
      'mbti': mbti,
      'bloodType': bloodType,
      'smoking': smoking,
      'drinking': drinking,
      'religion': religion,
      'firstRelationship': firstRelationship,
    };
  }
}

class Lifestyle {
  final List<String> hobbies;
  final bool hasPet;
  final String? petType;
  final String exerciseFrequency;
  final String travelStyle;

  Lifestyle({
    required this.hobbies,
    required this.hasPet,
    this.petType,
    required this.exerciseFrequency,
    required this.travelStyle,
  });

  factory Lifestyle.fromMap(Map<String, dynamic> map) {
    return Lifestyle(
      hobbies: List<String>.from(map['hobbies'] ?? []),
      hasPet: map['hasPet'] ?? false,
      petType: map['petType'],
      exerciseFrequency: map['exerciseFrequency'] ?? '',
      travelStyle: map['travelStyle'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hobbies': hobbies,
      'hasPet': hasPet,
      'petType': petType,
      'exerciseFrequency': exerciseFrequency,
      'travelStyle': travelStyle,
    };
  }
}

class Appearance {
  final String heightRange; // "170-173cm"
  final int? exactHeight; // 친밀도 1500 이후
  final String? bodyType; // 친밀도 1500 이후
  final List<Photo> photos;

  Appearance({
    required this.heightRange,
    this.exactHeight,
    this.bodyType,
    required this.photos,
  });

  factory Appearance.fromMap(Map<String, dynamic> map) {
    return Appearance(
      heightRange: map['heightRange'] ?? '',
      exactHeight: map['exactHeight'],
      bodyType: map['bodyType'],
      photos: (map['photos'] as List?)
          ?.map((p) => Photo.fromMap(p))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'heightRange': heightRange,
      'exactHeight': exactHeight,
      'bodyType': bodyType,
      'photos': photos.map((p) => p.toMap()).toList(),
    };
  }
}

class Photo {
  final String url;
  final String type; // "avatar", "daily", "face"
  final int unlockLevel; // 0: 즉시, 1500: 친밀도, 2500: 얼굴

  Photo({
    required this.url,
    required this.type,
    required this.unlockLevel,
  });

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      url: map['url'] ?? '',
      type: map['type'] ?? '',
      unlockLevel: map['unlockLevel'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'type': type,
      'unlockLevel': unlockLevel,
    };
  }
}

class DetailedInfo {
  final List<String> favoriteBooks;
  final List<String> favoriteMovies;
  final List<String> favoriteMusic;
  final String? voiceRecording;
  final List<String> dailyPhotos;
  final String communicationStyle;
  final RelationshipView relationshipView;

  DetailedInfo({
    required this.favoriteBooks,
    required this.favoriteMovies,
    required this.favoriteMusic,
    this.voiceRecording,
    required this.dailyPhotos,
    required this.communicationStyle,
    required this.relationshipView,
  });

  factory DetailedInfo.fromMap(Map<String, dynamic> map) {
    return DetailedInfo(
      favoriteBooks: List<String>.from(map['favoriteBooks'] ?? []),
      favoriteMovies: List<String>.from(map['favoriteMovies'] ?? []),
      favoriteMusic: List<String>.from(map['favoriteMusic'] ?? []),
      voiceRecording: map['voiceRecording'],
      dailyPhotos: List<String>.from(map['dailyPhotos'] ?? []),
      communicationStyle: map['communicationStyle'] ?? '',
      relationshipView: RelationshipView.fromMap(map['relationshipView'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'favoriteBooks': favoriteBooks,
      'favoriteMovies': favoriteMovies,
      'favoriteMusic': favoriteMusic,
      'voiceRecording': voiceRecording,
      'dailyPhotos': dailyPhotos,
      'communicationStyle': communicationStyle,
      'relationshipView': relationshipView.toMap(),
    };
  }
}

class RelationshipView {
  final String contactFrequency;
  final String skinshipSpeed;

  RelationshipView({
    required this.contactFrequency,
    required this.skinshipSpeed,
  });

  factory RelationshipView.fromMap(Map<String, dynamic> map) {
    return RelationshipView(
      contactFrequency: map['contactFrequency'] ?? '',
      skinshipSpeed: map['skinshipSpeed'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contactFrequency': contactFrequency,
      'skinshipSpeed': skinshipSpeed,
    };
  }
}

class VipInfo {
  final String job;
  final String jobDetail;
  final String education;
  final String educationDetail;
  final String salaryRange;
  final int? exactSalary; // 양측 합의 후
  final String assets;
  final Map<String, dynamic>? assetDetail; // 양측 합의 후
  final String marriagePlan;
  final String childcarePlan;
  final bool divorceHistory;
  final bool hasChildren;
  final int childrenCount;
  final bool? debt; // 양측 합의 후

  VipInfo({
    required this.job,
    required this.jobDetail,
    required this.education,
    required this.educationDetail,
    required this.salaryRange,
    this.exactSalary,
    required this.assets,
    this.assetDetail,
    required this.marriagePlan,
    required this.childcarePlan,
    required this.divorceHistory,
    required this.hasChildren,
    required this.childrenCount,
    this.debt,
  });

  factory VipInfo.fromMap(Map<String, dynamic> map) {
    return VipInfo(
      job: map['job'] ?? '',
      jobDetail: map['jobDetail'] ?? '',
      education: map['education'] ?? '',
      educationDetail: map['educationDetail'] ?? '',
      salaryRange: map['salaryRange'] ?? '',
      exactSalary: map['exactSalary'],
      assets: map['assets'] ?? '',
      assetDetail: map['assetDetail'],
      marriagePlan: map['marriagePlan'] ?? '',
      childcarePlan: map['childcarePlan'] ?? '',
      divorceHistory: map['divorceHistory'] ?? false,
      hasChildren: map['hasChildren'] ?? false,
      childrenCount: map['childrenCount'] ?? 0,
      debt: map['debt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'job': job,
      'jobDetail': jobDetail,
      'education': education,
      'educationDetail': educationDetail,
      'salaryRange': salaryRange,
      'exactSalary': exactSalary,
      'assets': assets,
      'assetDetail': assetDetail,
      'marriagePlan': marriagePlan,
      'childcarePlan': childcarePlan,
      'divorceHistory': divorceHistory,
      'hasChildren': hasChildren,
      'childrenCount': childrenCount,
      'debt': debt,
    };
  }
}

class Avatar {
  final String personality;
  final String style;
  final String colorPreference;
  final String animalType;
  final String hobby;
  final String baseCharacter;
  final AvatarOutfit currentOutfit;
  final OwnedItems ownedItems;

  Avatar({
    required this.personality,
    required this.style,
    required this.colorPreference,
    required this.animalType,
    required this.hobby,
    required this.baseCharacter,
    required this.currentOutfit,
    required this.ownedItems,
  });

  factory Avatar.fromMap(Map<String, dynamic> map) {
    return Avatar(
      personality: map['personality'] ?? '',
      style: map['style'] ?? '',
      colorPreference: map['colorPreference'] ?? '',
      animalType: map['animalType'] ?? '',
      hobby: map['hobby'] ?? '',
      baseCharacter: map['baseCharacter'] ?? '',
      currentOutfit: AvatarOutfit.fromMap(map['currentOutfit'] ?? {}),
      ownedItems: OwnedItems.fromMap(map['ownedItems'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'personality': personality,
      'style': style,
      'colorPreference': colorPreference,
      'animalType': animalType,
      'hobby': hobby,
      'baseCharacter': baseCharacter,
      'currentOutfit': currentOutfit.toMap(),
      'ownedItems': ownedItems.toMap(),
    };
  }

  Avatar copyWith({
    String? personality,
    String? style,
    String? colorPreference,
    String? animalType,
    String? hobby,
    String? baseCharacter,
    AvatarOutfit? currentOutfit,
    OwnedItems? ownedItems,
  }) {
    return Avatar(
      personality: personality ?? this.personality,
      style: style ?? this.style,
      colorPreference: colorPreference ?? this.colorPreference,
      animalType: animalType ?? this.animalType,
      hobby: hobby ?? this.hobby,
      baseCharacter: baseCharacter ?? this.baseCharacter,
      currentOutfit: currentOutfit ?? this.currentOutfit,
      ownedItems: ownedItems ?? this.ownedItems,
    );
  }

  // Alias for compatibility
  List<String> get favoriteColors => [colorPreference];
}

class AvatarOutfit {
  final String top;
  final String bottom;
  final List<String> accessories;
  final String hair;
  final String hairColor;
  final String background;
  final String specialItem;
  final String emotion;

  AvatarOutfit({
    required this.top,
    required this.bottom,
    required this.accessories,
    required this.hair,
    required this.hairColor,
    required this.background,
    required this.specialItem,
    required this.emotion,
  });

  factory AvatarOutfit.fromMap(Map<String, dynamic> map) {
    return AvatarOutfit(
      top: map['top'] ?? '',
      bottom: map['bottom'] ?? '',
      accessories: List<String>.from(map['accessories'] ?? []),
      hair: map['hair'] ?? '',
      hairColor: map['hairColor'] ?? '',
      background: map['background'] ?? '',
      specialItem: map['specialItem'] ?? '',
      emotion: map['emotion'] ?? 'neutral',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'top': top,
      'bottom': bottom,
      'accessories': accessories,
      'hair': hair,
      'hairColor': hairColor,
      'background': background,
      'specialItem': specialItem,
      'emotion': emotion,
    };
  }

  AvatarOutfit copyWith({
    String? top,
    String? bottom,
    List<String>? accessories,
    String? hair,
    String? hairColor,
    String? background,
    String? specialItem,
    String? emotion,
  }) {
    return AvatarOutfit(
      top: top ?? this.top,
      bottom: bottom ?? this.bottom,
      accessories: accessories ?? this.accessories,
      hair: hair ?? this.hair,
      hairColor: hairColor ?? this.hairColor,
      background: background ?? this.background,
      specialItem: specialItem ?? this.specialItem,
      emotion: emotion ?? this.emotion,
    );
  }

  // Alias for compatibility
  String? get accessory => accessories.isNotEmpty ? accessories.first : null;
}

class OwnedItems {
  final List<String> tops;
  final List<String> bottoms;
  final List<String> accessories;
  final List<String> hairs;
  final List<String> backgrounds;
  final List<String> specialItems;

  OwnedItems({
    required this.tops,
    required this.bottoms,
    required this.accessories,
    required this.hairs,
    required this.backgrounds,
    required this.specialItems,
  });

  factory OwnedItems.fromMap(Map<String, dynamic> map) {
    return OwnedItems(
      tops: List<String>.from(map['tops'] ?? []),
      bottoms: List<String>.from(map['bottoms'] ?? []),
      accessories: List<String>.from(map['accessories'] ?? []),
      hairs: List<String>.from(map['hairs'] ?? []),
      backgrounds: List<String>.from(map['backgrounds'] ?? []),
      specialItems: List<String>.from(map['specialItems'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tops': tops,
      'bottoms': bottoms,
      'accessories': accessories,
      'hairs': hairs,
      'backgrounds': backgrounds,
      'specialItems': specialItems,
    };
  }

  OwnedItems copyWith({
    List<String>? tops,
    List<String>? bottoms,
    List<String>? accessories,
    List<String>? hairs,
    List<String>? backgrounds,
    List<String>? specialItems,
  }) {
    return OwnedItems(
      tops: tops ?? this.tops,
      bottoms: bottoms ?? this.bottoms,
      accessories: accessories ?? this.accessories,
      hairs: hairs ?? this.hairs,
      backgrounds: backgrounds ?? this.backgrounds,
      specialItems: specialItems ?? this.specialItems,
    );
  }
}

class TrustScore {
  final double score; // 0-100
  final String level; // "새싹", "새내기" 등
  final int dailyQuestStreak;
  final DateTime? lastQuestDate;
  final int totalQuestCount;
  final int consecutiveLoginDays;
  final List<String> badges;

  TrustScore({
    required this.score,
    required this.level,
    required this.dailyQuestStreak,
    this.lastQuestDate,
    required this.totalQuestCount,
    required this.consecutiveLoginDays,
    required this.badges,
  });

  // Alias for compatibility
  int get questStreak => dailyQuestStreak;

  factory TrustScore.fromMap(Map<String, dynamic> map) {
    return TrustScore(
      score: (map['score'] ?? 0).toDouble(),
      level: map['level'] ?? '새싹',
      dailyQuestStreak: map['dailyQuestStreak'] ?? 0,
      lastQuestDate: (map['lastQuestDate'] as Timestamp?)?.toDate(),
      totalQuestCount: map['totalQuestCount'] ?? 0,
      consecutiveLoginDays: map['consecutiveLoginDays'] ?? 0,
      badges: List<String>.from(map['badges'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'level': level,
      'dailyQuestStreak': dailyQuestStreak,
      'lastQuestDate': lastQuestDate != null
          ? Timestamp.fromDate(lastQuestDate!)
          : null,
      'totalQuestCount': totalQuestCount,
      'consecutiveLoginDays': consecutiveLoginDays,
      'badges': badges,
    };
  }

  TrustScore copyWith({
    double? score,
    String? level,
    int? dailyQuestStreak,
    DateTime? lastQuestDate,
    int? totalQuestCount,
    int? consecutiveLoginDays,
    List<String>? badges,
  }) {
    return TrustScore(
      score: score ?? this.score,
      level: level ?? this.level,
      dailyQuestStreak: dailyQuestStreak ?? this.dailyQuestStreak,
      lastQuestDate: lastQuestDate ?? this.lastQuestDate,
      totalQuestCount: totalQuestCount ?? this.totalQuestCount,
      consecutiveLoginDays: consecutiveLoginDays ?? this.consecutiveLoginDays,
      badges: badges ?? this.badges,
    );
  }
}

class HeartTemperature {
  final double temperature; // 0-99.9
  final String level;

  HeartTemperature({
    required this.temperature,
    required this.level,
  });

  factory HeartTemperature.fromMap(Map<String, dynamic> map) {
    return HeartTemperature(
      temperature: (map['temperature'] ?? 36.5).toDouble(),
      level: map['level'] ?? '미지근',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'level': level,
    };
  }

  HeartTemperature copyWith({
    double? temperature,
    String? level,
  }) {
    return HeartTemperature(
      temperature: temperature ?? this.temperature,
      level: level ?? this.level,
    );
  }
}

class Subscription {
  final String type; // "free", "basic", "premium", "vip_basic", etc.
  final DateTime? startDate;
  final DateTime? endDate;
  final bool autoRenew;

  Subscription({
    required this.type,
    this.startDate,
    this.endDate,
    required this.autoRenew,
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      type: map['type'] ?? 'free',
      startDate: (map['startDate'] as Timestamp?)?.toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      autoRenew: map['autoRenew'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'autoRenew': autoRenew,
    };
  }

  bool get isVip => type.startsWith('vip_');
  bool get isPremium => type == 'vip_premium' || type == 'vip_platinum';
  bool get isActive => endDate != null && endDate!.isAfter(DateTime.now());

  Subscription copyWith({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    bool? autoRenew,
  }) {
    return Subscription(
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      autoRenew: autoRenew ?? this.autoRenew,
    );
  }
}

class Safety {
  final List<EmergencyContact> emergencyContacts;
  final List<String> blockList;

  Safety({
    required this.emergencyContacts,
    required this.blockList,
  });

  factory Safety.fromMap(Map<String, dynamic> map) {
    return Safety(
      emergencyContacts: (map['emergencyContacts'] as List?)
          ?.map((e) => EmergencyContact.fromMap(e))
          .toList() ?? [],
      blockList: List<String>.from(map['blockList'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'emergencyContacts': emergencyContacts.map((e) => e.toMap()).toList(),
      'blockList': blockList,
    };
  }
}

class EmergencyContact {
  final String name;
  final String phone;
  final String relationship;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.relationship,
  });

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      relationship: map['relationship'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }
}
