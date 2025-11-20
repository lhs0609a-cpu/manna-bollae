import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../chat/providers/chat_provider.dart';
import '../../chat/screens/chat_detail_screen.dart';
import '../../avatar/widgets/avatar_renderer.dart';

class MatchSuccessDialog extends StatelessWidget {
  final UserModel matchedUser;
  final Avatar? avatar;

  const MatchSuccessDialog({
    super.key,
    required this.matchedUser,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아바타 또는 하트 아이콘
            Stack(
              alignment: Alignment.center,
              children: [
                if (avatar != null)
                  AvatarRenderer(
                    avatar: avatar!,
                    size: 120,
                  )
                else
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                // 하트 오버레이
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 제목
            Text(
              '매칭 성공!',
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            // 설명
            Text(
              '${matchedUser.profile.basicInfo.name}님과\n서로 좋아요를 보냈어요!',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '이제 대화를 시작해보세요',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            // 버튼들
            Row(
              children: [
                // 나중에 버튼
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '나중에',
                      style: AppTextStyles.buttonRegular,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 대화 시작 버튼
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _startChat(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '대화 시작하기',
                      style: AppTextStyles.buttonRegular.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startChat(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();

    if (authProvider.user == null) return;

    // 채팅방 생성 또는 가져오기
    final chatId = await chatProvider.getOrCreateChat(
      authProvider.user!.uid,
      matchedUser.id,
    );

    if (chatId != null && context.mounted) {
      // 다이얼로그 닫기
      Navigator.pop(context);

      // 채팅 화면으로 이동하는 코드는 나중에 구현
      // 일단 매칭 성공 메시지만 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${matchedUser.profile.basicInfo.name}님과 매칭되었습니다!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
