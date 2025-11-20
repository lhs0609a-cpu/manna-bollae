import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class TemperatureGauge extends StatelessWidget {
  final double temperature;
  final double size;

  const TemperatureGauge({
    super.key,
    required this.temperature,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TemperatureGaugePainter(
          temperature: temperature,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${temperature.toStringAsFixed(1)}°',
                style: AppTextStyles.h1.copyWith(
                  fontSize: size * 0.25,
                  fontWeight: FontWeight.bold,
                  color: _getTemperatureColor(temperature),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getLevel(temperature),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: _getTemperatureColor(temperature),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTemperatureColor(double temp) {
    if (temp >= 60) return AppColors.heartTempColors[4];
    if (temp >= 40) return AppColors.heartTempColors[3];
    if (temp >= 20) return AppColors.heartTempColors[2];
    if (temp >= 10) return AppColors.heartTempColors[1];
    return AppColors.heartTempColors[0];
  }

  String _getLevel(double temp) {
    if (temp >= 60) return '뜨거움';
    if (temp >= 40) return '따뜻함';
    if (temp >= 20) return '미지근';
    if (temp >= 10) return '시원함';
    return '차가움';
  }
}

class _TemperatureGaugePainter extends CustomPainter {
  final double temperature;

  _TemperatureGaugePainter({
    required this.temperature,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // 배경 원
    final backgroundPaint = Paint()
      ..color = AppColors.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 온도 호
    final sweepAngle = (temperature / 99.9) * 2 * math.pi * 0.75;
    final startAngle = math.pi * 0.625; // 시작 각도 (오른쪽 하단)

    final temperaturePaint = Paint()
      ..shader = _getGradient(size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      temperaturePaint,
    );

    // 눈금 표시
    _drawTicks(canvas, center, radius);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius) {
    final tickPaint = Paint()
      ..color = AppColors.textSecondary
      ..strokeWidth = 2;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 0, 25, 50, 75, 99.9 눈금
    final ticks = [0.0, 25.0, 50.0, 75.0, 99.9];
    final startAngle = math.pi * 0.625;
    final totalAngle = 2 * math.pi * 0.75;

    for (var tick in ticks) {
      final angle = startAngle + (tick / 99.9) * totalAngle;
      final tickStart = Offset(
        center.dx + (radius - 10) * math.cos(angle),
        center.dy + (radius - 10) * math.sin(angle),
      );
      final tickEnd = Offset(
        center.dx + (radius + 10) * math.cos(angle),
        center.dy + (radius + 10) * math.sin(angle),
      );

      canvas.drawLine(tickStart, tickEnd, tickPaint);

      // 텍스트
      textPainter.text = TextSpan(
        text: tick == 99.9 ? '99.9' : tick.toInt().toString(),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
          fontSize: 10,
        ),
      );
      textPainter.layout();

      final textOffset = Offset(
        center.dx + (radius + 20) * math.cos(angle) - textPainter.width / 2,
        center.dy + (radius + 20) * math.sin(angle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }
  }

  Shader _getGradient(Size size) {
    final colors = [
      AppColors.heartTempColors[0], // 차가움 (파랑)
      AppColors.heartTempColors[1], // 시원함
      AppColors.heartTempColors[2], // 미지근 (초록)
      AppColors.heartTempColors[3], // 따뜻함 (오렌지)
      AppColors.heartTempColors[4], // 뜨거움 (빨강)
    ];

    return SweepGradient(
      colors: colors,
      startAngle: math.pi * 0.625,
      endAngle: math.pi * 0.625 + 2 * math.pi * 0.75,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldRepaint(_TemperatureGaugePainter oldDelegate) {
    return oldDelegate.temperature != temperature;
  }
}
