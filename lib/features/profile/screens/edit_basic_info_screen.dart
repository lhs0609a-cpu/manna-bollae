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

class EditBasicInfoScreen extends StatefulWidget {
  final UserModel currentUser;

  const EditBasicInfoScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<EditBasicInfoScreen> createState() => _EditBasicInfoScreenState();
}

class _EditBasicInfoScreenState extends State<EditBasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  DateTime? _selectedBirthDate;
  String? _selectedRegion;

  // 지역 목록
  final List<String> _regions = [
    '서울',
    '경기',
    '인천',
    '부산',
    '대구',
    '대전',
    '광주',
    '울산',
    '세종',
    '강원',
    '충북',
    '충남',
    '전북',
    '전남',
    '경북',
    '경남',
    '제주',
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.currentUser.profile.basicInfo.name);
    _selectedBirthDate = widget.currentUser.profile.basicInfo.birthDate;
    _selectedRegion = widget.currentUser.profile.basicInfo.region;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final selectedDate = await DialogHelper.showDatePickerDialog(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 19)),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedBirthDate = selectedDate;
      });
    }
  }

  Future<void> _selectRegion() async {
    final selectedRegion = await DialogHelper.showSelectionDialog<String>(
      context: context,
      title: '지역 선택',
      items: _regions,
      itemBuilder: (region) => region,
      selectedItem: _selectedRegion,
    );

    if (selectedRegion != null) {
      setState(() {
        _selectedRegion = selectedRegion;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('생년월일을 선택해주세요')),
      );
      return;
    }

    if (_selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지역을 선택해주세요')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    if (authProvider.user == null) return;

    DialogHelper.showLoadingDialog(context: context, message: '저장 중...');

    final success = await profileProvider.updateBasicInfo(
      userId: authProvider.user!.uid,
      name: _nameController.text,
      birthdate: _selectedBirthDate,
      region: _selectedRegion,
    );

    if (mounted) {
      DialogHelper.dismissLoadingDialog(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기본 정보가 수정되었습니다')),
        );
        Navigator.pop(context, true);
      } else {
        DialogHelper.showErrorDialog(
          context: context,
          title: '저장 실패',
          message: '기본 정보 수정에 실패했습니다. 다시 시도해주세요.',
        );
      }
    }
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('기본 정보 수정'),
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
            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber[700],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '성별은 변경할 수 없습니다. 기타 정보만 수정 가능합니다.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 이름
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '이름',
                hintText: '이름을 입력하세요',
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
              ),
              validator: Validators.validateName,
            ),
            const SizedBox(height: 16),

            // 생년월일
            InkWell(
              onTap: _selectBirthDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '생년월일',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.dividerColor),
                  ),
                  suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
                ),
                child: Text(
                  _selectedBirthDate != null
                      ? '${_selectedBirthDate!.year}년 ${_selectedBirthDate!.month}월 ${_selectedBirthDate!.day}일 (${_calculateAge(_selectedBirthDate!)}세)'
                      : '생년월일을 선택하세요',
                  style: _selectedBirthDate != null
                      ? AppTextStyles.bodyMedium
                      : AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 성별 (읽기 전용)
            InputDecorator(
              decoration: InputDecoration(
                labelText: '성별',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              child: Row(
                children: [
                  Text(
                    widget.currentUser.profile.basicInfo.gender,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 지역
            InkWell(
              onTap: _selectRegion,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '지역',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.dividerColor),
                  ),
                  suffixIcon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                ),
                child: Text(
                  _selectedRegion ?? '지역을 선택하세요',
                  style: _selectedRegion != null
                      ? AppTextStyles.bodyMedium
                      : AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                ),
              ),
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
