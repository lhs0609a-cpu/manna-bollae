import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/user_model.dart';
import '../../../models/subscription_type.dart';
import '../../auth/providers/auth_provider.dart';
import '../../matching/providers/matching_provider.dart';
import '../../avatar/providers/avatar_provider.dart';
import '../../avatar/widgets/avatar_renderer.dart';
import '../../trust_score/screens/trust_score_screen.dart';
import '../../heart_temperature/screens/heart_temperature_screen.dart';
import '../../subscription/screens/subscription_plan_screen.dart';
import '../../subscription/screens/subscription_manage_screen.dart';
import '../../gacha/widgets/dice_gacha_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = context.read<AuthProvider>();

    try {
      if (authProvider.user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(authProvider.user!.uid)
            .get();

        if (doc.exists && mounted) {
          setState(() {
            _currentUser = UserModel.fromMap(doc.data()!);
            _isLoading = false;
          });

          // Load avatar
          final avatarProvider = context.read<AvatarProvider>();
          avatarProvider.loadAvatar(authProvider.user!.uid);
        }
      } else {
        // Firebase 연결 없음 - Mock 데이터 사용
        if (mounted) {
          setState(() {
            _currentUser = _createMockUser();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Firebase 오류 - Mock 데이터 사용
      print('⚠️  Failed to load user data: $e');
      if (mounted) {
        setState(() {
          _currentUser = _createMockUser();
          _isLoading = false;
        });
      }
    }
  }

  UserModel _createMockUser() {
    return UserModel(
      userId: 'demo_user',
      profile: UserProfile(
        basicInfo: BasicInfo(
          name: '테스트 사용자',
          birthdate: DateTime(1995, 5, 15),
          ageRange: '20대 후반',
          gender: 'male',
          region: '서울',
          mbti: 'ENFP',
          bloodType: 'A',
          smoking: false,
          drinking: '가끔',
          religion: '무교',
          firstRelationship: false,
        ),
        lifestyle: Lifestyle(
          hobbies: ['영화', '음악', '여행'],
          hasPet: false,
          exerciseFrequency: '주 2-3회',
          travelStyle: '계획적',
        ),
        appearance: Appearance(
          heightRange: '170-175cm',
          photos: [],
        ),
        oneLiner: '안녕하세요! 만나서 반갑습니다 😊',
      ),
      avatar: Avatar(
        personality: 'cheerful',
        style: 'casual',
        colorPreference: 'blue',
        animalType: 'cat',
        hobby: 'music',
        baseCharacter: 'default',
        currentOutfit: AvatarOutfit(
          top: 'tshirt',
          bottom: 'jeans',
          accessories: [],
          hair: 'short',
          hairColor: 'black',
          background: 'plain',
          specialItem: '',
          emotion: 'happy',
        ),
        ownedItems: OwnedItems(
          tops: ['tshirt'],
          bottoms: ['jeans'],
          accessories: [],
          hairs: ['short'],
          backgrounds: ['plain'],
          specialItems: [],
        ),
      ),
      trustScore: TrustScore(
        score: 75.0,
        level: '신뢰',
        dailyQuestStreak: 5,
        totalQuestCount: 20,
        consecutiveLoginDays: 10,
        badges: ['초보자', '성실'],
      ),
      heartTemperature: HeartTemperature(
        temperature: 45.5,
        level: '따뜻',
      ),
      subscription: Subscription(
        type: 'free',
        autoRenew: false,
      ),
      safety: Safety(
        emergencyContacts: [],
        blockList: [],
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final matchingProvider = context.watch<MatchingProvider>();
    final avatarProvider = context.watch<AvatarProvider>();

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('사용자 정보를 불러올 수 없습니다')),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: CustomScrollView(
          slivers: [
            // 앱바
            _buildAppBar(),
            // 본문
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // 사용자 요약 카드
                  _buildUserSummaryCard(),
                  const SizedBox(height: 16),
                  // 신뢰 지수 & 온도 카드
                  _buildScoreCards(),
                  const SizedBox(height: 16),
                  // 오늘의 매칭
                  _buildTodayMatchingCard(matchingProvider),
                  const SizedBox(height: 16),
                  // 럭키 주사위 가챠
                  const DiceGachaCard(),
                  const SizedBox(height: 16),
                  // 빠른 액션
                  _buildQuickActions(),
                  const SizedBox(height: 16),
                  // 구독 정보
                  _buildSubscriptionCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '만나볼래',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
    );
  }

  Widget _buildUserSummaryCard() {
    final avatarProvider = context.watch<AvatarProvider>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아바타
          avatarProvider.avatar != null
              ? AvatarRenderer(
                  avatar: avatarProvider.avatar!,
                  size: 64,
                )
              : DefaultAvatar(
                  name: _currentUser!.profile.basicInfo.name,
                  size: 64,
                ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_currentUser!.profile.basicInfo.name}님',
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getGreetingMessage(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildScoreCard(
              title: '신뢰 지수',
              score: _currentUser!.trustScore.score.toInt(),
              maxScore: 100,
              color: AppColors.trustScoreColors[
                  _getTrustScoreColorIndex(_currentUser!.trustScore.score.toInt())],
              icon: Icons.verified_user,
              subtitle: _currentUser!.trustScore.level,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrustScoreScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildScoreCard(
              title: '하트 온도',
              score: _currentUser!.heartTemperature.temperature.toInt(),
              maxScore: 99,
              color: AppColors.heartTempColors[_getHeartTempColorIndex(
                  _currentUser!.heartTemperature.temperature)],
              icon: Icons.favorite,
              subtitle: _currentUser!.heartTemperature.level,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HeartTemperatureScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard({
    required String title,
    required int score,
    required int maxScore,
    required Color color,
    required IconData icon,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$score',
            style: AppTextStyles.scoreValue.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.scoreLabel.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildTodayMatchingCard(MatchingProvider matchingProvider) {
    final limit = _getMatchLimit();
    final used = matchingProvider.dailyMatchCount;
    final remaining = limit - used;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_border,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 매칭',
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '남은 매칭 횟수',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$remaining / $limit',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: limit > 0 ? used / limit : 0,
              backgroundColor: AppColors.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                remaining > 0 ? AppColors.primary : AppColors.error,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '빠른 액션',
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.favorite,
                  label: '매칭 시작',
                  color: AppColors.primary,
                  onTap: () {
                    // 매칭 탭으로 이동 (MainScreen의 BottomNavigationBar를 통해)
                    // 부모 위젯의 상태를 변경할 수 없으므로, 사용자가 직접 탭을 눌러야 함
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.chat_bubble,
                  label: '채팅',
                  color: AppColors.secondary,
                  onTap: () {
                    // 채팅 탭으로 이동 (MainScreen의 BottomNavigationBar를 통해)
                    // 부모 위젯의 상태를 변경할 수 없으므로, 사용자가 직접 탭을 눌러야 함
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    final subscription = _currentUser!.subscription;
    final isVIP = subscription.type == SubscriptionType.vip_basic ||
        subscription.type == SubscriptionType.vip_premium ||
        subscription.type == SubscriptionType.vip_platinum;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => isVIP || subscription.type != SubscriptionType.free
                ? const SubscriptionManageScreen()
                : const SubscriptionPlanScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isVIP
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.vipGold,
                    AppColors.vipGold.withOpacity(0.7),
                  ],
                )
              : null,
          color: isVIP ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isVIP ? null : Border.all(color: AppColors.borderColor),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isVIP ? Icons.workspace_premium : Icons.card_membership,
                color: isVIP ? Colors.white : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isVIP ? 'VIP 멤버십' : '구독 정보',
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isVIP ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getSubscriptionName(subscription.type),
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: isVIP ? Colors.white : AppColors.primary,
            ),
          ),
          if (subscription.endDate != null) ...[
            const SizedBox(height: 8),
            Text(
              '만료일: ${_formatDate(subscription.endDate!)}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isVIP ? Colors.white.withOpacity(0.9) : AppColors.textSecondary,
              ),
            ),
          ],
          if (!isVIP) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionPlanScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('VIP 되기'),
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '좋은 아침이에요! ☀️';
    } else if (hour < 18) {
      return '좋은 오후에요! 😊';
    } else {
      return '좋은 저녁이에요! 🌙';
    }
  }

  int _getTrustScoreColorIndex(int score) {
    if (score >= 80) return 4;
    if (score >= 60) return 3;
    if (score >= 40) return 2;
    if (score >= 20) return 1;
    return 0;
  }

  int _getHeartTempColorIndex(double temp) {
    if (temp >= 60) return 4;
    if (temp >= 40) return 3;
    if (temp >= 20) return 2;
    if (temp >= 10) return 1;
    return 0;
  }

  int _getMatchLimit() {
    switch (_currentUser!.subscription.type) {
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

  String _getSubscriptionName(String type) {
    final subscriptionType = SubscriptionTypeExtension.fromValue(type);
    switch (subscriptionType) {
      case SubscriptionType.vip_platinum:
        return 'VIP 플래티넘';
      case SubscriptionType.vip_premium:
        return 'VIP 프리미엄';
      case SubscriptionType.vip_basic:
        return 'VIP 베이직';
      case SubscriptionType.premium:
        return '프리미엄';
      case SubscriptionType.basic:
        return '베이직';
      case SubscriptionType.free:
      default:
        return '무료';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
