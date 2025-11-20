import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'profile_setup_step1.dart';
import 'profile_setup_step2.dart';
import 'profile_setup_step3.dart';
import 'profile_setup_step4.dart';
import 'profile_setup_step5.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeSetup();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeSetup() async {
    final profileProvider = context.read<ProfileProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.user == null) return;

    final success = await profileProvider.saveProfileToFirestore(
      authProvider.user!.uid,
    );

    if (success && mounted) {
      // 아바타 생성 화면으로 이동
      Navigator.of(context).pushReplacementNamed('/avatar-creation');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('프로필 저장에 실패했습니다. 다시 시도해주세요.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: _previousStep,
              )
            : null,
        title: Text(
          '프로필 설정 ${_currentStep + 1}/5',
          style: AppTextStyles.h5,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 진행률 표시
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              return LinearProgressIndicator(
                value: profileProvider.getProgress(_currentStep + 1),
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 4,
              );
            },
          ),

          // 페이지 뷰
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ProfileSetupStep1(onNext: _nextStep),
                ProfileSetupStep2(onNext: _nextStep),
                ProfileSetupStep3(onNext: _nextStep),
                ProfileSetupStep4(onNext: _nextStep),
                ProfileSetupStep5(onNext: _nextStep),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
