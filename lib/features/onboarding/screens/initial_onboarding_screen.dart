import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../providers/daily_mission_provider.dart';

class InitialOnboardingScreen extends StatefulWidget {
  const InitialOnboardingScreen({super.key});

  @override
  State<InitialOnboardingScreen> createState() =>
      _InitialOnboardingScreenState();
}

class _InitialOnboardingScreenState extends State<InitialOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // 사용자 입력 데이터
  String? name;
  int? age;
  String? gender;
  String? region;
  String? job;
  int? height;
  String? oneLiner;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    // 모든 필수 정보 저장 (SharedPreferences 등)
    // 여기서는 간단히 완료 플래그만 저장
    final provider = context.read<DailyMissionProvider>();

    // 초기 온보딩 완료 표시를 위한 특별 미션 완료 처리
    await provider.completeMission(0, {
      'name': name,
      'age': age,
      'gender': gender,
      'region': region,
      'job': job,
      'height': height,
      'oneLiner': oneLiner,
    });

    if (mounted) {
      // 30일 챌린지 화면으로 이동
      Navigator.of(context).pushReplacementNamed('/daily-mission');
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return name != null && name!.isNotEmpty;
      case 1:
        return age != null;
      case 2:
        return gender != null;
      case 3:
        return region != null;
      case 4:
        return job != null;
      case 5:
        return height != null;
      case 6:
        return oneLiner != null && oneLiner!.isNotEmpty;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildNameStep(),
                    _buildAgeStep(),
                    _buildGenderStep(),
                    _buildRegionStep(),
                    _buildJobStep(),
                    _buildHeightStep(),
                    _buildOneLinerStep(),
                  ],
                ),
              ),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_currentStep > 0)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _previousStep,
                )
              else
                const SizedBox(width: 48),
              const Spacer(),
              Text(
                '${_currentStep + 1}/7',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: (_currentStep + 1) / 7,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _canProceed() ? _nextStep : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            _currentStep == 6 ? '시작하기' : '다음',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContainer({
    required String emoji,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 80),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),
          child,
        ],
      ),
    );
  }

  Widget _buildNameStep() {
    return _buildStepContainer(
      emoji: '👋',
      title: '반가워요!',
      subtitle: '당신의 이름을 알려주세요',
      child: TextField(
        autofocus: true,
        onChanged: (value) {
          setState(() {
            name = value;
          });
        },
        decoration: InputDecoration(
          hintText: '이름을 입력하세요',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildAgeStep() {
    return _buildStepContainer(
      emoji: '🎂',
      title: '나이',
      subtitle: '몇 살이신가요?',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${age ?? 25}세',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Slider(
            value: (age ?? 25).toDouble(),
            min: 19,
            max: 60,
            divisions: 41,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                age = value.toInt();
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('19세', style: TextStyle(color: Colors.grey[600])),
              Text('60세', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderStep() {
    return _buildStepContainer(
      emoji: '⚧',
      title: '성별',
      subtitle: '성별을 선택해주세요',
      child: Row(
        children: [
          Expanded(
            child: _buildChoiceButton(
              label: '남성',
              isSelected: gender == '남성',
              onTap: () {
                setState(() {
                  gender = '남성';
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildChoiceButton(
              label: '여성',
              isSelected: gender == '여성',
              onTap: () {
                setState(() {
                  gender = '여성';
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionStep() {
    final regions = ['서울', '경기', '인천', '부산', '대구', '광주', '대전', '울산', '세종', '기타'];

    return _buildStepContainer(
      emoji: '📍',
      title: '거주지',
      subtitle: '어디에 살고 계신가요?',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: regions.map((r) {
          return _buildChoiceButton(
            label: r,
            isSelected: region == r,
            onTap: () {
              setState(() {
                region = r;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildJobStep() {
    final jobs = ['회사원', '공무원', '전문직', '자영업', '프리랜서', '학생', '기타'];

    return _buildStepContainer(
      emoji: '💼',
      title: '직업',
      subtitle: '어떤 일을 하시나요?',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: jobs.map((j) {
          return _buildChoiceButton(
            label: j,
            isSelected: job == j,
            onTap: () {
              setState(() {
                job = j;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeightStep() {
    return _buildStepContainer(
      emoji: '📏',
      title: '키',
      subtitle: '키는 어떻게 되시나요?',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${height ?? 170}cm',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Slider(
            value: (height ?? 170).toDouble(),
            min: 140,
            max: 200,
            divisions: 60,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                height = value.toInt();
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('140cm', style: TextStyle(color: Colors.grey[600])),
              Text('200cm', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOneLinerStep() {
    return _buildStepContainer(
      emoji: '✨',
      title: '한 줄 소개',
      subtitle: '자신을 한 줄로 표현해주세요',
      child: TextField(
        autofocus: true,
        maxLines: 3,
        onChanged: (value) {
          setState(() {
            oneLiner = value;
          });
        },
        decoration: InputDecoration(
          hintText: '예: 활발하고 긍정적인 사람입니다',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
