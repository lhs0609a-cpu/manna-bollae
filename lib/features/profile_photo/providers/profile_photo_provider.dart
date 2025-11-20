import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 프로필 사진 Provider
class ProfilePhotoProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _photoUrls = [];
  String? _mainPhotoUrl;
  bool _isLoading = false;
  String? _error;

  List<String> get photoUrls => _photoUrls;
  String? get mainPhotoUrl => _mainPhotoUrl;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 사진 목록 로드
  Future<void> loadPhotos(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _photoUrls = List<String>.from(userData['photoUrls'] ?? []);
        _mainPhotoUrl = userData['mainPhotoUrl'];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '사진을 불러오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 사진 추가 (테스트용 - 실제로는 Firebase Storage 사용)
  Future<bool> addPhoto(String userId, String photoPath) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Firebase Storage에 업로드
      // final ref = FirebaseStorage.instance.ref().child('profile_photos/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      // await ref.putFile(File(photoPath));
      // final downloadUrl = await ref.getDownloadURL();

      // 테스트용: 파일 경로를 그대로 사용
      await Future.delayed(const Duration(seconds: 1));
      final photoUrl = photoPath;

      // 최대 6장까지만 허용
      if (_photoUrls.length >= 6) {
        _error = '최대 6장까지만 업로드할 수 있습니다';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _photoUrls.add(photoUrl);

      // 첫 번째 사진이면 메인 사진으로 설정
      if (_photoUrls.length == 1) {
        _mainPhotoUrl = photoUrl;
      }

      // Firestore 업데이트
      await _firestore.collection('users').doc(userId).update({
        'photoUrls': _photoUrls,
        if (_mainPhotoUrl == photoUrl) 'mainPhotoUrl': _mainPhotoUrl,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '사진 업로드에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 사진 삭제
  Future<bool> deletePhoto(String userId, String photoUrl) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Firebase Storage에서 삭제
      // final ref = FirebaseStorage.instance.refFromURL(photoUrl);
      // await ref.delete();

      _photoUrls.remove(photoUrl);

      // 메인 사진을 삭제한 경우
      if (_mainPhotoUrl == photoUrl) {
        _mainPhotoUrl = _photoUrls.isNotEmpty ? _photoUrls.first : null;
      }

      // Firestore 업데이트
      await _firestore.collection('users').doc(userId).update({
        'photoUrls': _photoUrls,
        'mainPhotoUrl': _mainPhotoUrl,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = '사진 삭제에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 메인 사진 설정
  Future<bool> setMainPhoto(String userId, String photoUrl) async {
    try {
      if (!_photoUrls.contains(photoUrl)) {
        _error = '존재하지 않는 사진입니다';
        notifyListeners();
        return false;
      }

      _mainPhotoUrl = photoUrl;

      await _firestore.collection('users').doc(userId).update({
        'mainPhotoUrl': _mainPhotoUrl,
      });

      notifyListeners();
      return true;
    } catch (e) {
      _error = '메인 사진 설정에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 사진 순서 변경
  Future<bool> reorderPhotos(String userId, List<String> newOrder) async {
    try {
      _photoUrls = newOrder;

      await _firestore.collection('users').doc(userId).update({
        'photoUrls': _photoUrls,
      });

      notifyListeners();
      return true;
    } catch (e) {
      _error = '사진 순서 변경에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
