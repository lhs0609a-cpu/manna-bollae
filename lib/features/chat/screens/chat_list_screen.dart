import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/chat_model.dart';
import '../../../models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../../avatar/widgets/avatar_renderer.dart';
import 'chat_detail_screen.dart';
import '../../profile/screens/partner_profile_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final chatProvider = context.read<ChatProvider>();
      if (authProvider.user != null) {
        chatProvider.listenToChats(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final chatProvider = context.watch<ChatProvider>();

    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(
          child: Text('로그인이 필요합니다'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
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
      body: chatProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatProvider.chats.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  itemCount: chatProvider.chats.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    indent: 72,
                    color: AppColors.dividerColor,
                  ),
                  itemBuilder: (context, index) {
                    final chat = chatProvider.chats[index];
                    final otherUserId =
                        chat.getOtherUserId(authProvider.user!.uid);
                    return _buildChatListItem(
                      chat,
                      otherUserId,
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
            Icons.chat_bubble_outline,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 채팅이 없습니다',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '매칭된 상대와 대화를 시작해보세요!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatListItem(Chat chat, String otherUserId, String myUserId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 72);
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null) {
          return const SizedBox.shrink();
        }

        final otherUser = UserModel.fromMap(userData);
        final unreadCount = chat.getUnreadCount(myUserId);

        // 아바타 정보 추출
        Avatar? avatar;
        if (userData['avatar'] != null) {
          try {
            avatar = Avatar.fromMap(userData['avatar']);
          } catch (e) {
            avatar = null;
          }
        }

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: GestureDetector(
            onTap: () {
              // 상대방 프로필 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PartnerProfileDetailScreen(
                    partner: otherUser,
                    myUserId: authProvider.user!.uid,
                  ),
                ),
              );
            },
            child: Stack(
              children: [
                avatar != null
                    ? AvatarPreview(
                        avatar: avatar,
                        size: 56,
                      )
                    : DefaultAvatar(
                        name: otherUser.profile.basicInfo.name,
                        size: 56,
                      ),
                // 온라인 상태 표시 (나중에 구현)
                // Positioned(
                //   right: 0,
                //   bottom: 0,
                //   child: Container(
                //     width: 14,
                //     height: 14,
                //     decoration: BoxDecoration(
                //       color: AppColors.success,
                //       shape: BoxShape.circle,
                //       border: Border.all(color: Colors.white, width: 2),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  otherUser.profile.basicInfo.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (chat.lastMessageTime != null)
                Text(
                  _formatTime(chat.lastMessageTime!),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  chat.lastMessage ?? '메시지가 없습니다',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: unreadCount > 0
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: unreadCount > 0
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: AppTextStyles.badge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  chat: chat,
                  otherUser: otherUser,
                  otherUserAvatar: avatar,
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      // 오늘: 시간만 표시
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1) {
      // 어제
      return '어제';
    } else if (difference.inDays < 7) {
      // 일주일 이내
      return DateFormat('E', 'ko_KR').format(timestamp);
    } else if (difference.inDays < 365) {
      // 올해
      return DateFormat('MM/dd').format(timestamp);
    } else {
      // 작년 이전
      return DateFormat('yyyy/MM/dd').format(timestamp);
    }
  }
}
