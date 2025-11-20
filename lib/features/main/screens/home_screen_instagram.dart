import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../models/user_model.dart';
import '../../../models/daily_mission_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../matching/providers/matching_provider.dart';
import '../../mission/providers/daily_mission_provider.dart';

class HomeScreenInstagram extends StatefulWidget {
  const HomeScreenInstagram({super.key});

  @override
  State<HomeScreenInstagram> createState() => _HomeScreenInstagramState();
}

class _HomeScreenInstagramState extends State<HomeScreenInstagram> {
  UserModel? _currentUser;
  bool _isLoading = true;
  Timer? _timer;
  String _timeUntilReset = '00:00:00';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeUntilReset = _getTimeUntilReset();
        });
      }
    });
  }

  String _getTimeUntilReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final duration = tomorrow.difference(now);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _loadUserData() async {
    // Mock 데이터 사용
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _currentUser = _createMockUser();
        _isLoading = false;
      });

      // MatchingProvider 초기화
      final matchingProvider = context.read<MatchingProvider>();
      await matchingProvider.loadDailyMatchData();

      // DailyMissionProvider 초기화
      final missionProvider = context.read<DailyMissionProvider>();
      await missionProvider.initializeMissions();
    }
  }

  UserModel _createMockUser() {
    return UserModel(
      userId: 'demo_user',
      profile: UserProfile(
        basicInfo: BasicInfo(
          name: '지은',
          birthdate: DateTime(1995, 5, 15),
          ageRange: '20대 후반',
          gender: 'female',
          region: '서울',
          mbti: 'ENFP',
          bloodType: 'A',
          smoking: false,
          drinking: '가끔',
          religion: '무교',
          firstRelationship: false,
        ),
        lifestyle: Lifestyle(
          hobbies: ['여행', '사진', '카페투어'],
          hasPet: false,
          exerciseFrequency: '주 2-3회',
          travelStyle: '계획적',
        ),
        appearance: Appearance(
          heightRange: '160-165cm',
          photos: [],
        ),
        oneLiner: '좋은 사람들과 좋은 추억 만들고 싶어요 ✨',
      ),
      avatar: Avatar(
        personality: 'cheerful',
        style: 'casual',
        colorPreference: 'pink',
        animalType: 'cat',
        hobby: 'photography',
        baseCharacter: 'default',
        currentOutfit: AvatarOutfit(
          top: 'blouse',
          bottom: 'jeans',
          accessories: [],
          hair: 'long',
          hairColor: 'brown',
          background: 'cafe',
          specialItem: '',
          emotion: 'happy',
        ),
        ownedItems: OwnedItems(
          tops: ['blouse', 'tshirt'],
          bottoms: ['jeans'],
          accessories: [],
          hairs: ['long'],
          backgrounds: ['cafe', 'plain'],
          specialItems: [],
        ),
      ),
      trustScore: TrustScore(
        score: 85.0,
        level: '진심왕',
        dailyQuestStreak: 12,
        totalQuestCount: 45,
        consecutiveLoginDays: 21,
        badges: ['초보자', '성실', '인기'],
      ),
      heartTemperature: HeartTemperature(
        temperature: 52.3,
        level: '뜨거움',
      ),
      subscription: Subscription(
        type: 'vip_basic',
        autoRenew: true,
      ),
      safety: Safety(
        emergencyContacts: [],
        blockList: [],
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('사용자 정보를 불러올 수 없습니다')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 인스타 스타일 앱바
          _buildInstagramAppBar(),
          // 프로필 섹션 (스토리 스타일)
          _buildProfileStories(),
          // 피드 카드들
          _buildFeedCards(),
        ],
      ),
    );
  }

  Widget _buildInstagramAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      floating: true,
      pinned: true,
      title: const Text(
        '만나볼래',
        style: TextStyle(
          fontFamily: 'Pacifico',
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.chat_bubble_outline, color: Colors.black),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Colors.grey[300],
          height: 0.5,
        ),
      ),
    );
  }

  Widget _buildProfileStories() {
    return SliverToBoxAdapter(
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
          ),
        ),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            _buildStoryCircle(
              '나',
              _currentUser!.profile.basicInfo.name,
              Colors.pink,
              isMe: true,
            ),
            _buildStoryCircle('유진', '새로운 매칭', Colors.purple),
            _buildStoryCircle('민수', '채팅 중', Colors.blue),
            _buildStoryCircle('수진', '관심 표시', Colors.orange),
            _buildStoryCircle('현우', '매칭 성공', Colors.green),
            _buildStoryCircle('지혜', '새 메시지', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCircle(String name, String subtitle, Color color,
      {bool isMe = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    child: Text(
                      name[0],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
              if (isMe)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedCards() {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 8),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildWelcomeCard(),
          _buildDailyMissionsCard(), // 새로운: 일일 미션
          _buildFOMOCard(), // 새로운: FOMO 유발
          _buildSocialProofCard(), // 새로운: 소셜 증거
          _buildPersonalizedRecommendationCard(), // 새로운: 개인화된 추천
          _buildProgressVisualizationCard(), // 새로운: 진행 상황
          _buildStatsCard(),
          _buildTodayMatchCard(),
          _buildLeaderboardCard(), // 새로운: 경쟁 요소
          _buildRecommendationsCard(),
          _buildActivitiesCard(),
        ]),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '만나볼래',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '오늘도 좋은 하루 되세요!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                  iconSize: 20,
                ),
              ],
            ),
          ),
          // 이미지/내용
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.pink[50]!,
                  Colors.purple[50]!,
                ],
              ),
            ),
            child: Column(
              children: [
                Text(
                  '안녕하세요, ${_currentUser!.profile.basicInfo.name}님! 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _currentUser!.profile.oneLiner,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // 액션 버튼들
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildActionIcon(Icons.favorite_border, '좋아요'),
                const SizedBox(width: 16),
                _buildActionIcon(Icons.chat_bubble_outline, '댓글'),
                const SizedBox(width: 16),
                _buildActionIcon(Icons.send_outlined, '공유'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {},
                  iconSize: 26,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(
              '오늘 새로운 매칭 3개가 도착했어요!',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Icon(icon, size: 26),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.pink[100],
                  child: Icon(Icons.analytics, color: Colors.pink[700], size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  '나의 활동',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    _currentUser!.trustScore.score.round().toString(),
                    '신뢰 지수',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    _currentUser!.heartTemperature.temperature
                        .toStringAsFixed(1),
                    '하트 온도',
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    _currentUser!.trustScore.dailyQuestStreak.toString(),
                    '연속 출석',
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayMatchCard() {
    final matchingProvider = context.watch<MatchingProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.pink, size: 20),
              const SizedBox(width: 8),
              const Text(
                '오늘의 매칭',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('모두 보기'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 매칭 정보 카드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.pink[50]!,
                  Colors.purple[50]!,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.pink.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMatchInfoItem(
                      '오늘 매칭',
                      '${matchingProvider.dailyMatchCount}',
                      Icons.favorite,
                      Colors.pink,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                    _buildMatchInfoItem(
                      '남은 횟수',
                      '${matchingProvider.remainingMatches}',
                      Icons.favorite_border,
                      Colors.purple,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey[300],
                    ),
                    _buildMatchInfoItem(
                      '일일 한도',
                      '${matchingProvider.dailyMatchLimit}',
                      Icons.star,
                      Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text(
                      '다음 리셋까지 ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.pink[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _timeUntilReset,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildMatchPreview('민지', '25', 'ENFP'),
                _buildMatchPreview('준호', '28', 'INFJ'),
                _buildMatchPreview('서연', '26', 'ENFJ'),
                _buildMatchPreview('도윤', '27', 'ISTJ'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchInfoItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMatchPreview(String name, String age, String mbti) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.primaries[name.hashCode % Colors.primaries.length][100]!,
            Colors.primaries[name.hashCode % Colors.primaries.length][200]!,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Text(
              name[0],
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.primaries[name.hashCode % Colors.primaries.length],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$age세 • $mbti',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                '추천 프로필',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRecommendationTile('지수', '온도 높음', Colors.red),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRecommendationTile('현석', 'MBTI 일치', Colors.purple),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationTile(String name, String tag, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.2),
            child: Text(
              name[0],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              tag,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                '최근 활동',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            Icons.favorite,
            '새로운 좋아요 5개',
            '2시간 전',
            Colors.pink,
          ),
          _buildActivityItem(
            Icons.chat,
            '읽지 않은 메시지 3개',
            '5시간 전',
            Colors.blue,
          ),
          _buildActivityItem(
            Icons.person_add,
            '새로운 매칭 제안',
            '1일 전',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      IconData icon, String title, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  // ========== 새로운 카드 위젯들 ==========

  /// 1. 일일 미션 카드
  Widget _buildDailyMissionsCard() {
    final missionProvider = context.watch<DailyMissionProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.stars, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '오늘의 미션',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${missionProvider.completedCount}/${missionProvider.totalCount}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...missionProvider.missions.map((mission) => _buildMissionTile(mission)),
        ],
      ),
    );
  }

  Widget _buildMissionTile(DailyMission mission) {
    final missionProvider = context.read<DailyMissionProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: mission.isCompleted ? Colors.green[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mission.isCompleted ? Colors.green : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                mission.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: mission.isCompleted ? Colors.green : Colors.grey,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: mission.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      mission.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (mission.canClaim && !mission.isCompleted)
                ElevatedButton(
                  onPressed: () async {
                    await missionProvider.claimMissionReward(mission.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${mission.reward.description} 획득!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('받기', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: mission.progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    mission.isCompleted ? Colors.green : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${mission.currentCount}/${mission.targetCount}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. FOMO 카드 (시간 제한 이벤트)
  Widget _buildFOMOCard() {
    // FOMO 이벤트 시간 계산 (예: 오후 8-10시)
    final now = DateTime.now();
    final isHotTime = now.hour >= 20 && now.hour < 22;
    final hotTimeStart = DateTime(now.year, now.month, now.day, 20);
    final hotTimeEnd = DateTime(now.year, now.month, now.day, 22);

    Duration timeUntilEvent;
    String eventText;
    if (isHotTime) {
      timeUntilEvent = hotTimeEnd.difference(now);
      eventText = '핫타임 진행 중! 2배 보상!';
    } else if (now.hour < 20) {
      timeUntilEvent = hotTimeStart.difference(now);
      eventText = '핫타임까지 남은 시간';
    } else {
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 20);
      timeUntilEvent = tomorrow.difference(now);
      eventText = '다음 핫타임까지';
    }

    final hours = timeUntilEvent.inHours.toString().padLeft(2, '0');
    final minutes = (timeUntilEvent.inMinutes % 60).toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isHotTime
              ? [Colors.orange[700]!, Colors.red[700]!]
              : [Colors.purple[700]!, Colors.pink[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            isHotTime ? Icons.local_fire_department : Icons.access_time,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHotTime ? '🔥 핫타임 진행 중!' : '⏰ 핫타임 알림',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isHotTime
                      ? '지금 매칭하면 보상 2배! 서두르세요!'
                      : '오후 8-10시 접속자 200% 증가!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  '$hours:$minutes',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  eventText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 3. 소셜 증거 카드
  Widget _buildSocialProofCard() {
    final random = Random();
    final onlineUsers = 1200 + random.nextInt(300);
    final todayMatches = 450 + random.nextInt(150);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.green[100],
                child: Icon(Icons.people, color: Colors.green[700], size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '실시간 활동',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSocialProofItem(
                  '🟢 $onlineUsers명',
                  '지금 온라인',
                  Colors.green,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              Expanded(
                child: _buildSocialProofItem(
                  '❤️ $todayMatches건',
                  '오늘 매칭 성공',
                  Colors.pink,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              Expanded(
                child: _buildSocialProofItem(
                  '⏰ 오후 9시',
                  '인기 시간대',
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialProofItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 4. 개인화된 추천 알림 카드
  Widget _buildPersonalizedRecommendationCard() {
    final random = Random();
    final matchRate = 85 + random.nextInt(15);
    final likesCount = random.nextInt(6) + 1;
    final viewsCount = 15 + random.nextInt(15);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink[50]!, Colors.purple[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '나를 위한 추천',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPersonalizedRecommendationTile(
            '💕 $matchRate% 매칭되는 새로운 프로필!',
            '회원님과 취미, MBTI가 비슷한 분을 찾았어요',
            Colors.pink,
          ),
          const SizedBox(height: 8),
          _buildPersonalizedRecommendationTile(
            '👍 회원님을 좋아요한 사람 $likesCount명',
            '누가 회원님에게 관심이 있는지 확인해보세요',
            Colors.purple,
          ),
          const SizedBox(height: 8),
          _buildPersonalizedRecommendationTile(
            '👀 오늘 프로필 조회 $viewsCount번',
            '회원님의 매력이 빛나고 있어요!',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedRecommendationTile(String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: color),
        ],
      ),
    );
  }

  /// 5. 진행 상황 시각화 카드
  Widget _buildProgressVisualizationCard() {
    // 프로필 완성도 계산 (데모)
    final profileCompletion = 75.0;
    final currentLevel = 7;
    final levelProgress = 65.0;
    final badgesCollected = 15;
    final totalBadges = 50;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.trending_up, color: Colors.blue[700], size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                '내 성장',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 프로필 완성도
          _buildProgressItem(
            '프로필 완성도',
            profileCompletion,
            '${profileCompletion.toInt()}%',
            '사진 추가하면 95%!',
            Colors.blue,
          ),
          const SizedBox(height: 12),
          // 레벨
          _buildProgressItem(
            '레벨 $currentLevel',
            levelProgress,
            '레벨 ${currentLevel + 1}까지',
            '50점 남음',
            Colors.purple,
          ),
          const SizedBox(height: 12),
          // 뱃지 수집
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '뱃지 수집',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$badgesCollected/$totalBadges개 수집',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(badgesCollected / totalBadges * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[900],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
    String title,
    double progress,
    String progressText,
    String hint,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              progressText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Text(
          hint,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 6. 리더보드 카드 (경쟁 요소)
  Widget _buildLeaderboardCard() {
    final leaderboard = [
      {'name': '민지', 'score': 98.5, 'region': '서울'},
      {'name': '준호', 'score': 96.2, 'region': '서울'},
      {'name': '서연', 'score': 94.8, 'region': '경기'},
      {'name': '지은', 'score': 52.3, 'isMe': true, 'region': '서울', 'rank': 24},
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.orange[100],
                child: Icon(Icons.leaderboard, color: Colors.orange[700], size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '이번 주 하트 온도 TOP 10',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('전체보기'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...leaderboard.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            final isMe = user['isMe'] == true;
            final rank = isMe ? user['rank'] as int : index + 1;

            return _buildLeaderboardTile(
              rank,
              user['name'] as String,
              user['score'] as double,
              user['region'] as String,
              isMe,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(
    int rank,
    String name,
    double score,
    String region,
    bool isMe,
  ) {
    Color rankColor = Colors.grey[700]!;
    if (rank == 1) rankColor = Colors.amber[700]!;
    if (rank == 2) rankColor = Colors.grey[500]!;
    if (rank == 3) rankColor = Colors.brown[400]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? Colors.pink[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe ? Colors.pink : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: rank <= 3 ? rankColor.withOpacity(0.2) : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.pink[100],
            child: Text(
              name[0],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                Text(
                  region,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${score.toStringAsFixed(1)}°',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              if (isMe)
                Text(
                  '내 순위',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.pink[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
