import 'package:cloud_firestore/cloud_firestore.dart';

/// 메시지 타입
enum MessageType {
  text,
  image,
  voice,
}

/// 메시지 모델
class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final int intimacyGained; // 이 메시지로 얻은 친밀도

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.intimacyGained = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'intimacyGained': intimacyGained,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      intimacyGained: map['intimacyGained'] ?? 0,
    );
  }

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    int? intimacyGained,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      intimacyGained: intimacyGained ?? this.intimacyGained,
    );
  }
}

/// 채팅방 모델
class Chat {
  final String id;
  final List<String> participants; // [userId1, userId2]
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCount; // {userId: unreadCount}
  final int intimacyLevel; // 현재 친밀도
  final DateTime createdAt;

  Chat({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    Map<String, int>? unreadCount,
    this.intimacyLevel = 0,
    DateTime? createdAt,
  })  : unreadCount = unreadCount ?? {},
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime':
          lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'unreadCount': unreadCount,
      'intimacyLevel': intimacyLevel,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'],
      lastMessageTime: (map['lastMessageTime'] as Timestamp?)?.toDate(),
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
      intimacyLevel: map['intimacyLevel'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Chat copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCount,
    int? intimacyLevel,
    DateTime? createdAt,
  }) {
    return Chat(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      intimacyLevel: intimacyLevel ?? this.intimacyLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 특정 사용자의 읽지 않은 메시지 수 가져오기
  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }

  /// 상대방 userId 가져오기
  String getOtherUserId(String myUserId) {
    return participants.firstWhere(
      (id) => id != myUserId,
      orElse: () => '',
    );
  }
}
