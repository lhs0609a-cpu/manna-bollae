import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/chat_model.dart';
import '../../../models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../../avatar/widgets/avatar_renderer.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input_field.dart';
import '../../profile/screens/partner_profile_detail_screen.dart';
import '../providers/chat_intimacy_provider.dart';

class ChatDetailScreen extends StatefulWidget {
  final Chat chat;
  final UserModel otherUser;
  final Avatar? otherUserAvatar;

  const ChatDetailScreen({
    super.key,
    required this.chat,
    required this.otherUser,
    this.otherUserAvatar,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  int _intimacyLevel = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final chatProvider = context.read<ChatProvider>();
      final intimacyProvider = context.read<ChatIntimacyProvider>();

      if (authProvider.user != null) {
        // ChatIntimacyProvider 초기화
        intimacyProvider.initialize(authProvider.user!.uid);

        // 메시지 리스너 시작
        chatProvider.listenToMessages(widget.chat.id);

        // 읽음 처리
        chatProvider.markMessagesAsRead(
          widget.chat.id,
          authProvider.user!.uid,
        );

        // 친밀도 가져오기
        _loadIntimacy();
      }
    });
  }

  Future<void> _loadIntimacy() async {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();

    if (authProvider.user != null) {
      final intimacy = await chatProvider.getIntimacyWithUser(
        authProvider.user!.uid,
        widget.otherUser.id,
      );
      setState(() {
        _intimacyLevel = intimacy;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String content) async {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();

    if (authProvider.user == null) return;

    final success = await chatProvider.sendMessage(
      chatId: widget.chat.id,
      senderId: authProvider.user!.uid,
      receiverId: widget.otherUser.id,
      content: content,
      type: MessageType.text,
    );

    if (success) {
      _scrollToBottom();

      // 친밀도 업데이트
      final intimacyProvider = context.read<ChatIntimacyProvider>();
      await intimacyProvider.updateIntimacyOnMessage(
        authProvider.user!.uid,
        widget.otherUser.id,
      );

      await _loadIntimacy();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('메시지 전송에 실패했습니다')),
        );
      }
    }
  }

  void _handleTypingChanged(bool isTyping) {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();

    if (authProvider.user != null) {
      chatProvider.updateTypingStatus(
        widget.chat.id,
        authProvider.user!.uid,
        isTyping,
      );
    }
  }

  String _getIntimacyStage() {
    if (_intimacyLevel >= AppConstants.intimacyLevel5) {
      return '최고 친밀도';
    } else if (_intimacyLevel >= AppConstants.intimacyLevel4) {
      return '매우 친밀함';
    } else if (_intimacyLevel >= AppConstants.intimacyLevel3) {
      return '친밀함';
    } else if (_intimacyLevel >= AppConstants.intimacyLevel2) {
      return '알아가는 중';
    } else {
      return '처음 만남';
    }
  }

  int _getNextLevelIntimacy() {
    if (_intimacyLevel >= AppConstants.intimacyLevel5) {
      return AppConstants.intimacyLevel5;
    } else if (_intimacyLevel >= AppConstants.intimacyLevel4) {
      return AppConstants.intimacyLevel5;
    } else if (_intimacyLevel >= AppConstants.intimacyLevel3) {
      return AppConstants.intimacyLevel4;
    } else if (_intimacyLevel >= AppConstants.intimacyLevel2) {
      return AppConstants.intimacyLevel3;
    } else {
      return AppConstants.intimacyLevel2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final chatProvider = context.watch<ChatProvider>();

    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(child: Text('로그인이 필요합니다')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: GestureDetector(
          onTap: () {
            final authProvider = context.read<AuthProvider>();
            if (authProvider.user != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PartnerProfileDetailScreen(
                    partner: widget.otherUser,
                    myUserId: authProvider.user!.uid,
                  ),
                ),
              );
            }
          },
          child: Row(
            children: [
              widget.otherUserAvatar != null
                  ? AvatarRenderer(
                      avatar: widget.otherUserAvatar!,
                      size: 40,
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        widget.otherUser.profile.basicInfo.name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherUser.profile.basicInfo.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    StreamBuilder<bool>(
                      stream: chatProvider.listenToTypingStatus(
                        widget.chat.id,
                        widget.otherUser.id,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return Text(
                            '입력 중...',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                            ),
                          );
                        }
                        return Text(
                          _getIntimacyStage(),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.dividerColor,
            height: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            tooltip: '음성 통화',
            onPressed: () {
              _showCallDialog(isVideo: false);
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            tooltip: '영상 통화',
            onPressed: () {
              _showCallDialog(isVideo: true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: '채팅방 정보',
            onPressed: () {
              _showChatInfo();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 친밀도 진행 바
          _buildIntimacyProgress(),
          // 메시지 목록
          Expanded(
            child: chatProvider.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[index];
                      final isMe = message.senderId == authProvider.user!.uid;
                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                      );
                    },
                  ),
          ),
          // 입력 필드
          ChatInputField(
            onSendMessage: _sendMessage,
            onTypingChanged: _handleTypingChanged,
            onImagePick: () {
              // TODO: 이미지 전송 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('이미지 전송 기능은 준비 중입니다')),
              );
            },
            onVoiceRecord: () {
              // TODO: 음성 메시지 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('음성 메시지 기능은 준비 중입니다')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIntimacyProgress() {
    final nextLevel = _getNextLevelIntimacy();
    final progress = nextLevel > 0 ? _intimacyLevel / nextLevel : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.favorite,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '친밀도',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$_intimacyLevel / $nextLevel',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: AppColors.borderColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.borderColor,
            child: Text(
              widget.otherUser.profile.basicInfo.name[0],
              style: AppTextStyles.h2.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.otherUser.profile.basicInfo.name}님과\n대화를 시작해보세요!',
            style: AppTextStyles.h4,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '메시지를 주고받으며 친밀도를 쌓아가세요',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showIntimacyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('친밀도 정보'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '현재 친밀도: $_intimacyLevel',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildIntimacyInfoRow(
                '텍스트 메시지',
                '+${AppConstants.intimacyPerTextMessage}',
              ),
              _buildIntimacyInfoRow(
                '음성 메시지',
                '+${AppConstants.intimacyPerVoiceMessage}',
              ),
              _buildIntimacyInfoRow(
                '이미지 전송',
                '+${AppConstants.intimacyPerImageMessage}',
              ),
              _buildIntimacyInfoRow(
                '영상 통화',
                '+${AppConstants.intimacyPerVideoCall}',
              ),
              const Divider(height: 24),
              Text(
                '친밀도 단계',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildIntimacyStageSRow('처음 만남', '0'),
              _buildIntimacyStageRow('알아가는 중', '${AppConstants.intimacyLevel2}'),
              _buildIntimacyStageRow('친밀함', '${AppConstants.intimacyLevel3}'),
              _buildIntimacyStageRow('매우 친밀함', '${AppConstants.intimacyLevel4}'),
              _buildIntimacyStageRow('최고 친밀도', '${AppConstants.intimacyLevel5}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildIntimacyInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntimacyStageRow(String stage, String intimacy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(stage, style: AppTextStyles.bodySmall),
          Text(
            intimacy,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntimacyStageSRow(String stage, String intimacy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(stage, style: AppTextStyles.bodySmall),
          Text(
            intimacy,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showCallDialog({required bool isVideo}) {
    final intimacyProvider = context.read<ChatIntimacyProvider>();
    final authProvider = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isVideo ? Icons.videocam : Icons.call,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(isVideo ? '영상 통화' : '음성 통화'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.otherUser.profile.basicInfo.name}님과 ${isVideo ? '영상' : '음성'} 통화를 시작하시겠습니까?',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '통화 종료 시 친밀도 +${isVideo ? AppConstants.intimacyPerVideoCall : '10'}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // 통화 시작 (시뮬레이션)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${isVideo ? '영상' : '음성'} 통화를 시작합니다...'),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 2),
                ),
              );

              // 통화 종료 후 친밀도 증가 (3초 후 시뮬레이션)
              await Future.delayed(const Duration(seconds: 3));

              if (authProvider.user != null && mounted) {
                await intimacyProvider.updateIntimacyOnVideoCall(
                  authProvider.user!.uid,
                  widget.otherUser.id,
                );

                await _loadIntimacy();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '통화 종료! 친밀도 +${isVideo ? AppConstants.intimacyPerVideoCall : '10'}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('통화 시작'),
          ),
        ],
      ),
    );
  }

  void _showChatInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('채팅방 정보'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상대방 정보
              Row(
                children: [
                  widget.otherUserAvatar != null
                      ? AvatarRenderer(
                          avatar: widget.otherUserAvatar!,
                          size: 60,
                        )
                      : CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            widget.otherUser.profile.basicInfo.name[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.otherUser.profile.basicInfo.name,
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.otherUser.profile.basicInfo.ageRange} · ${widget.otherUser.profile.basicInfo.mbti}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),

              // 친밀도 정보
              _buildInfoRow(
                Icons.favorite,
                '친밀도',
                '$_intimacyLevel (${_getIntimacyStage()})',
              ),
              const SizedBox(height: 12),

              // 채팅방 ID
              _buildInfoRow(
                Icons.chat_bubble_outline,
                '채팅방 ID',
                widget.chat.id.substring(0, 8) + '...',
              ),
              const SizedBox(height: 12),

              // 채팅 시작일
              _buildInfoRow(
                Icons.calendar_today,
                '채팅 시작일',
                _formatDate(widget.chat.createdAt),
              ),
              const Divider(height: 32),

              // 기능 버튼들
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('프로필 보기'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  final authProvider = context.read<AuthProvider>();
                  if (authProvider.user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PartnerProfileDetailScreen(
                          partner: widget.otherUser,
                          myUserId: authProvider.user!.uid,
                        ),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('친밀도 정보'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  _showIntimacyInfo();
                },
              ),
              ListTile(
                leading: Icon(Icons.block, color: Colors.red[700]),
                title: Text(
                  '차단하기',
                  style: TextStyle(color: Colors.red[700]),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showBlockConfirmation();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  void _showBlockConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('차단 확인'),
        content: Text(
          '${widget.otherUser.profile.basicInfo.name}님을 차단하시겠습니까?\n\n차단하면 더 이상 메시지를 주고받을 수 없으며, 상대방의 프로필도 볼 수 없습니다.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('차단 기능은 준비 중입니다'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('차단하기'),
          ),
        ],
      ),
    );
  }
}
