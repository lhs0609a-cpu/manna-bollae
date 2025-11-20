import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/trust_score_provider.dart';
import 'daily_quest_screen.dart';
import 'verification_screen.dart';

class TrustScoreScreen extends StatefulWidget {
  const TrustScoreScreen({super.key});

  @override
  State<TrustScoreScreen> createState() => _TrustScoreScreenState();
}

class _TrustScoreScreenState extends State<TrustScoreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final trustScoreProvider = context.read<TrustScoreProvider>();

      if (authProvider.user != null) {
        trustScoreProvider.loadTrustScore(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final trustScoreProvider = context.watch<TrustScoreProvider>();

    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(child: Text('로그인이 필요합니다')),
      );
    }

    if (trustScoreProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final trustScore = trustScoreProvider.trustScore;
    if (trustScore == null) {
      return const Scaffold(
        body: Center(child: Text('신뢰 지수 정보를 불러올 수 없습니다')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('신뢰 지수'),
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
          // 점수 카드
          _buildScoreCard(trustScore),
          const SizedBox(height: 16),
          // 차트
          _buildChart(trustScore),
          const SizedBox(height: 16),
          // 일일 퀘스트 섹션
          _buildDailyQuestSection(trustScore),
          const SizedBox(height: 16),
          // 인증 섹션
          _buildVerificationSection(trustScore),
          const SizedBox(height: 16),
          // 배지 섹션
          _buildBadgesSection(trustScore),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildScoreCard(TrustScore trustScore) {
    final level = _getLevel(trustScore.score.toInt());
    final colorIndex = _getColorIndex(trustScore.score.toInt());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.trustScoreColors[colorIndex],
            AppColors.trustScoreColors[colorIndex].withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.trustScoreColors[colorIndex].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${trustScore.score}',
            style: AppTextStyles.h1.copyWith(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            level,
            style: AppTextStyles.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  '${trustScore.questStreak}일 연속',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(TrustScore trustScore) {
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
          Text(
            '레벨 진행도',
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const levels = ['새싹', '새내기', '일반', '믿음직한', '진심왕'];
                        if (value.toInt() >= 0 && value.toInt() < levels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              levels[value.toInt()],
                              style: AppTextStyles.caption,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTextStyles.caption,
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.borderColor,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, 20, trustScore.score.toInt()),
                  _makeBarGroup(1, 40, trustScore.score.toInt()),
                  _makeBarGroup(2, 60, trustScore.score.toInt()),
                  _makeBarGroup(3, 80, trustScore.score.toInt()),
                  _makeBarGroup(4, 100, trustScore.score.toInt()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, int threshold, int currentScore) {
    final isReached = currentScore >= threshold;
    final colorIndex = x;

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: threshold.toDouble(),
          color: isReached
              ? AppColors.trustScoreColors[colorIndex]
              : AppColors.borderColor,
          width: 30,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyQuestSection(TrustScore trustScore) {
    final today = DateTime.now();
    final lastQuestDate = trustScore.lastQuestDate;
    final isCompletedToday = lastQuestDate != null &&
        lastQuestDate.year == today.year &&
        lastQuestDate.month == today.month &&
        lastQuestDate.day == today.day;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isCompletedToday
                ? AppColors.success.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isCompletedToday ? Icons.check_circle : Icons.edit_note,
            color: isCompletedToday ? AppColors.success : AppColors.primary,
            size: 28,
          ),
        ),
        title: Text(
          '일일 퀘스트',
          style: AppTextStyles.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          isCompletedToday
              ? '오늘의 퀘스트 완료! 🎉'
              : '소개글을 작성하고 +${AppConstants.trustScoreDailyQuest}점 받기',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: isCompletedToday
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DailyQuestScreen(),
                  ),
                );
              },
      ),
    );
  }

  Widget _buildVerificationSection(TrustScore trustScore) {
    final verifications = [
      {
        'icon': Icons.phone_android,
        'title': '전화번호 인증',
        'score': AppConstants.trustScorePhoneVerification,
        'badge': 'phone_verified',
      },
      {
        'icon': Icons.videocam,
        'title': '비디오 인증',
        'score': AppConstants.trustScoreVideoVerification,
        'badge': 'video_verified',
      },
      {
        'icon': Icons.shield,
        'title': '범죄기록 조회',
        'score': AppConstants.trustScoreCriminalCheck,
        'badge': 'criminal_record_clear',
      },
      {
        'icon': Icons.school,
        'title': '학교폭력 기록 조회',
        'score': AppConstants.trustScoreSchoolViolenceCheck,
        'badge': 'school_violence_clear',
      },
      {
        'icon': Icons.work,
        'title': '직업 인증',
        'score': AppConstants.trustScoreOccupationVerification,
        'badge': 'occupation_verified',
      },
      {
        'icon': Icons.menu_book,
        'title': '학력 인증',
        'score': AppConstants.trustScoreEducationVerification,
        'badge': 'education_verified',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '인증 항목',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VerificationScreen(),
                      ),
                    );
                  },
                  child: const Text('전체 보기'),
                ),
              ],
            ),
          ),
          ...verifications.take(3).map((verification) {
            final isCompleted =
                trustScore.badges.contains(verification['badge']);
            return ListTile(
              leading: Icon(
                verification['icon'] as IconData,
                color: isCompleted ? AppColors.success : AppColors.textSecondary,
              ),
              title: Text(verification['title'] as String),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isCompleted)
                    Text(
                      '+${verification['score']}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (isCompleted)
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                    ),
                ],
              ),
              onTap: isCompleted
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VerificationScreen(),
                        ),
                      );
                    },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(TrustScore trustScore) {
    if (trustScore.badges.isEmpty) {
      return const SizedBox.shrink();
    }

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
          Text(
            '획득한 배지',
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: trustScore.badges.map((badge) {
              return _buildBadge(_getBadgeInfo(badge));
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(Map<String, dynamic> badgeInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeInfo['icon'] as IconData,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            badgeInfo['name'] as String,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getLevel(int score) {
    if (score >= 80) return '진심왕';
    if (score >= 60) return '믿음직한';
    if (score >= 40) return '일반';
    if (score >= 20) return '새내기';
    return '새싹';
  }

  int _getColorIndex(int score) {
    if (score >= 80) return 4;
    if (score >= 60) return 3;
    if (score >= 40) return 2;
    if (score >= 20) return 1;
    return 0;
  }

  Map<String, dynamic> _getBadgeInfo(String badge) {
    switch (badge) {
      case 'phone_verified':
        return {'icon': Icons.phone_android, 'name': '전화 인증'};
      case 'video_verified':
        return {'icon': Icons.videocam, 'name': '영상 인증'};
      case 'criminal_record_clear':
        return {'icon': Icons.shield, 'name': '범죄기록 무'};
      case 'school_violence_clear':
        return {'icon': Icons.school, 'name': '학폭기록 무'};
      case 'occupation_verified':
        return {'icon': Icons.work, 'name': '직업 인증'};
      case 'education_verified':
        return {'icon': Icons.menu_book, 'name': '학력 인증'};
      default:
        return {'icon': Icons.star, 'name': badge};
    }
  }
}
