import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/auth_service.dart';

// 데모 사용자 정보 클래스
class DemoUser {
  final String uid;
  final String email;

  DemoUser({required this.uid, required this.email});
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  DemoUser? _demoUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user {
    // 데모 모드에서는 가짜 User 반환
    if (_demoUser != null) {
      return null; // User 객체를 생성할 수 없으므로 null 반환
    }
    return _user;
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null || _demoUser != null;

  // 데모 모드에서 사용할 uid 반환
  String? get uid {
    if (_demoUser != null) return _demoUser!.uid;
    return _user?.uid;
  }

  // 데모 모드에서 사용할 email 반환
  String? get email {
    if (_demoUser != null) return _demoUser!.email;
    return _user?.email;
  }

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    // 데모 모드 로그인 상태 확인
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('demo_logged_in') ?? false;
    final userEmail = prefs.getString('demo_user_email');
    final userUid = prefs.getString('demo_user_uid');

    if (isLoggedIn && userEmail != null && userUid != null) {
      _demoUser = DemoUser(uid: userUid, email: userEmail);
      notifyListeners();
      print('📱 AuthProvider: 데모 로그인 상태 복원 - $userEmail');
    }

    // Auth 상태 변화 감지
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // 이메일/비밀번호 회원가입
  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signUpWithEmail(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      // 데모 모드 성공 처리
      if (e.toString().contains('DEMO_MODE_SUCCESS')) {
        // SharedPreferences에서 사용자 정보 가져오기
        final prefs = await SharedPreferences.getInstance();
        final userUid = prefs.getString('demo_user_uid');
        if (userUid != null) {
          _demoUser = DemoUser(uid: userUid, email: email);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _errorMessage = '알 수 없는 오류가 발생했습니다.';
      notifyListeners();
      return false;
    }
  }

  // 이메일/비밀번호 로그인
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      // 데모 모드 성공 처리
      if (e.toString().contains('DEMO_MODE_SUCCESS')) {
        // SharedPreferences에서 사용자 정보 가져오기
        final prefs = await SharedPreferences.getInstance();
        final userUid = prefs.getString('demo_user_uid');
        if (userUid != null) {
          _demoUser = DemoUser(uid: userUid, email: email);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      _errorMessage = '알 수 없는 오류가 발생했습니다.';
      notifyListeners();
      return false;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _demoUser = null;
    notifyListeners();
  }

  // 비밀번호 재설정
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.sendPasswordResetEmail(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = '비밀번호 재설정 이메일 전송에 실패했습니다.';
      notifyListeners();
      return false;
    }
  }

  // 프로필 완성도 확인
  Future<bool> isProfileComplete() async {
    if (!isAuthenticated) return false;
    final userId = uid;
    if (userId == null) return false;
    return await _authService.isProfileComplete(userId);
  }

  // Firebase 에러 메시지 변환
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return '유효하지 않은 이메일 형식입니다.';
      case 'operation-not-allowed':
        return '이메일/비밀번호 계정이 비활성화되어 있습니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다. 6자 이상 입력해주세요.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'user-not-found':
        return '존재하지 않는 계정입니다.';
      case 'wrong-password':
        return '잘못된 비밀번호입니다.';
      case 'too-many-requests':
        return '너무 많은 시도가 있었습니다. 잠시 후 다시 시도해주세요.';
      default:
        return '로그인에 실패했습니다. 다시 시도해주세요.';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
