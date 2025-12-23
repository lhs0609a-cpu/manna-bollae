import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../models/chat_model.dart';
import '../../../core/constants/app_constants.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  List<Chat> _chats = [];
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription? _chatsSubscription;
  StreamSubscription? _messagesSubscription;

  List<Chat> get chats => _chats;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 내 채팅 목록 실시간 감지
  void listenToChats(String userId) {
    _chatsSubscription?.cancel();

    _chatsSubscription = _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _chats = snapshot.docs
            .map((doc) => Chat.fromMap(doc.data()))
            .toList();
        notifyListeners();
      },
      onError: (error) {
        _error = '채팅 목록을 불러오는데 실패했습니다: $error';
        notifyListeners();
      },
    );
  }

  /// 특정 채팅방 메시지 실시간 감지
  void listenToMessages(String chatId) {
    _messagesSubscription?.cancel();

    _messagesSubscription = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _messages = snapshot.docs
            .map((doc) => Message.fromMap(doc.data()))
            .toList();
        notifyListeners();
      },
      onError: (error) {
        _error = '메시지를 불러오는데 실패했습니다: $error';
        notifyListeners();
      },
    );
  }

  /// 채팅방 생성 또는 기존 채팅방 가져오기
  Future<String?> getOrCreateChat(String userId1, String userId2) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 기존 채팅방 찾기
      final querySnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId1)
          .get();

      for (var doc in querySnapshot.docs) {
        final chat = Chat.fromMap(doc.data());
        if (chat.participants.contains(userId2)) {
          _isLoading = false;
          notifyListeners();
          return chat.id;
        }
      }

      // 새 채팅방 생성
      final chatId = _uuid.v4();
      final newChat = Chat(
        id: chatId,
        participants: [userId1, userId2],
        unreadCount: {userId1: 0, userId2: 0},
      );

      await _firestore.collection('chats').doc(chatId).set(newChat.toMap());

      _isLoading = false;
      notifyListeners();
      return chatId;
    } catch (e) {
      _error = '채팅방 생성에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// 채팅방 ID로 채팅방 가져오기
  Future<Chat?> getChatById(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (doc.exists && doc.data() != null) {
        return Chat.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      _error = '채팅방을 불러오는데 실패했습니다: $e';
      notifyListeners();
      return null;
    }
  }

  /// 메시지 전송
  Future<bool> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    try {
      final messageId = _uuid.v4();
      final now = DateTime.now();

      // 친밀도 계산
      int intimacyGained = 0;
      switch (type) {
        case MessageType.text:
          intimacyGained = AppConstants.intimacyPerTextMessage;
          break;
        case MessageType.voice:
          intimacyGained = AppConstants.intimacyPerVoiceMessage;
          break;
        case MessageType.image:
          intimacyGained = AppConstants.intimacyPerImageMessage;
          break;
      }

      final message = Message(
        id: messageId,
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        type: type,
        timestamp: now,
        intimacyGained: intimacyGained,
      );

      // Firestore에 메시지 저장
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());

      // 채팅방 정보 업데이트
      final chatRef = _firestore.collection('chats').doc(chatId);
      final chatDoc = await chatRef.get();
      final chat = Chat.fromMap(chatDoc.data()!);

      // 수신자의 읽지 않은 메시지 수 증가
      final updatedUnreadCount = Map<String, int>.from(chat.unreadCount);
      updatedUnreadCount[receiverId] = (updatedUnreadCount[receiverId] ?? 0) + 1;

      await chatRef.update({
        'lastMessage': content,
        'lastMessageTime': Timestamp.fromDate(now),
        'unreadCount': updatedUnreadCount,
        'intimacyLevel': chat.intimacyLevel + intimacyGained,
      });

      // 사용자의 친밀도 업데이트
      await _updateUserIntimacy(senderId, receiverId, intimacyGained);

      return true;
    } catch (e) {
      _error = '메시지 전송에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 메시지 읽음 처리
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final chatRef = _firestore.collection('chats').doc(chatId);
      final chatDoc = await chatRef.get();
      final chat = Chat.fromMap(chatDoc.data()!);

      // 읽지 않은 메시지 수 초기화
      final updatedUnreadCount = Map<String, int>.from(chat.unreadCount);
      updatedUnreadCount[userId] = 0;

      await chatRef.update({
        'unreadCount': updatedUnreadCount,
      });

      // 메시지들의 isRead 플래그 업데이트
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      _error = '메시지 읽음 처리에 실패했습니다: $e';
      notifyListeners();
    }
  }

  /// 사용자 간 친밀도 업데이트
  Future<void> _updateUserIntimacy(
    String userId1,
    String userId2,
    int intimacyGained,
  ) async {
    try {
      // userId1의 intimacy 업데이트
      final user1Ref = _firestore.collection('users').doc(userId1);
      final user1Doc = await user1Ref.get();
      final user1Intimacy = user1Doc.data()?['intimacy'] ?? {};

      user1Intimacy[userId2] =
          (user1Intimacy[userId2] ?? 0) + intimacyGained;

      await user1Ref.update({'intimacy': user1Intimacy});

      // userId2의 intimacy 업데이트
      final user2Ref = _firestore.collection('users').doc(userId2);
      final user2Doc = await user2Ref.get();
      final user2Intimacy = user2Doc.data()?['intimacy'] ?? {};

      user2Intimacy[userId1] =
          (user2Intimacy[userId1] ?? 0) + intimacyGained;

      await user2Ref.update({'intimacy': user2Intimacy});
    } catch (e) {
      debugPrint('친밀도 업데이트 실패: $e');
    }
  }

  /// 특정 사용자와의 친밀도 가져오기
  Future<int> getIntimacyWithUser(String myUserId, String otherUserId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(myUserId).get();
      final intimacy = userDoc.data()?['intimacy'] ?? {};
      return intimacy[otherUserId] ?? 0;
    } catch (e) {
      debugPrint('친밀도 조회 실패: $e');
      return 0;
    }
  }

  /// 타이핑 상태 업데이트
  Future<void> updateTypingStatus(
    String chatId,
    String userId,
    bool isTyping,
  ) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'typing_$userId': isTyping,
      });
    } catch (e) {
      debugPrint('타이핑 상태 업데이트 실패: $e');
    }
  }

  /// 타이핑 상태 감지
  Stream<bool> listenToTypingStatus(String chatId, String otherUserId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((doc) => doc.data()?['typing_$otherUserId'] ?? false);
  }

  /// 리소스 정리
  @override
  void dispose() {
    _chatsSubscription?.cancel();
    _messagesSubscription?.cancel();
    super.dispose();
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
