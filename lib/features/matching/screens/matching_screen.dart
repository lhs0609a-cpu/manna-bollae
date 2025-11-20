import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/matching_provider.dart';
import '../widgets/matching_card.dart';
import '../widgets/match_success_dialog.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  int _currentIndex = 0;
  final Map<String, Avatar?> _avatarCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecommendedUsers();
    });
  }

  Future<void> _loadRecommendedUsers() async {
    final authProvider = context.read<AuthProvider>();
    final matchingProvider = context.read<MatchingProvider>();

    if (authProvider.user != null) {
      await matchingProvider.fetchRecommendedUsers(authProvider.user!.uid);

      // 추천 사용자들의 아바타 로드
      if (mounted) {
        await _loadAvatars();
      }
    }
  }

  Future<void> _loadAvatars() async {
    final matchingProvider = context.read<MatchingProvider>();

    for (final user in matchingProvider.recommendedUsers) {
      if (!_avatarCache.containsKey(user.id)) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.id)
              .get();

          if (doc.exists && mounted) {
            final userData = doc.data()!;
            if (userData['avatar'] != null) {
              setState(() {
                _avatarCache[user.id] = Avatar.fromMap(userData['avatar']);
              });
            } else {
              setState(() {
                _avatarCache[user.id] = null;
              });
            }
          }
        } catch (e) {
          // 아바타 로드 실패 시 null로 설정
          if (mounted) {
            setState(() {
              _avatarCache[user.id] = null;
            });
          }
        }
      }
    }
  }

  Future<void> _handleLike() async {
    final authProvider = context.read<AuthProvider>();
    final matchingProvider = context.read<MatchingProvider>();

    if (authProvider.user == null) return;

    final currentUser = matchingProvider.recommendedUsers[_currentIndex];

    final isMatch = await matchingProvider.sendLike(
      authProvider.user!.uid,
      currentUser.id,
    );

    if (isMatch) {
      // 매칭 성공!
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => MatchSuccessDialog(
            matchedUser: currentUser,
            avatar: _avatarCache[currentUser.id],
          ),
        );
      }
    }

    // 다음 카드로
    _moveToNextCard();
  }

  Future<void> _handlePass() async {
    final authProvider = context.read<AuthProvider>();
    final matchingProvider = context.read<MatchingProvider>();

    if (authProvider.user == null) return;

    final currentUser = matchingProvider.recommendedUsers[_currentIndex];

    await matchingProvider.sendPass(
      authProvider.user!.uid,
      currentUser.id,
    );

    // 다음 카드로
    _moveToNextCard();
  }

  void _moveToNextCard() {
    final matchingProvider = context.read<MatchingProvider>();

    if (_currentIndex < matchingProvider.recommendedUsers.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      // 더 이상 추천할 사용자가 없음
      setState(() {
        _currentIndex = 0;
      });

      // 새로운 추천 사용자 가져오기
      _loadRecommendedUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final matchingProvider = context.watch<MatchingProvider>();

    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(child: Text('로그인이 필요합니다')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('매칭'),
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
          // 오늘 사용한 매칭 횟수
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${matchingProvider.dailyMatchCount}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: matchingProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : matchingProvider.recommendedUsers.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // 매칭 카드 영역
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _currentIndex <
                                matchingProvider.recommendedUsers.length
                            ? MatchingCard(
                                user: matchingProvider
                                    .recommendedUsers[_currentIndex],
                                avatar: _avatarCache[matchingProvider
                                    .recommendedUsers[_currentIndex].id],
                                onTap: () {
                                  _showProfileDetail(
                                    matchingProvider
                                        .recommendedUsers[_currentIndex],
                                  );
                                },
                              )
                            : _buildEmptyState(),
                      ),
                    ),
                    // 액션 버튼들
                    _buildActionButtons(),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '추천할 사용자가 없습니다',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '나중에 다시 확인해주세요',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 거절 버튼
          _buildActionButton(
            icon: Icons.close,
            color: AppColors.error,
            onTap: _handlePass,
            size: 60,
          ),
          // 좋아요 버튼
          _buildActionButton(
            icon: Icons.favorite,
            color: AppColors.primary,
            onTap: _handleLike,
            size: 70,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 60,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }

  void _showProfileDetail(UserModel user) {
    final basicInfo = user.profile.basicInfo;
    final lifestyle = user.profile.lifestyle;

    int? age;
    if (basicInfo.birthDate != null) {
      age = DateTime.now().year - basicInfo.birthDate!.year;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 드래그 핸들
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 이름과 나이
                  Row(
                    children: [
                      Text(
                        basicInfo.name,
                        style: AppTextStyles.h2,
                      ),
                      if (age != null)
                        Text(
                          ', $age',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 지역
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        basicInfo.region,
                        style: AppTextStyles.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 기본 정보
                  _buildInfoSection('기본 정보', [
                    if (basicInfo.mbti != null) 'MBTI: ${basicInfo.mbti}',
                    if (basicInfo.bloodType != null)
                      '혈액형: ${basicInfo.bloodType}형',
                    if (basicInfo.religion != null) '종교: ${basicInfo.religion}',
                    '흡연: ${basicInfo.smoking ? '흡연' : '비흡연'}',
                    '음주: ${basicInfo.drinking}',
                  ]),
                  const SizedBox(height: 24),
                  // 한 줄 소개
                  if (basicInfo.oneLiner.isNotEmpty) ...[
                    _buildInfoSection('한 줄 소개', [basicInfo.oneLiner]),
                    const SizedBox(height: 24),
                  ],
                  // 취미
                  if (lifestyle.hobbies.isNotEmpty) ...[
                    Text(
                      '취미',
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: lifestyle.hobbies.map((hobby) {
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8, right: 8),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
