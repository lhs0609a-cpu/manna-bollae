import 'package:cloud_firestore/cloud_firestore.dart';

/// 매칭 요청 타입
enum MatchRequestType {
  like, // 좋아요
  pass, // 거절
}

/// 매칭 요청 모델
class MatchRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final MatchRequestType type;
  final DateTime timestamp;

  MatchRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory MatchRequest.fromMap(Map<String, dynamic> map) {
    return MatchRequest(
      id: map['id'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      type: MatchRequestType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MatchRequestType.pass,
      ),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// 매칭 상태
enum MatchStatus {
  active, // 활성 매칭
  blocked, // 차단됨
  expired, // 만료됨
}

/// 매칭 모델
class Match {
  final String id;
  final List<String> users; // [userId1, userId2]
  final DateTime matchedAt;
  final MatchStatus status;
  final String? chatId; // 연결된 채팅방 ID
  final Map<String, int> intimacyLevel; // {userId: intimacy}

  Match({
    required this.id,
    required this.users,
    required this.matchedAt,
    this.status = MatchStatus.active,
    this.chatId,
    Map<String, int>? intimacyLevel,
  }) : intimacyLevel = intimacyLevel ?? {};

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'users': users,
      'matchedAt': Timestamp.fromDate(matchedAt),
      'status': status.name,
      'chatId': chatId,
      'intimacyLevel': intimacyLevel,
    };
  }

  factory Match.fromMap(Map<String, dynamic> map) {
    return Match(
      id: map['id'] ?? '',
      users: List<String>.from(map['users'] ?? []),
      matchedAt: (map['matchedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: MatchStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MatchStatus.active,
      ),
      chatId: map['chatId'],
      intimacyLevel: Map<String, int>.from(map['intimacyLevel'] ?? {}),
    );
  }

  /// 상대방 userId 가져오기
  String getOtherUserId(String myUserId) {
    return users.firstWhere(
      (id) => id != myUserId,
      orElse: () => '',
    );
  }

  Match copyWith({
    String? id,
    List<String>? users,
    DateTime? matchedAt,
    MatchStatus? status,
    String? chatId,
    Map<String, int>? intimacyLevel,
  }) {
    return Match(
      id: id ?? this.id,
      users: users ?? this.users,
      matchedAt: matchedAt ?? this.matchedAt,
      status: status ?? this.status,
      chatId: chatId ?? this.chatId,
      intimacyLevel: intimacyLevel ?? this.intimacyLevel,
    );
  }
}

/// 추천 사용자 (매칭 알고리즘 결과)
class RecommendedUser {
  final String userId;
  final double matchScore; // 0.0 ~ 1.0 매칭 점수
  final List<String> matchReasons; // 매칭 이유들

  RecommendedUser({
    required this.userId,
    required this.matchScore,
    this.matchReasons = const [],
  });
}
