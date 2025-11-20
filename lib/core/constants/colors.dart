import 'package:flutter/material.dart';

class AppColors {
  // Modern Instagram-like Primary Colors
  static const Color primary = Color(0xFFE91E63); // 핫핑크
  static const Color secondary = Color(0xFF7C4DFF); // 딥퍼플
  static const Color accent = Color(0xFFFF6F00); // 딥오렌지
  static const Color highlight = Color(0xFF00BCD4); // 사이안

  // Background Colors - 다크모드 지원
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF121212);
  static const Color cardBackground = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF8E8E8E);
  static const Color textHint = Color(0xFFC7C7C7);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Trust Score Colors (진심 지수)
  static const Color trustLevel1 = Color(0xFFE8F5E9); // 새싹 - 연한 초록
  static const Color trustLevel2 = Color(0xFFC8E6C9); // 새내기
  static const Color trustLevel3 = Color(0xFF81C784); // 일반
  static const Color trustLevel4 = Color(0xFF66BB6A); // 믿음직한
  static const Color trustLevel5 = Color(0xFF4CAF50); // 진심왕

  // Heart Temperature Colors (하트 온도)
  static const Color tempCold = Color(0xFF90CAF9); // 차가움 (0-20°C)
  static const Color tempCool = Color(0xFF81C784); // 시원함 (20-30°C)
  static const Color tempWarm = Color(0xFFFFB74D); // 미지근 (30-40°C)
  static const Color tempHot = Color(0xFFFF8A65); // 따뜻함 (40-60°C)
  static const Color tempBurning = Color(0xFFEF5350); // 뜨거움 (60-100°C)

  // VIP Colors
  static const Color vipBasic = Color(0xFFFFD700); // 골드
  static const Color vipPremium = Color(0xFFE6E6FA); // 플래티넘
  static const Color vipPlatinum = Color(0xFFB9F2FF); // 다이아몬드

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
  // Aliases for compatibility
  static const Color borderColor = border;
  static const Color dividerColor = divider;

  // Trust Score Color List
  static const List<Color> trustScoreColors = [
    trustLevel1, // 0-19
    trustLevel2, // 20-39
    trustLevel3, // 40-59
    trustLevel4, // 60-79
    trustLevel5, // 80-100
  ];

  // Heart Temperature Color List
  static const List<Color> heartTempColors = [
    tempCold,    // 0-19
    tempCool,    // 20-39
    tempWarm,    // 40-59
    tempHot,     // 60-79
    tempBurning, // 80-100
  ];

  // VIP Gold Alias
  static const Color vipGold = vipBasic;

  // Modern Instagram-like Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFF7C4DFF), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF6F00), Color(0xFFE91E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coolGradient = LinearGradient(
    colors: [Color(0xFF00BCD4), Color(0xFF7C4DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient storyGradient = LinearGradient(
    colors: [Color(0xFFFFD600), Color(0xFFFF6F00), Color(0xFFE91E63), Color(0xFF7C4DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 틱톡 스타일 다크 그라데이션
  static const LinearGradient tiktokGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF1A1A1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
