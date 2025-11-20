import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/verification_provider.dart';

class DocumentVerificationScreen extends StatefulWidget {
  final VerificationType type;

  const DocumentVerificationScreen({
    super.key,
    required this.type,
  });

  @override
  State<DocumentVerificationScreen> createState() =>
      _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState
    extends State<DocumentVerificationScreen> {
  File? _selectedDocument;
  bool _isSubmitting = false;
  final _additionalInfoController = TextEditingController();

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

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
        const SnackBar(content: Text('서류 사진을 선택해주세요')),
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
        widget.type,
      );

      if (documentUrl == null) {
        throw Exception('파일 업로드 실패');
      }

      // 인증 요청 제출
      final success = await verificationProvider.submitVerification(
        userId: authProvider.user!.uid,
        type: widget.type,
        documentUrl: documentUrl,
        metadata: {
          'additionalInfo': _additionalInfoController.text,
        },
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '${VerificationProvider.getVerificationName(widget.type)} 요청이 제출되었습니다')),
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

  String _getDocumentTypeDescription() {
    switch (widget.type) {
      case VerificationType.criminalRecord:
        return '• 최근 3개월 이내 발급된 서류\n'
            '• 정부24 또는 경찰청 발급 서류\n'
            '• 전체 내용이 선명하게 보여야 함';
      case VerificationType.schoolViolence:
        return '• 학교폭력대책자치위원회 확인서\n'
            '• 최근 1년 이내 발급된 서류\n'
            '• 전체 내용이 선명하게 보여야 함';
      case VerificationType.occupation:
        return '• 재직증명서 또는 사업자등록증\n'
            '• 최근 3개월 이내 발급된 서류\n'
            '• 개인정보는 가려도 됨 (이름, 주소 등)';
      case VerificationType.education:
        return '• 졸업증명서 또는 재학증명서\n'
            '• 학교명과 학과가 명확히 보여야 함\n'
            '• 개인정보는 가려도 됨 (주소 등)';
      default:
        return '';
    }
  }

  String _getAdditionalInfoLabel() {
    switch (widget.type) {
      case VerificationType.occupation:
        return '직업/직장명 (선택사항)';
      case VerificationType.education:
        return '학교명/학과 (선택사항)';
      default:
        return '추가 정보 (선택사항)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(VerificationProvider.getVerificationName(widget.type)),
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
                          '제출 안내',
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
                          widget.type),
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getDocumentTypeDescription() +
                          '\n• 승인 시 +${VerificationProvider.getVerificationPoints(widget.type)} 신뢰점수',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 보안 안내
              if (widget.type == VerificationType.criminalRecord ||
                  widget.type == VerificationType.schoolViolence)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
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
                          '제출된 서류는 암호화되어 안전하게 보관되며, 본인 확인 용도로만 사용됩니다.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.amber[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                              Icons.description_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '서류 사진을 선택해주세요',
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
                label: const Text('서류 사진 선택'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              // 추가 정보 입력
              TextField(
                controller: _additionalInfoController,
                decoration: InputDecoration(
                  labelText: _getAdditionalInfoLabel(),
                  hintText: '예: 홍길동 대학교, 컴퓨터공학과',
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
                maxLength: 100,
                enabled: !_isSubmitting,
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
