import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum VerificationType {
  photo,
  video,
  idCard,
  criminalRecord,
  schoolViolence,
  occupation,
  education,
}

enum VerificationStatus {
  pending,
  approved,
  rejected,
}

class VerificationRequest {
  final String id;
  final String userId;
  final VerificationType type;
  final VerificationStatus status;
  final String? imageUrl;
  final String? videoUrl;
  final String? documentUrl;
  final Map<String, dynamic>? metadata;
  final String? rejectReason;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  VerificationRequest({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    this.imageUrl,
    this.videoUrl,
    this.documentUrl,
    this.metadata,
    this.rejectReason,
    required this.createdAt,
    this.reviewedAt,
  });

  factory VerificationRequest.fromMap(Map<String, dynamic> map, String id) {
    return VerificationRequest(
      id: id,
      userId: map['userId'] ?? '',
      type: VerificationType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => VerificationType.photo,
      ),
      status: VerificationStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => VerificationStatus.pending,
      ),
      imageUrl: map['imageUrl'],
      videoUrl: map['videoUrl'],
      documentUrl: map['documentUrl'],
      metadata: map['metadata'],
      rejectReason: map['rejectReason'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      reviewedAt: map['reviewedAt'] != null
          ? (map['reviewedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.toString(),
      'status': status.toString(),
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'documentUrl': documentUrl,
      'metadata': metadata,
      'rejectReason': rejectReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
    };
  }
}

class VerificationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<VerificationRequest> _verificationRequests = [];
  bool _isLoading = false;
  String? _error;

  List<VerificationRequest> get verificationRequests => _verificationRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 인증 타입 이름
  static String getVerificationName(VerificationType type) {
    switch (type) {
      case VerificationType.photo:
        return '사진 인증';
      case VerificationType.video:
        return '영상 인증';
      case VerificationType.idCard:
        return '신분증 인증';
      case VerificationType.criminalRecord:
        return '범죄경력 조회';
      case VerificationType.schoolViolence:
        return '학교폭력 조회';
      case VerificationType.occupation:
        return '직업 인증';
      case VerificationType.education:
        return '학력 인증';
    }
  }

  // 인증 설명
  static String getVerificationDescription(VerificationType type) {
    switch (type) {
      case VerificationType.photo:
        return '본인 얼굴이 명확히 보이는 사진을 업로드해주세요';
      case VerificationType.video:
        return '본인 확인을 위한 짧은 영상을 촬영해주세요';
      case VerificationType.idCard:
        return '주민등록증 또는 운전면허증을 업로드해주세요';
      case VerificationType.criminalRecord:
        return '범죄경력조회 확인서를 업로드해주세요';
      case VerificationType.schoolViolence:
        return '학교폭력 확인서를 업로드해주세요';
      case VerificationType.occupation:
        return '재직증명서 또는 사업자등록증을 업로드해주세요';
      case VerificationType.education:
        return '졸업증명서 또는 재학증명서를 업로드해주세요';
    }
  }

  // 인증 포인트
  static int getVerificationPoints(VerificationType type) {
    switch (type) {
      case VerificationType.photo:
        return 5;
      case VerificationType.video:
        return 10;
      case VerificationType.idCard:
        return 10;
      case VerificationType.criminalRecord:
        return 15;
      case VerificationType.schoolViolence:
        return 15;
      case VerificationType.occupation:
        return 10;
      case VerificationType.education:
        return 10;
    }
  }

  /// 인증 요청 목록 로드
  Future<void> loadVerificationRequests(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('verification_requests')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _verificationRequests = querySnapshot.docs
          .map((doc) => VerificationRequest.fromMap(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '인증 요청 목록을 불러오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 인증 요청 제출
  Future<bool> submitVerification({
    required String userId,
    required VerificationType type,
    String? imageUrl,
    String? videoUrl,
    String? documentUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 이미 승인된 인증이 있는지 확인
      final existingApproved = await _firestore
          .collection('verification_requests')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type.toString())
          .where('status', isEqualTo: VerificationStatus.approved.toString())
          .get();

      if (existingApproved.docs.isNotEmpty) {
        _error = '이미 승인된 인증입니다';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 대기 중인 요청이 있는지 확인
      final existingPending = await _firestore
          .collection('verification_requests')
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type.toString())
          .where('status', isEqualTo: VerificationStatus.pending.toString())
          .get();

      if (existingPending.docs.isNotEmpty) {
        _error = '이미 검토 중인 요청이 있습니다';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final request = VerificationRequest(
        id: '',
        userId: userId,
        type: type,
        status: VerificationStatus.pending,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        documentUrl: documentUrl,
        metadata: metadata,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('verification_requests').add(request.toMap());

      // 목록 새로고침
      await loadVerificationRequests(userId);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = '인증 요청 제출에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 인증 상태 확인
  VerificationStatus? getVerificationStatus(VerificationType type) {
    final requests = _verificationRequests
        .where((req) => req.type == type)
        .toList();

    if (requests.isEmpty) return null;

    // 승인된 요청이 있으면 승인 상태
    if (requests.any((req) => req.status == VerificationStatus.approved)) {
      return VerificationStatus.approved;
    }

    // 대기 중인 요청이 있으면 대기 상태
    if (requests.any((req) => req.status == VerificationStatus.pending)) {
      return VerificationStatus.pending;
    }

    // 거절된 요청만 있으면 거절 상태
    return VerificationStatus.rejected;
  }

  /// 특정 인증 요청 가져오기
  VerificationRequest? getVerificationRequest(VerificationType type) {
    final requests = _verificationRequests
        .where((req) => req.type == type)
        .toList();

    if (requests.isEmpty) return null;

    // 최신 요청 반환
    return requests.first;
  }

  /// 파일 업로드 (테스트용 - 실제로는 Firebase Storage 사용)
  Future<String?> uploadFile(String filePath, VerificationType type) async {
    try {
      // TODO: 실제 Firebase Storage 업로드 구현
      // final ref = FirebaseStorage.instance.ref().child('verifications/${DateTime.now().millisecondsSinceEpoch}');
      // await ref.putFile(File(filePath));
      // return await ref.getDownloadURL();

      // 테스트용: 파일 경로 그대로 반환
      await Future.delayed(const Duration(seconds: 1)); // 업로드 시뮬레이션
      return filePath;
    } catch (e) {
      _error = '파일 업로드에 실패했습니다: $e';
      notifyListeners();
      return null;
    }
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
