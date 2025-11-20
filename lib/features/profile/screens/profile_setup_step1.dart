import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../providers/profile_provider.dart';

class ProfileSetupStep1 extends StatefulWidget {
  final VoidCallback onNext;

  const ProfileSetupStep1({
    super.key,
    required this.onNext,
  });

  @override
  State<ProfileSetupStep1> createState() => _ProfileSetupStep1State();
}

class _ProfileSetupStep1State extends State<ProfileSetupStep1> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedBirthdate;
  String? _selectedGender;
  String? _selectedRegion;

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
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthdate() async {
    final now = DateTime.now();
    final minDate = DateTime(now.year - 99);
    final maxDate = DateTime(now.year - 19); // 만 19세 이상

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: minDate,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthdate = picked;
      });
    }
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthdate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('생년월일을 선택해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('성별을 선택해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedRegion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('지역을 선택해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 데이터 저장
    context.read<ProfileProvider>().saveStep1(
          name: _nameController.text.trim(),
          birthdate: _selectedBirthdate!,
          gender: _selectedGender!,
          region: _selectedRegion!,
        );

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '기본 정보를\n입력해주세요',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 8),
            Text(
              '프로필 작성의 첫 단계입니다',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // 이름
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '이름',
                hintText: '실명을 입력해주세요',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이름을 입력해주세요';
                }
                if (value.length < 2) {
                  return '이름은 2자 이상이어야 합니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 생년월일
            GestureDetector(
              onTap: _selectBirthdate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cake_outlined, color: AppColors.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '생년월일',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedBirthdate != null
                                ? '${_selectedBirthdate!.year}년 ${_selectedBirthdate!.month}월 ${_selectedBirthdate!.day}일'
                                : '생년월일을 선택해주세요',
                            style: _selectedBirthdate != null
                                ? AppTextStyles.bodyMedium
                                : AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textHint,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 성별
            Text(
              '성별',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildGenderButton('남성', Icons.male),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGenderButton('여성', Icons.female),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 지역
            DropdownButtonFormField<String>(
              value: _selectedRegion,
              decoration: InputDecoration(
                labelText: '지역',
                hintText: '거주 지역을 선택해주세요',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _regions.map((region) {
                return DropdownMenuItem(
                  value: region,
                  child: Text(region),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRegion = value;
                });
              },
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
      ),
    );
  }

  Widget _buildGenderButton(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              gender,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
