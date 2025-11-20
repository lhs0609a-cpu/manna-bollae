import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../providers/gacha_provider.dart';
import 'daily_attendance_screen.dart';
import 'mission_slot_screen.dart';
import 'bingo_gacha_screen.dart';

class GachaHubScreen extends StatefulWidget {
  const GachaHubScreen({super.key});

  @override
  State<GachaHubScreen> createState() => _GachaHubScreenState();
}

class _GachaHubScreenState extends State<GachaHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GachaProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 앱바
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('럭키 박스'),
              background: Container(
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
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        '🎁',
                        style: const TextStyle(fontSize: 64),
                      ),
                      const SizedBox(height: 8),
                      Consumer<GachaProvider>(
                        builder: (context, provider, child) {
                          return Text(
                            '총 ${provider.totalRewardsObtained}개 획득',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 가챠 목록
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Phase 1: 기본 가챠
                _buildSectionHeader('매일 참여'),
                _buildGachaCard(
                  icon: '📅',
                  title: '출석 체크',
                  description: '매일 출석하고 보상 받기',
                  status: '매일 1회',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DailyAttendanceScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildGachaCard(
                  icon: '🎰',
                  title: '매칭 룰렛',
                  description: '좋아요 10개마다 룰렛 1회',
                  status: '활동 시 획득',
                  color: const Color(0xFFE91E63),
                  onTap: () {
                    _showComingSoon(context);
                  },
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('친구와 함께'),
                _buildGachaCard(
                  icon: '🎁',
                  title: '친구 초대 럭키박스',
                  description: '친구 초대할 때마다 보상',
                  status: '초대 시 즉시',
                  color: const Color(0xFFFF9800),
                  onTap: () {
                    Navigator.pushNamed(context, '/referral');
                  },
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('미션 & 성장'),
                _buildGachaCard(
                  icon: '🎲',
                  title: '미션 슬롯머신',
                  description: '일일 미션 완료 시 슬롯머신',
                  status: '미션 3개 완료',
                  color: const Color(0xFF9C27B0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MissionSlotScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildGachaCard(
                  icon: '📈',
                  title: '레벨업 보상',
                  description: '레벨업할 때마다 특별 보상',
                  status: '레벨업 시',
                  color: const Color(0xFF3F51B5),
                  onTap: () {
                    _showComingSoon(context);
                  },
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('특별 가챠'),
                _buildGachaCard(
                  icon: '💝',
                  title: '운명의 만남',
                  description: '3명 중 1명 선택하기',
                  status: '하루 1회',
                  color: const Color(0xFFE91E63),
                  onTap: () {
                    _showComingSoon(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildGachaCard(
                  icon: '🎨',
                  title: '아바타 가챠',
                  description: '다양한 아바타 아이템 획득',
                  status: '포인트 소모',
                  color: const Color(0xFF00BCD4),
                  onTap: () {
                    _showComingSoon(context);
                  },
                ),
                const SizedBox(height: 12),
                _buildGachaCard(
                  icon: '🌸',
                  title: '시즌 한정 가챠',
                  description: '계절마다 특별한 보상',
                  status: '시즌 이벤트',
                  color: const Color(0xFFFFEB3B),
                  onTap: () {
                    _showComingSoon(context);
                  },
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('게임 & 챌린지'),
                _buildGachaCard(
                  icon: '⭐',
                  title: '빙고 가챠',
                  description: '9칸 빙고판 완성하기',
                  status: '활동 시 진행',
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BingoGachaScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 통계 카드
                Consumer<GachaProvider>(
                  builder: (context, provider, child) {
                    return _buildStatsCard(provider);
                  },
                ),

                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: AppTextStyles.h3,
      ),
    );
  }

  Widget _buildGachaCard({
    required String icon,
    required String title,
    required String description,
    required String status,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h4,
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

              // 상태
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(GachaProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '나의 가챠 통계',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '총 뽑기',
                  '${provider.progress.totalPulls}회',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '보유 아이템',
                  '${provider.totalRewardsObtained}개',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '레전더리',
                  '${provider.legendaryRate.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.primary,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('준비 중'),
        content: const Text('곧 출시될 예정입니다!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
