import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 매칭 필터 설정 모델
class MatchingFilter {
  final int minAge;
  final int maxAge;
  final List<String> preferredRegions; // 빈 리스트 = 모든 지역
  final List<String> preferredReligions; // 빈 리스트 = 모든 종교
  final List<String> preferredDrinking; // 빈 리스트 = 모든 음주
  final bool allowSmoking; // true = 흡연자 포함, false = 비흡연자만
  final bool onlyNonSmoking; // true = 비흡연자만
  final int maxDistance; // 최대 거리 (km), 0 = 무제한

  MatchingFilter({
    this.minAge = 19,
    this.maxAge = 99,
    this.preferredRegions = const [],
    this.preferredReligions = const [],
    this.preferredDrinking = const [],
    this.allowSmoking = true,
    this.onlyNonSmoking = false,
    this.maxDistance = 0,
  });

  factory MatchingFilter.fromMap(Map<String, dynamic> map) {
    return MatchingFilter(
      minAge: map['minAge'] ?? 19,
      maxAge: map['maxAge'] ?? 99,
      preferredRegions: List<String>.from(map['preferredRegions'] ?? []),
      preferredReligions: List<String>.from(map['preferredReligions'] ?? []),
      preferredDrinking: List<String>.from(map['preferredDrinking'] ?? []),
      allowSmoking: map['allowSmoking'] ?? true,
      onlyNonSmoking: map['onlyNonSmoking'] ?? false,
      maxDistance: map['maxDistance'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'minAge': minAge,
      'maxAge': maxAge,
      'preferredRegions': preferredRegions,
      'preferredReligions': preferredReligions,
      'preferredDrinking': preferredDrinking,
      'allowSmoking': allowSmoking,
      'onlyNonSmoking': onlyNonSmoking,
      'maxDistance': maxDistance,
    };
  }

  MatchingFilter copyWith({
    int? minAge,
    int? maxAge,
    List<String>? preferredRegions,
    List<String>? preferredReligions,
    List<String>? preferredDrinking,
    bool? allowSmoking,
    bool? onlyNonSmoking,
    int? maxDistance,
  }) {
    return MatchingFilter(
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      preferredRegions: preferredRegions ?? this.preferredRegions,
      preferredReligions: preferredReligions ?? this.preferredReligions,
      preferredDrinking: preferredDrinking ?? this.preferredDrinking,
      allowSmoking: allowSmoking ?? this.allowSmoking,
      onlyNonSmoking: onlyNonSmoking ?? this.onlyNonSmoking,
      maxDistance: maxDistance ?? this.maxDistance,
    );
  }
}

/// 매칭 필터 Provider
class MatchingFilterProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  MatchingFilter _filter = MatchingFilter();
  bool _isLoading = false;
  String? _error;

  MatchingFilter get filter => _filter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 필터 설정 로드 (데모 모드: SharedPreferences 사용)
  Future<void> loadFilter(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // SharedPreferences에서 로드
      final prefs = await SharedPreferences.getInstance();
      final filterJson = prefs.getString('matching_filter_$userId');

      if (filterJson != null) {
        _filter = MatchingFilter.fromMap(jsonDecode(filterJson));
      } else {
        // 기본 필터 저장
        await _saveFilter(userId, _filter);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('⚠️ 필터 설정을 불러오는데 실패했습니다: $e');
      _error = '필터 설정을 불러오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 필터 설정 저장 (데모 모드: SharedPreferences 사용)
  Future<void> _saveFilter(String userId, MatchingFilter filter) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'matching_filter_$userId',
        jsonEncode(filter.toMap()),
      );
    } catch (e) {
      print('⚠️ 필터 저장 실패: $e');
    }
  }

  /// 나이 범위 설정
  Future<void> setAgeRange(String userId, int minAge, int maxAge) async {
    try {
      _filter = _filter.copyWith(minAge: minAge, maxAge: maxAge);
      await _saveFilter(userId, _filter);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 선호 지역 설정
  Future<void> setPreferredRegions(
      String userId, List<String> regions) async {
    try {
      _filter = _filter.copyWith(preferredRegions: regions);
      await _saveFilter(userId, _filter);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 선호 종교 설정
  Future<void> setPreferredReligions(
      String userId, List<String> religions) async {
    try {
      _filter = _filter.copyWith(preferredReligions: religions);
      await _saveFilter(userId, _filter);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 선호 음주 설정
  Future<void> setPreferredDrinking(
      String userId, List<String> drinking) async {
    try {
      _filter = _filter.copyWith(preferredDrinking: drinking);
      await _saveFilter(userId, _filter);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 흡연 필터 설정
  Future<void> setSmokingFilter(
      String userId, bool allowSmoking, bool onlyNonSmoking) async {
    try {
      _filter = _filter.copyWith(
        allowSmoking: allowSmoking,
        onlyNonSmoking: onlyNonSmoking,
      );
      await _saveFilter(userId, _filter);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 최대 거리 설정
  Future<void> setMaxDistance(String userId, int maxDistance) async {
    try {
      _filter = _filter.copyWith(maxDistance: maxDistance);
      await _saveFilter(userId, _filter);
      notifyListeners();
    } catch (e) {
      _error = '설정 저장에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 필터 초기화
  Future<void> resetFilter(String userId) async {
    try {
      _filter = MatchingFilter();
      await _saveFilter(userId, _filter);
      notifyListeners();
    } catch (e) {
      _error = '설정 초기화에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
