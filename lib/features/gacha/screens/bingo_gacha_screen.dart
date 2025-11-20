import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../providers/gacha_provider.dart';
import '../models/gacha_box.dart';
import '../models/gacha_reward.dart';
import '../widgets/gacha_result_dialog.dart';

class BingoGachaScreen extends StatefulWidget {
  const BingoGachaScreen({super.key});

  @override
  State<BingoGachaScreen> createState() => _BingoGachaScreenState();
}

class _BingoGachaScreenState extends State<BingoGachaScreen> {
  List<bool> _opened = List.generate(9, (_) => false);
  int _completedLines = 0;

  int get openedCount => _opened.where((o) => o).length;

  void _openCell(int index) async {
    if (_opened[index]) return;

    setState(() {
      _opened[index] = true;
    });

    _checkLines();

    // 보상 지급
    if (openedCount == 3 || openedCount == 6 || openedCount == 9) {
      await _giveReward();
    }
  }

  void _checkLines() {
    int lines = 0;

    // 가로 3줄
    for (int row = 0; row < 3; row++) {
      if (_opened[row * 3] &&
          _opened[row * 3 + 1] &&
          _opened[row * 3 + 2]) {
        lines++;
      }
    }

    // 세로 3줄
    for (int col = 0; col < 3; col++) {
      if (_opened[col] && _opened[col + 3] && _opened[col + 6]) {
        lines++;
      }
    }

    // 대각선 2줄
    if (_opened[0] && _opened[4] && _opened[8]) lines++;
    if (_opened[2] && _opened[4] && _opened[6]) lines++;

    setState(() {
      _completedLines = lines;
    });
  }

  Future<void> _giveReward() async {
    final gachaProvider = context.read<GachaProvider>();

    GachaBox box;
    if (openedCount == 9) {
      // 전체 완성: 레전더리 확정
      box = GachaBox(
        id: 'bingo_full_box',
        type: GachaBoxType.bingoGacha,
        name: '빙고 전체 완성',
        description: '9칸 모두 오픈!',
        iconUrl: '🏆',
        minRarity: RewardRarity.legendary,
        maxRarity: RewardRarity.legendary,
        rarityProbability: const {
          RewardRarity.legendary: 100.0,
        },
        isFree: true,
      );
    } else if (openedCount == 6) {
      // 6칸: 에픽 보상
      box = GachaBox(
        id: 'bingo_6_box',
        type: GachaBoxType.bingoGacha,
        name: '빙고 6칸 오픈',
        description: '6칸 오픈 보상',
        iconUrl: '✨',
        minRarity: RewardRarity.rare,
        maxRarity: RewardRarity.epic,
        rarityProbability: const {
          RewardRarity.rare: 50.0,
          RewardRarity.epic: 50.0,
        },
        isFree: true,
      );
    } else {
      // 3칸: 레어 보상
      box = GachaBox(
        id: 'bingo_3_box',
        type: GachaBoxType.bingoGacha,
        name: '빙고 3칸 오픈',
        description: '3칸 오픈 보상',
        iconUrl: '🎁',
        minRarity: RewardRarity.common,
        maxRarity: RewardRarity.rare,
        rarityProbability: const {
          RewardRarity.common: 50.0,
          RewardRarity.rare: 50.0,
        },
        isFree: true,
      );
    }

    final result = await gachaProvider.pullGacha(box);

    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => GachaResultDialog(result: result),
      );
    }
  }

  void _reset() {
    setState(() {
      _opened = List.generate(9, (_) => false);
      _completedLines = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = openedCount == 9;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('빙고 가챠'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 진행도
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4CAF50),
                    const Color(0xFF4CAF50).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '빙고 진행도',
                    style: AppTextStyles.h3.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('오픈', '$openedCount/9', Colors.white),
                      _buildStat('완성 줄', '$_completedLines줄', Colors.white),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 빙고판
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _openCell(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _opened[index]
                            ? const Color(0xFF4CAF50)
                            : AppColors.divider.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _opened[index]
                              ? const Color(0xFF4CAF50)
                              : AppColors.divider,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: _opened[index]
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 40,
                              )
                            : Text(
                                '?',
                                style: AppTextStyles.h1.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // 보상 단계
            Text(
              '보상 단계',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 12),
            _buildRewardMilestone(
                '3칸 오픈', '🎁', '커먼~레어', openedCount >= 3),
            _buildRewardMilestone(
                '6칸 오픈', '✨', '레어~에픽', openedCount >= 6),
            _buildRewardMilestone(
                '9칸 완성', '🏆', '레전더리 확정', openedCount >= 9),

            if (isComplete) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFFD700),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 48,
                      color: Color(0xFFFFD700),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '빙고 완성!',
                      style: AppTextStyles.h2.copyWith(
                        color: const Color(0xFFFFD700),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '새로운 빙고를 시작하세요',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _reset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('새 빙고 시작'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h2.copyWith(
            color: color,
            fontSize: 28,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardMilestone(
      String title, String icon, String reward, bool achieved) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achieved
            ? const Color(0xFF4CAF50).withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achieved
              ? const Color(0xFF4CAF50)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h4),
                Text(
                  reward,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (achieved)
            const Icon(
              Icons.check_circle,
              color: Color(0xFF4CAF50),
            ),
        ],
      ),
    );
  }
}
