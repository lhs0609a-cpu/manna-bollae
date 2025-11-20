import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';
import '../../../models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../matching/providers/matching_provider.dart';
import '../../avatar/widgets/avatar_renderer.dart';
import '../../onboarding/providers/daily_question_provider.dart';
import '../../onboarding/widgets/today_question_card.dart';
import '../../gacha/providers/gacha_provider.dart';
import '../../gacha/widgets/dice_gacha_card.dart';
import '../../chat/providers/chat_provider.dart';
import '../../chat/screens/chat_detail_screen.dart';
import '../../../models/chat_model.dart';
import '../../streak/providers/streak_provider.dart';
import '../../streak/widgets/streak_card.dart';
import '../../popularity/providers/popularity_provider.dart';
import '../../popularity/widgets/popularity_dashboard.dart';
import '../../notifications/widgets/urgent_notification_banner.dart';
import '../../activity/widgets/real_time_activity_feed.dart';
import '../../profile/widgets/profile_completion_card.dart';
import '../../poll/widgets/quick_poll_card.dart';
import '../../gacha/widgets/daily_lucky_box.dart';
import '../../leaderboard/widgets/weekly_leaderboard_card.dart';
import '../../matching/widgets/swipe_matching_card.dart';

class HomeScreenMatchingFirst extends StatefulWidget {
  const HomeScreenMatchingFirst({super.key});

  @override
  State<HomeScreenMatchingFirst> createState() => _HomeScreenMatchingFirstState();
}

class _HomeScreenMatchingFirstState extends State<HomeScreenMatchingFirst>
    with TickerProviderStateMixin {
  UserModel? _currentUser;
  bool _isLoading = true;
  Timer? _timer;
  String _timeUntilReset = '00:00:00';
  String _hotTimeRemaining = '00:00';
  int _currentCardIndex = 0;
  late AnimationController _cardAnimationController;
  late AnimationController _likeAnimationController;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  // Mock data for who liked you
  final List<Map<String, dynamic>> _whoLikedYou = [
    {'name': '민지', 'age': 25, 'mbti': 'ENFP', 'time': '5분 전'},
    {'name': '수진', 'age': 27, 'mbti': 'INFJ', 'time': '12분 전'},
    {'name': '하은', 'age': 26, 'mbti': 'ENTP', 'time': '1시간 전'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _startTimer();
    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cardAnimationController.dispose();
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeUntilReset = _getTimeUntilReset();
          _hotTimeRemaining = _getHotTimeRemaining();
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

  String _getHotTimeRemaining() {
    final now = DateTime.now();
    if (now.hour >= 20 && now.hour < 22) {
      final hotTimeEnd = DateTime(now.year, now.month, now.day, 22);
      final duration = hotTimeEnd.difference(now);
      final hours = duration.inHours.toString().padLeft(2, '0');
      final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
      return '$hours:$minutes';
    } else if (now.hour < 20) {
      final hotTimeStart = DateTime(now.year, now.month, now.day, 20);
      final duration = hotTimeStart.difference(now);
      final hours = duration.inHours.toString().padLeft(2, '0');
      final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
      return '$hours:$minutes';
    } else {
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 20);
      final duration = tomorrow.difference(now);
      final hours = duration.inHours.toString().padLeft(2, '0');
      final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
      return '$hours:$minutes';
    }
  }

  Future<void> _loadUserData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _currentUser = _createMockUser();
        _isLoading = false;
      });

      final matchingProvider = context.read<MatchingProvider>();
      await matchingProvider.loadDailyMatchData();
      await matchingProvider.fetchRecommendedUsers('demo_user');

      // DailyQuestionProvider 초기화
      final questionProvider = context.read<DailyQuestionProvider>();
      await questionProvider.initialize('demo_user');

      // GachaProvider 초기화 (주사위 가챠)
      final gachaProvider = context.read<GachaProvider>();
      await gachaProvider.initialize(userId: 'demo_user');

      // StreakProvider 초기화
      final streakProvider = context.read<StreakProvider>();
      await streakProvider.initialize('demo_user');

      // PopularityProvider 초기화
      final popularityProvider = context.read<PopularityProvider>();
      await popularityProvider.initialize('demo_user');

      // 오늘의 질문 팝업 표시
      _showDailyQuestionPopup();
    }
  }

  Future<void> _showDailyQuestionPopup() async {
    final questionProvider = context.read<DailyQuestionProvider>();
    final progress = questionProvider.progress;

    // 이미 오늘 3개 질문에 모두 답변했거나 30일 완료했으면 팝업 표시 안 함
    if (progress.isCompleted || questionProvider.hasAnsweredToday) {
      return;
    }

    // 답변하지 않은 질문이 있는지 확인
    final todayQuestions = questionProvider.todayQuestions;
    if (todayQuestions.isEmpty) {
      return;
    }

    // SharedPreferences에서 마지막 팝업 표시 날짜 확인 (중복 방지)
    final prefs = await SharedPreferences.getInstance();
    final lastPopupDate = prefs.getString('last_question_popup_date');
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';

    // 오늘 이미 팝업을 표시했으면 다시 표시하지 않음
    if (lastPopupDate == todayString) {
      return;
    }

    // 약간의 딜레이 후 팝업 표시 (최초 1회만)
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (mounted && !questionProvider.hasAnsweredToday) {
        // 팝업 표시 날짜 저장
        await prefs.setString('last_question_popup_date', todayString);

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => TodayQuestionCard(userId: 'demo_user'),
          );
        }
      }
    });
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

  void _handleSwipe(DragEndDetails details, UserModel user) {
    final velocity = details.velocity.pixelsPerSecond;

    if (velocity.dx.abs() > 500 || _dragOffset.dx.abs() > 100) {
      // Swipe detected
      if (_dragOffset.dx > 0) {
        // Swipe right - Like
        _handleLike(user);
      } else {
        // Swipe left - Pass
        _handlePass(user);
      }
    } else {
      // Return to center
      setState(() {
        _dragOffset = Offset.zero;
        _isDragging = false;
      });
    }
  }

  void _handleLike(UserModel user) async {
    final matchingProvider = context.read<MatchingProvider>();

    _likeAnimationController.forward(from: 0);

    // Animate card off screen
    setState(() {
      _dragOffset = Offset(500, 0);
    });

    await Future.delayed(const Duration(milliseconds: 300));

    final success = await matchingProvider.sendLike('demo_user', user.userId);

    if (success) {
      setState(() {
        _currentCardIndex++;
        _dragOffset = Offset.zero;
        _isDragging = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.profile.basicInfo.name}님에게 좋아요를 보냈습니다!'),
            backgroundColor: Colors.pink,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      setState(() {
        _dragOffset = Offset.zero;
        _isDragging = false;
      });

      if (mounted && matchingProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(matchingProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handlePass(UserModel user) async {
    final matchingProvider = context.read<MatchingProvider>();

    // Animate card off screen
    setState(() {
      _dragOffset = Offset(-500, 0);
    });

    await Future.delayed(const Duration(milliseconds: 300));

    await matchingProvider.sendPass('demo_user', user.userId);

    setState(() {
      _currentCardIndex++;
      _dragOffset = Offset.zero;
      _isDragging = false;
    });
  }

  void _handleMessage(UserModel user) async {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();

    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    // 기존 채팅방 찾기 또는 새로 만들기
    try {
      Chat? existingChat;

      // 기존 채팅방 찾기
      for (final chat in chatProvider.chats) {
        if (chat.participants.contains(user.userId)) {
          existingChat = chat;
          break;
        }
      }

      // 채팅방이 없으면 새로 만들기
      if (existingChat == null) {
        final chatId = await chatProvider.getOrCreateChat(
          authProvider.uid!,
          user.userId,
        );

        if (chatId != null) {
          existingChat = Chat(
            id: chatId,
            participants: [authProvider.uid!, user.userId],
            lastMessage: null,
            lastMessageTime: DateTime.now(),
            unreadCount: {authProvider.uid!: 0, user.userId: 0},
            createdAt: DateTime.now(),
          );
        }
      }

      if (existingChat != null && mounted) {
        // 채팅 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              chat: existingChat!,
              otherUser: user,
              otherUserAvatar: user.avatar,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('채팅방을 여는데 실패했습니다: $e')),
        );
      }
    }
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
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 스와이프 매칭 카드 (매칭 탭에서 이동)
            SwipeMatchingCard(),

            const SizedBox(height: 16),

            // 긴급 알림 배너
            UrgentNotificationBanner(),

            // 실시간 인기도 대시보드
            PopularityDashboard(),

            // 프로필 완성도 카드
            ProfileCompletionCard(),

            // 대형 매칭 카드
            _buildLargeMatchingCard(),

            const SizedBox(height: 16),

            // 스트릭 시스템 (연속 접속)
            StreakCard(userId: 'demo_user'),

            const SizedBox(height: 16),

            // 데일리 럭키박스
            DailyLuckyBox(),

            const SizedBox(height: 16),

            // 주사위 가챠 (매칭 추가 획득)
            DiceGachaCard(),

            const SizedBox(height: 16),

            // 실시간 활동 피드
            RealTimeActivityFeed(),

            const SizedBox(height: 16),

            // 빠른 투표
            QuickPollCard(),

            const SizedBox(height: 16),

            // 주간 리더보드
            WeeklyLeaderboardCard(),

            const SizedBox(height: 16),

            // 누가 나를 좋아하는지
            _buildWhoLikedYouSection(),

            const SizedBox(height: 12),

            // Hot Time 타이머
            _buildHotTimeSection(),

            const SizedBox(height: 12),

            // 실시간 활동
            _buildRealTimeActivity(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
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
          icon: Stack(
            children: [
              const Icon(Icons.favorite_border, color: Colors.black),
              if (_whoLikedYou.isNotEmpty)
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
                    child: Text(
                      '${_whoLikedYou.length}',
                      style: const TextStyle(
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
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildLargeMatchingCard() {
    final matchingProvider = context.watch<MatchingProvider>();
    final recommendedUsers = matchingProvider.recommendedUsers;

    if (_currentCardIndex >= recommendedUsers.length) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.65,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[200]!, Colors.grey[100]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                '더 이상 추천할 프로필이 없습니다',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '내일 다시 확인해주세요!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentUser = recommendedUsers[_currentCardIndex];
    final compatibility = 75 + Random().nextInt(20); // 75-94%
    final distance = (Random().nextDouble() * 5).toStringAsFixed(1); // 0-5km
    final isOnline = Random().nextBool();

    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          _isDragging = true;
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _dragOffset += details.delta;
        });
      },
      onPanEnd: (details) => _handleSwipe(details, currentUser),
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: _dragOffset.dx / 1000,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.65,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.primaries[currentUser.userId.hashCode % Colors.primaries.length][200]!,
                  Colors.primaries[currentUser.userId.hashCode % Colors.primaries.length][400]!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 배경 이미지 (상대방이 설정한 배경)
                if (currentUser.avatar.currentOutfit.background.isNotEmpty)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Opacity(
                        opacity: 0.3,
                        child: _getBackgroundWidget(currentUser.avatar.currentOutfit.background),
                      ),
                    ),
                  ),
                // 메인 콘텐츠
                Column(
                  children: [
                    const Expanded(
                      child: Center(
                        child: Text(
                          '매칭 카드',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getBackgroundWidget(String background) {
    // 배경 타입에 따라 위젯 반환
    switch (background) {
      case 'cafe':
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.brown[200]!,
                Colors.brown[400]!,
              ],
            ),
          ),
          child: Center(
            child: Text(
              '☕',
              style: TextStyle(fontSize: 100, color: Colors.white.withOpacity(0.3)),
            ),
          ),
        );
      case 'park':
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green[200]!,
                Colors.green[400]!,
              ],
            ),
          ),
          child: Center(
            child: Text(
              '🌳',
              style: TextStyle(fontSize: 100, color: Colors.white.withOpacity(0.3)),
            ),
          ),
        );
      case 'beach':
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue[200]!,
                Colors.cyan[400]!,
              ],
            ),
          ),
          child: Center(
            child: Text(
              '🏖️',
              style: TextStyle(fontSize: 100, color: Colors.white.withOpacity(0.3)),
            ),
          ),
        );
      case 'city':
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey[300]!,
                Colors.grey[600]!,
              ],
            ),
          ),
          child: Center(
            child: Text(
              '🏙️',
              style: TextStyle(fontSize: 100, color: Colors.white.withOpacity(0.3)),
            ),
          ),
        );
      case 'plain':
      default:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
            ),
          ),
        );
    }
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: size * 0.5,
        ),
      ),
    );
  }

  Widget _buildWhoLikedYouSection() {
    if (_whoLikedYou.isEmpty) return const SizedBox.shrink();
    return Container(); // Placeholder
  }

  Widget _buildHotTimeSection() {
    return Container(); // Placeholder
  }

  Widget _buildRealTimeActivity() {
    return Container(); // Placeholder
  }

  Widget _buildActivityStat(String value, String label, Color color) {
    return Container(); // Placeholder
  }

}
