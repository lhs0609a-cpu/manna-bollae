import 'package:flutter/material.dart';
import 'dart:math';

class WeeklyLeaderboardCard extends StatelessWidget {
  const WeeklyLeaderboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 시뮬레이션 데이터
    final myRank = 15;
    final topUsers = [
      {'name': '지은', 'score': 2850, 'avatar': '👩'},
      {'name': '민지', 'score': 2720, 'avatar': '👧'},
      {'name': '하은', 'score': 2590, 'avatar': '👩‍🦰'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple[400]!, Colors.purple[300]!],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '주간 인기 순위',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '내 순위: $myRank위',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // TOP 3
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 2위
                _buildPodium(
                  rank: 2,
                  name: topUsers[1]['name'] as String,
                  score: topUsers[1]['score'] as int,
                  avatar: topUsers[1]['avatar'] as String,
                  height: 100,
                  color: Colors.grey[400]!,
                ),

                // 1위
                _buildPodium(
                  rank: 1,
                  name: topUsers[0]['name'] as String,
                  score: topUsers[0]['score'] as int,
                  avatar: topUsers[0]['avatar'] as String,
                  height: 130,
                  color: Colors.amber,
                ),

                // 3위
                _buildPodium(
                  rank: 3,
                  name: topUsers[2]['name'] as String,
                  score: topUsers[2]['score'] as int,
                  avatar: topUsers[2]['avatar'] as String,
                  height: 80,
                  color: Colors.orange[300]!,
                ),
              ],
            ),
          ),

          // 구분선
          Divider(height: 1, color: Colors.grey[300]),

          // 내 정보
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple[300]!, Colors.deepPurple[400]!],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '😊',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '나',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '주간 점수: 1,850',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward, size: 14, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        '+3',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 보상 안내
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.purple[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'TOP 10 진입 시 특별 보상!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium({
    required int rank,
    required String name,
    required int score,
    required String avatar,
    required double height,
    required Color color,
  }) {
    return Column(
      children: [
        // 아바타
        Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: rank == 1
                      ? [Colors.amber, Colors.orange]
                      : rank == 2
                          ? [Colors.grey[400]!, Colors.grey[600]!]
                          : [Colors.orange[300]!, Colors.orange[500]!],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Center(
                child: Text(avatar, style: const TextStyle(fontSize: 28)),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 이름
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        // 점수
        Text(
          score.toString(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        // 받침대
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border(
              top: BorderSide(color: color, width: 3),
              left: BorderSide(color: color, width: 2),
              right: BorderSide(color: color, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
