import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../providers/gacha_provider.dart';
import '../models/gacha_box.dart';
import '../widgets/gacha_result_dialog.dart';

class DailyAttendanceScreen extends StatefulWidget {
  const DailyAttendanceScreen({super.key});

  @override
  State<DailyAttendanceScreen> createState() => _DailyAttendanceScreenState();
}

class _DailyAttendanceScreenState extends State<DailyAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GachaProvider>().initialize();
      _startShakeAnimation();
    });
  }

  void _startShakeAnimation() {
    _shakeController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _handleAttendance() async {
    final provider = context.read<GachaProvider>();
    final result = await provider.checkAttendance();

    if (result != null && mounted) {
      // 결과 다이얼로그 표시
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => GachaResultDialog(result: result),
      );
    } else if (mounted) {
      // 이미 출석했을 경우
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('오늘은 이미 출석했습니다!'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('출석 체크'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<GachaProvider>(
        builder: (context, provider, child) {
          final progress = provider.progress;
          final consecutiveDays = progress.consecutiveDays;
          final canCheck = progress.canCheckAttendance();

          // 현재 등급 상자
          GachaBox currentBox;
          if (consecutiveDays >= 7) {
            currentBox = GachaBoxData.goldenBox;
          } else if (consecutiveDays >= 5) {
            currentBox = GachaBoxData.epicBox;
          } else if (consecutiveDays >= 3) {
            currentBox = GachaBoxData.rareBox;
          } else {
            currentBox = GachaBoxData.normalBox;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // 상단: 메인 상자
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        Colors.white,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        '연속 출석',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$consecutiveDays일',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 상자 애니메이션
                      AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: canCheck
                                ? Offset(_shakeAnimation.value, 0)
                                : Offset.zero,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  currentBox.iconUrl,
                                  style: const TextStyle(fontSize: 80),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentBox.name,
                        style: AppTextStyles.h2,
                      ),
                      Text(
                        currentBox.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 출석 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: canCheck ? _handleAttendance : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canCheck
                                ? AppColors.primary
                                : AppColors.divider,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: canCheck ? 8 : 0,
                          ),
                          child: Text(
                            canCheck ? '출석 체크하기' : '오늘은 이미 출석했어요',
                            style: AppTextStyles.button.copyWith(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 7일 출석 달력
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '출석 캘린더',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 12),
                      _buildAttendanceCalendar(consecutiveDays),

                      const SizedBox(height: 24),

                      // 보상 등급 안내
                      Text(
                        '출석 보상',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 12),
                      _buildRewardTier('1-2일차', '일반 상자', '📦', false),
                      _buildRewardTier('3-4일차', '레어 상자', '🎁', false),
                      _buildRewardTier('5-6일차', '에픽 상자', '✨', false),
                      _buildRewardTier('7일차', '황금 상자', '🏆', true),

                      const SizedBox(height: 24),

                      // 최근 획득 히스토리
                      if (progress.history.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '최근 획득',
                              style: AppTextStyles.h3,
                            ),
                            Text(
                              '총 ${provider.totalRewardsObtained}개',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...progress.history.take(5).map((result) {
                          return _buildHistoryItem(result);
                        }).toList(),
                      ],

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

  Widget _buildAttendanceCalendar(int consecutiveDays) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final day = index + 1;
          final isChecked = day <= consecutiveDays;
          final isToday = day == consecutiveDays;
          final isGolden = day == 7;

          return Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isChecked
                      ? (isGolden
                          ? const Color(0xFFFFD700)
                          : AppColors.primary)
                      : AppColors.divider.withOpacity(0.3),
                  border: isToday
                      ? Border.all(
                          color: AppColors.primary,
                          width: 3,
                        )
                      : null,
                ),
                child: Center(
                  child: isChecked
                      ? Icon(
                          isGolden ? Icons.emoji_events : Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : Text(
                          '$day',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Day$day',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10,
                  color: isChecked
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildRewardTier(
      String days, String name, String icon, bool isSpecial) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSpecial
            ? const Color(0xFFFFD700).withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSpecial
              ? const Color(0xFFFFD700).withOpacity(0.3)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.h4.copyWith(
                    color: isSpecial ? const Color(0xFFB8860B) : null,
                  ),
                ),
                Text(
                  days,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isSpecial)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'JACKPOT',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            result.reward.iconUrl,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.reward.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  result.reward.rarityName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Color(
                      int.parse(result.reward.rarityColor.replaceFirst('#', '0xFF')),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (result.isNew)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'NEW',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
