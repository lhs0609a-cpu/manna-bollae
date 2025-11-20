import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../auth/providers/auth_provider.dart';

class ChatListScreenInstagram extends StatefulWidget {
  const ChatListScreenInstagram({super.key});

  @override
  State<ChatListScreenInstagram> createState() => _ChatListScreenInstagramState();
}

class _ChatListScreenInstagramState extends State<ChatListScreenInstagram> {
  final List<ChatPreview> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _chats.addAll([
        ChatPreview(
          name: '민준',
          lastMessage: '오늘 저녁 어때요?',
          time: '5분 전',
          unreadCount: 2,
          isOnline: true,
          avatar: 'M',
          color: Colors.blue,
        ),
        ChatPreview(
          name: '서연',
          lastMessage: '네! 좋아요 😊',
          time: '1시간 전',
          unreadCount: 0,
          isOnline: true,
          avatar: 'S',
          color: Colors.pink,
        ),
        ChatPreview(
          name: '지우',
          lastMessage: '사진 보내드렸어요',
          time: '3시간 전',
          unreadCount: 1,
          isOnline: false,
          avatar: 'J',
          color: Colors.purple,
        ),
        ChatPreview(
          name: '현우',
          lastMessage: '감사합니다!',
          time: '어제',
          unreadCount: 0,
          isOnline: false,
          avatar: 'H',
          color: Colors.orange,
        ),
        ChatPreview(
          name: '수민',
          lastMessage: '주말에 시간 되세요?',
          time: '어제',
          unreadCount: 3,
          isOnline: true,
          avatar: 'S',
          color: Colors.green,
        ),
        ChatPreview(
          name: '예진',
          lastMessage: '좋은 하루 보내세요!',
          time: '2일 전',
          unreadCount: 0,
          isOnline: false,
          avatar: 'Y',
          color: Colors.teal,
        ),
        ChatPreview(
          name: '도현',
          lastMessage: '알겠습니다 ㅎㅎ',
          time: '3일 전',
          unreadCount: 0,
          isOnline: false,
          avatar: 'D',
          color: Colors.indigo,
        ),
      ]);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_chats.isEmpty)
              _buildEmptyState()
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _chats.length,
                  itemBuilder: (context, index) {
                    return _buildChatItem(_chats[index]);
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.pink,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.chat_bubble, color: Colors.blue, size: 28),
          const SizedBox(width: 12),
          const Text(
            '채팅',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.video_call, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.edit_square, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(
          hintText: '검색',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildChatItem(ChatPreview chat) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreenInstagram(chat: chat),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: chat.unreadCount > 0 ? Colors.blue[50]!.withOpacity(0.3) : Colors.white,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [chat.color, chat.color.withOpacity(0.6)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      chat.avatar,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        chat.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: chat.unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (chat.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${chat.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: chat.unreadCount > 0
                          ? Colors.black87
                          : Colors.grey[600],
                      fontWeight: chat.unreadCount > 0
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: TextStyle(
                    fontSize: 13,
                    color: chat.unreadCount > 0 ? Colors.blue : Colors.grey[500],
                    fontWeight: chat.unreadCount > 0
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                if (chat.unreadCount == 0)
                  Icon(Icons.check, size: 16, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              '아직 대화가 없어요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '매칭된 사람과 대화를 시작해보세요!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPreview {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final String avatar;
  final Color color;

  ChatPreview({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
    required this.avatar,
    required this.color,
  });
}

// 채팅 상세 화면
class ChatDetailScreenInstagram extends StatefulWidget {
  final ChatPreview chat;

  const ChatDetailScreenInstagram({super.key, required this.chat});

  @override
  State<ChatDetailScreenInstagram> createState() => _ChatDetailScreenInstagramState();
}

class _ChatDetailScreenInstagramState extends State<ChatDetailScreenInstagram> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    setState(() {
      _messages.addAll([
        ChatMessage(
          text: '안녕하세요! 반가워요 😊',
          isMine: false,
          time: '오전 10:30',
        ),
        ChatMessage(
          text: '안녕하세요! 저도 반가워요',
          isMine: true,
          time: '오전 10:32',
        ),
        ChatMessage(
          text: '프로필 보니까 취미가 비슷하시더라구요',
          isMine: false,
          time: '오전 10:33',
        ),
        ChatMessage(
          text: '네 맞아요! 저도 그래서 관심갖고 봤어요',
          isMine: true,
          time: '오전 10:35',
        ),
        ChatMessage(
          text: widget.chat.lastMessage,
          isMine: false,
          time: widget.chat.time,
        ),
      ]);
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: _messageController.text,
        isMine: true,
        time: '방금',
      ));
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [widget.chat.color, widget.chat.color.withOpacity(0.6)],
                ),
              ),
              child: Center(
                child: Text(
                  widget.chat.avatar,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (widget.chat.isOnline)
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '활동 중',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMine) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [widget.chat.color, widget.chat.color.withOpacity(0.6)],
                ),
              ),
              child: Center(
                child: Text(
                  widget.chat.avatar,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: message.isMine
                        ? Colors.blue[500]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: message.isMine ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          if (message.isMine) const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.grey[600]),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.image, color: Colors.grey[600]),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.mic, color: Colors.grey[600]),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '메시지 입력...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMine;
  final String time;

  ChatMessage({
    required this.text,
    required this.isMine,
    required this.time,
  });
}
