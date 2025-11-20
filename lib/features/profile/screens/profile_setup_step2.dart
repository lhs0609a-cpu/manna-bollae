import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../providers/profile_provider.dart';

class ProfileSetupStep2 extends StatefulWidget {
  final VoidCallback onNext;

  const ProfileSetupStep2({
    super.key,
    required this.onNext,
  });

  @override
  State<ProfileSetupStep2> createState() => _ProfileSetupStep2State();
}

class _ProfileSetupStep2State extends State<ProfileSetupStep2> {
  String? _selectedMbti;
  String? _selectedBloodType;
  bool _smoking = false;
  String? _selectedDrinking;
  String? _selectedReligion;
  bool _firstRelationship = false;

  final List<String> _mbtiList = [
    'ISTJ',
    'ISFJ',
    'INFJ',
    'INTJ',
    'ISTP',
    'ISFP',
    'INFP',
    'INTP',
    'ESTP',
    'ESFP',
    'ENFP',
    'ENTP',
    'ESTJ',
    'ESFJ',
    'ENFJ',
    'ENTJ',
  ];

  final List<String> _bloodTypes = ['A', 'B', 'O', 'AB'];
  final List<String> _drinkingOptions = ['전혀 안함', '가끔', '자주', '매일'];
  final List<String> _religions = ['무교', '기독교', '천주교', '불교', '기타'];

  void _handleNext() {
    if (_selectedMbti == null ||
        _selectedBloodType == null ||
        _selectedDrinking == null ||
        _selectedReligion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모든 항목을 선택해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<ProfileProvider>().saveStep2(
          mbti: _selectedMbti!,
          bloodType: _selectedBloodType!,
          smoking: _smoking,
          drinking: _selectedDrinking!,
          religion: _selectedReligion!,
          firstRelationship: _firstRelationship,
        );

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
            '성격과 습관을\n알려주세요',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 8),
          Text(
            '더 잘 맞는 상대를 찾을 수 있어요',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // MBTI
                  Text('MBTI', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _mbtiList.map((mbti) {
                      return _buildChip(
                        mbti,
                        _selectedMbti == mbti,
                        () => setState(() => _selectedMbti = mbti),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 혈액형
                  Text('혈액형', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Row(
                    children: _bloodTypes.map((type) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildChip(
                            type,
                            _selectedBloodType == type,
                            () => setState(() => _selectedBloodType = type),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 흡연
                  Text('흡연', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _smoking,
                    onChanged: (value) => setState(() => _smoking = value),
                    title: Text(_smoking ? '흡연함' : '비흡연'),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(height: 16),

                  // 음주
                  Text('음주', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _drinkingOptions.map((option) {
                      return _buildChip(
                        option,
                        _selectedDrinking == option,
                        () => setState(() => _selectedDrinking = option),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 종교
                  Text('종교', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _religions.map((religion) {
                      return _buildChip(
                        religion,
                        _selectedReligion == religion,
                        () => setState(() => _selectedReligion = religion),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 첫 연애 여부
                  Text('첫 연애', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: _firstRelationship,
                    onChanged: (value) =>
                        setState(() => _firstRelationship = value),
                    title: Text(_firstRelationship ? '첫 연애입니다' : '연애 경험 있음'),
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    activeColor: AppColors.primary,
                  ),
                ],
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

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
