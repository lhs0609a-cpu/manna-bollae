import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportReason {
  inappropriate_profile,
  harassment,
  spam,
  fake_profile,
  inappropriate_content,
  scam,
  underage,
  other,
}

class Report {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final ReportReason reason;
  final String? description;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    required this.reason,
    this.description,
    required this.createdAt,
  });

  factory Report.fromMap(Map<String, dynamic> map, String id) {
    return Report(
      id: id,
      reporterId: map['reporterId'] ?? '',
      reportedUserId: map['reportedUserId'] ?? '',
      reason: ReportReason.values.firstWhere(
        (e) => e.toString() == map['reason'],
        orElse: () => ReportReason.other,
      ),
      description: map['description'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'reason': reason.toString(),
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class SafetyProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _blockedUsers = [];
  bool _isLoading = false;
  String? _error;

  List<String> get blockedUsers => _blockedUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 신고 사유 이름 가져오기
  static String getReasonName(ReportReason reason) {
    switch (reason) {
      case ReportReason.inappropriate_profile:
        return '부적절한 프로필';
      case ReportReason.harassment:
        return '괴롭힘 및 협박';
      case ReportReason.spam:
        return '스팸 및 광고';
      case ReportReason.fake_profile:
        return '가짜 프로필';
      case ReportReason.inappropriate_content:
        return '부적절한 콘텐츠';
      case ReportReason.scam:
        return '사기 의심';
      case ReportReason.underage:
        return '미성년자';
      case ReportReason.other:
        return '기타';
    }
  }

  // 신고 사유 설명 가져오기
  static String getReasonDescription(ReportReason reason) {
    switch (reason) {
      case ReportReason.inappropriate_profile:
        return '프로필 사진이나 소개가 부적절합니다';
      case ReportReason.harassment:
        return '욕설, 협박, 괴롭힘 등의 행위를 합니다';
      case ReportReason.spam:
        return '스팸 메시지나 광고를 보냅니다';
      case ReportReason.fake_profile:
        return '가짜 정보로 프로필을 작성했습니다';
      case ReportReason.inappropriate_content:
        return '불법적이거나 음란한 콘텐츠를 전송합니다';
      case ReportReason.scam:
        return '금전 요구 등 사기 행위를 합니다';
      case ReportReason.underage:
        return '미성년자로 의심됩니다';
      case ReportReason.other:
        return '기타 사유';
    }
  }

  /// 차단 목록 로드
  Future<void> loadBlockedUsers(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _blockedUsers = List<String>.from(userData['blockedUsers'] ?? []);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '차단 목록을 불러오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 사용자 신고
  Future<bool> reportUser({
    required String reporterId,
    required String reportedUserId,
    required ReportReason reason,
    String? description,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 중복 신고 확인 (같은 사용자를 24시간 이내에 신고한 적이 있는지)
      final yesterday = DateTime.now().subtract(const Duration(hours: 24));
      final existingReports = await _firestore
          .collection('reports')
          .where('reporterId', isEqualTo: reporterId)
          .where('reportedUserId', isEqualTo: reportedUserId)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(yesterday))
          .get();

      if (existingReports.docs.isNotEmpty) {
        _error = '이미 신고한 사용자입니다. 24시간 후에 다시 시도해주세요.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 신고 생성
      final report = Report(
        id: '',
        reporterId: reporterId,
        reportedUserId: reportedUserId,
        reason: reason,
        description: description,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('reports').add(report.toMap());

      // 신고 횟수 업데이트
      await _firestore.collection('users').doc(reportedUserId).update({
        'reportCount': FieldValue.increment(1),
      });

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = '신고에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 사용자 차단
  Future<bool> blockUser(String userId, String blockedUserId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 이미 차단했는지 확인
      if (_blockedUsers.contains(blockedUserId)) {
        _error = '이미 차단한 사용자입니다';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Firestore에 차단 정보 업데이트
      await _firestore.collection('users').doc(userId).update({
        'blockedUsers': FieldValue.arrayUnion([blockedUserId]),
      });

      // 로컬 상태 업데이트
      _blockedUsers.add(blockedUserId);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = '차단에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 사용자 차단 해제
  Future<bool> unblockUser(String userId, String blockedUserId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Firestore에서 차단 해제
      await _firestore.collection('users').doc(userId).update({
        'blockedUsers': FieldValue.arrayRemove([blockedUserId]),
      });

      // 로컬 상태 업데이트
      _blockedUsers.remove(blockedUserId);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = '차단 해제에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 신고 및 차단 (동시에 실행)
  Future<bool> reportAndBlock({
    required String reporterId,
    required String reportedUserId,
    required ReportReason reason,
    String? description,
  }) async {
    final reportSuccess = await reportUser(
      reporterId: reporterId,
      reportedUserId: reportedUserId,
      reason: reason,
      description: description,
    );

    if (reportSuccess) {
      return await blockUser(reporterId, reportedUserId);
    }

    return false;
  }

  /// 차단 여부 확인
  bool isBlocked(String userId) {
    return _blockedUsers.contains(userId);
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
