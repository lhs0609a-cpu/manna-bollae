import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/profile_provider.dart';

class ProfileSetupStep4 extends StatefulWidget {
  final VoidCallback onNext;

  const ProfileSetupStep4({
    super.key,
    required this.onNext,
  });

  @override
  State<ProfileSetupStep4> createState() => _ProfileSetupStep4State();
}

class _ProfileSetupStep4State extends State<ProfileSetupStep4> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('한 줄 소개를 작성해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_textController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('10자 이상 작성해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<ProfileProvider>().saveStep4(_textController.text.trim());
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '한 줄로\n자신을 소개해주세요',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 8),
          Text(
            '첫인상이 될 수 있어요',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: _textController,
              maxLength: AppConstants.oneLinerMaxLength,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '예: 긍정적이고 밝은 성격입니다. 함께 맛집 탐방하실 분 찾아요!',
                border: InputBorder.none,
                counterText: '',
              ),
              style: AppTextStyles.bodyLarge,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10자 이상 작성해주세요',
                style: AppTextStyles.caption,
              ),
              Text(
                '${_textController.text.length}/${AppConstants.oneLinerMaxLength}',
                style: AppTextStyles.caption.copyWith(
                  color: _textController.text.length >= 10
                      ? AppColors.primary
                      : AppColors.textHint,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 예시
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '작성 팁',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• 자신의 성격이나 취미를 간단히 소개해보세요\n'
                  '• 함께 하고 싶은 활동을 언급해보세요\n'
                  '• 긍정적이고 솔직한 표현이 좋아요',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          const Spacer(),

          // 다음 버튼
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text('다음', style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }
}
