import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../models/user_model.dart';
import '../../../models/chat_intimacy_model.dart';
import '../../chat/providers/chat_intimacy_provider.dart';

/// 상대방 프로필 상세 화면
/// 친밀도 레벨에 따라 정보가 점진적으로 공개됨
class PartnerProfileDetailScreen extends StatelessWidget {
  final UserModel partner;
  final String myUserId;

  const PartnerProfileDetailScreen({
    super.key,
    required this.partner,
    required this.myUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatIntimacyProvider>(
      builder: (context, intimacyProvider, child) {
        final intimacy = intimacyProvider.getIntimacy(myUserId, partner.userId);

        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: CustomScrollView(
            slivers: [
              // 앱바
              _buildAppBar(context, intimacy),

              // 친밀도 상태
              _buildIntimacySection(context, intimacy),

              // 프로필 내용
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildBasicInfoSection(intimacy),
                    const SizedBox(height: 16),
                    _buildLifestyleSection(intimacy),
                    const SizedBox(height: 16),
                    _buildDetailedInfoSection(intimacy),
                    const SizedBox(height: 16),
                    _buildVipInfoSection(intimacy),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, ChatIntimacy? intimacy) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          partner.profile.basicInfo.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.primaries[partner.userId.hashCode % Colors.primaries.length][300]!,
                Colors.primaries[partner.userId.hashCode % Colors.primaries.length][600]!,
              ],
            ),
          ),
          child: Center(
            child: Hero(
              tag: 'avatar_${partner.userId}',
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    partner.profile.basicInfo.name[0],
                    style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: Colors.primaries[partner.userId.hashCode % Colors.primaries.length],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntimacySection(BuildContext context, ChatIntimacy? intimacy) {
    if (intimacy == null) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(16),
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
          child: const Column(
            children: [
              Icon(Icons.lock, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                '아직 대화를 시작하지 않았어요',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '대화를 시작하면 정보가 공개됩니다',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIntimacyIcon(intimacy.currentLevel),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        intimacy.currentLevel.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        intimacy.currentLevel.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${intimacy.intimacyScore}점',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '다음 단계까지',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            intimacy.currentLevel == IntimacyLevel.intimate
                                ? '최대 레벨!'
                                : '${intimacy.scoreToNextLevel}점 남음',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: intimacy.levelProgress / 100,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white30),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '${intimacy.daysKnown}일',
                  '알고 지낸 기간',
                ),
                Container(width: 1, height: 40, color: Colors.white30),
                _buildStatItem(
                  '${intimacy.consecutiveDays}일',
                  '연속 대화',
                ),
                Container(width: 1, height: 40, color: Colors.white30),
                _buildStatItem(
                  '${intimacy.totalMessageCount}회',
                  '총 대화 수',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  IconData _getIntimacyIcon(IntimacyLevel level) {
    switch (level) {
      case IntimacyLevel.stranger:
        return Icons.person_outline;
      case IntimacyLevel.acquaintance:
        return Icons.waving_hand;
      case IntimacyLevel.friend:
        return Icons.favorite_border;
      case IntimacyLevel.close:
        return Icons.favorite;
      case IntimacyLevel.intimate:
        return Icons.diamond;
    }
  }

  Widget _buildBasicInfoSection(ChatIntimacy? intimacy) {
    return _buildSection(
      title: '기본 정보',
      level: IntimacyLevel.acquaintance,
      intimacy: intimacy,
      children: [
        _buildInfoRow(
          '한줄소개',
          partner.profile.oneLiner,
          'profile.oneLiner',
          intimacy,
        ),
        _buildInfoRow(
          'MBTI',
          partner.profile.basicInfo.mbti,
          'basicInfo.mbti',
          intimacy,
        ),
        _buildInfoRow(
          '지역',
          intimacy != null && intimacy.intimacyScore >= 900
              ? '${partner.profile.basicInfo.region} ${partner.profile.basicInfo.detailedRegion ?? ""}'
              : partner.profile.basicInfo.region,
          'basicInfo.region',
          intimacy,
        ),
        _buildInfoRow(
          '나이',
          intimacy != null && intimacy.intimacyScore >= 900
              ? '${partner.profile.basicInfo.exactAge ?? 25}세'
              : partner.profile.basicInfo.ageRange,
          'basicInfo.ageRange',
          intimacy,
        ),
        _buildInfoRow(
          '혈액형',
          partner.profile.basicInfo.bloodType,
          'basicInfo.bloodType',
          intimacy,
        ),
      ],
    );
  }

  Widget _buildLifestyleSection(ChatIntimacy? intimacy) {
    return _buildSection(
      title: '라이프스타일',
      level: IntimacyLevel.friend,
      intimacy: intimacy,
      children: [
        _buildInfoRow(
          '취미',
          partner.profile.lifestyle.hobbies.join(', '),
          'lifestyle.hobbies',
          intimacy,
        ),
        _buildInfoRow(
          '운동',
          partner.profile.lifestyle.exerciseFrequency,
          'lifestyle.exerciseFrequency',
          intimacy,
        ),
        _buildInfoRow(
          '여행 스타일',
          partner.profile.lifestyle.travelStyle,
          'lifestyle.travelStyle',
          intimacy,
        ),
        _buildInfoRow(
          '반려동물',
          partner.profile.lifestyle.hasPet ? '키우고 있어요' : '키우지 않아요',
          'lifestyle.hasPet',
          intimacy,
        ),
        _buildInfoRow(
          '흡연',
          partner.profile.basicInfo.smoking ? '흡연' : '비흡연',
          'basicInfo.smoking',
          intimacy,
        ),
        _buildInfoRow(
          '음주',
          partner.profile.basicInfo.drinking,
          'basicInfo.drinking',
          intimacy,
        ),
      ],
    );
  }

  Widget _buildDetailedInfoSection(ChatIntimacy? intimacy) {
    return _buildSection(
      title: '상세 정보',
      level: IntimacyLevel.close,
      intimacy: intimacy,
      children: [
        _buildInfoRow(
          '키',
          intimacy != null && intimacy.intimacyScore >= 900
              ? '${partner.profile.appearance.exactHeight ?? 170}cm'
              : partner.profile.appearance.heightRange,
          'appearance.heightRange',
          intimacy,
        ),
        _buildInfoRow(
          '체형',
          partner.profile.appearance.bodyType ?? '보통',
          'appearance.bodyType',
          intimacy,
        ),
      ],
    );
  }

  Widget _buildVipInfoSection(ChatIntimacy? intimacy) {
    return _buildSection(
      title: 'VIP 정보',
      level: IntimacyLevel.intimate,
      intimacy: intimacy,
      children: [
        _buildInfoRow(
          '직업',
          partner.profile.vipInfo?.job ?? '미등록',
          'vipInfo.job',
          intimacy,
        ),
        _buildInfoRow(
          '학력',
          partner.profile.vipInfo?.education ?? '미등록',
          'vipInfo.education',
          intimacy,
        ),
        _buildInfoRow(
          '결혼관',
          partner.profile.vipInfo?.marriagePlan ?? '미등록',
          'vipInfo.marriagePlan',
          intimacy,
        ),
        _buildInfoRow(
          '자녀계획',
          partner.profile.vipInfo?.childcarePlan ?? '미등록',
          'vipInfo.childcarePlan',
          intimacy,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IntimacyLevel level,
    required ChatIntimacy? intimacy,
    required List<Widget> children,
  }) {
    final isUnlocked = intimacy != null && intimacy.currentLevel.index >= level.index;

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
              color: isUnlocked ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isUnlocked ? Icons.lock_open : Icons.lock,
                  color: isUnlocked ? AppColors.primary : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? AppColors.primary : Colors.grey,
                    ),
                  ),
                ),
                if (!isUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      level.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildInfoRow(
    String label,
    String value,
    String fieldPath,
    ChatIntimacy? intimacy,
  ) {
    final isUnlocked = intimacy != null &&
        intimacy.currentLevel.unlockedFields.contains(fieldPath);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (!isUnlocked)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.lock, size: 16, color: Colors.grey),
                  ),
                Expanded(
                  child: Text(
                    isUnlocked ? value : '●●●●●',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isUnlocked ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
