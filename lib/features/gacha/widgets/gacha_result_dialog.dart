import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../models/gacha_box.dart';

class GachaResultDialog extends StatefulWidget {
  final GachaResult result;

  const GachaResultDialog({
    super.key,
    required this.result,
  });

  @override
  State<GachaResultDialog> createState() => _GachaResultDialogState();
}

class _GachaResultDialogState extends State<GachaResultDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // 스케일 애니메이션
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // 회전 애니메이션
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // 빛나는 효과
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // 애니메이션 시작
    _scaleController.forward();
    _rotationController.repeat();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Color _getRarityColor() {
    return Color(
      int.parse(
        widget.result.reward.rarityColor.replaceFirst('#', '0xFF'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 닫기 버튼
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // 희귀도 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: rarityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: rarityColor, width: 2),
              ),
              child: Text(
                widget.result.reward.rarityName,
                style: AppTextStyles.h4.copyWith(
                  color: rarityColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 보상 아이콘 (애니메이션)
            AnimatedBuilder(
              animation: Listenable.merge([
                _scaleAnimation,
                _rotationAnimation,
                _glowAnimation,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 빛나는 배경
                      Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Container(
                          width: 150 * _glowAnimation.value,
                          height: 150 * _glowAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                rarityColor.withOpacity(0.3),
                                rarityColor.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // 아이콘
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: rarityColor.withOpacity(0.1),
                          border: Border.all(
                            color: rarityColor,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.result.reward.iconUrl,
                            style: const TextStyle(fontSize: 64),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // 보상 이름
            Text(
              widget.result.reward.name,
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // 보상 설명
            Text(
              widget.result.reward.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // NEW 뱃지 (처음 획득한 경우)
            if (widget.result.isNew) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '처음 획득한 보상!',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 확인 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: rarityColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
