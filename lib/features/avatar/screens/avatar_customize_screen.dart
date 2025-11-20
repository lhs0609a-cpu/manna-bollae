import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/avatar_provider.dart';
import '../widgets/avatar_renderer.dart';

class AvatarCustomizeScreen extends StatefulWidget {
  const AvatarCustomizeScreen({super.key});

  @override
  State<AvatarCustomizeScreen> createState() => _AvatarCustomizeScreenState();
}

class _AvatarCustomizeScreenState extends State<AvatarCustomizeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _emotions = [
    '미소',
    '웃음',
    '사랑',
    '윙크',
    '쿨',
    '생각',
    '놀람',
    '행복',
  ];

  final List<String> _accessories = [
    '없음',
    '안경',
    '모자',
    '왕관',
    '나비넥타이',
    '꽃',
    '별',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final avatarProvider = context.read<AvatarProvider>();

      if (authProvider.user != null) {
        avatarProvider.loadAvatar(authProvider.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final avatarProvider = context.watch<AvatarProvider>();

    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(child: Text('로그인이 필요합니다')),
      );
    }

    if (avatarProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final avatar = avatarProvider.avatar;
    if (avatar == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('아바타 커스터마이징'),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 80,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                '아바타를 먼저 생성해주세요',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('아바타 커스터마이징'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: '감정'),
            Tab(text: '액세서리'),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          // 아바타 미리보기
          Center(
            child: AvatarRenderer(
              avatar: avatar,
              size: 200,
            ),
          ),
          const SizedBox(height: 24),
          // 정보 카드
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              children: [
                _buildInfoRow('동물', avatar.animalType),
                const SizedBox(height: 8),
                _buildInfoRow('성격', avatar.personality),
                const SizedBox(height: 8),
                _buildInfoRow('스타일', avatar.style),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 커스터마이징 옵션
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEmotionTab(authProvider.user!.uid, avatar),
                _buildAccessoryTab(authProvider.user!.uid, avatar),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionTab(String userId, avatar) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _emotions.length,
      itemBuilder: (context, index) {
        final emotion = _emotions[index];
        final isSelected = avatar.currentOutfit.emotion == emotion;

        return InkWell(
          onTap: () => _changeEmotion(userId, emotion),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.borderColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getEmotionEmoji(emotion),
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 4),
                Text(
                  emotion,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccessoryTab(String userId, avatar) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _accessories.length,
      itemBuilder: (context, index) {
        final accessory = _accessories[index];
        final isSelected = accessory == '없음'
            ? avatar.currentOutfit.accessory == null
            : avatar.currentOutfit.accessory == accessory;

        // 보유 여부 확인 (없음은 항상 보유)
        final isOwned = accessory == '없음' ||
            avatar.ownedItems.accessories.contains(accessory);

        return InkWell(
          onTap: isOwned
              ? () => _changeAccessory(
                    userId,
                    accessory == '없음' ? null : accessory,
                  )
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: !isOwned
                  ? AppColors.borderColor.withOpacity(0.3)
                  : isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.borderColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        accessory == '없음'
                            ? '❌'
                            : _getAccessoryEmoji(accessory),
                        style: TextStyle(
                          fontSize: 32,
                          color: !isOwned
                              ? Colors.grey.withOpacity(0.5)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        accessory,
                        style: AppTextStyles.caption.copyWith(
                          color: !isOwned
                              ? AppColors.textSecondary.withOpacity(0.5)
                              : isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isOwned)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(
                      Icons.lock,
                      size: 16,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeEmotion(String userId, String emotion) async {
    final avatarProvider = context.read<AvatarProvider>();

    final success = await avatarProvider.changeEmotion(userId, emotion);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('감정이 $emotion(으)로 변경되었습니다'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _changeAccessory(String userId, String? accessory) async {
    final avatarProvider = context.read<AvatarProvider>();

    final success = await avatarProvider.updateOutfit(
      userId: userId,
      accessory: accessory,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accessory == null
              ? '액세서리를 해제했습니다'
              : '액세서리가 $accessory(으)로 변경되었습니다'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion) {
      case '미소':
        return '😊';
      case '웃음':
        return '😄';
      case '사랑':
        return '😍';
      case '윙크':
        return '😉';
      case '쿨':
        return '😎';
      case '생각':
        return '🤔';
      case '놀람':
        return '😲';
      case '행복':
        return '🥰';
      default:
        return '😊';
    }
  }

  String _getAccessoryEmoji(String accessory) {
    switch (accessory) {
      case '안경':
        return '👓';
      case '모자':
        return '🎩';
      case '왕관':
        return '👑';
      case '나비넥타이':
        return '🎀';
      case '꽃':
        return '🌸';
      case '별':
        return '⭐';
      default:
        return '✨';
    }
  }
}
