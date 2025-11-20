import 'package:flutter/material.dart';
import 'dart:math';

class QuickPollCard extends StatefulWidget {
  const QuickPollCard({super.key});

  @override
  State<QuickPollCard> createState() => _QuickPollCardState();
}

class _QuickPollCardState extends State<QuickPollCard> {
  int? _selectedOption;
  bool _hasVoted = false;

  final List<Map<String, dynamic>> _polls = [
    {
      'question': '첫 데이트 장소는?',
      'options': [
        {'text': '카페 ☕', 'votes': 342},
        {'text': '영화관 🎬', 'votes': 256},
        {'text': '식당 🍽️', 'votes': 198},
        {'text': '공원 🌳', 'votes': 124},
      ],
    },
    {
      'question': '이상형의 MBTI는?',
      'options': [
        {'text': 'E (외향형)', 'votes': 445},
        {'text': 'I (내향형)', 'votes': 523},
      ],
    },
    {
      'question': '매력을 느끼는 포인트?',
      'options': [
        {'text': '유머감각 😄', 'votes': 389},
        {'text': '외모 ✨', 'votes': 267},
        {'text': '성격 💝', 'votes': 512},
        {'text': '목소리 🎵', 'votes': 156},
      ],
    },
  ];

  late Map<String, dynamic> _currentPoll;

  @override
  void initState() {
    super.initState();
    _currentPoll = _polls[Random().nextInt(_polls.length)];
  }

  void _vote(int optionIndex) {
    setState(() {
      _selectedOption = optionIndex;
      _hasVoted = true;
      // 투표 수 증가
      _currentPoll['options'][optionIndex]['votes']++;
    });

    // 코인 보상
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.amber),
                SizedBox(width: 8),
                Text('코인 +10 획득!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  int get _totalVotes {
    return (_currentPoll['options'] as List).fold<int>(
      0,
      (sum, option) => sum + (option['votes'] as int),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = _currentPoll['options'] as List<Map<String, dynamic>>;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink[400]!, Colors.orange[400]!],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.poll,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '빠른 투표',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!_hasVoted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.monetization_on, size: 14, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(
                        '+10',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // 질문
          Text(
            _currentPoll['question'] as String,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          // 옵션들
          ...List.generate(options.length, (index) {
            final option = options[index];
            final votes = option['votes'] as int;
            final percentage = _totalVotes > 0 ? (votes / _totalVotes * 100).round() : 0;
            final isSelected = _selectedOption == index;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: _hasVoted ? null : () => _vote(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: isSelected && _hasVoted
                        ? LinearGradient(
                            colors: [Colors.pink[400]!, Colors.orange[400]!],
                          )
                        : null,
                    color: isSelected && _hasVoted
                        ? null
                        : _hasVoted
                            ? Colors.grey[100]
                            : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? _hasVoted
                              ? Colors.transparent
                              : Colors.pink[300]!
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // 배경 진행 바
                      if (_hasVoted)
                        Positioned.fill(
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: percentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                      // 텍스트
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            option['text'] as String,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isSelected && _hasVoted ? Colors.white : Colors.black87,
                            ),
                          ),
                          if (_hasVoted)
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected && _hasVoted ? Colors.white : Colors.grey[700],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          if (_hasVoted) ...[
            const SizedBox(height: 12),
            Text(
              '총 $_totalVotes명 참여',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
