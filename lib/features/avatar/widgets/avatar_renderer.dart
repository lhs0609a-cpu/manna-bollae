import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

/// 간단한 아바타 렌더러 (이모지 기반)
class AvatarRenderer extends StatelessWidget {
  final Avatar avatar;
  final double size;
  final bool showEmotion;

  const AvatarRenderer({
    super.key,
    required this.avatar,
    this.size = 120,
    this.showEmotion = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getBackgroundColors(),
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: _getBorderColor(),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: _getBorderColor().withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 동물 이모지
          Center(
            child: Text(
              _getAnimalEmoji(avatar.animalType),
              style: TextStyle(fontSize: size * 0.5),
            ),
          ),
          // 감정 표시
          if (showEmotion && avatar.currentOutfit.emotion != null)
            Positioned(
              bottom: size * 0.05,
              right: size * 0.05,
              child: Container(
                padding: EdgeInsets.all(size * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  _getEmotionEmoji(avatar.currentOutfit.emotion!),
                  style: TextStyle(fontSize: size * 0.15),
                ),
              ),
            ),
          // 액세서리 표시
          if (avatar.currentOutfit.accessory != null)
            Positioned(
              top: size * 0.1,
              right: size * 0.1,
              child: Text(
                _getAccessoryEmoji(avatar.currentOutfit.accessory!),
                style: TextStyle(fontSize: size * 0.2),
              ),
            ),
        ],
      ),
    );
  }

  List<Color> _getBackgroundColors() {
    // 선호 색상에 따라 배경 그라데이션 결정
    if (avatar.favoriteColors.isEmpty) {
      return [
        AppColors.primary.withOpacity(0.3),
        AppColors.secondary.withOpacity(0.3),
      ];
    }

    final firstColor = _getColorFromName(avatar.favoriteColors.first);
    final secondColor = avatar.favoriteColors.length > 1
        ? _getColorFromName(avatar.favoriteColors[1])
        : firstColor.withOpacity(0.7);

    return [
      firstColor.withOpacity(0.4),
      secondColor.withOpacity(0.4),
    ];
  }

  Color _getBorderColor() {
    // 스타일에 따라 테두리 색상 결정
    switch (avatar.style) {
      case '포멀':
        return Colors.black87;
      case '스포티':
        return Colors.blue;
      case '힙합':
        return Colors.purple;
      case '빈티지':
        return Colors.brown;
      case '아트':
        return Colors.deepPurple;
      default:
        return AppColors.primary;
    }
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case '빨강':
        return Colors.red;
      case '주황':
        return Colors.orange;
      case '노랑':
        return Colors.yellow;
      case '초록':
        return Colors.green;
      case '파랑':
        return Colors.blue;
      case '남색':
        return Colors.indigo;
      case '보라':
        return Colors.purple;
      case '핑크':
        return Colors.pink;
      case '흰색':
        return Colors.white;
      case '검정':
        return Colors.black;
      default:
        return AppColors.primary;
    }
  }

  String _getAnimalEmoji(String animal) {
    switch (animal) {
      case '고양이':
        return '🐱';
      case '강아지':
        return '🐶';
      case '토끼':
        return '🐰';
      case '곰':
        return '🐻';
      case '여우':
        return '🦊';
      case '팬더':
        return '🐼';
      case '호랑이':
        return '🐯';
      case '사자':
        return '🦁';
      default:
        return '😊';
    }
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion) {
      case '미소':
        return '😊';
      case '웃음':
        return '😄';
      case '사랑':
        return '😍';
      case '윙크':
        return '😉';
      case '쿨':
        return '😎';
      case '생각':
        return '🤔';
      case '놀람':
        return '😲';
      case '행복':
        return '🥰';
      default:
        return '😊';
    }
  }

  String _getAccessoryEmoji(String accessory) {
    switch (accessory) {
      case '안경':
        return '👓';
      case '모자':
        return '🎩';
      case '왕관':
        return '👑';
      case '나비넥타이':
        return '🎀';
      case '꽃':
        return '🌸';
      case '별':
        return '⭐';
      default:
        return '✨';
    }
  }
}

/// 아바타 미리보기 (작은 크기)
class AvatarPreview extends StatelessWidget {
  final Avatar avatar;
  final double size;

  const AvatarPreview({
    super.key,
    required this.avatar,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return AvatarRenderer(
      avatar: avatar,
      size: size,
      showEmotion: false,
    );
  }
}

/// 아바타가 없을 때 기본 아바타
class DefaultAvatar extends StatelessWidget {
  final String name;
  final double size;

  const DefaultAvatar({
    super.key,
    required this.name,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary,
          width: 3,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : '?',
          style: AppTextStyles.h1.copyWith(
            fontSize: size * 0.4,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
