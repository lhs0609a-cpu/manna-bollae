import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/gacha_reward.dart';
import '../models/gacha_box.dart';
import '../models/gacha_progress.dart';
import '../../../models/dice_gacha_model.dart';

class GachaProvider extends ChangeNotifier {
  GachaProgress _progress = GachaProgress();
  final Random _random = Random();

  // 주사위 가챠 관련
  DiceGachaProgress? _diceProgress;
  List<int> _currentDiceResults = [];
  bool _isRollingDice = false;

  GachaProgress get progress => _progress;
  DiceGachaProgress? get diceProgress => _diceProgress;
  List<int> get currentDiceResults => _currentDiceResults;
  bool get isRollingDice => _isRollingDice;

  // 초기화
  Future<void> initialize({String? userId}) async {
    await loadProgress();
    _checkAndResetDailyPulls();
    if (userId != null) {
      await initializeDiceGacha(userId);
    }
    notifyListeners();
  }

  // 진행도 로드
  Future<void> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? progressJson = prefs.getString('gacha_progress');

      if (progressJson != null) {
        final Map<String, dynamic> json = jsonDecode(progressJson);
        _progress = GachaProgress.fromJson(json);
      } else {
        _progress = GachaProgress();
      }

      notifyListeners();
    } catch (e) {
      print('⚠️ Failed to load gacha progress: $e');
      _progress = GachaProgress();
      notifyListeners();
    }
  }

  // 진행도 저장
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String progressJson = jsonEncode(_progress.toJson());
      await prefs.setString('gacha_progress', progressJson);
    } catch (e) {
      print('⚠️ Failed to save gacha progress: $e');
    }
  }

  // 일일 뽑기 횟수 리셋 체크
  void _checkAndResetDailyPulls() {
    if (_progress.lastPullAt != null && !_progress.isToday(_progress.lastPullAt)) {
      _progress = _progress.copyWith(todayPulls: 0);
    }
  }

  // 가챠 뽑기 (핵심 로직)
  Future<GachaResult> pullGacha(GachaBox box) async {
    // 1. 희귀도 결정
    final rarity = _determineRarity(box.rarityProbability);

    // 2. 해당 희귀도의 보상 목록 가져오기
    final availableRewards = _getRewardsByRarity(rarity);

    // 3. 랜덤으로 하나 선택
    final reward = availableRewards[_random.nextInt(availableRewards.length)];

    // 4. 결과 생성
    final result = GachaResult(
      id: 'result_${DateTime.now().millisecondsSinceEpoch}',
      box: box,
      reward: reward,
      obtainedAt: DateTime.now(),
      isNew: _progress.getRewardCount(reward.id) == 0,
    );

    // 5. 진행도 업데이트
    await _updateProgress(result);

    // 6. 저장
    await _saveProgress();

    notifyListeners();

    return result;
  }

  // 희귀도 결정 로직 (확률 기반)
  RewardRarity _determineRarity(Map<RewardRarity, double> probabilities) {
    final roll = _random.nextDouble() * 100;
    double cumulative = 0;

    for (var entry in probabilities.entries) {
      cumulative += entry.value;
      if (roll <= cumulative) {
        return entry.key;
      }
    }

    // 기본값 (도달하지 않아야 함)
    return probabilities.keys.first;
  }

  // 희귀도별 보상 목록 가져오기
  List<GachaReward> _getRewardsByRarity(RewardRarity rarity) {
    switch (rarity) {
      case RewardRarity.common:
        return GachaRewardData.commonRewards;
      case RewardRarity.rare:
        return GachaRewardData.rareRewards;
      case RewardRarity.epic:
        return GachaRewardData.epicRewards;
      case RewardRarity.legendary:
        return GachaRewardData.legendaryRewards;
    }
  }

  // 진행도 업데이트
  Future<void> _updateProgress(GachaResult result) async {
    // 총 뽑기 횟수 증가
    final newTotalPulls = _progress.totalPulls + 1;
    final newTodayPulls = _progress.todayPulls + 1;

    // 인벤토리 업데이트
    final newInventory = Map<String, int>.from(_progress.rewardInventory);
    final currentCount = newInventory[result.reward.id] ?? 0;
    newInventory[result.reward.id] = currentCount + result.reward.amount;

    // 히스토리 업데이트 (최근 20개만 유지)
    final newHistory = [result, ..._progress.history];
    if (newHistory.length > 20) {
      newHistory.removeRange(20, newHistory.length);
    }

    // 타입별 횟수 업데이트
    final newPullCountByType = Map<GachaBoxType, int>.from(_progress.pullCountByType);
    final currentTypeCount = newPullCountByType[result.box.type] ?? 0;
    newPullCountByType[result.box.type] = currentTypeCount + 1;

    // 희귀도별 획득 횟수 업데이트
    final newObtainedByRarity = Map<RewardRarity, int>.from(_progress.obtainedByRarity);
    final currentRarityCount = newObtainedByRarity[result.reward.rarity] ?? 0;
    newObtainedByRarity[result.reward.rarity] = currentRarityCount + 1;

    _progress = _progress.copyWith(
      totalPulls: newTotalPulls,
      todayPulls: newTodayPulls,
      rewardInventory: newInventory,
      history: newHistory,
      lastPullAt: DateTime.now(),
      pullCountByType: newPullCountByType,
      obtainedByRarity: newObtainedByRarity,
    );
  }

  // 아이템 사용
  Future<bool> useReward(String rewardId, int amount) async {
    final currentAmount = _progress.getRewardCount(rewardId);
    if (currentAmount < amount) {
      return false; // 보유량 부족
    }

    final newInventory = Map<String, int>.from(_progress.rewardInventory);
    newInventory[rewardId] = currentAmount - amount;

    _progress = _progress.copyWith(rewardInventory: newInventory);
    await _saveProgress();
    notifyListeners();

    return true;
  }

  // 출석 체크 (일일 출석 가챠용)
  Future<GachaResult?> checkAttendance() async {
    if (!_progress.canCheckAttendance()) {
      return null; // 이미 오늘 출석함
    }

    // 연속 출석 일수 업데이트
    int newConsecutiveDays;
    if (_progress.isStreakBroken()) {
      newConsecutiveDays = 1; // 연속 끊김, 1일부터 시작
    } else {
      newConsecutiveDays = _progress.consecutiveDays + 1;
    }

    // 출석 날짜 업데이트
    _progress = _progress.copyWith(
      consecutiveDays: newConsecutiveDays,
      lastAttendanceDate: DateTime.now(),
    );

    // 연속 일수에 따라 다른 등급의 상자 제공
    GachaBox box;
    if (newConsecutiveDays >= 7) {
      box = GachaBoxData.goldenBox; // 7일 이상: 황금 상자
      // 7일마다 리셋
      _progress = _progress.copyWith(consecutiveDays: 0);
    } else if (newConsecutiveDays >= 5) {
      box = GachaBoxData.epicBox; // 5-6일: 에픽 상자
    } else if (newConsecutiveDays >= 3) {
      box = GachaBoxData.rareBox; // 3-4일: 레어 상자
    } else {
      box = GachaBoxData.normalBox; // 1-2일: 일반 상자
    }

    // 가챠 뽑기
    return await pullGacha(box);
  }

  // 통계
  int get totalRewardsObtained {
    return _progress.rewardInventory.values.fold(0, (sum, count) => sum + count);
  }

  int get uniqueRewardsObtained {
    return _progress.rewardInventory.keys.length;
  }

  double get legendaryRate {
    final total = _progress.totalPulls;
    if (total == 0) return 0;
    final legendary = _progress.getRarityCount(RewardRarity.legendary);
    return (legendary / total) * 100;
  }

  // 진행도 초기화 (테스트용)
  Future<void> resetProgress() async {
    _progress = GachaProgress();
    await _saveProgress();
    notifyListeners();
  }

  // ==================== 주사위 가챠 ====================

  /// 주사위 가챠 초기화
  Future<void> initializeDiceGacha(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('dice_gacha_progress_$userId');

      if (progressJson != null) {
        final map = json.decode(progressJson) as Map<String, dynamic>;
        _diceProgress = DiceGachaProgress.fromMap(map);
      } else {
        // 처음 사용하는 경우 - 3분 전으로 설정하여 바로 사용 가능하도록
        _diceProgress = DiceGachaProgress(
          userId: userId,
          lastRollDate: DateTime.now().subtract(const Duration(minutes: 3)),
        );
      }

      notifyListeners();
    } catch (e) {
      print('⚠️ Failed to load dice gacha progress: $e');
    }
  }

  /// 주사위 1개 굴리기
  Future<int?> rollSingleDice() async {
    if (_diceProgress == null) return null;
    if (_isRollingDice) return null;

    // 새로운 굴림 시작
    if (_currentDiceResults.isEmpty && !_diceProgress!.canRollAgain) {
      return null; // 15분이 지나지 않음
    }

    try {
      _isRollingDice = true;
      notifyListeners();

      // 0.5초 대기 (애니메이션 효과)
      await Future.delayed(const Duration(milliseconds: 500));

      final diceValue = _random.nextInt(6) + 1; // 1-6

      _currentDiceResults.add(diceValue);
      _isRollingDice = false;
      notifyListeners();

      // 3개를 모두 굴렸다면 결과 저장
      if (_currentDiceResults.length == 3) {
        await _saveDiceResult();
      }

      return diceValue;
    } catch (e) {
      print('⚠️ Failed to roll dice: $e');
      _isRollingDice = false;
      notifyListeners();
      return null;
    }
  }

  /// 주사위 결과 저장
  Future<void> _saveDiceResult() async {
    if (_diceProgress == null || _currentDiceResults.length != 3) return;

    try {
      final result = DiceGachaResult(
        dice1: _currentDiceResults[0],
        dice2: _currentDiceResults[1],
        dice3: _currentDiceResults[2],
        rolledAt: DateTime.now(),
      );

      // 최근 결과 업데이트 (최대 10개)
      final updatedRecentResults = [result, ..._diceProgress!.recentResults];
      if (updatedRecentResults.length > 10) {
        updatedRecentResults.removeRange(10, updatedRecentResults.length);
      }

      _diceProgress = _diceProgress!.copyWith(
        lastRollDate: DateTime.now(),
        totalRolls: _diceProgress!.totalRolls + 1,
        totalJackpots: _diceProgress!.totalJackpots + (result.isJackpot ? 1 : 0),
        totalBonusMatches: _diceProgress!.totalBonusMatches + result.bonusMatches,
        recentResults: updatedRecentResults,
      );

      await _saveDiceProgress();
      notifyListeners();
    } catch (e) {
      print('⚠️ Failed to save dice result: $e');
    }
  }

  /// 주사위 진행 상황 저장
  Future<void> _saveDiceProgress() async {
    if (_diceProgress == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = json.encode(_diceProgress!.toMap());
      await prefs.setString('dice_gacha_progress_${_diceProgress!.userId}', progressJson);
    } catch (e) {
      print('⚠️ Failed to save dice progress: $e');
    }
  }

  /// 현재 굴림 리셋 (새로운 15분 사이클 시작)
  void resetCurrentDiceRoll() {
    _currentDiceResults.clear();
    notifyListeners();
  }

  /// 마지막 주사위 결과 가져오기
  DiceGachaResult? get lastDiceResult {
    if (_diceProgress == null || _diceProgress!.recentResults.isEmpty) return null;
    return _diceProgress!.recentResults.first;
  }

  /// 현재 결과가 잭팟인지
  bool get isCurrentDiceJackpot {
    if (_currentDiceResults.length != 3) return false;
    return _currentDiceResults[0] == _currentDiceResults[1] &&
           _currentDiceResults[1] == _currentDiceResults[2];
  }
}
