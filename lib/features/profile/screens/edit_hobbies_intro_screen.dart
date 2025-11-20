import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class EditHobbiesIntroScreen extends StatefulWidget {
  final UserModel currentUser;

  const EditHobbiesIntroScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<EditHobbiesIntroScreen> createState() =>
      _EditHobbiesIntroScreenState();
}

class _EditHobbiesIntroScreenState extends State<EditHobbiesIntroScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _oneLinerController;
  List<String> _selectedHobbies = [];

  // 취미 목록
  final List<String> _allHobbies = [
    '운동',
    '음악감상',
    '영화감상',
    '독서',
    '요리',
    '여행',
    '사진',
    '게임',
    '등산',
    '캠핑',
    '낚시',
    '자전거',
    '드라이브',
    '맛집탐방',
    '카페투어',
    '쇼핑',
    '공연관람',
    '전시회',
    '미술',
    '악기연주',
    '노래방',
    '춤',
    '요가',
    '명상',
    '반려동물',
  ];

  @override
  void initState() {
    super.initState();
    _oneLinerController = TextEditingController(
      text: widget.currentUser.profile.basicInfo.oneLiner,
    );
    _selectedHobbies = List.from(widget.currentUser.profile.lifestyle.hobbies);
  }

  @override
  void dispose() {
    _oneLinerController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedHobbies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 1개 이상의 취미를 선택해주세요')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    if (authProvider.user == null) return;

    DialogHelper.showLoadingDialog(context: context, message: '저장 중...');

    // 취미 업데이트
    final hobbiesSuccess = await profileProvider.updateHobbies(
      userId: authProvider.user!.uid,
      hobbies: _selectedHobbies,
    );

    // 한 줄 소개 업데이트
    final oneLinerSuccess = await profileProvider.updateOneLiner(
      userId: authProvider.user!.uid,
      oneLiner: _oneLinerController.text,
    );

    if (mounted) {
      DialogHelper.dismissLoadingDialog(context);

      if (hobbiesSuccess && oneLinerSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('취미 & 소개가 수정되었습니다')),
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
        title: const Text('취미 & 소개 수정'),
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // 한 줄 소개
            const Text(
              '한 줄 소개',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '나를 표현할 수 있는 한 줄 소개를 작성해주세요',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _oneLinerController,
              decoration: InputDecoration(
                hintText: '예: 함께 웃을 수 있는 사람을 찾습니다',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                counterText: '',
              ),
              maxLength: 100,
              maxLines: 2,
              validator: Validators.validateOneLiner,
            ),
            const SizedBox(height: 32),

            // 취미
            Row(
              children: [
                const Text(
                  '취미',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedHobbies.length}개 선택',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '최소 1개 이상 선택해주세요 (최대 10개)',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allHobbies.map((hobby) {
                final isSelected = _selectedHobbies.contains(hobby);
                return FilterChip(
                  label: Text(hobby),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (_selectedHobbies.length < 10) {
                          _selectedHobbies.add(hobby);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('최대 10개까지 선택할 수 있습니다')),
                          );
                        }
                      } else {
                        _selectedHobbies.remove(hobby);
                      }
                    });
                  },
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
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
      ),
    );
  }
}
