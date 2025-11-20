import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

/// 빈 상태를 표시하는 위젯
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 채팅 없음 위젯
class EmptyChatWidget extends StatelessWidget {
  const EmptyChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      title: '아직 대화가 없어요',
      description: '매칭된 사람과 대화를 시작해보세요!',
      icon: Icons.chat_bubble_outline,
    );
  }
}

/// 매칭 없음 위젯
class EmptyMatchWidget extends StatelessWidget {
  const EmptyMatchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      title: '추천할 사람이 없어요',
      description: '프로필을 더 상세히 작성하면\n더 좋은 매칭을 받을 수 있어요!',
      icon: Icons.favorite_border,
    );
  }
}

/// 알림 없음 위젯
class EmptyNotificationWidget extends StatelessWidget {
  const EmptyNotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      title: '새로운 알림이 없어요',
      description: '활동하면서 받은 알림이 여기에 표시됩니다',
      icon: Icons.notifications_none,
    );
  }
}

/// 검색 결과 없음 위젯
class EmptySearchWidget extends StatelessWidget {
  final String? query;

  const EmptySearchWidget({
    super.key,
    this.query,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: '검색 결과가 없어요',
      description: query != null ? '"$query"에 대한 결과를 찾을 수 없습니다' : '다른 검색어를 입력해보세요',
      icon: Icons.search_off,
    );
  }
}
