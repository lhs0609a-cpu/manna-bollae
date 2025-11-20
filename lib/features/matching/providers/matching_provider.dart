import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/match_model.dart';
import '../../../models/user_model.dart';
import '../../../models/subscription_type.dart';
import '../../../core/constants/app_constants.dart';

class MatchingProvider extends ChangeNotifier {
  List<UserModel> _recommendedUsers = [];
  List<Match> _myMatches = [];
  bool _isLoading = false;
  String? _error;
  int _dailyMatchCount = 0;
  int _bonusMatches = 0; // 주사위 등으로 얻은 보너스 매칭
  DateTime? _lastResetDate;
  String _currentSubscriptionType = 'free'; // 데모 모드: 기본 무료

  List<UserModel> get recommendedUsers => _recommendedUsers;
  List<Match> get myMatches => _myMatches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get dailyMatchCount => _dailyMatchCount;
  int get bonusMatches => _bonusMatches;

  /// 현재 등급별 일일 매칭 한도
  int get dailyMatchLimit {
    final subscriptionType = SubscriptionTypeExtension.fromValue(_currentSubscriptionType);
    switch (subscriptionType) {
      case SubscriptionType.vip_platinum:
        return AppConstants.matchLimitVIPPlatinum;
      case SubscriptionType.vip_premium:
        return AppConstants.matchLimitVIPPremium;
      case SubscriptionType.vip_basic:
        return AppConstants.matchLimitVIPBasic;
      case SubscriptionType.premium:
        return AppConstants.matchLimitPremium;
      case SubscriptionType.basic:
        return AppConstants.matchLimitBasic;
      case SubscriptionType.free:
      default:
        return AppConstants.matchLimitFree;
    }
  }

  /// 남은 매칭 횟수 (일반 + 보너스)
  int get remainingMatches => ((dailyMatchLimit - _dailyMatchCount).clamp(0, dailyMatchLimit) + _bonusMatches);

  /// 다음 리셋까지 남은 시간 (초)
  int get secondsUntilReset {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now).inSeconds;
  }

  /// 일일 매칭 데이터 로드
  Future<void> loadDailyMatchData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetStr = prefs.getString('last_match_reset');
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    if (lastResetStr != todayStr) {
      // 날짜가 바뀌었으면 카운트 리셋
      _dailyMatchCount = 0;
      await prefs.setString('last_match_reset', todayStr);
      await prefs.setInt('daily_match_count', 0);
      // 보너스는 리셋하지 않음 (영구적)
    } else {
      // 오늘 날짜면 저장된 카운트 로드
      _dailyMatchCount = prefs.getInt('daily_match_count') ?? 0;
    }

    // 보너스 매칭 로드
    _bonusMatches = prefs.getInt('bonus_matches') ?? 0;

    // 구독 타입 로드 (데모 모드)
    _currentSubscriptionType = prefs.getString('subscription_type') ?? 'free';

    notifyListeners();
  }

  /// 일일 매칭 카운트 저장
  Future<void> _saveDailyMatchCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_match_count', _dailyMatchCount);
  }

  /// 구독 타입 변경 (데모 모드)
  Future<void> setSubscriptionType(String type) async {
    _currentSubscriptionType = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('subscription_type', type);
    notifyListeners();
  }

  /// 보너스 매칭 추가 (주사위 잭팟 등)
  Future<void> addBonusMatches(int count) async {
    _bonusMatches += count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bonus_matches', _bonusMatches);
    notifyListeners();
  }

  /// 보너스 매칭 저장
  Future<void> _saveBonusMatches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bonus_matches', _bonusMatches);
  }

  /// 추천 사용자 가져오기 (데모 모드)
  Future<void> fetchRecommendedUsers(String myUserId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 일일 매칭 데이터 로드
      await loadDailyMatchData();

      // 데모 모드: 더미 추천 사용자 생성
      await Future.delayed(const Duration(milliseconds: 500));

      _recommendedUsers = _generateDemoUsers();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '추천 사용자를 불러오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 데모 사용자 생성
  List<UserModel> _generateDemoUsers() {
    final names = ['지민', '수진', '하은', '서윤', '민서', '예린', '채원', '유나', '소연', '다현'];
    final regions = ['서울 강남구', '서울 송파구', '경기 수원', '서울 마포구', '서울 종로구'];
    final mbtis = ['ENFP', 'INFJ', 'ENTP', 'ISFJ', 'ESTP'];
    final hobbies = [
      ['독서', '영화감상', '카페투어'],
      ['운동', '여행', '요리'],
      ['음악감상', '게임', '사진촬영'],
      ['등산', '자전거', '캠핑'],
      ['미술', '공예', '베이킹'],
    ];

    return List.generate(10, (index) {
      return UserModel(
        userId: 'demo_match_user_$index',
        profile: UserProfile(
          basicInfo: BasicInfo(
            name: names[index],
            birthdate: DateTime(1995 + index, 3 + index, 10 + index),
            ageRange: '20대 ${index % 2 == 0 ? '후반' : '중반'}',
            exactAge: 25 + index,
            gender: '여성',
            region: regions[index % regions.length].split(' ')[0],
            detailedRegion: regions[index % regions.length].split(' ')[1],
            mbti: mbtis[index % mbtis.length],
            bloodType: ['A', 'B', 'O', 'AB'][index % 4],
            smoking: false,
            drinking: ['안마심', '가끔', '자주'][index % 3],
            religion: '무교',
            firstRelationship: index % 3 == 0,
          ),
          lifestyle: Lifestyle(
            hobbies: hobbies[index % hobbies.length],
            hasPet: index % 3 == 0,
            exerciseFrequency: ['안 함', '주 1-2회', '주 3회 이상'][index % 3],
            travelStyle: ['계획적', '즉흥적', '여유있게'][index % 3],
          ),
          appearance: Appearance(
            heightRange: '160-165cm',
            exactHeight: 160 + index,
            bodyType: ['마른', '보통', '통통'][index % 3],
            photos: [],
          ),
          oneLiner: '즐거운 인연을 만들고 싶어요 ${index + 1}',
        ),
        avatar: Avatar(
          personality: ['friendly', 'cool', 'cute'][index % 3],
          style: ['casual', 'formal', 'sporty'][index % 3],
          colorPreference: ['blue', 'pink', 'green'][index % 3],
          animalType: ['dog', 'cat', 'rabbit'][index % 3],
          hobby: ['sports', 'reading', 'music'][index % 3],
          baseCharacter: 'happy',
          currentOutfit: AvatarOutfit(
            top: 'shirt',
            bottom: 'jeans',
            accessories: ['cap'],
            hair: 'long',
            hairColor: 'brown',
            background: 'city',
            specialItem: '',
            emotion: 'happy',
          ),
          ownedItems: OwnedItems(
            tops: ['shirt'],
            bottoms: ['jeans'],
            accessories: ['cap'],
            hairs: ['long'],
            backgrounds: ['city'],
            specialItems: [],
          ),
        ),
        trustScore: TrustScore(
          score: 70.0 + (index * 2),
          level: '믿음직한',
          dailyQuestStreak: 5 + index,
          totalQuestCount: 30 + index,
          consecutiveLoginDays: 10 + index,
          badges: ['신규회원', '친절한'],
        ),
        heartTemperature: HeartTemperature(
          temperature: 40.0 + index,
          level: '따뜻함',
        ),
        subscription: Subscription(
          type: index % 4 == 0 ? 'vip_basic' : 'free',
          autoRenew: false,
        ),
        safety: Safety(
          emergencyContacts: [],
          blockList: [],
        ),
        createdAt: DateTime.now().subtract(Duration(days: 30 + index)),
        updatedAt: DateTime.now(),
      );
    });
  }


  /// 좋아요 보내기 (데모 모드)
  Future<bool> sendLike(String myUserId, String otherUserId) async {
    try {
      // 일일 매칭 데이터 로드
      await loadDailyMatchData();

      // 매칭 한도 체크 (보너스 포함)
      if (_dailyMatchCount >= dailyMatchLimit && _bonusMatches <= 0) {
        _error = '오늘의 매칭 한도를 초과했습니다. ${_getResetTimeString()}에 리셋됩니다.';
        notifyListeners();
        return false;
      }

      // 보너스 매칭이 있으면 먼저 사용
      if (_bonusMatches > 0) {
        _bonusMatches--;
        await _saveBonusMatches();
      } else {
        // 일일 매칭 카운트 증가
        _dailyMatchCount++;
        await _saveDailyMatchCount();
      }

      notifyListeners();
      return true; // 데모 모드: 항상 좋아요 성공
    } catch (e) {
      _error = '좋아요 전송에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 거절하기 (데모 모드)
  Future<void> sendPass(String myUserId, String otherUserId) async {
    try {
      // 일일 매칭 데이터 로드
      await loadDailyMatchData();

      // 일일 매칭 카운트 증가
      _dailyMatchCount++;
      await _saveDailyMatchCount();

      notifyListeners();
    } catch (e) {
      _error = '거절 처리에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 리셋 시간 문자열 (HH:MM:SS 형식)
  String _getResetTimeString() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final duration = tomorrow.difference(now);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// 내 매칭 목록 가져오기 (데모 모드)
  Future<void> fetchMyMatches(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 데모 모드: 빈 목록 반환
      await Future.delayed(const Duration(milliseconds: 300));
      _myMatches = [];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '매칭 목록을 불러오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 일일 카운트 초기화 (매일 자정에 자동 호출됨)
  void resetDailyCount() {
    _dailyMatchCount = 0;
    notifyListeners();
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
