import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/user_model.dart';
import '../../avatar/widgets/avatar_renderer.dart';
import '../../avatar/providers/avatar_provider.dart';

class ProfileDetailScreen extends StatelessWidget {
  final UserModel user;
  final bool isMyProfile;
  final int intimacyLevel;

  const ProfileDetailScreen({
    super.key,
    required this.user,
    this.isMyProfile = false,
    this.intimacyLevel = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 프로필 헤더
          _buildProfileHeader(context),

          // 프로필 내용
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 한 줄 소개
                if (user.profile.oneLiner.isNotEmpty)
                  _buildOneLinerCard(),
                const SizedBox(height: 12),

                // 기본 정보
                _buildBasicInfoCard(),
                const SizedBox(height: 12),

                // 성격 & 습관
                _buildPersonalityCard(),
                const SizedBox(height: 12),

                // 라이프스타일
                if (user.profile.lifestyle.hobbies.isNotEmpty)
                  _buildLifestyleCard(),
                if (user.profile.lifestyle.hobbies.isNotEmpty)
                  const SizedBox(height: 12),

                // 외모 정보
                _buildAppearanceCard(),
                const SizedBox(height: 12),

                // 상세 정보 (친밀도 500+)
                if (_canViewDetailedInfo())
                  _buildDetailedInfoCard(),
                if (_canViewDetailedInfo())
                  const SizedBox(height: 12),

                // VIP 정보 (VIP 전용)
                if (_canViewVipInfo())
                  _buildVipInfoCard(),
                if (_canViewVipInfo())
                  const SizedBox(height: 12),

                // 잠금된 정보 안내
                if (!isMyProfile && !_canViewDetailedInfo())
                  _buildLockedInfoCard(),

                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // 아바타
                Consumer<AvatarProvider>(
                  builder: (context, avatarProvider, child) {
                    return Hero(
                      tag: 'avatar_${user.userId}',
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: AvatarRenderer(
                          avatar: user.avatar,
                          size: 120,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // 이름
                Text(
                  user.profile.basicInfo.name,
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // 지역, 나이
                Text(
                  '${user.profile.basicInfo.region} · ${_getAge()}세',
                  style: AppTextStyles.h4.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                // 배지
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBadge(
                      '신뢰 ${user.trustScore.score.toInt()}',
                      Icons.verified_user,
                      AppColors.trustScoreColors[3],
                    ),
                    const SizedBox(width: 12),
                    _buildBadge(
                      '하트 ${user.heartTemperature.temperature.toStringAsFixed(1)}°',
                      Icons.favorite,
                      AppColors.heartTempColors[3],
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

  Widget _buildBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOneLinerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.format_quote,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              user.profile.oneLiner,
              style: AppTextStyles.bodyLarge.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildCard(
      title: '기본 정보',
      icon: Icons.person,
      children: [
        _buildInfoRow(Icons.wc, '성별', user.profile.basicInfo.gender),
        _buildInfoRow(Icons.calendar_today, '나이', '${_getAge()}세'),
        _buildInfoRow(Icons.location_on, '지역', user.profile.basicInfo.region),
        if (_canViewExactInfo())
          _buildInfoRow(
            Icons.location_city,
            '상세 지역',
            user.profile.basicInfo.detailedRegion ?? '미입력',
          ),
        if (user.profile.basicInfo.firstRelationship)
          _buildInfoRow(
            Icons.favorite_border,
            '연애 경험',
            '첫 연애',
          ),
      ],
    );
  }

  Widget _buildPersonalityCard() {
    return _buildCard(
      title: '성격 & 습관',
      icon: Icons.psychology,
      children: [
        if (user.profile.basicInfo.mbti.isNotEmpty)
          _buildInfoRow(Icons.psychology, 'MBTI', user.profile.basicInfo.mbti),
        if (user.profile.basicInfo.bloodType.isNotEmpty)
          _buildInfoRow(
            Icons.bloodtype,
            '혈액형',
            '${user.profile.basicInfo.bloodType}형',
          ),
        _buildInfoRow(
          Icons.smoking_rooms,
          '흡연',
          user.profile.basicInfo.smoking ? '흡연' : '비흡연',
        ),
        _buildInfoRow(
          Icons.local_bar,
          '음주',
          user.profile.basicInfo.drinking,
        ),
        if (user.profile.basicInfo.religion.isNotEmpty)
          _buildInfoRow(
            Icons.church,
            '종교',
            user.profile.basicInfo.religion,
          ),
      ],
    );
  }

  Widget _buildLifestyleCard() {
    return _buildCard(
      title: '라이프스타일',
      icon: Icons.favorite,
      children: [
        // 취미
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sports_esports, size: 20, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text('취미', style: AppTextStyles.bodyMedium),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.profile.lifestyle.hobbies.map((hobby) {
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
            ],
          ),
        ),
        if (user.profile.lifestyle.hasPet)
          _buildInfoRow(
            Icons.pets,
            '반려동물',
            user.profile.lifestyle.petType ?? '있음',
          ),
        if (user.profile.lifestyle.exerciseFrequency.isNotEmpty)
          _buildInfoRow(
            Icons.fitness_center,
            '운동',
            user.profile.lifestyle.exerciseFrequency,
          ),
        if (user.profile.lifestyle.travelStyle.isNotEmpty)
          _buildInfoRow(
            Icons.flight_takeoff,
            '여행 스타일',
            user.profile.lifestyle.travelStyle,
          ),
      ],
    );
  }

  Widget _buildAppearanceCard() {
    return _buildCard(
      title: '외모',
      icon: Icons.accessibility_new,
      children: [
        _buildInfoRow(
          Icons.height,
          '키',
          _canViewExactInfo() && user.profile.appearance.exactHeight != null
              ? '${user.profile.appearance.exactHeight}cm'
              : user.profile.appearance.heightRange,
        ),
        if (_canViewExactInfo() && user.profile.appearance.bodyType != null)
          _buildInfoRow(
            Icons.person_outline,
            '체형',
            user.profile.appearance.bodyType!,
          ),
      ],
    );
  }

  Widget _buildDetailedInfoCard() {
    final detailedInfo = user.profile.detailedInfo;
    if (detailedInfo == null) return const SizedBox.shrink();

    return Column(
      children: [
        if (detailedInfo.favoriteBooks.isNotEmpty)
          _buildCard(
            title: '좋아하는 책',
            icon: Icons.book,
            children: [
              _buildTagList(detailedInfo.favoriteBooks),
            ],
          ),
        if (detailedInfo.favoriteBooks.isNotEmpty)
          const SizedBox(height: 12),
        if (detailedInfo.favoriteMovies.isNotEmpty)
          _buildCard(
            title: '좋아하는 영화',
            icon: Icons.movie,
            children: [
              _buildTagList(detailedInfo.favoriteMovies),
            ],
          ),
        if (detailedInfo.favoriteMovies.isNotEmpty)
          const SizedBox(height: 12),
        if (detailedInfo.favoriteMusic.isNotEmpty)
          _buildCard(
            title: '좋아하는 음악',
            icon: Icons.music_note,
            children: [
              _buildTagList(detailedInfo.favoriteMusic),
            ],
          ),
        if (detailedInfo.favoriteMusic.isNotEmpty)
          const SizedBox(height: 12),
        _buildCard(
          title: '커뮤니케이션',
          icon: Icons.chat_bubble_outline,
          children: [
            _buildInfoRow(
              Icons.chat,
              '대화 스타일',
              detailedInfo.communicationStyle,
            ),
            _buildInfoRow(
              Icons.schedule,
              '연락 빈도',
              detailedInfo.relationshipView.contactFrequency,
            ),
            _buildInfoRow(
              Icons.favorite_border,
              '스킨십 속도',
              detailedInfo.relationshipView.skinshipSpeed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVipInfoCard() {
    final vipInfo = user.profile.vipInfo;
    if (vipInfo == null) return const SizedBox.shrink();

    return Column(
      children: [
        _buildCard(
          title: '직업 & 학력',
          icon: Icons.work,
          color: const Color(0xFFFFD700),
          children: [
            _buildInfoRow(Icons.business_center, '직업', vipInfo.job),
            if (vipInfo.jobDetail.isNotEmpty)
              _buildInfoRow(Icons.description, '직업 상세', vipInfo.jobDetail),
            _buildInfoRow(Icons.school, '학력', vipInfo.education),
            if (vipInfo.educationDetail.isNotEmpty)
              _buildInfoRow(
                Icons.description,
                '학력 상세',
                vipInfo.educationDetail,
              ),
          ],
        ),
        const SizedBox(height: 12),
        _buildCard(
          title: '경제',
          icon: Icons.account_balance_wallet,
          color: const Color(0xFFFFD700),
          children: [
            _buildInfoRow(Icons.monetization_on, '연봉', vipInfo.salaryRange),
            if (vipInfo.exactSalary != null && _canViewFullVipInfo())
              _buildInfoRow(
                Icons.attach_money,
                '정확한 연봉',
                '${vipInfo.exactSalary}만원',
              ),
            _buildInfoRow(Icons.home, '자산', vipInfo.assets),
          ],
        ),
        const SizedBox(height: 12),
        _buildCard(
          title: '결혼관',
          icon: Icons.favorite,
          color: const Color(0xFFFFD700),
          children: [
            _buildInfoRow(Icons.calendar_today, '결혼 계획', vipInfo.marriagePlan),
            _buildInfoRow(Icons.child_care, '육아 계획', vipInfo.childcarePlan),
            if (vipInfo.divorceHistory)
              _buildInfoRow(Icons.info, '이혼 이력', '있음'),
            if (vipInfo.hasChildren)
              _buildInfoRow(
                Icons.child_friendly,
                '자녀',
                '${vipInfo.childrenCount}명',
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLockedInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lock_outline,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '더 많은 정보 보기',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '친밀도를 쌓으면 더 많은 정보를 볼 수 있어요',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildUnlockStage('상세 정보', '친밀도 500', intimacyLevel >= 500),
                const SizedBox(height: 8),
                _buildUnlockStage('정확한 정보', '친밀도 1500', intimacyLevel >= 1500),
                const SizedBox(height: 8),
                _buildUnlockStage('VIP 정보', 'VIP 구독', user.subscription.isVip),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockStage(String label, String requirement, bool unlocked) {
    return Row(
      children: [
        Icon(
          unlocked ? Icons.check_circle : Icons.lock,
          size: 20,
          color: unlocked ? Colors.green : AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium,
          ),
        ),
        Text(
          requirement,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color ?? AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.h4.copyWith(
                    color: color ?? AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagList(List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderColor,
            ),
          ),
          child: Text(
            tag,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  int _getAge() {
    final now = DateTime.now();
    final birthDate = user.profile.basicInfo.birthdate;
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  bool _canViewDetailedInfo() {
    return isMyProfile || intimacyLevel >= 500;
  }

  bool _canViewExactInfo() {
    return isMyProfile || intimacyLevel >= 1500;
  }

  bool _canViewVipInfo() {
    return isMyProfile || (user.subscription.isVip && intimacyLevel >= 500);
  }

  bool _canViewFullVipInfo() {
    return isMyProfile || intimacyLevel >= 2500;
  }
}
