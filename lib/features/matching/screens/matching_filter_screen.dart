import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/matching_filter_provider.dart';

class MatchingFilterScreen extends StatefulWidget {
  const MatchingFilterScreen({super.key});

  @override
  State<MatchingFilterScreen> createState() => _MatchingFilterScreenState();
}

class _MatchingFilterScreenState extends State<MatchingFilterScreen> {
  late RangeValues _ageRange;
  List<String> _selectedRegions = [];
  List<String> _selectedReligions = [];
  List<String> _selectedDrinking = [];
  bool _onlyNonSmoking = false;

  // 지역 목록
  final List<String> _regions = [
    '서울',
    '경기',
    '인천',
    '부산',
    '대구',
    '대전',
    '광주',
    '울산',
    '세종',
    '강원',
    '충북',
    '충남',
    '전북',
    '전남',
    '경북',
    '경남',
    '제주',
  ];

  // 종교 목록
  final List<String> _religions = ['무교', '기독교', '천주교', '불교', '기타'];

  // 음주 목록
  final List<String> _drinkingList = ['안마심', '가끔', '자주', '매일'];

  @override
  void initState() {
    super.initState();
    _loadFilter();
  }

  Future<void> _loadFilter() async {
    final authProvider = context.read<AuthProvider>();
    final filterProvider = context.read<MatchingFilterProvider>();

    if (authProvider.user != null) {
      await filterProvider.loadFilter(authProvider.user!.uid);

      if (mounted) {
        setState(() {
          _ageRange = RangeValues(
            filterProvider.filter.minAge.toDouble(),
            filterProvider.filter.maxAge.toDouble(),
          );
          _selectedRegions = List.from(filterProvider.filter.preferredRegions);
          _selectedReligions =
              List.from(filterProvider.filter.preferredReligions);
          _selectedDrinking =
              List.from(filterProvider.filter.preferredDrinking);
          _onlyNonSmoking = filterProvider.filter.onlyNonSmoking;
        });
      }
    }
  }

  Future<void> _saveFilter() async {
    final authProvider = context.read<AuthProvider>();
    final filterProvider = context.read<MatchingFilterProvider>();

    if (authProvider.user == null) return;

    // 나이 범위 저장
    await filterProvider.setAgeRange(
      authProvider.user!.uid,
      _ageRange.start.toInt(),
      _ageRange.end.toInt(),
    );

    // 지역 저장
    await filterProvider.setPreferredRegions(
      authProvider.user!.uid,
      _selectedRegions,
    );

    // 종교 저장
    await filterProvider.setPreferredReligions(
      authProvider.user!.uid,
      _selectedReligions,
    );

    // 음주 저장
    await filterProvider.setPreferredDrinking(
      authProvider.user!.uid,
      _selectedDrinking,
    );

    // 흡연 저장
    await filterProvider.setSmokingFilter(
      authProvider.user!.uid,
      !_onlyNonSmoking,
      _onlyNonSmoking,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필터 설정이 저장되었습니다')),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _resetFilter() async {
    final authProvider = context.read<AuthProvider>();
    final filterProvider = context.read<MatchingFilterProvider>();

    if (authProvider.user == null) return;

    await filterProvider.resetFilter(authProvider.user!.uid);

    setState(() {
      _ageRange = const RangeValues(19, 99);
      _selectedRegions = [];
      _selectedReligions = [];
      _selectedDrinking = [];
      _onlyNonSmoking = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필터가 초기화되었습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filterProvider = context.watch<MatchingFilterProvider>();

    if (filterProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('매칭 필터 설정'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.dividerColor,
            height: 1,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _resetFilter,
            child: Text(
              '초기화',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // 안내 메시지
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '선호하는 조건을 설정하여 더 나은 매칭을 받아보세요!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 나이 범위
          const Text(
            '나이',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_ageRange.start.toInt()}세 ~ ${_ageRange.end.toInt()}세',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          RangeSlider(
            values: _ageRange,
            min: 19,
            max: 99,
            divisions: 80,
            labels: RangeLabels(
              '${_ageRange.start.toInt()}',
              '${_ageRange.end.toInt()}',
            ),
            onChanged: (values) {
              setState(() {
                _ageRange = values;
              });
            },
            activeColor: AppColors.primary,
          ),
          const SizedBox(height: 24),

          // 지역
          Row(
            children: [
              const Text(
                '지역',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              if (_selectedRegions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedRegions.length}개 선택',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _selectedRegions.isEmpty ? '모든 지역' : '선택한 지역만',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _regions.map((region) {
              final isSelected = _selectedRegions.contains(region);
              return FilterChip(
                label: Text(region),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedRegions.add(region);
                    } else {
                      _selectedRegions.remove(region);
                    }
                  });
                },
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey[200],
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 종교
          Row(
            children: [
              const Text(
                '종교',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              if (_selectedReligions.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedReligions.length}개 선택',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _selectedReligions.isEmpty ? '모든 종교' : '선택한 종교만',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _religions.map((religion) {
              final isSelected = _selectedReligions.contains(religion);
              return FilterChip(
                label: Text(religion),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedReligions.add(religion);
                    } else {
                      _selectedReligions.remove(religion);
                    }
                  });
                },
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey[200],
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 음주
          Row(
            children: [
              const Text(
                '음주',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              if (_selectedDrinking.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedDrinking.length}개 선택',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _selectedDrinking.isEmpty ? '모든 음주 빈도' : '선택한 음주 빈도만',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _drinkingList.map((drinking) {
              final isSelected = _selectedDrinking.contains(drinking);
              return FilterChip(
                label: Text(drinking),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDrinking.add(drinking);
                    } else {
                      _selectedDrinking.remove(drinking);
                    }
                  });
                },
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey[200],
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 흡연
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.dividerColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '비흡연자만 매칭',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _onlyNonSmoking ? '비흡연자만 추천' : '흡연 여부 무관',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _onlyNonSmoking,
                  onChanged: (value) {
                    setState(() {
                      _onlyNonSmoking = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 저장 버튼
          PrimaryButton(
            label: '필터 저장',
            onPressed: _saveFilter,
          ),
        ],
      ),
    );
  }
}
