import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../matching/providers/matching_provider.dart';
import '../providers/gacha_provider.dart';
import '../../../models/dice_gacha_model.dart';

/// 주사위 가챠 카드 위젯
class DiceGachaCard extends StatefulWidget {
  const DiceGachaCard({super.key});

  @override
  State<DiceGachaCard> createState() => _DiceGachaCardState();
}

class _DiceGachaCardState extends State<DiceGachaCard> with TickerProviderStateMixin {
  Timer? _countdownTimer;
  int _remainingSeconds = 0;
  late List<AnimationController> _diceControllers;
  late List<Animation<double>> _diceScaleAnimations;
  late List<AnimationController> _diceRotationControllers;
  late List<Animation<double>> _diceRotationAnimations;
  List<int> _rollingNumbers = [1, 1, 1]; // 굴리는 중 보여줄 숫자
  List<Timer?> _numberTimers = [null, null, null];

  @override
  void initState() {
    super.initState();

    // 3개의 주사위 스케일 애니메이션 컨트롤러 생성
    _diceControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ),
    );

    _diceScaleAnimations = _diceControllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      );
    }).toList();

    // 3개의 주사위 2D 회전 애니메이션 컨트롤러 생성 (웹 호환)
    _diceRotationControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _diceRotationAnimations = _diceRotationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 2 * pi).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final gachaProvider = context.read<GachaProvider>();
      if (gachaProvider.diceProgress != null) {
        final seconds = gachaProvider.diceProgress!.secondsUntilNextRoll;
        setState(() {
          _remainingSeconds = seconds;
        });
        if (seconds <= 0) {
          timer.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (var controller in _diceControllers) {
      controller.dispose();
    }
    for (var controller in _diceRotationControllers) {
      controller.dispose();
    }
    for (var timer in _numberTimers) {
      timer?.cancel();
    }
    super.dispose();
  }

  // 주사위 3개 모두 굴리기
  Future<void> _rollAllDice() async {
    print('🎲 주사위 굴리기 버튼 클릭됨!');

    final authProvider = context.read<AuthProvider>();
    final gachaProvider = context.read<GachaProvider>();

    if (!authProvider.isAuthenticated) {
      print('⚠️ 유저가 로그인되어 있지 않습니다');
      return;
    }

    if (gachaProvider.diceProgress == null) {
      print('⚠️ diceProgress가 null입니다');
      return;
    }

    if (!gachaProvider.diceProgress!.canRollAgain) {
      print('⚠️ 아직 다시 굴릴 수 없습니다 (쿨타임)');
      return;
    }

    // 이전 결과가 있다면 초기화
    if (gachaProvider.currentDiceResults.isNotEmpty) {
      print('🔄 이전 주사위 결과 초기화');
      gachaProvider.resetCurrentDiceRoll();
      await Future.delayed(const Duration(milliseconds: 100));
    }

    print('✅ 주사위 굴리기 시작!');

    // 3개를 순차적으로 굴림
    for (int i = 0; i < 3; i++) {
      print('🎲 주사위 $i 굴리는 중...');
      await _rollDice(i);
      // 각 주사위 사이에 약간의 딜레이 (애니메이션 효과)
      if (i < 2) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    print('✅ 모든 주사위 굴리기 완료!');
  }

  Future<void> _rollDice(int index) async {
    final authProvider = context.read<AuthProvider>();
    final gachaProvider = context.read<GachaProvider>();

    if (!authProvider.isAuthenticated) return;

    // 이미 굴린 주사위는 다시 굴릴 수 없음
    if (gachaProvider.currentDiceResults.length > index) return;

    // 회전 애니메이션 시작
    _diceRotationControllers[index].forward(from: 0);

    // 숫자가 빠르게 변하는 애니메이션
    _numberTimers[index]?.cancel();
    _numberTimers[index] = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          _rollingNumbers[index] = Random().nextInt(6) + 1;
        });
      }
    });

    final result = await gachaProvider.rollSingleDice();

    // 숫자 변경 타이머 중지
    _numberTimers[index]?.cancel();
    _numberTimers[index] = null;

    if (result != null && mounted) {
      // 최종 결과 표시를 위한 스케일 애니메이션
      setState(() {
        _rollingNumbers[index] = result;
      });
      _diceControllers[index].forward(from: 0);

      // 3개 모두 굴렸다면
      if (gachaProvider.currentDiceResults.length == 3) {
        _startCountdown();

        // 결과 생성하여 보너스 계산
        final diceResult = DiceGachaResult(
          dice1: gachaProvider.currentDiceResults[0],
          dice2: gachaProvider.currentDiceResults[1],
          dice3: gachaProvider.currentDiceResults[2],
          rolledAt: DateTime.now(),
        );

        // 보너스가 있는 경우 (FAIL 제외)
        if (diceResult.bonusMatches > 0) {
          final matchingProvider = context.read<MatchingProvider>();
          await matchingProvider.addBonusMatches(diceResult.bonusMatches);

          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            _showResultDialog(diceResult);
          }
        } else {
          // FAIL인 경우에도 다이얼로그 표시
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            _showResultDialog(diceResult);
          }
        }
      }
    }
  }

  void _showResultDialog(DiceGachaResult result) {
    String title;
    String message;
    IconData icon;
    Color iconColor;

    switch (result.rarity) {
      case DiceRarity.ssr:
        title = '🏆 SSR! 대박!';
        message = '6-6-6! 완벽한 잭팟입니다!';
        icon = Icons.military_tech;
        iconColor = const Color(0xFFFFD700);
        break;
      case DiceRarity.sr:
        title = '⭐ SR! 축하합니다!';
        message = '세 주사위가 모두 ${result.dice1}입니다!';
        icon = Icons.stars;
        iconColor = const Color(0xFF8B5CF6);
        break;
      case DiceRarity.r:
        title = '💎 R! 성공!';
        message = '세 주사위가 모두 ${result.dice1}입니다!';
        icon = Icons.diamond;
        iconColor = const Color(0xFF3B82F6);
        break;
      case DiceRarity.n:
        title = '✨ N! 두 개 매칭!';
        message = '두 개가 같은 숫자입니다!';
        icon = Icons.auto_awesome;
        iconColor = const Color(0xFF10B981);
        break;
      case DiceRarity.fail:
        title = '💫 아쉽네요!';
        message = '모두 다른 숫자가 나왔습니다.';
        icon = Icons.sentiment_dissatisfied;
        iconColor = Colors.grey;
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(width: 12),
            Text(title, style: AppTextStyles.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: _getRarityGradient(result.rarity).gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                result.bonusMatches > 0
                    ? '매칭 +${result.bonusMatches}'
                    : '보상 없음',
                style: AppTextStyles.h2.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final gachaProvider = context.read<GachaProvider>();
              gachaProvider.resetCurrentDiceRoll();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 등급별 색상 가져오기
  ({LinearGradient gradient, Color shadowColor}) _getRarityGradient(DiceRarity rarity) {
    switch (rarity) {
      case DiceRarity.ssr:
        // 🏆 SSR: 황금색
        return (
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFD700), // Gold
              Color(0xFFFFA500), // Orange
              Color(0xFFFF8C00), // Dark Orange
            ],
          ),
          shadowColor: const Color(0xFFFFD700),
        );
      case DiceRarity.sr:
        // ⭐ SR: 보라색
        return (
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
              Color(0xFFA855F7),
            ],
          ),
          shadowColor: const Color(0xFF8B5CF6),
        );
      case DiceRarity.r:
        // 💎 R: 파란색
        return (
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF3B82F6),
              Color(0xFF2563EB),
              Color(0xFF1D4ED8),
            ],
          ),
          shadowColor: const Color(0xFF3B82F6),
        );
      case DiceRarity.n:
        // ✨ N: 초록색
        return (
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF10B981),
              Color(0xFF059669),
            ],
          ),
          shadowColor: const Color(0xFF10B981),
        );
      case DiceRarity.fail:
        // 💫 FAIL: 회색-빨강
        return (
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[600]!,
              Colors.grey[700]!,
            ],
          ),
          shadowColor: Colors.grey,
        );
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GachaProvider>(
      builder: (context, gachaProvider, child) {
        final diceProgress = gachaProvider.diceProgress;
        final canRoll = diceProgress?.canRollAgain ?? false;
        final currentResults = gachaProvider.currentDiceResults;

        // 간소화된 주사위 카드 (애니메이션 없이)
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                Colors.purple.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.casino, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('럭키 주사위', style: AppTextStyles.h4),
                      Text(
                        '같은 숫자 = 매칭 획득!',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 주사위 굴리기 버튼 또는 쿨타임 카운트다운
              Container(
                width: double.infinity,
                height: 56,
                margin: const EdgeInsets.only(bottom: 20),
                child: canRoll
                    ? ElevatedButton(
                        onPressed: _rollAllDice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primary.withOpacity(0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.casino, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              '주사위 굴리기',
                              style: AppTextStyles.h4.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange[400]!,
                              Colors.red[400]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.timer,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _formatTime(_remainingSeconds),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '후 재도전!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),

              // 주사위 3개 - 3D 트렌디 스타일 (클릭 가능)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  final canRollThis = currentResults.length == index && (canRoll || currentResults.isEmpty);
                  final hasResult = currentResults.length > index;
                  final value = hasResult ? currentResults[index] : (canRollThis ? null : null);
                  final displayValue = hasResult ? currentResults[index] : _rollingNumbers[index];
                  final isActive = value != null;

                  // 등급 계산 (3개 모두 굴렸을 때)
                  DiceRarity? rarity;
                  if (currentResults.length == 3) {
                    final tempResult = DiceGachaResult(
                      dice1: currentResults[0],
                      dice2: currentResults[1],
                      dice3: currentResults[2],
                      rolledAt: DateTime.now(),
                    );
                    rarity = tempResult.rarity;
                  }

                  // 등급에 따른 색상 가져오기
                  LinearGradient diceGradient;
                  Color shadowColor;

                  if (isActive && rarity != null) {
                    // 3개 모두 굴림 - 등급별 색상
                    final rarityColors = _getRarityGradient(rarity);
                    diceGradient = rarityColors.gradient;
                    shadowColor = rarityColors.shadowColor;
                  } else if (isActive) {
                    // 일부만 굴림 - 기본 보라색
                    diceGradient = const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF8B5CF6),
                        Color(0xFFA855F7),
                      ],
                    );
                    shadowColor = const Color(0xFF8B5CF6);
                  } else if (canRollThis) {
                    // 굴릴 수 있음 - 초록색
                    diceGradient = const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF10B981),
                        Color(0xFF059669),
                      ],
                    );
                    shadowColor = const Color(0xFF10B981);
                  } else {
                    // 비활성 - 회색
                    diceGradient = LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[400]!,
                        Colors.grey[500]!,
                      ],
                    );
                    shadowColor = Colors.grey;
                  }

                  return MouseRegion(
                    cursor: canRollThis ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
                    child: GestureDetector(
                      onTap: canRollThis ? () {
                        print('🎲 주사위 $index 클릭됨!');
                        _rollDice(index);
                      } : null,
                      child: AnimatedBuilder(
                        animation: _diceRotationAnimations[index],
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _diceRotationAnimations[index].value,
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                gradient: diceGradient,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: shadowColor.withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(-5, -5),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // 반짝이는 효과
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.3),
                                            Colors.transparent,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                  // 중앙 컨텐츠
                                  Center(
                                    child: hasResult || _numberTimers[index] != null
                                        ? Text(
                                            '$displayValue',
                                            style: const TextStyle(
                                              fontSize: 48,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(2, 2),
                                                  blurRadius: 4,
                                                  color: Colors.black26,
                                                ),
                                              ],
                                            ),
                                          )
                                        : canRollThis
                                            ? Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.casino,
                                                    color: Colors.white,
                                                    size: 36,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  const Text(
                                                    'ROLL!',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                      letterSpacing: 1.5,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Icon(
                                                Icons.lock_outline,
                                                color: Colors.white.withOpacity(0.5),
                                                size: 32,
                                              ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // 통계
              if (diceProgress != null) ...[
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('총 도전', '${diceProgress.totalRolls}회'),
                    _buildStat('성공', '${diceProgress.totalJackpots}회'),
                    _buildStat('획득 매칭', '+${diceProgress.totalBonusMatches}'),
                  ],
                ),
              ],
            ],
          ),
        );

        /* 원래 코드 - 주석 처리
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                Colors.purple.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.casino, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('럭키 주사위', style: AppTextStyles.h4),
                          Text(
                            '같은 숫자 = 매칭 획득!',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!canRoll && currentResults.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(_remainingSeconds),
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // 주사위 3개
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  return _buildDice(
                    index,
                    currentResults.length > index ? currentResults[index] : null,
                    canRoll || currentResults.isNotEmpty,
                  );
                }),
              ),
              const SizedBox(height: 16),

              // 통계
              if (diceProgress != null) ...[
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('총 도전', '${diceProgress.totalRolls}회'),
                    _buildStat('성공', '${diceProgress.totalJackpots}회'),
                    _buildStat('획득 매칭', '+${diceProgress.totalBonusMatches}'),
                  ],
                ),
              ],
            ],
          ),
        );
        */
      },
    );
  }

  Widget _buildDice(int index, int? value, bool enabled) {
    final gachaProvider = context.watch<GachaProvider>();
    final currentResults = gachaProvider.currentDiceResults;
    final canRollThis = enabled && currentResults.length == index;
    final isRolling = gachaProvider.isRollingDice && currentResults.length == index;

    return GestureDetector(
      onTap: canRollThis && !isRolling ? () => _rollDice(index) : null,
      child: AnimatedBuilder(
        animation: _diceRotationAnimations[index],
        builder: (context, child) {
          return Transform.rotate(
            angle: _diceRotationAnimations[index].value,
            child: ScaleTransition(
              scale: _diceScaleAnimations[index],
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: value != null
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            Colors.purple,
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[300]!,
                            Colors.grey[400]!,
                          ],
                        ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (value != null ? AppColors.primary : Colors.grey).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: isRolling || (value == null && _numberTimers[index] != null)
                      ? Text(
                          '${_rollingNumbers[index]}',
                          style: AppTextStyles.h1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : value != null
                          ? Text(
                              '$value',
                              style: AppTextStyles.h1.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : canRollThis
                              ? Icon(
                                  Icons.touch_app,
                                  color: Colors.white,
                                  size: 32,
                                )
                              : Icon(
                                  Icons.lock,
                                  color: Colors.white.withOpacity(0.5),
                                  size: 32,
                                ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
