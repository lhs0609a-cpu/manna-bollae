import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/referral_reward.dart';
import '../models/referral_progress.dart';
import '../../gacha/providers/gacha_provider.dart';
import '../../gacha/models/gacha_box.dart';
import '../../gacha/models/gacha_reward.dart';

class ReferralProvider extends ChangeNotifier {
  ReferralProgress _progress = ReferralProgress(referralCode: '');
  final List<ReferralReward> _rewards = ReferralRewardData.allRewards;

  ReferralProgress get progress => _progress;
  List<ReferralReward> get rewards => _rewards;

  // 다음 달성 목표
  ReferralReward? get nextMilestone {
    try {
      return _rewards.firstWhere(
        (reward) => reward.milestone > _progress.successfulReferred,
      );
    } catch (e) {
      return null; // 모든 목표 달성
    }
  }

  // 진행도 퍼센트 (다음 목표까지)
  double get progressPercentage {
    if (nextMilestone == null) return 100.0;

    final current = _progress.successfulReferred;
    final next = nextMilestone!.milestone;
    final previous = current > 0
        ? _rewards
            .lastWhere(
              (r) => r.milestone <= current,
              orElse: () => ReferralReward(
                milestone: 0,
                title: '',
                description: '',
                rewards: [],
                icon: '',
              ),
            )
            .milestone
        : 0;

    return ((current - previous) / (next - previous) * 100).clamp(0.0, 100.0);
  }

  // 초기화
  Future<void> initialize() async {
    await loadProgress();

    // 초대 코드가 없으면 생성
    if (_progress.referralCode.isEmpty) {
      final code = _generateReferralCode();
      _progress = _progress.copyWith(referralCode: code);
      await _saveProgress();
    }

    notifyListeners();
  }

  // 진행도 로드
  Future<void> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? progressJson = prefs.getString('referral_progress');

      if (progressJson != null) {
        final Map<String, dynamic> json = jsonDecode(progressJson);
        _progress = ReferralProgress.fromJson(json);
      } else {
        // 신규 사용자 - 초대 코드 생성
        _progress = ReferralProgress(
          referralCode: _generateReferralCode(),
        );
      }

      notifyListeners();
    } catch (e) {
      print('⚠️ Failed to load referral progress: $e');
      _progress = ReferralProgress(
        referralCode: _generateReferralCode(),
      );
      notifyListeners();
    }
  }

  // 진행도 저장
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String progressJson = jsonEncode(_progress.toJson());
      await prefs.setString('referral_progress', progressJson);
    } catch (e) {
      print('⚠️ Failed to save referral progress: $e');
    }
  }

  // 초대 코드 생성 (예쁜 코드)
  String _generateReferralCode() {
    final random = Random();
    final chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // 혼동되는 문자 제외
    final codeLength = 6;

    return List.generate(
      codeLength,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  // 친구 초대하기 (초대 링크 생성)
  String getInviteLink() {
    // 실제로는 딥링크 또는 웹 링크
    return 'https://mannabollae.com/invite/${_progress.referralCode}';
  }

  // 친구 초대 럭키박스 가챠 (가챠 시스템 연동)
  Future<GachaResult?> getReferralLuckyBox(GachaProvider gachaProvider) async {
    // 친구 초대 전용 럭키박스
    final referralBox = GachaBox(
      id: 'referral_lucky_box',
      type: GachaBoxType.referralLuckyBox,
      name: '친구 초대 럭키박스',
      description: '친구를 초대하면 받는 특별한 상자',
      iconUrl: '🎁',
      minRarity: RewardRarity.common,
      maxRarity: RewardRarity.epic,
      rarityProbability: const {
        RewardRarity.common: 50.0,
        RewardRarity.rare: 35.0,
        RewardRarity.epic: 15.0,
      },
      isFree: true,
    );

    return await gachaProvider.pullGacha(referralBox);
  }

  // 초대 코드로 친구 추가 (데모용)
  Future<void> inviteFriend(String friendName) async {
    final newFriend = ReferredFriend(
      userId: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      name: friendName,
      invitedAt: DateTime.now(),
    );

    final updatedFriends = [..._progress.referredFriends, newFriend];

    _progress = _progress.copyWith(
      referredFriends: updatedFriends,
      totalReferred: _progress.totalReferred + 1,
    );

    await _saveProgress();
    notifyListeners();
  }

  // 친구가 가입 완료
  Future<void> friendSignedUp(String userId) async {
    final friendIndex = _progress.referredFriends
        .indexWhere((friend) => friend.userId == userId);

    if (friendIndex == -1) return;

    final updatedFriends = List<ReferredFriend>.from(_progress.referredFriends);
    updatedFriends[friendIndex] = updatedFriends[friendIndex].copyWith(
      hasSignedUp: true,
    );

    _progress = _progress.copyWith(
      referredFriends: updatedFriends,
      successfulReferred: _progress.successfulReferred + 1,
    );

    await _saveProgress();
    notifyListeners();

    // 자동으로 보상 체크
    await _checkAndGrantRewards();
  }

  // 친구가 프로필 완성
  Future<void> friendCompletedProfile(String userId) async {
    final friendIndex = _progress.referredFriends
        .indexWhere((friend) => friend.userId == userId);

    if (friendIndex == -1) return;

    final updatedFriends = List<ReferredFriend>.from(_progress.referredFriends);
    updatedFriends[friendIndex] = updatedFriends[friendIndex].copyWith(
      hasCompletedProfile: true,
    );

    _progress = _progress.copyWith(
      referredFriends: updatedFriends,
      totalPoints: _progress.totalPoints + 2000, // 프로필 완성 보너스
    );

    await _saveProgress();
    notifyListeners();
  }

  // 친구가 활성 사용자됨 (7일 연속)
  Future<void> friendBecameActive(String userId) async {
    final friendIndex = _progress.referredFriends
        .indexWhere((friend) => friend.userId == userId);

    if (friendIndex == -1) return;

    final updatedFriends = List<ReferredFriend>.from(_progress.referredFriends);
    updatedFriends[friendIndex] = updatedFriends[friendIndex].copyWith(
      isActive: true,
    );

    _progress = _progress.copyWith(
      referredFriends: updatedFriends,
      totalPoints: _progress.totalPoints + 5000, // 활성 사용자 보너스
    );

    await _saveProgress();
    notifyListeners();
  }

  // 친구가 매칭 성공
  Future<void> friendMatched(String userId) async {
    final friendIndex = _progress.referredFriends
        .indexWhere((friend) => friend.userId == userId);

    if (friendIndex == -1) return;

    final updatedFriends = List<ReferredFriend>.from(_progress.referredFriends);
    updatedFriends[friendIndex] = updatedFriends[friendIndex].copyWith(
      hasMatched: true,
    );

    _progress = _progress.copyWith(
      referredFriends: updatedFriends,
      totalPoints: _progress.totalPoints + 3000, // 매칭 성공 보너스
    );

    await _saveProgress();
    notifyListeners();
  }

  // 보상 확인 및 자동 지급
  Future<void> _checkAndGrantRewards() async {
    for (var reward in _rewards) {
      // 이미 수령한 보상은 스킵
      if (_progress.claimedRewards[reward.milestone] == true) continue;

      // 목표 달성 여부 확인
      if (_progress.successfulReferred >= reward.milestone) {
        await claimReward(reward.milestone);
      }
    }
  }

  // 보상 수령
  Future<bool> claimReward(int milestone) async {
    // 이미 수령했는지 확인
    if (_progress.claimedRewards[milestone] == true) {
      return false;
    }

    // 목표 달성 여부 확인
    if (_progress.successfulReferred < milestone) {
      return false;
    }

    // 보상 찾기
    final reward = _rewards.firstWhere(
      (r) => r.milestone == milestone,
      orElse: () => throw Exception('Reward not found'),
    );

    // 포인트 계산
    int points = 0;
    for (var item in reward.rewards) {
      if (item.type == RewardType.cash) {
        points += item.amount;
      } else if (item.type == RewardType.superLikes) {
        points += item.amount * 1000; // 슈퍼 라이크 1개 = 1000 포인트
      } else if (item.type == RewardType.premium) {
        points += item.amount * 1000; // 프리미엄 1일 = 1000 포인트
      }
    }

    // 보상 수령 처리
    final updatedClaimed = {..._progress.claimedRewards, milestone: true};

    _progress = _progress.copyWith(
      claimedRewards: updatedClaimed,
      totalPoints: _progress.totalPoints + points,
    );

    await _saveProgress();
    notifyListeners();

    return true;
  }

  // 초대 코드 입력 (신규 사용자가 사용)
  Future<bool> enterReferralCode(String code) async {
    // 실제로는 서버에서 검증
    // 여기서는 데모용으로 간단히 처리
    if (code.length == 6) {
      print('📱 초대 코드 입력: $code');
      return true;
    }
    return false;
  }

  // 진행도 초기화 (테스트용)
  Future<void> resetProgress() async {
    _progress = ReferralProgress(
      referralCode: _generateReferralCode(),
    );
    await _saveProgress();
    notifyListeners();
  }

  // 데모: 친구 추가 시뮬레이션
  Future<void> simulateReferral() async {
    final demoNames = [
      '김민수',
      '이지은',
      '박철수',
      '최유리',
      '정다은',
      '강민호',
      '윤서연',
      '한지우'
    ];
    final random = Random();
    final name = demoNames[random.nextInt(demoNames.length)];

    await inviteFriend(name);

    // 2초 후 자동 가입 처리
    await Future.delayed(const Duration(seconds: 2));

    if (_progress.referredFriends.isNotEmpty) {
      final lastFriend = _progress.referredFriends.last;
      await friendSignedUp(lastFriend.userId);
    }
  }
}
