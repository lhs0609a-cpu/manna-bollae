import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../providers/daily_mission_provider.dart';
import '../models/daily_mission.dart';

class DailyMissionScreen extends StatefulWidget {
  const DailyMissionScreen({super.key});

  @override
  State<DailyMissionScreen> createState() => _DailyMissionScreenState();
}

class _DailyMissionScreenState extends State<DailyMissionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  String? _textAnswer;
  String? _selectedChoice;
  List<String> _selectedMultiChoices = [];
  int? _rangeValue;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    // 진행도 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DailyMissionProvider>().loadProgress();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _completeMission(BuildContext context, DailyMission mission) async {
    dynamic answer;

    switch (mission.type) {
      case MissionType.text:
        if (_textAnswer == null || _textAnswer!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('답변을 입력해주세요')),
          );
          return;
        }
        answer = _textAnswer;
        break;
      case MissionType.choice:
        if (_selectedChoice == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('항목을 선택해주세요')),
          );
          return;
        }
        answer = _selectedChoice;
        break;
      case MissionType.multiChoice:
        if (_selectedMultiChoices.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('최소 1개 이상 선택해주세요')),
          );
          return;
        }
        answer = _selectedMultiChoices;
        break;
      case MissionType.range:
        if (_rangeValue == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('값을 선택해주세요')),
          );
          return;
        }
        answer = _rangeValue;
        break;
      case MissionType.photo:
        answer = 'photo_path'; // 실제로는 이미지 업로드 구현
        break;
    }

    final provider = context.read<DailyMissionProvider>();
    final success = await provider.completeMission(mission.day, answer);

    if (success && mounted) {
      // 성공 애니메이션
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildSuccessDialog(mission),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pop(); // 다이얼로그 닫기

        // 100일 완료 여부 확인
        if (provider.hasCompletedAllMissions) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          // 다음 미션 준비
          setState(() {
            _textAnswer = null;
            _selectedChoice = null;
            _selectedMultiChoices = [];
            _rangeValue = null;
          });

          _animationController.reset();
          _animationController.forward();
        }
      }
    }
  }

  Widget _buildSuccessDialog(DailyMission mission) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mission.icon ?? '🎉',
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              const Text(
                '미션 완료!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '신뢰점수 +${mission.rewardTrustScore}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue[600],
                ),
              ),
              Text(
                '하트온도 +${mission.rewardTemperature}°',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DailyMissionProvider>(
        builder: (context, provider, child) {
          final mission = provider.todayMission;

          if (mission == null) {
            return _buildCompletedView(provider);
          }

          return _buildMissionView(mission, provider);
        },
      ),
    );
  }

  Widget _buildMissionView(DailyMission mission, DailyMissionProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
            Colors.pink.withOpacity(0.1),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(provider),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        _buildMissionCard(mission),
                        const SizedBox(height: 32),
                        _buildAnswerInput(mission),
                        const SizedBox(height: 32),
                        _buildCompleteButton(mission),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DailyMissionProvider provider) {
    final progress = provider.progress;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
              ),
              Text(
                'Day ${progress.currentDay}/30',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '🔥 ${progress.consecutiveDays}일',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.completionPercentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '${progress.completionPercentage}% 완료',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(DailyMission mission) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            mission.icon ?? '✨',
            style: const TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 16),
          Text(
            mission.category,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mission.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            mission.question,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerInput(DailyMission mission) {
    switch (mission.type) {
      case MissionType.text:
        return _buildTextInput(mission);
      case MissionType.choice:
        return _buildChoiceInput(mission);
      case MissionType.multiChoice:
        return _buildMultiChoiceInput(mission);
      case MissionType.range:
        return _buildRangeInput(mission);
      case MissionType.photo:
        return _buildPhotoInput(mission);
    }
  }

  Widget _buildTextInput(DailyMission mission) {
    return TextField(
      onChanged: (value) => _textAnswer = value,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: mission.placeholder ?? '답변을 입력해주세요',
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
    );
  }

  Widget _buildChoiceInput(DailyMission mission) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: mission.choices!.map((choice) {
        final isSelected = _selectedChoice == choice;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedChoice = choice;
            });
          },
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
              choice,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiChoiceInput(DailyMission mission) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: mission.choices!.map((choice) {
        final isSelected = _selectedMultiChoices.contains(choice);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedMultiChoices.remove(choice);
              } else {
                _selectedMultiChoices.add(choice);
              }
            });
          },
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.check, color: Colors.white, size: 18),
                  ),
                Text(
                  choice,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRangeInput(DailyMission mission) {
    _rangeValue ??= mission.minValue;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${_rangeValue ?? mission.minValue}',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Slider(
          value: (_rangeValue ?? mission.minValue!).toDouble(),
          min: mission.minValue!.toDouble(),
          max: mission.maxValue!.toDouble(),
          divisions: mission.maxValue! - mission.minValue!,
          activeColor: AppColors.primary,
          onChanged: (value) {
            setState(() {
              _rangeValue = value.toInt();
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${mission.minValue}'),
            Text('${mission.maxValue}'),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoInput(DailyMission mission) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '사진 업로드',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteButton(DailyMission mission) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _completeMission(context, mission),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          '완료',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedView(DailyMissionProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.2),
            Colors.purple.withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 100),
              ),
              const SizedBox(height: 24),
              const Text(
                '오늘의 미션 완료!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '내일 다시 만나요!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '홈으로 가기',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
