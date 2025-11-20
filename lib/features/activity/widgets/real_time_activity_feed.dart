import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../../core/constants/colors.dart';

class RealTimeActivityFeed extends StatefulWidget {
  const RealTimeActivityFeed({super.key});

  @override
  State<RealTimeActivityFeed> createState() => _RealTimeActivityFeedState();
}

class _RealTimeActivityFeedState extends State<RealTimeActivityFeed> {
  final List<Map<String, dynamic>> _activities = [];
  Timer? _timer;

  final List<Map<String, dynamic>> _activityTemplates = [
    {
      'icon': Icons.favorite,
      'color': Colors.pink,
      'texts': [
        '민호님이 당신의 사진을 좋아해요',
        '수진님이 당신에게 관심을 보였어요',
        '재현님이 당신을 찜했어요',
        '서연님이 당신의 프로필을 저장했어요',
      ],
    },
    {
      'icon': Icons.message,
      'color': Colors.blue,
      'texts': [
        '지은님이 메시지를 보냈어요',
        '민지님이 채팅을 시작했어요',
        '현수님이 답장을 기다리고 있어요',
      ],
    },
    {
      'icon': Icons.celebration,
      'color': Colors.orange,
      'texts': [
        '새로운 매칭! 하은님과 매칭되었어요',
        '축하합니다! 서진님과 매칭!',
        '완벽한 매칭! 유나님과 연결되었어요',
      ],
    },
    {
      'icon': Icons.person_add,
      'color': Colors.green,
      'texts': [
        '태희님이 지금 온라인',
        '동현님이 접속했어요',
        '소연님이 활동 중',
      ],
    },
    {
      'icon': Icons.local_fire_department,
      'color': Colors.deepOrange,
      'texts': [
        'Hot Time 시작! 지금 접속자 500명',
        '특별 이벤트 시작!',
        '럭키타임! 지금 매칭 확률 2배',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    // 초기 활동 3개 추가
    for (int i = 0; i < 3; i++) {
      _addRandomActivity();
    }

    // 5~10초마다 새 활동 추가
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mounted) {
        setState(() {
          _addRandomActivity();
          // 최대 5개까지만 유지
          if (_activities.length > 5) {
            _activities.removeAt(0);
          }
        });
      }
    });
  }

  void _addRandomActivity() {
    final random = Random();
    final template = _activityTemplates[random.nextInt(_activityTemplates.length)];
    final texts = template['texts'] as List<String>;

    _activities.add({
      'icon': template['icon'],
      'color': template['color'],
      'text': texts[random.nextInt(texts.length)],
      'time': _getTimeAgo(random.nextInt(20) + 1),
      'id': DateTime.now().millisecondsSinceEpoch,
    });
  }

  String _getTimeAgo(int minutes) {
    if (minutes < 1) return '방금 전';
    if (minutes < 60) return '$minutes분 전';
    final hours = minutes ~/ 60;
    if (hours < 24) return '$hours시간 전';
    return '${hours ~/ 24}일 전';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[400]!, Colors.purple[400]!],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '실시간 활동',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // 활동 리스트
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: _activities.length,
            separatorBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: Colors.grey[200]),
            ),
            itemBuilder: (context, index) {
              final activity = _activities[index];
              return _buildActivityItem(
                icon: activity['icon'] as IconData,
                color: activity['color'] as Color,
                text: activity['text'] as String,
                time: activity['time'] as String,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String text,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 아이콘
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // 화살표
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
            size: 20,
          ),
        ],
      ),
    );
  }
}
