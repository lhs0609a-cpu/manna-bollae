import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../avatar/providers/avatar_provider.dart';
import '../../avatar/widgets/avatar_renderer.dart';
import '../../avatar/screens/avatar_creation_screen.dart';
import '../../avatar/screens/avatar_customize_screen.dart';
import '../../safety/screens/block_list_screen.dart';
import '../../item_shop/screens/item_shop_screen.dart';
import '../../verification/screens/verification_manage_screen.dart';
import '../../notification/screens/notification_settings_screen.dart';
import '../../profile/screens/edit_profile_screen.dart';
import '../../profile/screens/profile_detail_screen.dart';
import '../../account/screens/account_settings_screen.dart';
import '../../matching/screens/matching_filter_screen.dart';
import '../../profile_photo/screens/profile_photo_manage_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // 데모 모드: 더미 데이터 생성
    setState(() {
      _currentUser = UserModel(
        userId: 'demo_user_123',
        profile: UserProfile(
          basicInfo: BasicInfo(
            name: '김민수',
            birthdate: DateTime(1995, 3, 15),
            ageRange: '20대 후반',
            exactAge: 29,
            gender: '남성',
            region: '서울',
            detailedRegion: '강남구',
            mbti: 'ENFP',
            bloodType: 'A',
            smoking: false,
            drinking: '가끔',
            religion: '무교',
            firstRelationship: false,
          ),
          lifestyle: Lifestyle(
            hobbies: ['운동', '여행', '영화감상', '요리'],
            hasPet: false,
            exerciseFrequency: '주 3회',
            travelStyle: '여유있게',
          ),
          appearance: Appearance(
            heightRange: '175-178cm',
            exactHeight: 176,
            bodyType: '보통',
            photos: [],
          ),
          oneLiner: '즐거운 인연을 만들고 싶어요! 😊',
        ),
        avatar: Avatar(
          personality: 'friendly',
          style: 'casual',
          colorPreference: 'blue',
          animalType: 'dog',
          hobby: 'sports',
          baseCharacter: 'happy',
          currentOutfit: AvatarOutfit(
            top: 'shirt',
            bottom: 'jeans',
            accessories: ['cap'],
            hair: 'short',
            hairColor: 'black',
            background: 'city',
            specialItem: '',
            emotion: 'happy',
          ),
          ownedItems: OwnedItems(
            tops: ['shirt', 'tshirt'],
            bottoms: ['jeans', 'shorts'],
            accessories: ['cap', 'glasses'],
            hairs: ['short'],
            backgrounds: ['city'],
            specialItems: [],
          ),
        ),
        trustScore: TrustScore(
          score: 85.0,
          level: '믿음직한',
          dailyQuestStreak: 7,
          totalQuestCount: 42,
          consecutiveLoginDays: 15,
          badges: ['신규회원', '친절한', '활동왕'],
        ),
        heartTemperature: HeartTemperature(
          temperature: 45.8,
          level: '따뜻함',
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
      _isLoading = false;
    });

    // Load avatar - 데모 모드에서는 생략
  }

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
              child: Text(
                _currentUser!.profile.basicInfo.name,
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.verified,
              size: 18,
              color: AppColors.primary,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.divider.withOpacity(0.3),
            height: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.menu,
                size: 20,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccountSettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        color: AppColors.primary,
        child: ListView(
          children: [
            // 프로필 헤더
            _buildProfileHeader(),
            const SizedBox(height: 8),
            // 기본 정보
            _buildSection('기본 정보', [
              _buildInfoTile(
                Icons.person,
                '이름',
                _currentUser!.profile.basicInfo.name,
              ),
              _buildInfoTile(
                Icons.calendar_today,
                '나이',
                _getAge().toString(),
              ),
              _buildInfoTile(
                Icons.wc,
                '성별',
                _currentUser!.profile.basicInfo.gender,
              ),
              _buildInfoTile(
                Icons.location_on,
                '지역',
                _currentUser!.profile.basicInfo.region,
              ),
            ]),
            const SizedBox(height: 8),
            // 성격 & 습관
            _buildSection('성격 & 습관', [
              if (_currentUser!.profile.basicInfo.mbti != null)
                _buildInfoTile(
                  Icons.psychology,
                  'MBTI',
                  _currentUser!.profile.basicInfo.mbti!,
                ),
              if (_currentUser!.profile.basicInfo.bloodType != null)
                _buildInfoTile(
                  Icons.bloodtype,
                  '혈액형',
                  '${_currentUser!.profile.basicInfo.bloodType}형',
                ),
              _buildInfoTile(
                Icons.smoking_rooms,
                '흡연',
                _currentUser!.profile.basicInfo.smoking ? '흡연' : '비흡연',
              ),
              _buildInfoTile(
                Icons.local_bar,
                '음주',
                _currentUser!.profile.basicInfo.drinking,
              ),
              if (_currentUser!.profile.basicInfo.religion != null)
                _buildInfoTile(
                  Icons.church,
                  '종교',
                  _currentUser!.profile.basicInfo.religion!,
                ),
            ]),
            const SizedBox(height: 8),
            // 한 줄 소개
            if (_currentUser!.profile.basicInfo.oneLiner.isNotEmpty)
              _buildSection('한 줄 소개', [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _currentUser!.profile.basicInfo.oneLiner,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ]),
            const SizedBox(height: 8),
            // 취미
            if (_currentUser!.profile.lifestyle.hobbies.isNotEmpty)
              _buildSection('취미', [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _currentUser!.profile.lifestyle.hobbies.map((hobby) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          hobby,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ]),
            const SizedBox(height: 8),
            // 설정
            _buildSection('설정', [
              _buildActionTile(
                Icons.edit,
                '프로필 수정',
                () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                  if (result == true && mounted) {
                    _loadUserData();
                  }
                },
              ),
              _buildActionTile(
                Icons.photo_library,
                '프로필 사진',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePhotoManageScreen(),
                    ),
                  );
                },
              ),
              _buildActionTile(
                Icons.face,
                '아바타 관리',
                () {
                  final avatarProvider = context.read<AvatarProvider>();
                  if (avatarProvider.avatar != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AvatarCustomizeScreen(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AvatarCreationScreen(),
                      ),
                    );
                  }
                },
              ),
              _buildActionTile(
                Icons.shopping_bag,
                '아이템 샵',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ItemShopScreen(),
                    ),
                  );
                },
              ),
              _buildActionTile(
                Icons.card_giftcard,
                '친구 초대',
                () {
                  Navigator.pushNamed(context, '/referral');
                },
              ),
              _buildActionTile(
                Icons.redeem,
                '럭키 박스',
                () {
                  Navigator.pushNamed(context, '/gacha-hub');
                },
              ),
              _buildActionTile(
                Icons.filter_list,
                '매칭 필터',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MatchingFilterScreen(),
                    ),
                  );
                },
              ),
              _buildActionTile(
                Icons.security,
                '안전 설정',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BlockListScreen(),
                    ),
                  );
                },
              ),
              _buildActionTile(
                Icons.verified_user,
                '인증 관리',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VerificationManageScreen(),
                    ),
                  );
                },
              ),
              _buildActionTile(
                Icons.notifications,
                '알림 설정',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 8),
            // 계정 관리
            _buildSection('계정', [
              _buildActionTile(
                Icons.settings,
                '계정 관리',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountSettingsScreen(),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAFAFA),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: Column(
        children: [
          // 상단 프로필 섹션
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // 아바타 - Instagram 스타일 스토리 링
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileDetailScreen(
                          user: _currentUser!,
                          isMyProfile: true,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.storyGradient,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Hero(
                        tag: 'avatar_${_currentUser!.userId}',
                        child: AvatarRenderer(
                          avatar: _currentUser!.avatar,
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // 통계 정보 - Instagram 스타일
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        '${_currentUser!.trustScore.score.toInt()}',
                        '신뢰 지수',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.divider,
                      ),
                      _buildStatItem(
                        '${_currentUser!.heartTemperature.temperature.toStringAsFixed(1)}°',
                        '하트 온도',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.divider,
                      ),
                      _buildStatItem(
                        '${_currentUser!.trustScore.consecutiveLoginDays}',
                        '연속 출석',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 이름과 소개
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _currentUser!.profile.basicInfo.name,
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_currentUser!.trustScore.badges.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _currentUser!.trustScore.badges.first,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_currentUser!.profile.basicInfo.region} · ${_getAge()}세',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_currentUser!.profile.basicInfo.oneLiner.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _currentUser!.profile.basicInfo.oneLiner,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 프로필 수정 버튼 - Instagram 스타일
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                        if (result == true && mounted) {
                          _loadUserData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '프로필 수정',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.share_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      // TODO: 프로필 공유
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTextStyles.bodyMedium),
      trailing: Text(
        value,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: color,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: color ?? AppColors.textSecondary,
      ),
      onTap: onTap,
    );
  }

  int _getAge() {
    if (_currentUser!.profile.basicInfo.birthDate == null) return 0;
    final now = DateTime.now();
    final birthDate = _currentUser!.profile.basicInfo.birthDate!;
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
