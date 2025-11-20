import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/safety_provider.dart';

class ReportScreen extends StatefulWidget {
  final UserModel reportedUser;

  const ReportScreen({
    super.key,
    required this.reportedUser,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  ReportReason? _selectedReason;
  final TextEditingController _descriptionController = TextEditingController();
  bool _alsoBlock = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 신고'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 경고 메시지
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '신고 전 확인해주세요',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '허위 신고 시 계정이 제한될 수 있습니다',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 신고 대상
            Text(
              '신고 대상',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.borderColor,
                    child: Text(
                      widget.reportedUser.profile.basicInfo.name[0],
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.reportedUser.profile.basicInfo.name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.reportedUser.profile.basicInfo.region,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 신고 사유 선택
            Text(
              '신고 사유',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...ReportReason.values.map((reason) {
              return _buildReasonTile(reason);
            }).toList(),

            const SizedBox(height: 24),

            // 상세 설명
            Text(
              '상세 설명 (선택)',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: '신고 사유에 대한 구체적인 설명을 입력해주세요',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // 차단 옵션
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: CheckboxListTile(
                value: _alsoBlock,
                onChanged: (value) {
                  setState(() {
                    _alsoBlock = value ?? false;
                  });
                },
                title: Text(
                  '이 사용자를 차단하기',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '차단하면 서로 프로필을 볼 수 없고 매칭되지 않습니다',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                activeColor: AppColors.error,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),

            const SizedBox(height: 24),

            // 신고 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedReason != null ? _handleReport : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: AppColors.borderColor,
                ),
                child: Text(
                  '신고하기',
                  style: AppTextStyles.buttonRegular.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 취소 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.borderColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '취소',
                  style: AppTextStyles.buttonRegular.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonTile(ReportReason reason) {
    final isSelected = _selectedReason == reason;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.error.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.error : AppColors.borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<ReportReason>(
        value: reason,
        groupValue: _selectedReason,
        onChanged: (value) {
          setState(() {
            _selectedReason = value;
          });
        },
        title: Text(
          SafetyProvider.getReasonName(reason),
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.error : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          SafetyProvider.getReasonDescription(reason),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        activeColor: AppColors.error,
      ),
    );
  }

  Future<void> _handleReport() async {
    if (_selectedReason == null) return;

    final authProvider = context.read<AuthProvider>();
    final safetyProvider = context.read<SafetyProvider>();

    if (authProvider.user == null) return;

    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('신고하시겠습니까?'),
        content: Text(
          _alsoBlock
              ? '${widget.reportedUser.profile.basicInfo.name}님을 신고하고 차단합니다.\n\n'
                  '신고 내용은 관리자가 검토하며, 허위 신고 시 계정이 제한될 수 있습니다.'
              : '${widget.reportedUser.profile.basicInfo.name}님을 신고합니다.\n\n'
                  '신고 내용은 관리자가 검토하며, 허위 신고 시 계정이 제한될 수 있습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('신고'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // 로딩 표시
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      bool success;
      if (_alsoBlock) {
        // 신고 및 차단
        success = await safetyProvider.reportAndBlock(
          reporterId: authProvider.user!.uid,
          reportedUserId: widget.reportedUser.id,
          reason: _selectedReason!,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
      } else {
        // 신고만
        success = await safetyProvider.reportUser(
          reporterId: authProvider.user!.uid,
          reportedUserId: widget.reportedUser.id,
          reason: _selectedReason!,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
      }

      // 로딩 다이얼로그 닫기
      if (mounted) Navigator.pop(context);

      if (success && mounted) {
        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_alsoBlock ? '신고 및 차단이 완료되었습니다' : '신고가 접수되었습니다'),
            backgroundColor: AppColors.success,
          ),
        );

        // 화면 닫기
        Navigator.pop(context, true);
      } else if (safetyProvider.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(safetyProvider.error!),
            backgroundColor: AppColors.error,
          ),
        );
        safetyProvider.clearError();
      }
    }
  }
}
