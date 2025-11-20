import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/chat_model.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            // 상대방 프로필 이미지 (나중에 구현)
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.borderColor,
              child: Icon(Icons.person, size: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildMessageContent(),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: AppTextStyles.chatTimestamp,
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 14,
                        color: message.isRead
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage();
      case MessageType.image:
        return _buildImageMessage();
      case MessageType.voice:
        return _buildVoiceMessage();
    }
  }

  Widget _buildTextMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isMe ? 20 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message.content,
        style: AppTextStyles.chatMessage.copyWith(
          color: isMe ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildImageMessage() {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 250,
        maxHeight: 300,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: message.content,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 250,
            height: 250,
            color: AppColors.surface,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 250,
            height: 250,
            color: AppColors.surface,
            child: const Center(
              child: Icon(Icons.error, color: AppColors.error),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_arrow,
            color: isMe ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.graphic_eq,
            color: isMe ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '음성 메시지',
            style: AppTextStyles.chatMessage.copyWith(
              color: isMe ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
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
      return '어제 ${DateFormat('HH:mm').format(timestamp)}';
    } else if (difference.inDays < 7) {
      // 일주일 이내
      return DateFormat('E HH:mm', 'ko_KR').format(timestamp);
    } else {
      // 그 외
      return DateFormat('MM/dd HH:mm').format(timestamp);
    }
  }
}
