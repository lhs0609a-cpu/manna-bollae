import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/user_model.dart';
import '../../../models/subscription_type.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/subscription_provider.dart';
import 'subscription_plan_screen.dart';

class SubscriptionManageScreen extends StatefulWidget {
  const SubscriptionManageScreen({super.key});

  @override
  State<SubscriptionManageScreen> createState() =>
      _SubscriptionManageScreenState();
}

class _SubscriptionManageScreenState extends State<SubscriptionManageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final subscriptionProvider = context.read<SubscriptionProvider>();

      if (authProvider.user != null) {
        subscriptionProvider.loadSubscription(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    if (subscriptionProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final subscription = subscriptionProvider.currentSubscription;
    if (subscription == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('구독 관리'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: const Center(
          child: Text('구독 정보를 불러올 수 없습니다'),
        ),
      );
    }

    final planData = SubscriptionProvider.planInfo[subscription.type]!;
    final isVIP = subscriptionProvider.isVIP();
    final daysRemaining = subscriptionProvider.getDaysRemaining();

    return Scaffold(
      appBar: AppBar(
        title: const Text('구독 관리'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 현재 플랜 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                    : AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isVIP ? AppColors.vipGold : AppColors.primary)
                        .withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isVIP
                            ? Icons.workspace_premium
                            : Icons.card_membership,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '현재 플랜',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            Text(
                              planData['name'],
                              style: AppTextStyles.h2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (subscription.type != SubscriptionType.free.toValue()) ...[
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '남은 기간',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$daysRemaining일',
                              style: AppTextStyles.h3.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '다음 결제일',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subscription.endDate != null
                                  ? _formatDate(subscription.endDate!)
                                  : '-',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 혜택 섹션
            Text(
              '구독 혜택',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                children: List.generate(
                  (planData['features'] as List).length,
                  (index) {
                    final feature = planData['features'][index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color:
                                isVIP ? AppColors.vipGold : AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 설정 섹션
            if (subscription.type != SubscriptionType.free.toValue()) ...[
              Text(
                '구독 설정',
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  children: [
                    // 자동 갱신
                    SwitchListTile(
                      title: Text(
                        '자동 갱신',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        subscription.autoRenew
                            ? '다음 결제일에 자동으로 갱신됩니다'
                            : '구독이 만료되면 무료 플랜으로 전환됩니다',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      value: subscription.autoRenew,
                      activeColor: AppColors.primary,
                      onChanged: (value) => _handleAutoRenewToggle(value),
                    ),
                    const Divider(height: 1),
                    // 플랜 변경
                    ListTile(
                      leading: const Icon(
                        Icons.swap_horiz,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        '플랜 변경',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '다른 플랜으로 변경하기',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SubscriptionPlanScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    // 구독 취소
                    ListTile(
                      leading: const Icon(
                        Icons.cancel,
                        color: AppColors.error,
                      ),
                      title: Text(
                        '구독 취소',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                      subtitle: Text(
                        '다음 결제일까지는 계속 이용 가능합니다',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.error,
                      ),
                      onTap: _handleCancelSubscription,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // 무료 플랜 업그레이드 권장
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.rocket_launch,
                      color: Colors.white,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '더 많은 기능을 경험하세요!',
                      style: AppTextStyles.h4.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '프리미엄 플랜으로 업그레이드하고\n더 많은 매칭 기회를 얻으세요',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SubscriptionPlanScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '플랜 둘러보기',
                        style: AppTextStyles.buttonRegular.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAutoRenewToggle(bool value) async {
    final authProvider = context.read<AuthProvider>();
    final subscriptionProvider = context.read<SubscriptionProvider>();

    if (authProvider.user == null) return;

    final success = await subscriptionProvider.updateAutoRenew(
      authProvider.user!.uid,
      value,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? '자동 갱신이 활성화되었습니다' : '자동 갱신이 비활성화되었습니다'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (subscriptionProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(subscriptionProvider.error!),
          backgroundColor: AppColors.error,
        ),
      );
      subscriptionProvider.clearError();
    }
  }

  Future<void> _handleCancelSubscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('구독 취소'),
        content: const Text(
          '구독을 취소하시겠습니까?\n\n'
          '다음 결제일까지는 계속 이용 가능하며, '
          '그 이후에는 자동으로 무료 플랜으로 전환됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('닫기'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('취소하기'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = context.read<AuthProvider>();
      final subscriptionProvider = context.read<SubscriptionProvider>();

      if (authProvider.user == null) return;

      final success =
          await subscriptionProvider.cancelSubscription(authProvider.user!.uid);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구독이 취소되었습니다. 현재 기간이 끝날 때까지 계속 이용하실 수 있습니다.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (subscriptionProvider.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(subscriptionProvider.error!),
            backgroundColor: AppColors.error,
          ),
        );
        subscriptionProvider.clearError();
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
