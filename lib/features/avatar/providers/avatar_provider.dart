import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';

class AvatarProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Avatar? _avatar;
  bool _isLoading = false;
  String? _error;

  Avatar? get avatar => _avatar;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 사용 가능한 옵션들
  final List<String> availableAnimals = [
    '고양이',
    '강아지',
    '토끼',
    '곰',
    '여우',
    '팬더',
    '호랑이',
    '사자',
  ];

  final List<String> availablePersonalities = [
    '활발한',
    '차분한',
    '유머러스한',
    '진지한',
    '낭만적인',
    '실용적인',
    '모험적인',
    '안정적인',
  ];

  final List<String> availableStyles = [
    '캐주얼',
    '포멀',
    '스포티',
    '빈티지',
    '미니멀',
    '힙합',
    '클래식',
    '아트',
  ];

  final List<String> availableColors = [
    '빨강',
    '주황',
    '노랑',
    '초록',
    '파랑',
    '남색',
    '보라',
    '핑크',
    '흰색',
    '검정',
  ];

  /// 아바타 로드
  Future<void> loadAvatar(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _avatar = Avatar.fromMap(userData['avatar'] ?? {});
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '아바타 정보를 불러오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 아바타 생성
  Future<bool> createAvatar({
    required String userId,
    required String animalType,
    required String personality,
    required String style,
    required List<String> favoriteColors,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 기본 아바타 생성
      final avatar = Avatar(
        animalType: animalType,
        personality: personality,
        style: style,
        colorPreference: favoriteColors.isNotEmpty ? favoriteColors.first : '파란색',
        hobby: '',
        baseCharacter: animalType,
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
          tops: ['기본 상의'],
          bottoms: ['기본 하의'],
          accessories: [],
          hairs: ['기본 헤어'],
          backgrounds: ['기본 배경'],
          specialItems: [],
        ),
      );

      await _firestore.collection('users').doc(userId).update({
        'avatar': avatar.toMap(),
      });

      _avatar = avatar;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = '아바타 생성에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 복장 변경
  Future<bool> updateOutfit({
    required String userId,
    String? top,
    String? bottom,
    String? accessory,
    String? hair,
    String? background,
    String? specialItem,
    String? emotion,
  }) async {
    try {
      if (_avatar == null) return false;

      final updatedOutfit = _avatar!.currentOutfit.copyWith(
        top: top,
        bottom: bottom,
        accessories: accessory != null ? [accessory] : [],
        hair: hair,
        background: background,
        specialItem: specialItem,
        emotion: emotion,
      );

      final updatedAvatar = _avatar!.copyWith(
        currentOutfit: updatedOutfit,
      );

      await _firestore.collection('users').doc(userId).update({
        'avatar': updatedAvatar.toMap(),
      });

      _avatar = updatedAvatar;
      notifyListeners();

      return true;
    } catch (e) {
      _error = '복장 변경에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 아이템 구매
  Future<bool> purchaseItem({
    required String userId,
    required String itemType,
    required String itemName,
    required int price,
  }) async {
    try {
      if (_avatar == null) return false;

      // TODO: 실제로는 사용자의 포인트/코인을 차감해야 함
      // 현재는 단순히 아이템만 추가

      final ownedItems = _avatar!.ownedItems;
      OwnedItems updatedOwnedItems;

      switch (itemType) {
        case 'top':
          if (ownedItems.tops.contains(itemName)) {
            _error = '이미 보유한 아이템입니다';
            notifyListeners();
            return false;
          }
          updatedOwnedItems = ownedItems.copyWith(
            tops: [...ownedItems.tops, itemName],
          );
          break;
        case 'bottom':
          if (ownedItems.bottoms.contains(itemName)) {
            _error = '이미 보유한 아이템입니다';
            notifyListeners();
            return false;
          }
          updatedOwnedItems = ownedItems.copyWith(
            bottoms: [...ownedItems.bottoms, itemName],
          );
          break;
        case 'accessory':
          if (ownedItems.accessories.contains(itemName)) {
            _error = '이미 보유한 아이템입니다';
            notifyListeners();
            return false;
          }
          updatedOwnedItems = ownedItems.copyWith(
            accessories: [...ownedItems.accessories, itemName],
          );
          break;
        case 'hair':
          if (ownedItems.hairs.contains(itemName)) {
            _error = '이미 보유한 아이템입니다';
            notifyListeners();
            return false;
          }
          updatedOwnedItems = ownedItems.copyWith(
            hairs: [...ownedItems.hairs, itemName],
          );
          break;
        case 'background':
          if (ownedItems.backgrounds.contains(itemName)) {
            _error = '이미 보유한 아이템입니다';
            notifyListeners();
            return false;
          }
          updatedOwnedItems = ownedItems.copyWith(
            backgrounds: [...ownedItems.backgrounds, itemName],
          );
          break;
        case 'special':
          if (ownedItems.specialItems.contains(itemName)) {
            _error = '이미 보유한 아이템입니다';
            notifyListeners();
            return false;
          }
          updatedOwnedItems = ownedItems.copyWith(
            specialItems: [...ownedItems.specialItems, itemName],
          );
          break;
        default:
          _error = '알 수 없는 아이템 타입입니다';
          notifyListeners();
          return false;
      }

      final updatedAvatar = _avatar!.copyWith(
        ownedItems: updatedOwnedItems,
      );

      await _firestore.collection('users').doc(userId).update({
        'avatar': updatedAvatar.toMap(),
      });

      _avatar = updatedAvatar;
      notifyListeners();

      return true;
    } catch (e) {
      _error = '아이템 구매에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 감정 변경
  Future<bool> changeEmotion(String userId, String emotion) async {
    return await updateOutfit(
      userId: userId,
      emotion: emotion,
    );
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
