import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/verification_provider.dart';
import 'photo_verification_screen.dart';
import 'video_verification_screen.dart';
import 'id_card_verification_screen.dart';
import 'document_verification_screen.dart';

class VerificationManageScreen extends StatefulWidget {
  const VerificationManageScreen({super.key});

  @override
  State<VerificationManageScreen> createState() =>
      _VerificationManageScreenState();
}

class _VerificationManageScreenState extends State<VerificationManageScreen> {
  @override
  void initState() {
    super.initState();
    _loadVerifications();
  }

  Future<void> _loadVerifications() async {
    final authProvider = context.read<AuthProvider>();
    final verificationProvider = context.read<VerificationProvider>();

    if (authProvider.user != null) {
      await verificationProvider.loadVerificationRequests(authProvider.user!.uid);
    }
  }

  Future<void> _navigateToVerification(VerificationType type) async {
    Widget screen;

    switch (type) {
      case VerificationType.photo:
        screen = const PhotoVerificationScreen();
        break;
      case VerificationType.video:
        screen = const VideoVerificationScreen();
        break;
      case VerificationType.idCard:
        screen = const IdCardVerificationScreen();
        break;
      case VerificationType.criminalRecord:
      case VerificationType.schoolViolence:
      case VerificationType.occupation:
      case VerificationType.education:
        screen = DocumentVerificationScreen(type: type);
        break;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    if (result == true && mounted) {
      await _loadVerifications();
    }
  }

  Color _getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return Colors.orange;
      case VerificationStatus.approved:
        return Colors.green;
      case VerificationStatus.rejected:
        return AppColors.error;
    }
  }

  String _getStatusText(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.pending:
        return '검토 중';
      case VerificationStatus.approved:
        return '승인됨';
      case VerificationStatus.rejected:
        return '거절됨';
    }
  }

  IconData _getTypeIcon(VerificationType type) {
    switch (type) {
      case VerificationType.photo:
        return Icons.photo_camera;
      case VerificationType.video:
        return Icons.videocam;
      case VerificationType.idCard:
        return Icons.credit_card;
      case VerificationType.criminalRecord:
        return Icons.policy;
      case VerificationType.schoolViolence:
        return Icons.school;
      case VerificationType.occupation:
        return Icons.work;
      case VerificationType.education:
        return Icons.school_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final verificationProvider = context.watch<VerificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('인증 관리'),
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
      body: verificationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadVerifications,
              child: ListView(
                children: [
                  // 안내 배너
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_user,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '신뢰도를 높이세요!',
                              style: AppTextStyles.h4.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '다양한 인증을 완료하여 신뢰 점수를 높이고\n더 많은 사람들과 만나보세요.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 인증 항목 리스트
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      '인증 항목',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...VerificationType.values.map((type) {
                    final status = verificationProvider.getVerificationStatus(type);
                    final request = verificationProvider.getVerificationRequest(type);
                    final points = VerificationProvider.getVerificationPoints(type);

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: status == VerificationStatus.approved
                              ? Colors.green.withOpacity(0.3)
                              : AppColors.dividerColor,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: status == VerificationStatus.approved
                                ? Colors.green.withOpacity(0.1)
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getTypeIcon(type),
                            color: status == VerificationStatus.approved
                                ? Colors.green
                                : AppColors.primary,
                          ),
                        ),
                        title: Text(
                          VerificationProvider.getVerificationName(type),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            if (status != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getStatusText(status),
                                  style: AppTextStyles.caption.copyWith(
                                    color: _getStatusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Text(
                                '+$points 신뢰점수',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            if (status == VerificationStatus.rejected &&
                                request?.rejectReason != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                '사유: ${request!.rejectReason}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: status == VerificationStatus.approved
                            ? Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : Icon(
                                Icons.chevron_right,
                                color: AppColors.textSecondary,
                              ),
                        onTap: status == VerificationStatus.approved ||
                                status == VerificationStatus.pending
                            ? null
                            : () => _navigateToVerification(type),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
