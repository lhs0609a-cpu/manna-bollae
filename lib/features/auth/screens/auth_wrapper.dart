import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../../profile/screens/profile_setup_screen.dart';
import '../../main/screens/main_screen.dart';
import 'login_screen.dart';

/// 인증 상태에 따라 적절한 화면으로 라우팅
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // 로딩 중
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 로그인하지 않음
    if (authProvider.user == null) {
      return const LoginScreen();
    }

    // 로그인했지만 프로필 완성도 확인 필요
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.user!.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Firebase 연결 오류 - 데모 모드로 전환
        if (snapshot.hasError) {
          return _buildDemoModeWarning(context);
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          // 사용자 문서가 없음 (회원가입 직후)
          return const ProfileSetupScreen();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final user = UserModel.fromMap(userData);

        // 프로필 완성도 확인
        if (!_isProfileComplete(user)) {
          return const ProfileSetupScreen();
        }

        // 모든 조건 충족 - 메인 화면으로
        return const MainScreen();
      },
    );
  }

  Widget _buildDemoModeWarning(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              const Text(
                'Firebase 연결 실패',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Firebase 설정이 완료되지 않았습니다.\nUI 테스트를 위해 데모 모드로 실행합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(),
                    ),
                  );
                },
                child: const Text('데모 모드로 계속'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isProfileComplete(UserModel user) {
    final basicInfo = user.profile.basicInfo;

    // 필수 정보 확인
    if (basicInfo.name.isEmpty) return false;
    if (basicInfo.birthDate == null) return false;
    if (basicInfo.gender.isEmpty) return false;
    if (basicInfo.region.isEmpty) return false;
    if (user.profile.oneLiner.isEmpty) return false;

    return true;
  }
}
