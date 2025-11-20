import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../providers/profile_provider.dart';

class ProfileSetupStep5 extends StatefulWidget {
  final VoidCallback onNext;

  const ProfileSetupStep5({
    super.key,
    required this.onNext,
  });

  @override
  State<ProfileSetupStep5> createState() => _ProfileSetupStep5State();
}

class _ProfileSetupStep5State extends State<ProfileSetupStep5> {
  String? _selectedHeightRange;

  final List<String> _heightRanges = [
    '150cm 미만',
    '150-154cm',
    '155-159cm',
    '160-164cm',
    '165-169cm',
    '170-174cm',
    '175-179cm',
    '180-184cm',
    '185-189cm',
    '190cm 이상',
  ];

  void _handleNext() {
    if (_selectedHeightRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('키 범위를 선택해주세요'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    context.read<ProfileProvider>().saveStep5(_selectedHeightRange!);
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
            '마지막으로\n키를 알려주세요',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 8),
          Text(
            '정확한 키는 친밀도가 쌓이면 공개돼요',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          Expanded(
            child: ListView.builder(
              itemCount: _heightRanges.length,
              itemBuilder: (context, index) {
                final heightRange = _heightRanges[index];
                final isSelected = _selectedHeightRange == heightRange;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedHeightRange = heightRange;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.height,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              heightRange,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                                fontWeight:
                                    isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 완료 버튼
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              return SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: profileProvider.isLoading ? null : _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: profileProvider.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('완료', style: AppTextStyles.button),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
