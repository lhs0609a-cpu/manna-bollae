import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../providers/gacha_provider.dart';
import '../models/gacha_box.dart';
import '../models/gacha_reward.dart';
import '../widgets/gacha_result_dialog.dart';

class MissionSlotScreen extends StatefulWidget {
  const MissionSlotScreen({super.key});

  @override
  State<MissionSlotScreen> createState() => _MissionSlotScreenState();
}

class _MissionSlotScreenState extends State<MissionSlotScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  bool _isSpinning = false;
  final List<String> _symbols = ['⭐', '💎', '👑', '🎁', '💰', '🏆', '✨'];
  List<int> _currentSymbols = [0, 0, 0];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _randomizeSymbols();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _randomizeSymbols() {
    final random = math.Random();
    setState(() {
      _currentSymbols = List.generate(3, (_) => random.nextInt(_symbols.length));
    });
  }

  Future<void> _spinSlot() async {
    if (_isSpinning) return;

    setState(() => _isSpinning = true);

    // 슬롯 애니메이션
    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      _randomizeSymbols();
    }

    // 가챠 뽑기
    final gachaProvider = context.read<GachaProvider>();
    final slotBox = GachaBox(
      id: 'mission_slot_box',
      type: GachaBoxType.missionSlot,
      name: '미션 슬롯머신',
      description: '일일 미션 완료 보상',
      iconUrl: '🎲',
      minRarity: RewardRarity.common,
      maxRarity: RewardRarity.legendary,
      rarityProbability: const {
        RewardRarity.common: 40.0,
        RewardRarity.rare: 35.0,
        RewardRarity.epic: 20.0,
        RewardRarity.legendary: 5.0,
      },
      isFree: true,
    );

    final result = await gachaProvider.pullGacha(slotBox);

    // 결과에 따라 심볼 맞추기 (시각적 효과)
    final random = math.Random();
    switch (result.reward.rarity) {
      case RewardRarity.legendary:
        // 잭팟! 3개 같은 심볼
        final symbol = random.nextInt(_symbols.length);
        setState(() {
          _currentSymbols = [symbol, symbol, symbol];
        });
        break;
      case RewardRarity.epic:
        // 2개 같은 심볼
        final symbol = random.nextInt(_symbols.length);
        setState(() {
          _currentSymbols = [symbol, symbol, random.nextInt(_symbols.length)];
        });
        break;
      default:
        _randomizeSymbols();
    }

    setState(() => _isSpinning = false);

    // 결과 표시
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => GachaResultDialog(result: result),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allSame = _currentSymbols[0] == _currentSymbols[1] &&
        _currentSymbols[1] == _currentSymbols[2];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('미션 슬롯머신'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 설명
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF9C27B0).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF9C27B0)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '일일 미션 3개를 완료하면 슬롯머신을 돌릴 수 있어요!',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 슬롯머신
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF9C27B0),
                    const Color(0xFF9C27B0).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '🎰 슬롯머신 🎰',
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 24),

                  // 슬롯 릴
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        width: 80,
                        height: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _symbols[_currentSymbols[index]],
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // 잭팟 표시
                  if (allSame && !_isSpinning)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '🎉 JACKPOT! 🎉',
                        style: AppTextStyles.h4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // 스핀 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSpinning ? null : _spinSlot,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: const Color(0xFF9C27B0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                      child: _isSpinning
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'SPIN!',
                              style: AppTextStyles.button.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 보상 확률
            Text(
              '보상 확률',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 16),
            _buildProbabilityCard('3개 일치', '잭팟 (레전더리)', '5%', Colors.amber),
            _buildProbabilityCard('2개 일치', '에픽 보상', '20%', Colors.purple),
            _buildProbabilityCard('일반', '커먼~레어 보상', '75%', Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildProbabilityCard(
      String condition, String reward, String probability, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                probability,
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(condition, style: AppTextStyles.h4),
                Text(
                  reward,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
