import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/safety_provider.dart';

class BlockListScreen extends StatefulWidget {
  const BlockListScreen({super.key});

  @override
  State<BlockListScreen> createState() => _BlockListScreenState();
}

class _BlockListScreenState extends State<BlockListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final safetyProvider = context.read<SafetyProvider>();

      if (authProvider.user != null) {
        safetyProvider.loadBlockedUsers(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final safetyProvider = context.watch<SafetyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('차단 목록'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: safetyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : safetyProvider.blockedUsers.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: safetyProvider.blockedUsers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final blockedUserId = safetyProvider.blockedUsers[index];
                    return _buildBlockedUserTile(
                      blockedUserId,
                      authProvider.user!.uid,
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.block,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '차단한 사용자가 없습니다',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '차단한 사용자는 여기에 표시됩니다',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedUserTile(String blockedUserId, String currentUserId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(blockedUserId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null) {
          return const SizedBox.shrink();
        }

        final blockedUser = UserModel.fromMap(userData);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.borderColor,
              child: Text(
                blockedUser.profile.basicInfo.name[0],
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            title: Text(
              blockedUser.profile.basicInfo.name,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              blockedUser.profile.basicInfo.region,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: OutlinedButton(
              onPressed: () => _handleUnblock(currentUserId, blockedUserId),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text('차단 해제'),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleUnblock(String userId, String blockedUserId) async {
    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('차단 해제'),
        content: const Text(
          '차단을 해제하시겠습니까?\n\n'
          '차단을 해제하면 다시 매칭될 수 있으며,\n'
          '서로의 프로필을 볼 수 있게 됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: const Text('해제'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final safetyProvider = context.read<SafetyProvider>();

      final success = await safetyProvider.unblockUser(userId, blockedUserId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('차단이 해제되었습니다'),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (safetyProvider.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(safetyProvider.error!),
            backgroundColor: AppColors.error,
          ),
        );
        safetyProvider.clearError();
      }
    }
  }
}
