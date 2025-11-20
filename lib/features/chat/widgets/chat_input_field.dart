import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class ChatInputField extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback? onImagePick;
  final VoidCallback? onVoiceRecord;
  final Function(bool)? onTypingChanged;

  const ChatInputField({
    super.key,
    required this.onSendMessage,
    this.onImagePick,
    this.onVoiceRecord,
    this.onTypingChanged,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _isTyping) {
      setState(() {
        _isTyping = hasText;
      });
      widget.onTypingChanged?.call(hasText);
    }
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _controller.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
      child: SafeArea(
        child: Row(
          children: [
            // 이미지 첨부 버튼
            IconButton(
              icon: const Icon(Icons.image_outlined),
              color: AppColors.textSecondary,
              onPressed: widget.onImagePick,
              tooltip: '이미지 전송',
            ),
            // 음성 녹음 버튼
            IconButton(
              icon: const Icon(Icons.mic_outlined),
              color: AppColors.textSecondary,
              onPressed: widget.onVoiceRecord,
              tooltip: '음성 메시지',
            ),
            const SizedBox(width: 8),
            // 텍스트 입력 필드
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? AppColors.primary
                        : AppColors.borderColor,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: AppTextStyles.chatMessage,
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요...',
                    hintStyle: AppTextStyles.chatMessage.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 전송 버튼
            Container(
              decoration: BoxDecoration(
                gradient: _isTyping
                    ? AppColors.primaryGradient
                    : null,
                color: _isTyping ? null : AppColors.borderColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded),
                color: Colors.white,
                onPressed: _isTyping ? _sendMessage : null,
                tooltip: '전송',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
