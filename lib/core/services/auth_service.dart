import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 데모 모드 플래그 (Firebase가 설정되지 않았으므로 항상 데모 모드)
  bool _isDemoMode = true;
  User? _demoUser;
  final _authStateController = StreamController<User?>.broadcast();

  // 데모 모드 계정 저장소 (간단한 메모리 저장)
  static final Map<String, Map<String, String>> _demoAccounts = {};

  AuthService() {
    _initDemoMode();
  }

  Future<void> _initDemoMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('demo_logged_in') ?? false;
    final userEmail = prefs.getString('demo_user_email');

    if (isLoggedIn && userEmail != null) {
      // 데모 유저 상태 복원
      _authStateController.add(_createDemoUser(userEmail));
      print('📱 데모 모드: 로그인 상태 복원 - $userEmail');
    }
  }

  // 데모 User 객체 생성 (Firebase User는 직접 생성 불가하므로 가짜 객체)
  User? _createDemoUser(String email) {
    // Firebase User를 직접 생성할 수 없으므로 null 반환
    // 대신 AuthProvider에서 이메일 정보를 저장하도록 처리
    return null;
  }

  // 현재 사용자
  User? get currentUser => _demoUser;

  // 사용자 스트림
  Stream<User?> get authStateChanges => _authStateController.stream;

  // 이메일/비밀번호 회원가입
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // SharedPreferences에서 기존 계정 확인
    final existingPassword = prefs.getString('demo_account_$email');
    if (existingPassword != null) {
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message: '이미 사용 중인 이메일입니다.',
      );
    }

    // 계정 정보를 SharedPreferences에 저장
    final uid = 'demo_${email.hashCode}';
    await prefs.setString('demo_account_$email', password);
    await prefs.setString('demo_account_${email}_uid', uid);

    // 메모리에도 저장
    _demoAccounts[email] = {
      'email': email,
      'password': password,
      'uid': uid,
    };

    // 로그인 상태 저장
    await prefs.setBool('demo_logged_in', true);
    await prefs.setString('demo_user_email', email);
    await prefs.setString('demo_user_uid', uid);

    // Auth 상태 업데이트
    _authStateController.add(_createDemoUser(email));

    print('📱 데모 모드: 회원가입 성공 - $email');

    // 데모 모드 성공 신호
    throw Exception('DEMO_MODE_SUCCESS');
  }

  // 이메일/비밀번호 로그인
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // SharedPreferences에서 계정 확인
    final savedPassword = prefs.getString('demo_account_$email');
    if (savedPassword == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: '존재하지 않는 계정입니다.',
      );
    }

    if (savedPassword != password) {
      throw FirebaseAuthException(
        code: 'wrong-password',
        message: '잘못된 비밀번호입니다.',
      );
    }

    // UID 가져오기
    final uid = prefs.getString('demo_account_${email}_uid') ?? 'demo_${email.hashCode}';

    // 메모리에도 저장 (나중에 사용할 수 있도록)
    _demoAccounts[email] = {
      'email': email,
      'password': password,
      'uid': uid,
    };

    // 로그인 상태 저장
    await prefs.setBool('demo_logged_in', true);
    await prefs.setString('demo_user_email', email);
    await prefs.setString('demo_user_uid', uid);

    // Auth 상태 업데이트
    _authStateController.add(_createDemoUser(email));

    print('📱 데모 모드: 로그인 성공 - $email');

    // 데모 모드 성공 신호
    throw Exception('DEMO_MODE_SUCCESS');
  }

  // 로그아웃
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();

    // 로그인 상태 제거
    await prefs.remove('demo_logged_in');
    await prefs.remove('demo_user_email');
    await prefs.remove('demo_user_uid');

    _demoUser = null;
    _authStateController.add(null);
    print('📱 데모 모드: 로그아웃');
  }

  // 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Firestore에 사용자 문서 생성
  Future<void> _createUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    // 문서가 이미 존재하는지 확인
    final docSnapshot = await userDoc.get();
    if (docSnapshot.exists) {
      return;
    }

    // 새 사용자 문서 생성
    await userDoc.set({
      'userId': user.uid,
      'profile': {
        'basicInfo': {
          'name': '',
          'birthdate': null,
          'ageRange': '',
          'gender': '',
          'region': '',
          'mbti': '',
          'bloodType': '',
          'smoking': false,
          'drinking': '',
          'religion': '',
          'firstRelationship': false,
        },
        'lifestyle': {
          'hobbies': [],
          'hasPet': false,
          'exerciseFrequency': '',
          'travelStyle': '',
        },
        'appearance': {
          'heightRange': '',
          'photos': [],
        },
        'oneLiner': '',
      },
      'avatar': {
        'personality': '',
        'style': '',
        'colorPreference': '',
        'animalType': '',
        'hobby': '',
        'baseCharacter': '',
        'currentOutfit': {
          'top': '',
          'bottom': '',
          'accessories': [],
          'hair': '',
          'hairColor': '',
          'background': '',
          'specialItem': '',
          'emotion': 'neutral',
        },
        'ownedItems': {
          'tops': [],
          'bottoms': [],
          'accessories': [],
          'hairs': [],
          'backgrounds': [],
          'specialItems': [],
        },
      },
      'trustScore': {
        'score': 0.0,
        'level': '새싹',
        'dailyQuestStreak': 0,
        'totalQuestCount': 0,
        'consecutiveLoginDays': 0,
        'badges': [],
      },
      'heartTemperature': {
        'temperature': 36.5,
        'level': '미지근',
      },
      'subscription': {
        'type': 'free',
        'autoRenew': false,
      },
      'safety': {
        'emergencyContacts': [],
        'blockList': [],
      },
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 프로필 완성도 확인
  Future<bool> isProfileComplete(String userId) async {
    // 데모 모드: 항상 false 반환 (프로필 설정 필요)
    return false;
  }

  // 데모 모드 여부 확인
  bool get isDemoMode => _isDemoMode;
}
