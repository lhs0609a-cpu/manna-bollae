import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Step 1: 기본 정보
  String name = '';
  DateTime? birthdate;
  String gender = '';
  String region = '';

  // Step 2: 성격/습관
  String mbti = '';
  String bloodType = '';
  bool smoking = false;
  String drinking = '';
  String religion = '';
  bool firstRelationship = false;

  // Step 3: 취미
  List<String> selectedHobbies = [];

  // Step 4: 한 줄 소개
  String oneLiner = '';

  // Step 5: 키 범위
  String heightRange = '';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 나이 계산
  int? get age {
    if (birthdate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthdate!.year;
    if (now.month < birthdate!.month ||
        (now.month == birthdate!.month && now.day < birthdate!.day)) {
      age--;
    }
    return age;
  }

  // 나이대 계산 (20대 초반, 20대 후반 등)
  String? get ageRange {
    if (age == null) return null;
    final decade = (age! ~/ 10) * 10;
    final position = age! % 10 < 5 ? '초반' : '후반';
    return '$decade대 $position';
  }

  // Step 1 데이터 저장
  void saveStep1({
    required String name,
    required DateTime birthdate,
    required String gender,
    required String region,
  }) {
    this.name = name;
    this.birthdate = birthdate;
    this.gender = gender;
    this.region = region;
    notifyListeners();
  }

  // Step 2 데이터 저장
  void saveStep2({
    required String mbti,
    required String bloodType,
    required bool smoking,
    required String drinking,
    required String religion,
    required bool firstRelationship,
  }) {
    this.mbti = mbti;
    this.bloodType = bloodType;
    this.smoking = smoking;
    this.drinking = drinking;
    this.religion = religion;
    this.firstRelationship = firstRelationship;
    notifyListeners();
  }

  // Step 3 데이터 저장
  void saveStep3(List<String> hobbies) {
    selectedHobbies = hobbies;
    notifyListeners();
  }

  // Step 4 데이터 저장
  void saveStep4(String oneLiner) {
    this.oneLiner = oneLiner;
    notifyListeners();
  }

  // Step 5 데이터 저장
  void saveStep5(String heightRange) {
    this.heightRange = heightRange;
    notifyListeners();
  }

  // Firestore에 프로필 저장
  Future<bool> saveProfileToFirestore(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('users').doc(userId).update({
        'profile.basicInfo.name': name,
        'profile.basicInfo.birthdate': Timestamp.fromDate(birthdate!),
        'profile.basicInfo.ageRange': ageRange,
        'profile.basicInfo.exactAge': age,
        'profile.basicInfo.gender': gender,
        'profile.basicInfo.region': region,
        'profile.basicInfo.mbti': mbti,
        'profile.basicInfo.bloodType': bloodType,
        'profile.basicInfo.smoking': smoking,
        'profile.basicInfo.drinking': drinking,
        'profile.basicInfo.religion': religion,
        'profile.basicInfo.firstRelationship': firstRelationship,
        'profile.lifestyle.hobbies': selectedHobbies,
        'profile.appearance.heightRange': heightRange,
        'profile.oneLiner': oneLiner,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 진행률 계산
  double getProgress(int currentStep) {
    return (currentStep / 5);
  }

  // 초기화
  void reset() {
    name = '';
    birthdate = null;
    gender = '';
    region = '';
    mbti = '';
    bloodType = '';
    smoking = false;
    drinking = '';
    religion = '';
    firstRelationship = false;
    selectedHobbies = [];
    oneLiner = '';
    heightRange = '';
    notifyListeners();
  }

  /// 기본 정보 업데이트
  Future<bool> updateBasicInfo({
    required String userId,
    String? name,
    DateTime? birthdate,
    String? region,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final Map<String, dynamic> updates = {};

      if (name != null) {
        updates['profile.basicInfo.name'] = name;
        this.name = name;
      }

      if (birthdate != null) {
        updates['profile.basicInfo.birthDate'] = Timestamp.fromDate(birthdate);
        this.birthdate = birthdate;
        updates['profile.basicInfo.ageRange'] = ageRange;
        updates['profile.basicInfo.exactAge'] = age;
      }

      if (region != null) {
        updates['profile.basicInfo.region'] = region;
        this.region = region;
      }

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(userId).update(updates);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 성격 & 습관 업데이트
  Future<bool> updatePersonalityAndHabits({
    required String userId,
    String? mbti,
    String? bloodType,
    bool? smoking,
    String? drinking,
    String? religion,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final Map<String, dynamic> updates = {};

      if (mbti != null) {
        updates['profile.basicInfo.mbti'] = mbti;
        this.mbti = mbti;
      }

      if (bloodType != null) {
        updates['profile.basicInfo.bloodType'] = bloodType;
        this.bloodType = bloodType;
      }

      if (smoking != null) {
        updates['profile.basicInfo.smoking'] = smoking;
        this.smoking = smoking;
      }

      if (drinking != null) {
        updates['profile.basicInfo.drinking'] = drinking;
        this.drinking = drinking;
      }

      if (religion != null) {
        updates['profile.basicInfo.religion'] = religion;
        this.religion = religion;
      }

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(userId).update(updates);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 취미 업데이트
  Future<bool> updateHobbies({
    required String userId,
    required List<String> hobbies,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('users').doc(userId).update({
        'profile.lifestyle.hobbies': hobbies,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      selectedHobbies = hobbies;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 한 줄 소개 업데이트
  Future<bool> updateOneLiner({
    required String userId,
    required String oneLiner,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('users').doc(userId).update({
        'profile.basicInfo.oneLiner': oneLiner,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      this.oneLiner = oneLiner;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 키 범위 업데이트
  Future<bool> updateHeightRange({
    required String userId,
    required String heightRange,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('users').doc(userId).update({
        'profile.appearance.heightRange': heightRange,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      this.heightRange = heightRange;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
