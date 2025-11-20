class AppConstants {
  // App Info
  static const String appName = '만나볼래';
  static const String appVersion = '1.0.0';

  // Intimacy Levels (친밀도 단계)
  static const int intimacyLevel0 = 0; // 기본 정보
  static const int intimacyLevel1 = 500; // 상세 정보
  static const int intimacyLevel2 = 1500; // 정확한 나이/지역/키
  static const int intimacyLevel3 = 2500; // 얼굴 사진
  static const int intimacyLevel4 = 3500; // 추가 정보
  static const int intimacyLevel5 = 4500; // 전체 공개
  static const int intimacyMax = 5000;

  // Intimacy Gains (친밀도 획득량)
  static const int intimacyTextMessage = 10;
  static const int intimacyVoiceMessage = 20;
  static const int intimacyImageMessage = 15;
  static const int intimacyVideoCall = 50;
  // Aliases for compatibility
  static const int intimacyPerTextMessage = intimacyTextMessage;
  static const int intimacyPerVoiceMessage = intimacyVoiceMessage;
  static const int intimacyPerImageMessage = intimacyImageMessage;
  static const int intimacyPerVideoCall = intimacyVideoCall;

  // Trust Score (진심 지수)
  static const double trustScoreMax = 100.0;
  static const double trustScoreDailyQuest = 0.3;
  static const double trustScorePhoneVerification = 5.0;
  static const double trustScoreVideoVerification = 5.0;
  static const double trustScoreCriminalRecord = 8.0;
  static const double trustScoreSchoolViolence = 8.0;
  static const double trustScoreJobVerification = 5.0;
  static const double trustScoreEducationVerification = 3.0;
  static const double trustScore7DayStreak = 1.0;
  // Aliases for compatibility
  static const double trustScoreCriminalCheck = trustScoreCriminalRecord;
  static const double trustScoreSchoolViolenceCheck = trustScoreSchoolViolence;
  static const double trustScoreOccupationVerification = trustScoreJobVerification;
  static const double trustScoreSevenDayBonus = trustScore7DayStreak;

  // Trust Score Levels
  static const Map<String, double> trustScoreLevels = {
    '새싹': 0,
    '새내기': 20,
    '일반': 40,
    '믿음직한': 60,
    '진심왕': 80,
  };

  // Trust Score Levels by Score (reverse map for quick lookup)
  static const Map<int, String> trustScoreLevelsByScore = {
    0: '새싹',
    20: '새내기',
    40: '일반',
    60: '믿음직한',
    80: '진심왕',
  };

  // Heart Temperature (하트 온도)
  static const double heartTempMin = 0.0;
  static const double heartTempMax = 99.9;
  static const double heartTempDefault = 36.5;
  static const double heartTempPositiveReview = 1.0;
  static const double heartTempNegativeReview = 3.0;
  static const double heartTempReport = 10.0;

  // Temperature Levels
  static const Map<String, double> temperatureLevels = {
    '차가움': 0,
    '시원함': 20,
    '미지근': 30,
    '따뜻함': 40,
    '뜨거움': 60,
  };

  // Heart Temperature Levels by Score (reverse map for quick lookup)
  static const Map<int, String> heartTempLevelsByScore = {
    0: '차가움',
    10: '차가움',
    20: '시원함',
    40: '따뜻함',
    60: '뜨거움',
  };
  // Alias for compatibility
  static const Map<int, String> heartTempLevels = heartTempLevelsByScore;

  // VIP Subscription Requirements
  static const double vipRequiredTrustScore = 60.0;
  static const double vipRequiredTemperature = 30.0;

  // VIP Plan Prices (월 구독료, 원)
  static const int vipBasicPrice = 49900;
  static const int vipPremiumPrice = 79900;
  static const int vipPlatinumPrice = 129900;

  // Avatar Item Prices
  static const int avatarItemMinPrice = 1000;
  static const int avatarItemMaxPrice = 10000;
  static const int avatarStarterPackagePrice = 9900;
  static const int avatarPremiumPackagePrice = 19900;

  // Matching Limits (일일 매칭 가능 횟수)
  static const int matchLimitFree = 5;
  static const int matchLimitBasic = 5;
  static const int matchLimitPremium = 10;
  static const int matchLimitVIPBasic = 15;
  static const int matchLimitVIPPremium = 30;
  static const int matchLimitVIPPlatinum = 999; // 무제한
  static const int freeMatchesPerDay = 5;
  static const int vipBasicMatchesPerDay = 15;
  static const int vipPremiumMatchesPerDay = 30;
  static const int vipPlatinumMatchesPerDay = 999;

  // Chat Limits
  static const int freeChatLimit = 5;
  static const int vipBasicChatLimit = 15;
  static const int vipPremiumChatLimit = 30;
  static const int vipPlatinumChatLimit = 999;

  // Daily Quest
  static const int dailyQuestMinCharacters = 30;
  static const int dailyQuestMaxCharacters = 500;
  // Aliases for compatibility
  static const int questMinLength = dailyQuestMinCharacters;
  static const int questMaxLength = dailyQuestMaxCharacters;

  // Voice Message
  static const int voiceMessageMaxDuration = 60; // seconds

  // Safety
  static const int emergencyContactsMax = 3;
  static const int safetyCheckDelayMinutes = 30;
  static const int safetyCheckReminderMinutes = 10;
  static const int emergencyLocationUpdateSeconds = 60;

  // Verification
  static const int verificationVideoMaxDuration = 30; // seconds
  static const int verificationReviewHours = 24;
  static const int verificationExpiryDays = 365;

  // Age Range
  static const int minAge = 19;
  static const int maxAge = 99;

  // Profile
  static const int maxHobbies = 5;
  static const int oneLinerMaxLength = 100;
  static const int bioMaxLength = 500;

  // Photo Limits
  static const int maxPhotos = 6;
  static const int maxDailyPhotos = 10;

  // Regex Patterns
  static const String phoneNumberPattern = r'^01[0-9]-?[0-9]{4}-?[0-9]{4}$';
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  // API Endpoints (Firebase Cloud Functions)
  static const String functionBaseUrl = 'https://asia-northeast3-mannabollae.cloudfunctions.net';

  // Backend API Base URL
  // 환경 변수로 설정 가능: flutter build web --dart-define=API_URL=https://your-oracle-server.com
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080', // 로컬 개발용 기본값
  );

  // Storage Paths
  static const String storageProfilePhotos = 'profile_photos';
  static const String storageDailyPhotos = 'daily_photos';
  static const String storageVoiceMessages = 'voice_messages';
  static const String storageVerificationVideos = 'verification_videos';
  static const String storageVerificationDocuments = 'verification_documents';

  // Error Messages
  static const String errorNetwork = '네트워크 연결을 확인해주세요';
  static const String errorUnknown = '오류가 발생했습니다. 다시 시도해주세요';
  static const String errorAuth = '인증에 실패했습니다';
  static const String errorPermission = '권한이 필요합니다';

  // Success Messages
  static const String successProfileUpdated = '프로필이 업데이트되었습니다';
  static const String successMatchCreated = '매칭이 성공했습니다!';
  static const String successVerificationSubmitted = '인증이 제출되었습니다. 24시간 내 검토 예정입니다';
}
