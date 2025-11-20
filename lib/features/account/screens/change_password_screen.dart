import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart' as app_auth;

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isChanging = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
      _isChanging = true;
    });

    try {
      // 현재 비밀번호로 재인증
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // 새 비밀번호로 변경
      await user.updatePassword(_newPasswordController.text);

      if (mounted) {
        await DialogHelper.showSuccessDialog(
          context: context,
          title: '비밀번호 변경 완료',
          message: '비밀번호가 성공적으로 변경되었습니다.',
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = '현재 비밀번호가 올바르지 않습니다.';
          break;
        case 'weak-password':
          errorMessage = '새 비밀번호가 너무 약합니다.';
          break;
        case 'requires-recent-login':
          errorMessage = '보안을 위해 다시 로그인해주세요.';
          break;
        default:
          errorMessage = '비밀번호 변경에 실패했습니다: ${e.message}';
      }

      if (mounted) {
        DialogHelper.showErrorDialog(
          context: context,
          title: '비밀번호 변경 실패',
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
          _isChanging = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 변경'),
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
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '보안을 위해 정기적으로 비밀번호를 변경해주세요.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 현재 비밀번호
            TextFormField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrentPassword,
              decoration: InputDecoration(
                labelText: '현재 비밀번호',
                hintText: '현재 비밀번호를 입력하세요',
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
                    _obscureCurrentPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
              ),
              validator: (value) => Validators.validateRequired(value, '현재 비밀번호'),
              enabled: !_isChanging,
            ),
            const SizedBox(height: 16),

            // 새 비밀번호
            TextFormField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                labelText: '새 비밀번호',
                hintText: '새 비밀번호를 입력하세요 (8자 이상)',
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
                    _obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
              validator: Validators.validatePassword,
              enabled: !_isChanging,
            ),
            const SizedBox(height: 16),

            // 새 비밀번호 확인
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: '새 비밀번호 확인',
                hintText: '새 비밀번호를 다시 입력하세요',
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
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) => Validators.validatePasswordConfirm(
                value,
                _newPasswordController.text,
              ),
              enabled: !_isChanging,
            ),
            const SizedBox(height: 32),

            // 변경 버튼
            PrimaryButton(
              label: '비밀번호 변경',
              onPressed: _changePassword,
              isLoading: _isChanging,
            ),
          ],
        ),
      ),
    );
  }
}
