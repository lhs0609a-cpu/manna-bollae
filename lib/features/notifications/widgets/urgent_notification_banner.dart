import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class UrgentNotificationBanner extends StatefulWidget {
  const UrgentNotificationBanner({super.key});

  @override
  State<UrgentNotificationBanner> createState() => _UrgentNotificationBannerState();
}

class _UrgentNotificationBannerState extends State<UrgentNotificationBanner> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.local_fire_department,
      'title': '🔥 지금! 당신 근처 8명 접속중',
      'subtitle': '빨리 매칭하면 만날 확률 UP!',
      'color': Colors.deepOrange,
      'action': 'nearby',
    },
    {
      'icon': Icons.favorite,
      'title': '💝 새로운 좋아요 3개!',
      'subtitle': '누가 당신을 좋아할까요?',
      'color': Colors.pink,
      'action': 'likes',
    },
    {
      'icon': Icons.star,
      'title': '⭐ VIP 매칭 타임 시작!',
      'subtitle': '지금 30분간 프리미엄 회원 우선 매칭',
      'color': Colors.purple,
      'action': 'vip',
    },
    {
      'icon': Icons.celebration,
      'title': '🎉 럭키타임! 슈퍼 부스트 무료',
      'subtitle': '15분 동안 노출 10배 증가',
      'color': Colors.orange,
      'action': 'boost',
    },
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 7초마다 자동 전환
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _notifications.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTap() {
    final action = _notifications[_currentIndex]['action'] as String;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action 기능 실행!'),
        backgroundColor: _notifications[_currentIndex]['color'] as Color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notification = _notifications[_currentIndex];
    final color = notification['color'] as Color;

    return ScaleTransition(
      scale: _pulseAnimation,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 아이콘
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification['icon'] as IconData,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification['subtitle'] as String,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // 화살표
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
