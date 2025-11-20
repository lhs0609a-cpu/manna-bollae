import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/user_model.dart';
import '../../../models/subscription_type.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/subscription_provider.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  const SubscriptionPlanScreen({super.key});

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.user!.uid)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _currentUser = UserModel.fromMap(doc.data()!);
          _isLoading = false;
        });

        // 구독 정보 로드
        final subscriptionProvider = context.read<SubscriptionProvider>();
        subscriptionProvider.loadSubscription(authProvider.user!.uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();

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
      appBar: AppBar(
        title: const Text('구독 플랜'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 설명
            Text(
              '나에게 맞는 플랜을 선택하세요',
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'VIP 플랜은 신뢰 지수와 하트 온도 요건을 충족해야 합니다',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // 일반 플랜
            Text(
              '일반 플랜',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildPlanCard(
              SubscriptionType.free,
              subscriptionProvider.currentSubscription?.type ==
                  SubscriptionType.free,
            ),
            const SizedBox(height: 12),
            _buildPlanCard(
              SubscriptionType.basic,
              subscriptionProvider.currentSubscription?.type ==
                  SubscriptionType.basic,
            ),
            const SizedBox(height: 12),
            _buildPlanCard(
              SubscriptionType.premium,
              subscriptionProvider.currentSubscription?.type ==
                  SubscriptionType.premium,
            ),

            const SizedBox(height: 32),

            // VIP 플랜
            Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: AppColors.vipGold,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'VIP 플랜',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.vipGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPlanCard(
              SubscriptionType.vip_basic,
              subscriptionProvider.currentSubscription?.type ==
                  SubscriptionType.vip_basic,
            ),
            const SizedBox(height: 12),
            _buildPlanCard(
              SubscriptionType.vip_premium,
              subscriptionProvider.currentSubscription?.type ==
                  SubscriptionType.vip_premium,
            ),
            const SizedBox(height: 12),
            _buildPlanCard(
              SubscriptionType.vip_platinum,
              subscriptionProvider.currentSubscription?.type ==
                  SubscriptionType.vip_platinum,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionType type, bool isCurrent) {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    final planData = SubscriptionProvider.planInfo[type]!;

    final bool isVIP = type == SubscriptionType.vip_basic ||
        type == SubscriptionType.vip_premium ||
        type == SubscriptionType.vip_platinum;

    // VIP 자격 확인
    final bool canSubscribe = subscriptionProvider.canSubscribe(
      type,
      _currentUser!.trustScore.score.round(),
      _currentUser!.heartTemperature.temperature,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: isVIP && canSubscribe
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.vipGold.withOpacity(0.1),
                  AppColors.vipGold.withOpacity(0.05),
                ],
              )
            : null,
        color: isVIP && canSubscribe ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? AppColors.primary
              : (isVIP && canSubscribe
                  ? AppColors.vipGold
                  : AppColors.borderColor),
          width: isCurrent ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 플랜 이름 & 현재 플랜 배지
          Row(
            children: [
              Text(
                planData['name'],
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isVIP ? AppColors.vipGold : AppColors.textPrimary,
                ),
              ),
              if (isCurrent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '현재 플랜',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // 가격
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${planData['price']}원',
                style: AppTextStyles.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isVIP ? AppColors.vipGold : AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ ${planData['duration']}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // VIP 자격 요건
          if (isVIP && planData['requirements'] != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: canSubscribe
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        canSubscribe ? Icons.check_circle : Icons.lock,
                        size: 16,
                        color: canSubscribe ? AppColors.success : AppColors.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        canSubscribe ? 'VIP 자격 충족' : 'VIP 자격 요건',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              canSubscribe ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(width: 22),
                      Text(
                        '신뢰 지수 ${planData['requirements']['trustScore']}점 이상 ',
                        style: AppTextStyles.caption.copyWith(
                          color: _currentUser!.trustScore.score >=
                                  planData['requirements']['trustScore']
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '(현재: ${_currentUser!.trustScore.score}점)',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 22),
                      Text(
                        '하트 온도 ${planData['requirements']['temperature']}° 이상 ',
                        style: AppTextStyles.caption.copyWith(
                          color: _currentUser!.heartTemperature.temperature >=
                                  planData['requirements']['temperature']
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '(현재: ${_currentUser!.heartTemperature.temperature.toStringAsFixed(1)}°)',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 혜택
          ...List<Widget>.generate(
            (planData['features'] as List).length,
            (index) {
              final feature = planData['features'][index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: isVIP ? AppColors.vipGold : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
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

          const SizedBox(height: 16),

          // 구독 버튼
          if (!isCurrent)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSubscribe
                    ? () => _handleSubscribe(type)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isVIP ? AppColors.vipGold : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: AppColors.borderColor,
                ),
                child: Text(
                  canSubscribe
                      ? (type == SubscriptionType.free ? '무료로 시작' : '구독하기')
                      : 'VIP 자격 부족',
                  style: AppTextStyles.buttonRegular.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleSubscribe(SubscriptionType type) async {
    final authProvider = context.read<AuthProvider>();
    final subscriptionProvider = context.read<SubscriptionProvider>();

    if (authProvider.user == null) return;

    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final planData = SubscriptionProvider.planInfo[type]!;
        return AlertDialog(
          title: Text('${planData['name']} 플랜 구독'),
          content: type == SubscriptionType.free
              ? const Text('무료 플랜으로 변경하시겠습니까?')
              : Text(
                  '${planData['price']}원/월로 ${planData['name']} 플랜을 구독하시겠습니까?\n\n'
                  '(테스트 모드: 실제 결제 없이 구독이 활성화됩니다)',
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final success = await subscriptionProvider.changeSubscription(
        userId: authProvider.user!.uid,
        newType: type,
        trustScore: _currentUser!.trustScore.score.round(),
        temperature: _currentUser!.heartTemperature.temperature,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${SubscriptionProvider.planInfo[type]!['name']} 플랜으로 변경되었습니다'),
            backgroundColor: AppColors.success,
          ),
        );

        // 사용자 데이터 새로고침
        await _loadUserData();
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
}
