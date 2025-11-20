import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart' as app_auth;

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _reasonController = TextEditingController();

  bool _obscurePassword = true;
  bool _isDeleting = false;
  String? _selectedReason;

  final List<String> _deleteReasons = [
    '더 이상 사용하지 않아요',
    '원하는 사람을 만났어요',
    '다른 앱을 사용할 거예요',
    '개인정보가 걱정돼요',
    '앱 사용이 불편해요',
    '기타',
  ];

  @override
  void dispose() {
    _passwordController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 최종 확인
    final confirmed = await DialogHelper.showConfirmDialog(
      context: context,
      title: '정말 탈퇴하시겠습니까?',
      message: '탈퇴 시 모든 데이터가 삭제되며 복구할 수 없습니다.\n정말로 계속하시겠습니까?',
      confirmText: '탈퇴',
      cancelText: '취소',
      isDanger: true,
    );

    if (!confirmed) return;

    final authProvider = context.read<app_auth.AuthProvider>();
    final user = authProvider.user;

    if (user == null || user.email == null) {
      DialogHelper.showErrorDialog(
        context: context,
        title: '오류',
        message: '사용자 정보를 찾을 수 없습니다.',
      );
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      // 비밀번호로 재인증
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _passwordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // 탈퇴 사유 저장 (선택사항)
      if (_selectedReason != null) {
        await FirebaseFirestore.instance.collection('delete_feedback').add({
          'userId': user.uid,
          'reason': _selectedReason,
          'details': _reasonController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Firestore 사용자 데이터 삭제
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

      // 관련 컬렉션 삭제 (설정, 알림 등)
      final batch = FirebaseFirestore.instance.batch();

      // 사용자 설정 삭제
      final settingsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('settings');
      final settingsDocs = await settingsRef.get();
      for (var doc in settingsDocs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Firebase Auth 계정 삭제
      await user.delete();

      if (mounted) {
        // 로그인 화면으로 이동
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('계정이 삭제되었습니다. 그동안 이용해주셔서 감사합니다.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = '비밀번호가 올바르지 않습니다.';
          break;
        case 'requires-recent-login':
          errorMessage = '보안을 위해 다시 로그인해주세요.';
          break;
        default:
          errorMessage = '계정 삭제에 실패했습니다: ${e.message}';
      }

      if (mounted) {
        DialogHelper.showErrorDialog(
          context: context,
          title: '계정 삭제 실패',
          message: errorMessage,
        );
      }
    } catch (e) {
      if (mounted) {
        DialogHelper.showErrorDialog(
          context: context,
          title: '오류',
          message: '알 수 없는 오류가 발생했습니다: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원 탈퇴'),
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
            // 경고 메시지
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: AppColors.error,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '회원 탈퇴 시 유의사항',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• 모든 개인정보가 즉시 삭제됩니다\n'
                    '• 매칭 기록, 채팅 내역이 삭제됩니다\n'
                    '• 신뢰 점수, 하트 온도가 초기화됩니다\n'
                    '• 보유 중인 아이템, 코인이 삭제됩니다\n'
                    '• 구독 중인 플랜이 즉시 취소됩니다\n'
                    '• 삭제된 데이터는 복구할 수 없습니다',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 탈퇴 사유 선택
            const Text(
              '탈퇴 사유를 알려주세요 (선택사항)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._deleteReasons.map((reason) {
              return RadioListTile<String>(
                title: Text(reason),
                value: reason,
                groupValue: _selectedReason,
                onChanged: _isDeleting
                    ? null
                    : (value) {
                        setState(() {
                          _selectedReason = value;
                        });
                      },
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
            const SizedBox(height: 16),

            // 추가 의견
            TextFormField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: '추가 의견 (선택사항)',
                hintText: '개선이 필요한 점을 알려주세요',
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
              maxLength: 500,
              maxLines: 3,
              enabled: !_isDeleting,
            ),
            const SizedBox(height: 32),

            // 비밀번호 확인
            const Text(
              '본인 확인을 위해 비밀번호를 입력해주세요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: '비밀번호',
                hintText: '비밀번호를 입력하세요',
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
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) => Validators.validateRequired(value, '비밀번호'),
              enabled: !_isDeleting,
            ),
            const SizedBox(height: 32),

            // 탈퇴 버튼
            DangerButton(
              label: '회원 탈퇴',
              onPressed: _deleteAccount,
              isLoading: _isDeleting,
              icon: Icons.delete_forever,
            ),
          ],
        ),
      ),
    );
  }
}
