import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/heart_temperature_provider.dart';
import '../widgets/temperature_gauge.dart';
import 'temperature_history_screen.dart';

class HeartTemperatureScreen extends StatefulWidget {
  const HeartTemperatureScreen({super.key});

  @override
  State<HeartTemperatureScreen> createState() => _HeartTemperatureScreenState();
}

class _HeartTemperatureScreenState extends State<HeartTemperatureScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final tempProvider = context.read<HeartTemperatureProvider>();

      if (authProvider.user != null) {
        tempProvider.loadHeartTemperature(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final tempProvider = context.watch<HeartTemperatureProvider>();

    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(child: Text('로그인이 필요합니다')),
      );
    }

    if (tempProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final heartTemp = tempProvider.heartTemperature;
    if (heartTemp == null) {
      return const Scaffold(
        body: Center(child: Text('온도 정보를 불러올 수 없습니다')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('하트 온도'),
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TemperatureHistoryScreen(),
                ),
              );
            },
            child: const Text('이력'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // 온도 게이지
          Center(
            child: TemperatureGauge(
              temperature: heartTemp.temperature,
              size: 250,
            ),
          ),
          const SizedBox(height: 32),
          // 설명 카드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '하트 온도란?',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '다른 사용자들의 리뷰와 평가로 결정되는\n신뢰도 지표입니다. 긍정적인 매너로 온도를 높여보세요!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 온도 변화 안내
          Text(
            '온도 변화',
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildTemperatureChangeCard(
            icon: Icons.thumb_up,
            title: '긍정 리뷰',
            description: '좋은 매너와 진실한 태도',
            change: '+${AppConstants.heartTempPositiveReview}°',
            color: AppColors.success,
          ),
          const SizedBox(height: 8),
          _buildTemperatureChangeCard(
            icon: Icons.thumb_down,
            title: '부정 리뷰',
            description: '불편한 경험이나 매너 부족',
            change: '${AppConstants.heartTempNegativeReview}°',
            color: AppColors.warning,
          ),
          const SizedBox(height: 8),
          _buildTemperatureChangeCard(
            icon: Icons.report,
            title: '신고 접수',
            description: '부적절한 행동이나 규정 위반',
            change: '${AppConstants.heartTempReport}°',
            color: AppColors.error,
          ),
          const SizedBox(height: 24),
          // VIP 자격 안내
          if (heartTemp.temperature >= AppConstants.vipRequiredTemperature)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.vipGold,
                    AppColors.vipGold.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VIP 자격 달성!',
                          style: AppTextStyles.h4.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '하트 온도 ${AppConstants.vipRequiredTemperature}° 이상',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: AppColors.vipGold,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'VIP 되기',
                        style: AppTextStyles.h4.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '하트 온도 ${AppConstants.vipRequiredTemperature}° 이상 필요',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: heartTemp.temperature /
                          AppConstants.vipRequiredTemperature,
                      backgroundColor: AppColors.borderColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.vipGold,
                      ),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(AppConstants.vipRequiredTemperature - heartTemp.temperature).toStringAsFixed(1)}° 부족',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTemperatureChangeCard({
    required IconData icon,
    required String title,
    required String description,
    required String change,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            change,
            style: AppTextStyles.h4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
