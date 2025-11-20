import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/verification_provider.dart';

class IdCardVerificationScreen extends StatefulWidget {
  const IdCardVerificationScreen({super.key});

  @override
  State<IdCardVerificationScreen> createState() =>
      _IdCardVerificationScreenState();
}

class _IdCardVerificationScreenState extends State<IdCardVerificationScreen> {
  File? _selectedDocument;
  bool _isSubmitting = false;
  bool _agreeToPrivacy = false;

  Future<void> _pickDocument() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedDocument = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('파일을 선택하는데 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _submitVerification() async {
    if (_selectedDocument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신분증 사진을 선택해주세요')),
      );
      return;
    }

    if (!_agreeToPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('개인정보 처리 방침에 동의해주세요')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final verificationProvider = context.read<VerificationProvider>();

    if (authProvider.user == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 파일 업로드
      final documentUrl = await verificationProvider.uploadFile(
        _selectedDocument!.path,
        VerificationType.idCard,
      );

      if (documentUrl == null) {
        throw Exception('파일 업로드 실패');
      }

      // 인증 요청 제출
      final success = await verificationProvider.submitVerification(
        userId: authProvider.user!.uid,
        type: VerificationType.idCard,
        documentUrl: documentUrl,
        metadata: {
          'agreeToPrivacy': true,
        },
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('신분증 인증 요청이 제출되었습니다')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(verificationProvider.error ?? '인증 요청 제출에 실패했습니다')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('신분증 인증'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 안내 카드
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '신분증 인증 안내',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      VerificationProvider.getVerificationDescription(
                          VerificationType.idCard),
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• 주민등록번호 뒷자리는 가려주세요\n'
                      '• 신분증 전체가 선명하게 보이도록 촬영해주세요\n'
                      '• 반사광이 없도록 주의해주세요\n'
                      '• 승인 시 +${VerificationProvider.getVerificationPoints(VerificationType.idCard)} 신뢰점수',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 보안 안내
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
                      Icons.security,
                      color: Colors.amber[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '제출된 신분증은 암호화되어 안전하게 보관되며, 본인 확인 용도로만 사용됩니다.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.amber[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // 문서 미리보기
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.dividerColor,
                    width: 2,
                  ),
                ),
                child: _selectedDocument != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _selectedDocument!,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.credit_card,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '신분증 사진을 선택해주세요',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              // 파일 선택 버튼
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _pickDocument,
                icon: const Icon(Icons.upload_file),
                label: const Text('신분증 사진 선택'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              // 개인정보 동의
              CheckboxListTile(
                value: _agreeToPrivacy,
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        setState(() {
                          _agreeToPrivacy = value ?? false;
                        });
                      },
                title: Text(
                  '개인정보 수집 및 이용에 동의합니다',
                  style: AppTextStyles.bodyMedium,
                ),
                subtitle: Text(
                  '신분증 정보는 본인 확인 용도로만 사용되며, 안전하게 보관됩니다.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              // 제출 버튼
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '인증 요청 제출',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
