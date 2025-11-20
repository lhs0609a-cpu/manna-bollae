import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/profile_provider.dart';

class ProfileSetupStep3 extends StatefulWidget {
  final VoidCallback onNext;

  const ProfileSetupStep3({
    super.key,
    required this.onNext,
  });

  @override
  State<ProfileSetupStep3> createState() => _ProfileSetupStep3State();
}

class _ProfileSetupStep3State extends State<ProfileSetupStep3> {
  final List<String> _selectedHobbies = [];

  final List<String> _hobbiesList = [
    '운동',
    '요리',
    '여행',
    '독서',
    '영화',
    '음악',
    '게임',
    '사진',
    '그림',
    '춤',
    '노래',
    '악기',
    '등산',
    '캠핑',
    '낚시',
    '자전거',
    '수영',
    '요가',
    '명상',
    '봉사활동',
  ];

  void _toggleHobby(String hobby) {
    setState(() {
      if (_selectedHobbies.contains(hobby)) {
        _selectedHobbies.remove(hobby);
      } else {
        if (_selectedHobbies.length < AppConstants.maxHobbies) {
          _selectedHobbies.add(hobby);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('최대 ${AppConstants.maxHobbies}개까지 선택 가능합니다'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    });
  }

  void _handleNext() {
    if (_selectedHobbies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('최소 1개 이상의 취미를 선택해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<ProfileProvider>().saveStep3(_selectedHobbies);
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
            '취미를\n선택해주세요',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 8),
          Text(
            '최대 ${AppConstants.maxHobbies}개까지 선택 가능 (${_selectedHobbies.length}/${AppConstants.maxHobbies})',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _hobbiesList.map((hobby) {
                  final isSelected = _selectedHobbies.contains(hobby);
                  return GestureDetector(
                    onTap: () => _toggleHobby(hobby),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        hobby,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),

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
