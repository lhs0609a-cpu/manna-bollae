import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../models/daily_question_model.dart';
import '../providers/daily_question_provider.dart';

class TodayQuestionCard extends StatefulWidget {
  final String userId;

  const TodayQuestionCard({
    super.key,
    required this.userId,
  });

  @override
  State<TodayQuestionCard> createState() => _TodayQuestionCardState();
}

class _TodayQuestionCardState extends State<TodayQuestionCard> {
  int _currentQuestionIndex = 0; // 0, 1, 2
  String? _selectedAnswer;
  final List<String> _multipleSelectedAnswers = [];
  final TextEditingController _textController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // 이미 답변한 질문은 건너뛰기 (초기화 시)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCurrentQuestionIndex();
    });
  }

  void _updateCurrentQuestionIndex() {
    final provider = context.read<DailyQuestionProvider>();
    int newIndex = 0;

    // 답변하지 않은 첫 번째 질문 찾기
    for (int i = 0; i < 3; i++) {
      final key = '${provider.progress.currentDay}_$i';
      if (!provider.progress.answers.containsKey(key)) {
        newIndex = i;
        break;
      }
    }

    if (newIndex != _currentQuestionIndex) {
      setState(() {
        _currentQuestionIndex = newIndex;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _resetAnswerInputs() {
    setState(() {
      _selectedAnswer = null;
      _multipleSelectedAnswers.clear();
      _textController.clear();
    });
  }

  Future<void> _submitAnswer() async {
    final provider = context.read<DailyQuestionProvider>();
    final questions = provider.todayQuestions;

    if (questions.isEmpty || _currentQuestionIndex >= questions.length) return;

    final question = questions[_currentQuestionIndex];
    String answer = '';

    // 답변 형식에 따라 처리
    switch (question.type) {
      case QuestionType.singleChoice:
        if (_selectedAnswer == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('답변을 선택해주세요')),
          );
          return;
        }
        answer = _selectedAnswer!;
        break;

      case QuestionType.multipleChoice:
        if (_multipleSelectedAnswers.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('최소 하나 이상 선택해주세요')),
          );
          return;
        }
        answer = _multipleSelectedAnswers.join(', ');
        break;

      case QuestionType.text:
        if (_textController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('답변을 입력해주세요')),
          );
          return;
        }
        answer = _textController.text.trim();
        break;

      default:
        break;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await provider.submitAnswer(
      widget.userId,
      answer,
      questionIndex: _currentQuestionIndex,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (success && mounted) {
      // 입력 초기화
      _resetAnswerInputs();

      // 다음 질문으로 이동하거나 완료
      if (_currentQuestionIndex < 2) {
        // 아직 답변할 질문이 남음
        setState(() {
          _currentQuestionIndex++;
        });
      } else {
        // 모든 질문 완료
        await _showCompletionDialog(question.rewardPoints);
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  Future<void> _showCompletionDialog(int points) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '오늘의 질문 완료!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '내일 오전 8시에 새로운 질문이 준비됩니다',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                ),
                child: const Text('확인'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DailyQuestionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (provider.progress.isCompleted) {
          return _buildCompletedDialog();
        }

        if (provider.hasAnsweredToday) {
          return _buildAlreadyAnsweredDialog(provider);
        }

        final questions = provider.todayQuestions;
        if (questions.isEmpty) {
          return const SizedBox.shrink();
        }

        // 현재 질문 인덱스가 유효한지 확인
        if (_currentQuestionIndex >= questions.length) {
          return const SizedBox.shrink();
        }

        final question = questions[_currentQuestionIndex];
        final currentStep = _currentQuestionIndex + 1;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 컴팩트 헤더
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      // 단계 표시
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$currentStep/3',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          question.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // 진행 바
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: List.generate(3, (index) {
                      final isCompleted = index < currentStep - 1;
                      final isCurrent = index == currentStep - 1;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                          decoration: BoxDecoration(
                            color: isCompleted || isCurrent
                                ? AppColors.primary
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // 질문 내용
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.question,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAnswerInput(question),
                      ],
                    ),
                  ),
                ),

                // 제출 버튼
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              currentStep < 3 ? '다음' : '완료',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerInput(DailyQuestion question) {
    switch (question.type) {
      case QuestionType.singleChoice:
        return _buildSingleChoiceInput(question);

      case QuestionType.multipleChoice:
        return _buildMultipleChoiceInput(question);

      case QuestionType.text:
        return _buildTextInput(question);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSingleChoiceInput(DailyQuestion question) {
    return Column(
      children: question.options.map((option) {
        final isSelected = _selectedAnswer == option;
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedAnswer = option;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected ? AppColors.primary : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppColors.primary : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoiceInput(DailyQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '여러 개 선택 가능',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        ...question.options.map((option) {
          final isSelected = _multipleSelectedAnswers.contains(option);
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _multipleSelectedAnswers.remove(option);
                    } else {
                      _multipleSelectedAnswers.add(option);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: isSelected ? AppColors.primary : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? AppColors.primary : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTextInput(DailyQuestion question) {
    return TextField(
      controller: _textController,
      maxLines: 3,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: question.placeholder ?? '답변을 입력해주세요',
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildAlreadyAnsweredDialog(DailyQuestionProvider provider) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green[100]!, Colors.teal[100]!],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green[700],
              size: 50,
            ),
            const SizedBox(height: 16),
            const Text(
              '오늘의 질문 완료!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '내일 오전 8시에 새로운 질문이 준비됩니다',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '⏰ ${provider.timeUntilNextQuestion} 후',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '확인',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.amber[100]!, Colors.orange[100]!],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              color: Colors.amber[700],
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              '🎉 30일 완성!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '모든 질문에 답변을 완료했습니다.\n이제 완벽한 프로필로 매칭을 시작해보세요!',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '확인',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
