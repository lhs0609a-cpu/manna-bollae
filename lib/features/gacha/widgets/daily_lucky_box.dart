import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/constants/colors.dart';

class DailyLuckyBox extends StatefulWidget {
  const DailyLuckyBox({super.key});

  @override
  State<DailyLuckyBox> createState() => _DailyLuckyBoxState();
}

class _DailyLuckyBoxState extends State<DailyLuckyBox> with SingleTickerProviderStateMixin {
  bool _canOpen = true;
  bool _isOpening = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final List<Map<String, dynamic>> _rewards = [
    {'name': '매칭권 x2', 'icon': Icons.favorite, 'color': Colors.pink, 'rarity': 'common'},
    {'name': '슈퍼 라이크 x1', 'icon': Icons.star, 'color': Colors.amber, 'rarity': 'rare'},
    {'name': '프로필 부스트 1시간', 'icon': Icons.rocket_launch, 'color': Colors.orange, 'rarity': 'rare'},
    {'name': '코인 x50', 'icon': Icons.monetization_on, 'color': Colors.yellow, 'rarity': 'common'},
    {'name': '럭키 다이아 x1', 'icon': Icons.diamond, 'color': Colors.cyan, 'rarity': 'epic'},
    {'name': '프리미엄 1일권', 'icon': Icons.workspace_premium, 'color': Colors.purple, 'rarity': 'legendary'},
  ];

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _shakeAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _openBox() async {
    if (!_canOpen || _isOpening) return;

    setState(() {
      _isOpening = true;
    });

    // 흔들기 애니메이션
    for (int i = 0; i < 3; i++) {
      await _shakeController.forward();
      await _shakeController.reverse();
    }

    // 보상 선택 (확률 적용)
    final random = Random();
    final randomValue = random.nextDouble();
    Map<String, dynamic> reward;

    if (randomValue < 0.01) {
      // 1% - Legendary
      reward = _rewards.where((r) => r['rarity'] == 'legendary').first;
    } else if (randomValue < 0.10) {
      // 9% - Epic
      reward = _rewards.where((r) => r['rarity'] == 'epic').first;
    } else if (randomValue < 0.35) {
      // 25% - Rare
      final rareRewards = _rewards.where((r) => r['rarity'] == 'rare').toList();
      reward = rareRewards[random.nextInt(rareRewards.length)];
    } else {
      // 65% - Common
      final commonRewards = _rewards.where((r) => r['rarity'] == 'common').toList();
      reward = commonRewards[random.nextInt(commonRewards.length)];
    }

    // 보상 다이얼로그 표시
    if (mounted) {
      await _showRewardDialog(reward);
    }

    setState(() {
      _canOpen = false;
      _isOpening = false;
    });
  }

  Future<void> _showRewardDialog(Map<String, dynamic> reward) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                reward['color'].withOpacity(0.2),
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉 축하합니다!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: reward['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  reward['icon'] as IconData,
                  size: 64,
                  color: reward['color'] as Color,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                reward['name'] as String,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: reward['color'] as Color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRarityColor(reward['rarity'] as String),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getRarityText(reward['rarity'] as String),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: reward['color'] as Color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('확인', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'legendary':
        return Colors.purple;
      case 'epic':
        return Colors.deepPurple;
      case 'rare':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getRarityText(String rarity) {
    switch (rarity) {
      case 'legendary':
        return '전설';
      case 'epic':
        return '영웅';
      case 'rare':
        return '희귀';
      default:
        return '일반';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _isOpening ? Offset(_shakeAnimation.value, 0) : Offset.zero,
          child: GestureDetector(
            onTap: _openBox,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: _canOpen
                    ? LinearGradient(
                        colors: [Colors.amber[400]!, Colors.orange[600]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [Colors.grey[400]!, Colors.grey[600]!],
                      ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_canOpen ? Colors.amber : Colors.grey).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 상자 아이콘
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 텍스트
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '데일리 럭키박스',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _canOpen ? '탭하여 보상 획득!' : '내일 다시 도전!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 화살표 또는 체크
                  Icon(
                    _canOpen ? Icons.touch_app : Icons.check_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
