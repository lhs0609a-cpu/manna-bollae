import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../providers/referral_provider.dart';
import '../models/referral_progress.dart';

class ReferralDashboardScreen extends StatelessWidget {
  const ReferralDashboardScreen({super.key});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}분 전';
      }
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return DateFormat('yyyy.MM.dd').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('초대 현황'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ReferralProvider>(
        builder: (context, provider, child) {
          final progress = provider.progress;
          final friends = progress.referredFriends;

          return SingleChildScrollView(
            child: Column(
              children: [
                // 통계 요약
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '누적 통계',
                        style: AppTextStyles.h3.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatBox(
                              label: '총 초대',
                              value: '${progress.totalReferred}명',
                              icon: Icons.people_outline,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatBox(
                              label: '가입 완료',
                              value: '${progress.successfulReferred}명',
                              icon: Icons.check_circle_outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatBox(
                              label: '프로필 완성',
                              value: '${progress.completedProfileCount}명',
                              icon: Icons.person_outline,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatBox(
                              label: '활성 사용자',
                              value: '${progress.activeUserCount}명',
                              icon: Icons.star_outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatBox(
                              label: '매칭 성공',
                              value: '${progress.matchedCount}명',
                              icon: Icons.favorite_outline,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatBox(
                              label: '누적 포인트',
                              value: '${progress.totalPoints}P',
                              icon: Icons.monetization_on_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 초대한 친구 목록
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '초대한 친구',
                            style: AppTextStyles.h3,
                          ),
                          if (friends.isNotEmpty)
                            Text(
                              '총 ${friends.length}명',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (friends.isEmpty)
                        _buildEmptyState()
                      else
                        ...friends.map((friend) {
                          return _buildFriendCard(friend);
                        }).toList(),

                      const SizedBox(height: 24),

                      // 보상 히스토리
                      Text(
                        '보상 히스토리',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 16),

                      if (progress.claimedRewards.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 48,
                                  color: AppColors.textSecondary.withOpacity(0.5),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '아직 받은 보상이 없습니다',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...progress.claimedRewards.entries.map((entry) {
                          final milestone = entry.key;
                          final reward = provider.rewards.firstWhere(
                            (r) => r.milestone == milestone,
                          );
                          return _buildRewardHistoryCard(reward);
                        }).toList(),

                      const SizedBox(height: 24),

                      // 팁 카드
                      _buildTipCard(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatBox({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(ReferredFriend friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              // 아바타
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    friend.name[0],
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      style: AppTextStyles.h4,
                    ),
                    Text(
                      _formatDate(friend.invitedAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // 가입 완료 배지
              if (friend.hasSignedUp)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '가입 완료',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),

          // 진행 상황
          if (friend.hasSignedUp) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusChip(
                  label: '프로필 완성',
                  isCompleted: friend.hasCompletedProfile,
                  icon: Icons.person,
                ),
                _buildStatusChip(
                  label: '활성 사용자',
                  isCompleted: friend.isActive,
                  icon: Icons.star,
                ),
                _buildStatusChip(
                  label: '매칭 성공',
                  isCompleted: friend.hasMatched,
                  icon: Icons.favorite,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required bool isCompleted,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.divider.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isCompleted ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isCompleted ? AppColors.primary : AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          if (isCompleted) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.check,
              size: 14,
              color: AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRewardHistoryCard(reward) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                reward.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: AppTextStyles.h4,
                ),
                Text(
                  '${reward.rewards.length}개의 보상 수령 완료',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '아직 초대한 친구가 없습니다',
              style: AppTextStyles.h4.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '친구를 초대하고 특별한 보상을 받아보세요!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '더 많은 보상 받는 팁',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('친구가 프로필을 완성하면 +2,000 포인트'),
          _buildTipItem('친구가 7일 연속 접속하면 +5,000 포인트'),
          _buildTipItem('친구가 매칭에 성공하면 +3,000 포인트'),
          const SizedBox(height: 8),
          Text(
            '친구들이 적극적으로 활동할수록 더 많은 보상을 받을 수 있어요!',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(
              Icons.check_circle,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
