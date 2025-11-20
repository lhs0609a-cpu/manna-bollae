import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class EditPersonalityScreen extends StatefulWidget {
  final UserModel currentUser;

  const EditPersonalityScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<EditPersonalityScreen> createState() => _EditPersonalityScreenState();
}

class _EditPersonalityScreenState extends State<EditPersonalityScreen> {
  String? _selectedMbti;
  String? _selectedBloodType;
  bool _smoking = false;
  String? _selectedDrinking;
  String? _selectedReligion;

  // MBTI 목록
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

  // 혈액형 목록
  final List<String> _bloodTypes = ['A', 'B', 'O', 'AB'];

  // 음주 목록
  final List<String> _drinkingList = ['안마심', '가끔', '자주', '매일'];

  // 종교 목록
  final List<String> _religionList = ['무교', '기독교', '천주교', '불교', '기타'];

  @override
  void initState() {
    super.initState();
    _selectedMbti = widget.currentUser.profile.basicInfo.mbti;
    _selectedBloodType = widget.currentUser.profile.basicInfo.bloodType;
    _smoking = widget.currentUser.profile.basicInfo.smoking;
    _selectedDrinking = widget.currentUser.profile.basicInfo.drinking;
    _selectedReligion = widget.currentUser.profile.basicInfo.religion;
  }

  Future<void> _saveChanges() async {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    if (authProvider.user == null) return;

    DialogHelper.showLoadingDialog(context: context, message: '저장 중...');

    final success = await profileProvider.updatePersonalityAndHabits(
      userId: authProvider.user!.uid,
      mbti: _selectedMbti,
      bloodType: _selectedBloodType,
      smoking: _smoking,
      drinking: _selectedDrinking,
      religion: _selectedReligion,
    );

    if (mounted) {
      DialogHelper.dismissLoadingDialog(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('성격 & 습관 정보가 수정되었습니다')),
        );
        Navigator.pop(context, true);
      } else {
        DialogHelper.showErrorDialog(
          context: context,
          title: '저장 실패',
          message: '정보 수정에 실패했습니다. 다시 시도해주세요.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('성격 & 습관 수정'),
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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // MBTI
          const Text(
            'MBTI',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _mbtiList.map((mbti) {
              final isSelected = _selectedMbti == mbti;
              return ChoiceChip(
                label: Text(mbti),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedMbti = selected ? mbti : null;
                  });
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey[200],
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 혈액형
          const Text(
            '혈액형',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _bloodTypes.map((type) {
              final isSelected = _selectedBloodType == type;
              return ChoiceChip(
                label: Text('$type형'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedBloodType = selected ? type : null;
                  });
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey[200],
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 흡연
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.dividerColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '흡연',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _smoking ? '흡연' : '비흡연',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _smoking,
                  onChanged: (value) {
                    setState(() {
                      _smoking = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 음주
          const Text(
            '음주',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _drinkingList.map((drinking) {
              final isSelected = _selectedDrinking == drinking;
              return ChoiceChip(
                label: Text(drinking),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedDrinking = selected ? drinking : null;
                  });
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey[200],
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 종교
          const Text(
            '종교',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _religionList.map((religion) {
              final isSelected = _selectedReligion == religion;
              return ChoiceChip(
                label: Text(religion),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedReligion = selected ? religion : null;
                  });
                },
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey[200],
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // 저장 버튼
          PrimaryButton(
            label: '저장',
            onPressed: _saveChanges,
          ),
        ],
      ),
    );
  }
}
