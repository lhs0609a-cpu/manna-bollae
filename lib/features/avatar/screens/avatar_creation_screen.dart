import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/avatar_provider.dart';
import '../widgets/avatar_renderer.dart';

class AvatarCreationScreen extends StatefulWidget {
  const AvatarCreationScreen({super.key});

  @override
  State<AvatarCreationScreen> createState() => _AvatarCreationScreenState();
}

class _AvatarCreationScreenState extends State<AvatarCreationScreen> {
  String? _selectedAnimal;
  String? _selectedPersonality;
  String? _selectedStyle;
  final List<String> _selectedColors = [];

  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    final avatarProvider = context.watch<AvatarProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('아바타 만들기'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 안내 텍스트
            Center(
              child: Column(
                children: [
                  Text(
                    '나를 표현하는 아바타를 만들어보세요!',
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '나중에 언제든지 변경할 수 있습니다',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // 미리보기
            if (_selectedAnimal != null)
              Center(
                child: AvatarRenderer(
                  avatar: Avatar(
                    animalType: _selectedAnimal!,
                    personality: _selectedPersonality ?? '활발한',
                    style: _selectedStyle ?? '캐주얼',
                    colorPreference: _selectedColors.isNotEmpty ? _selectedColors.first : '파란색',
                    hobby: '',
                    baseCharacter: _selectedAnimal!,
                    currentOutfit: AvatarOutfit(
                      top: '기본 상의',
                      bottom: '기본 하의',
                      accessories: [],
                      hair: '기본 헤어',
                      hairColor: '검정',
                      background: '기본 배경',
                      specialItem: '',
                      emotion: '미소',
                    ),
                    ownedItems: OwnedItems(
                      tops: [],
                      bottoms: [],
                      accessories: [],
                      hairs: [],
                      backgrounds: [],
                      specialItems: [],
                    ),
                  ),
                  size: 150,
                ),
              ),
            const SizedBox(height: 32),
            // 동물 선택
            Text(
              '동물 타입',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: avatarProvider.availableAnimals.map((animal) {
                final isSelected = _selectedAnimal == animal;
                return ChoiceChip(
                  label: Text(animal),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedAnimal = selected ? animal : null;
                    });
                  },
                  selectedColor: AppColors.primary,
                  labelStyle: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // 성격 선택
            Text(
              '성격',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: avatarProvider.availablePersonalities.map((personality) {
                final isSelected = _selectedPersonality == personality;
                return ChoiceChip(
                  label: Text(personality),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPersonality = selected ? personality : null;
                    });
                  },
                  selectedColor: AppColors.secondary,
                  labelStyle: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // 스타일 선택
            Text(
              '스타일',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: avatarProvider.availableStyles.map((style) {
                final isSelected = _selectedStyle == style;
                return ChoiceChip(
                  label: Text(style),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStyle = selected ? style : null;
                    });
                  },
                  selectedColor: AppColors.accent,
                  labelStyle: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // 선호 색상 선택 (최대 3개)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '선호 색상',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_selectedColors.length}/3',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: avatarProvider.availableColors.map((color) {
                final isSelected = _selectedColors.contains(color);
                return FilterChip(
                  label: Text(color),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (_selectedColors.length < 3) {
                          _selectedColors.add(color);
                        }
                      } else {
                        _selectedColors.remove(color);
                      }
                    });
                  },
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            // 생성 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canCreate() && !_isCreating ? _createAvatar : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: AppColors.borderColor,
                ),
                child: _isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        '아바타 생성하기',
                        style: AppTextStyles.buttonRegular.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canCreate() {
    return _selectedAnimal != null &&
        _selectedPersonality != null &&
        _selectedStyle != null &&
        _selectedColors.isNotEmpty;
  }

  Future<void> _createAvatar() async {
    if (!_canCreate()) return;

    setState(() {
      _isCreating = true;
    });

    final authProvider = context.read<AuthProvider>();
    final avatarProvider = context.read<AvatarProvider>();

    if (authProvider.user == null) return;

    final success = await avatarProvider.createAvatar(
      userId: authProvider.user!.uid,
      animalType: _selectedAnimal!,
      personality: _selectedPersonality!,
      style: _selectedStyle!,
      favoriteColors: _selectedColors,
    );

    setState(() {
      _isCreating = false;
    });

    if (success && mounted) {
      // 성공 다이얼로그
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.celebration,
                color: AppColors.success,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text('아바타 생성 완료!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AvatarRenderer(
                avatar: avatarProvider.avatar!,
                size: 120,
              ),
              const SizedBox(height: 16),
              Text(
                '멋진 아바타가 만들어졌어요!\n언제든지 커스터마이징할 수 있습니다',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context); // 생성 화면 닫기
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else if (avatarProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(avatarProvider.error!)),
      );
      avatarProvider.clearError();
    }
  }
}
