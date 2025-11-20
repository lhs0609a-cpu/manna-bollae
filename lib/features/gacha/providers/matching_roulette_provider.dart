import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/gacha_box.dart';
import '../models/gacha_reward.dart';
import 'gacha_provider.dart';

class MatchingRouletteProvider extends ChangeNotifier {
  int _likesCount = 0; // 현재 좋아요 카운트
  int _rouletteTickets = 0; // 보유한 룰렛 티켓
  int _totalRoulettePlays = 0; // 총 룰렛 플레이 횟수
  static const int _likesRequired = 10; // 룰렛 1회에 필요한 좋아요 수

  int get likesCount => _likesCount;
  int get rouletteTickets => _rouletteTickets;
  int get totalRoulettePlays => _totalRoulettePlays;
  int get likesRequired => _likesRequired;
  int get progress => _likesCount % _likesRequired;
  double get progressPercentage => (progress / _likesRequired) * 100;
  bool get canPlayRoulette => _rouletteTickets > 0;

  // 초기화
  Future<void> initialize() async {
    await _loadProgress();
    notifyListeners();
  }

  // 진행도 로드
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _likesCount = prefs.getInt('matching_roulette_likes') ?? 0;
      _rouletteTickets = prefs.getInt('matching_roulette_tickets') ?? 0;
      _totalRoulettePlays = prefs.getInt('matching_roulette_total_plays') ?? 0;
    } catch (e) {
      print('⚠️ Failed to load matching roulette progress: $e');
    }
  }

  // 진행도 저장
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('matching_roulette_likes', _likesCount);
      await prefs.setInt('matching_roulette_tickets', _rouletteTickets);
      await prefs.setInt('matching_roulette_total_plays', _totalRoulettePlays);
    } catch (e) {
      print('⚠️ Failed to save matching roulette progress: $e');
    }
  }

  // 좋아요 추가
  Future<void> addLike() async {
    _likesCount++;

    // 10개마다 티켓 지급
    if (_likesCount % _likesRequired == 0) {
      _rouletteTickets++;
    }

    await _saveProgress();
    notifyListeners();
  }

  // 룰렛 플레이
  Future<GachaResult?> playRoulette(GachaProvider gachaProvider) async {
    if (!canPlayRoulette) return null;

    _rouletteTickets--;
    _totalRoulettePlays++;

    // 룰렛 전용 상자 (에픽 등급)
    final rouletteBox = GachaBox(
      id: 'matching_roulette_box',
      type: GachaBoxType.matchingRoulette,
      name: '매칭 룰렛 상자',
      description: '좋아요 10개로 얻은 특별한 상자',
      iconUrl: '🎰',
      minRarity: RewardRarity.rare,
      maxRarity: RewardRarity.legendary,
      rarityProbability: const {
        RewardRarity.rare: 60.0,
        RewardRarity.epic: 30.0,
        RewardRarity.legendary: 10.0,
      },
      isFree: true,
    );

    final result = await gachaProvider.pullGacha(rouletteBox);

    await _saveProgress();
    notifyListeners();

    return result;
  }

  // 테스트용: 좋아요 10개 한 번에 추가
  Future<void> addTenLikes() async {
    for (int i = 0; i < 10; i++) {
      await addLike();
    }
  }

  // 초기화 (테스트용)
  Future<void> reset() async {
    _likesCount = 0;
    _rouletteTickets = 0;
    _totalRoulettePlays = 0;
    await _saveProgress();
    notifyListeners();
  }
}
