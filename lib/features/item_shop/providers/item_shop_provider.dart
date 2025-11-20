import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';
import '../../../models/subscription_type.dart';

enum ItemCategory {
  top,
  bottom,
  accessory,
  hair,
  background,
  special,
}

class ShopItem {
  final String id;
  final String name;
  final ItemCategory category;
  final int price;
  final String emoji;
  final String description;
  final bool isVIPExclusive;
  final bool isLimitedEdition;

  ShopItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.emoji,
    required this.description,
    this.isVIPExclusive = false,
    this.isLimitedEdition = false,
  });
}

class ItemShopProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _coins = 0;
  bool _isLoading = false;
  String? _error;

  int get coins => _coins;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 카테고리 이름 가져오기
  static String getCategoryName(ItemCategory category) {
    switch (category) {
      case ItemCategory.top:
        return '상의';
      case ItemCategory.bottom:
        return '하의';
      case ItemCategory.accessory:
        return '액세서리';
      case ItemCategory.hair:
        return '헤어';
      case ItemCategory.background:
        return '배경';
      case ItemCategory.special:
        return '특별 아이템';
    }
  }

  // 상점 아이템 목록
  static final List<ShopItem> shopItems = [
    // 상의
    ShopItem(
      id: 'top_basic_shirt',
      name: '기본 셔츠',
      category: ItemCategory.top,
      price: 100,
      emoji: '👕',
      description: '깔끔한 기본 셔츠',
    ),
    ShopItem(
      id: 'top_hoodie',
      name: '후드티',
      category: ItemCategory.top,
      price: 150,
      emoji: '🧥',
      description: '편안한 후드티',
    ),
    ShopItem(
      id: 'top_suit',
      name: '정장',
      category: ItemCategory.top,
      price: 300,
      emoji: '🤵',
      description: '포멀한 정장',
      isVIPExclusive: true,
    ),

    // 하의
    ShopItem(
      id: 'bottom_jeans',
      name: '청바지',
      category: ItemCategory.bottom,
      price: 100,
      emoji: '👖',
      description: '기본 청바지',
    ),
    ShopItem(
      id: 'bottom_skirt',
      name: '치마',
      category: ItemCategory.bottom,
      price: 150,
      emoji: '👗',
      description: '예쁜 치마',
    ),

    // 액세서리
    ShopItem(
      id: 'acc_glasses',
      name: '안경',
      category: ItemCategory.accessory,
      price: 100,
      emoji: '👓',
      description: '멋진 안경',
    ),
    ShopItem(
      id: 'acc_hat',
      name: '모자',
      category: ItemCategory.accessory,
      price: 120,
      emoji: '🎩',
      description: '세련된 모자',
    ),
    ShopItem(
      id: 'acc_crown',
      name: '왕관',
      category: ItemCategory.accessory,
      price: 500,
      emoji: '👑',
      description: '화려한 왕관',
      isVIPExclusive: true,
    ),
    ShopItem(
      id: 'acc_bowtie',
      name: '나비넥타이',
      category: ItemCategory.accessory,
      price: 150,
      emoji: '🎀',
      description: '귀여운 나비넥타이',
    ),
    ShopItem(
      id: 'acc_flower',
      name: '꽃',
      category: ItemCategory.accessory,
      price: 100,
      emoji: '🌸',
      description: '아름다운 꽃',
    ),
    ShopItem(
      id: 'acc_star',
      name: '별',
      category: ItemCategory.accessory,
      price: 200,
      emoji: '⭐',
      description: '반짝이는 별',
    ),

    // 헤어
    ShopItem(
      id: 'hair_short',
      name: '단발머리',
      category: ItemCategory.hair,
      price: 200,
      emoji: '💇',
      description: '산뜻한 단발',
    ),
    ShopItem(
      id: 'hair_long',
      name: '긴 머리',
      category: ItemCategory.hair,
      price: 250,
      emoji: '💁',
      description: '우아한 긴 머리',
    ),
    ShopItem(
      id: 'hair_curly',
      name: '웨이브',
      category: ItemCategory.hair,
      price: 300,
      emoji: '💇‍♀️',
      description: '멋진 웨이브 헤어',
      isVIPExclusive: true,
    ),

    // 배경
    ShopItem(
      id: 'bg_sunset',
      name: '석양',
      category: ItemCategory.background,
      price: 300,
      emoji: '🌅',
      description: '아름다운 석양 배경',
    ),
    ShopItem(
      id: 'bg_stars',
      name: '별밤',
      category: ItemCategory.background,
      price: 350,
      emoji: '🌃',
      description: '반짝이는 별이 있는 밤',
    ),
    ShopItem(
      id: 'bg_rainbow',
      name: '무지개',
      category: ItemCategory.background,
      price: 400,
      emoji: '🌈',
      description: '화려한 무지개 배경',
      isVIPExclusive: true,
    ),

    // 특별 아이템
    ShopItem(
      id: 'special_wings',
      name: '천사 날개',
      category: ItemCategory.special,
      price: 1000,
      emoji: '👼',
      description: '천사의 날개',
      isVIPExclusive: true,
      isLimitedEdition: true,
    ),
    ShopItem(
      id: 'special_halo',
      name: '후광',
      category: ItemCategory.special,
      price: 800,
      emoji: '😇',
      description: '밝게 빛나는 후광',
      isVIPExclusive: true,
      isLimitedEdition: true,
    ),
    ShopItem(
      id: 'special_heart',
      name: '하트 이펙트',
      category: ItemCategory.special,
      price: 500,
      emoji: '💖',
      description: '하트가 둥둥 떠다니는 효과',
      isLimitedEdition: true,
    ),
  ];

  /// 코인 로드
  Future<void> loadCoins(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _coins = userData['coins'] ?? 0;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '코인 정보를 불러오는데 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 카테고리별 아이템 필터링
  List<ShopItem> getItemsByCategory(ItemCategory? category) {
    if (category == null) {
      return shopItems;
    }
    return shopItems.where((item) => item.category == category).toList();
  }

  /// VIP 전용 아이템 필터링
  List<ShopItem> getVIPItems() {
    return shopItems.where((item) => item.isVIPExclusive).toList();
  }

  /// 한정판 아이템 필터링
  List<ShopItem> getLimitedEditionItems() {
    return shopItems.where((item) => item.isLimitedEdition).toList();
  }

  /// 아이템 구매
  Future<bool> purchaseItem({
    required String userId,
    required ShopItem item,
    required bool isVIP,
    int? vipDiscount, // VIP 할인율 (10, 20, 30)
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // VIP 전용 아이템 확인
      if (item.isVIPExclusive && !isVIP) {
        _error = 'VIP 전용 아이템입니다';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 가격 계산 (VIP 할인 적용)
      int finalPrice = item.price;
      if (isVIP && vipDiscount != null) {
        finalPrice = (item.price * (100 - vipDiscount) / 100).round();
      }

      // 코인 확인
      if (_coins < finalPrice) {
        _error = '코인이 부족합니다';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 이미 보유 여부 확인
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final avatar = Avatar.fromMap(userData['avatar'] ?? {});

        bool alreadyOwned = false;
        switch (item.category) {
          case ItemCategory.top:
            alreadyOwned = avatar.ownedItems.tops.contains(item.name);
            break;
          case ItemCategory.bottom:
            alreadyOwned = avatar.ownedItems.bottoms.contains(item.name);
            break;
          case ItemCategory.accessory:
            alreadyOwned = avatar.ownedItems.accessories.contains(item.name);
            break;
          case ItemCategory.hair:
            alreadyOwned = avatar.ownedItems.hairs.contains(item.name);
            break;
          case ItemCategory.background:
            alreadyOwned = avatar.ownedItems.backgrounds.contains(item.name);
            break;
          case ItemCategory.special:
            alreadyOwned = avatar.ownedItems.specialItems.contains(item.name);
            break;
        }

        if (alreadyOwned) {
          _error = '이미 보유한 아이템입니다';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // 아이템 추가 및 코인 차감
        String fieldName;
        switch (item.category) {
          case ItemCategory.top:
            fieldName = 'avatar.ownedItems.tops';
            break;
          case ItemCategory.bottom:
            fieldName = 'avatar.ownedItems.bottoms';
            break;
          case ItemCategory.accessory:
            fieldName = 'avatar.ownedItems.accessories';
            break;
          case ItemCategory.hair:
            fieldName = 'avatar.ownedItems.hairs';
            break;
          case ItemCategory.background:
            fieldName = 'avatar.ownedItems.backgrounds';
            break;
          case ItemCategory.special:
            fieldName = 'avatar.ownedItems.specialItems';
            break;
        }

        await _firestore.collection('users').doc(userId).update({
          fieldName: FieldValue.arrayUnion([item.name]),
          'coins': FieldValue.increment(-finalPrice),
        });

        // 구매 히스토리 기록
        await _firestore.collection('purchase_history').add({
          'userId': userId,
          'itemId': item.id,
          'itemName': item.name,
          'category': item.category.toString(),
          'price': finalPrice,
          'originalPrice': item.price,
          'discount': vipDiscount ?? 0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 로컬 코인 업데이트
        _coins -= finalPrice;
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = '아이템 구매에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 코인 충전 (테스트용)
  Future<bool> addCoins(String userId, int amount) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'coins': FieldValue.increment(amount),
      });

      _coins += amount;
      notifyListeners();

      return true;
    } catch (e) {
      _error = '코인 충전에 실패했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// VIP 할인율 가져오기
  static int getVIPDiscount(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.vip_basic:
        return 10;
      case SubscriptionType.vip_premium:
        return 20;
      case SubscriptionType.vip_platinum:
        return 30;
      default:
        return 0;
    }
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
