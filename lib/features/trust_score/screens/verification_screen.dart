import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/trust_score_provider.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final trustScoreProvider = context.watch<TrustScoreProvider>();

    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(child: Text('로그인이 필요합니다')),
      );
    }

    final trustScore = trustScoreProvider.trustScore;
    if (trustScore == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('인증 관리'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.dividerColor,
            height: 1,
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          // 안내 카드
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '인증을 통해 신뢰 지수를 높이고\nVIP 자격을 얻을 수 있습니다',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 기본 인증
          _buildSection(context, '기본 인증', [
            _buildVerificationTile(
              context,
              icon: Icons.phone_android,
              title: '전화번호 인증',
              description: '본인 명의의 휴대폰 번호를 인증합니다',
              score: AppConstants.trustScorePhoneVerification.toInt(),
              badge: 'phone_verified',
              isCompleted: trustScore.badges.contains('phone_verified'),
              onTap: () => _handlePhoneVerification(context),
            ),
            _buildVerificationTile(
              context,
              icon: Icons.videocam,
              title: '비디오 인증',
              description: '30초 영상으로 본인 여부를 확인합니다',
              score: AppConstants.trustScoreVideoVerification.toInt(),
              badge: 'video_verified',
              isCompleted: trustScore.badges.contains('video_verified'),
              onTap: () => _handleVideoVerification(context),
            ),
          ]),
          const SizedBox(height: 16),
          // 신원 인증
          _buildSection(context, '신원 인증', [
            _buildVerificationTile(
              context,
              icon: Icons.shield,
              title: '범죄기록 조회',
              description: '범죄기록이 없음을 확인합니다',
              score: AppConstants.trustScoreCriminalCheck.toInt(),
              badge: 'criminal_record_clear',
              isCompleted: trustScore.badges.contains('criminal_record_clear'),
              onTap: () => _handleCriminalCheck(context),
              isHighScore: true,
            ),
            _buildVerificationTile(
              context,
              icon: Icons.school,
              title: '학교폭력 기록 조회',
              description: '학교폭력 기록이 없음을 확인합니다',
              score: AppConstants.trustScoreSchoolViolenceCheck.toInt(),
              badge: 'school_violence_clear',
              isCompleted:
                  trustScore.badges.contains('school_violence_clear'),
              onTap: () => _handleSchoolViolenceCheck(context),
              isHighScore: true,
            ),
          ]),
          const SizedBox(height: 16),
          // 추가 인증
          _buildSection(context, '추가 인증', [
            _buildVerificationTile(
              context,
              icon: Icons.work,
              title: '직업 인증',
              description: '재직증명서 또는 사업자등록증을 제출합니다',
              score: AppConstants.trustScoreOccupationVerification.toInt(),
              badge: 'occupation_verified',
              isCompleted: trustScore.badges.contains('occupation_verified'),
              onTap: () => _handleOccupationVerification(context),
            ),
            _buildVerificationTile(
              context,
              icon: Icons.menu_book,
              title: '학력 인증',
              description: '졸업증명서 또는 재학증명서를 제출합니다',
              score: AppConstants.trustScoreEducationVerification.toInt(),
              badge: 'education_verified',
              isCompleted: trustScore.badges.contains('education_verified'),
              onTap: () => _handleEducationVerification(context),
            ),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
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

  Widget _buildVerificationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required int score,
    required String badge,
    required bool isCompleted,
    required VoidCallback onTap,
    bool isHighScore = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.success.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isCompleted ? AppColors.success : AppColors.primary,
          size: 24,
        ),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isHighScore) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.vipGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'HIGH',
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.vipGold,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (!isCompleted) ...[
                Icon(
                  Icons.stars,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '+$score점',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.check_circle,
                  size: 14,
                  color: AppColors.success,
                ),
                const SizedBox(width: 4),
                Text(
                  '인증 완료',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: Icon(
        isCompleted ? Icons.check_circle : Icons.chevron_right,
        color: isCompleted ? AppColors.success : AppColors.textSecondary,
      ),
      onTap: isCompleted ? null : onTap,
    );
  }

  Future<void> _handlePhoneVerification(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전화번호 인증'),
        content: const Text(
          '본인 명의의 휴대폰 번호로 인증을 진행합니다.\n\n인증을 시작하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('시작'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      final trustScoreProvider = context.read<TrustScoreProvider>();

      // TODO: 실제 전화번호 입력 및 인증 로직
      // 현재는 시뮬레이션
      final success = await trustScoreProvider.verifyPhoneNumber(
        authProvider.user!.uid,
        '01012345678',
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('전화번호 인증이 완료되었습니다 (+${AppConstants.trustScorePhoneVerification}점)'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _handleVideoVerification(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('비디오 인증 기능은 준비 중입니다')),
    );
  }

  Future<void> _handleCriminalCheck(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('범죄기록 조회'),
        content: const Text(
          '범죄기록 조회 동의서를 작성하고 본인확인을 진행합니다.\n\n조회 결과는 24시간 이내에 확인됩니다.\n\n진행하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('진행'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = context.read<AuthProvider>();
      final trustScoreProvider = context.read<TrustScoreProvider>();

      // 시뮬레이션
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final success = await trustScoreProvider.checkCriminalRecord(
        authProvider.user!.uid,
      );

      if (context.mounted) {
        Navigator.pop(context); // 로딩 다이얼로그 닫기

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('범죄기록 조회가 완료되었습니다 (+${AppConstants.trustScoreCriminalCheck}점)'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleSchoolViolenceCheck(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('학교폭력 기록 조회 기능은 준비 중입니다')),
    );
  }

  Future<void> _handleOccupationVerification(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('직업 인증 기능은 준비 중입니다')),
    );
  }

  Future<void> _handleEducationVerification(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('학력 인증 기능은 준비 중입니다')),
    );
  }
}
