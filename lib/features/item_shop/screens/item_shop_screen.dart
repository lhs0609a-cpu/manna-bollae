import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/user_model.dart';
import '../../../models/subscription_type.dart';
import '../../auth/providers/auth_provider.dart';
import '../../avatar/providers/avatar_provider.dart';
import '../providers/item_shop_provider.dart';

class ItemShopScreen extends StatefulWidget {
  const ItemShopScreen({super.key});

  @override
  State<ItemShopScreen> createState() => _ItemShopScreenState();
}

class _ItemShopScreenState extends State<ItemShopScreen> {
  ItemCategory? _selectedCategory;
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final itemShopProvider = context.read<ItemShopProvider>();
    final avatarProvider = context.read<AvatarProvider>();

    if (authProvider.user != null) {
      // 사용자 정보 로드
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authProvider.user!.uid)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          _currentUser = UserModel.fromMap(doc.data()!);
          _isLoading = false;
        });
      }

      // 코인 및 아바타 로드
      itemShopProvider.loadCoins(authProvider.user!.uid);
      avatarProvider.loadAvatar(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemShopProvider = context.watch<ItemShopProvider>();
    final avatarProvider = context.watch<AvatarProvider>();

    if (_isLoading || _currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final items = itemShopProvider.getItemsByCategory(_selectedCategory);
    final isVIP = _currentUser!.subscription.type == SubscriptionType.vip_basic.toValue() ||
        _currentUser!.subscription.type == SubscriptionType.vip_premium.toValue() ||
        _currentUser!.subscription.type == SubscriptionType.vip_platinum.toValue();

    return Scaffold(
      appBar: AppBar(
        title: const Text('아이템 샵'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          // 코인 표시
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  '${itemShopProvider.coins}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // VIP 할인 배너
          if (isVIP)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.vipGold,
                    AppColors.vipGold.withOpacity(0.7),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'VIP ${ItemShopProvider.getVIPDiscount(SubscriptionTypeExtension.fromValue(_currentUser!.subscription.type))}% 할인 중!',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // 카테고리 필터
          _buildCategoryFilter(),

          // 아이템 그리드
          Expanded(
            child: items.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _buildItemCard(
                        items[index],
                        avatarProvider.avatar,
                        isVIP,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCoinChargeDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('코인 충전'),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip(null, '전체', Icons.apps),
          const SizedBox(width: 8),
          ...ItemCategory.values.map((category) {
            IconData icon;
            switch (category) {
              case ItemCategory.top:
                icon = Icons.checkroom;
                break;
              case ItemCategory.bottom:
                icon = Icons.shopping_bag;
                break;
              case ItemCategory.accessory:
                icon = Icons.grade;
                break;
              case ItemCategory.hair:
                icon = Icons.face;
                break;
              case ItemCategory.background:
                icon = Icons.wallpaper;
                break;
              case ItemCategory.special:
                icon = Icons.star;
                break;
            }
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildCategoryChip(
                category,
                ItemShopProvider.getCategoryName(category),
                icon,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    ItemCategory? category,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedCategory == category;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.borderColor,
      ),
    );
  }

  Widget _buildItemCard(ShopItem item, Avatar? avatar, bool isVIP) {
    // 보유 여부 확인
    bool isOwned = false;
    if (avatar != null) {
      switch (item.category) {
        case ItemCategory.top:
          isOwned = avatar.ownedItems.tops.contains(item.name);
          break;
        case ItemCategory.bottom:
          isOwned = avatar.ownedItems.bottoms.contains(item.name);
          break;
        case ItemCategory.accessory:
          isOwned = avatar.ownedItems.accessories.contains(item.name);
          break;
        case ItemCategory.hair:
          isOwned = avatar.ownedItems.hairs.contains(item.name);
          break;
        case ItemCategory.background:
          isOwned = avatar.ownedItems.backgrounds.contains(item.name);
          break;
        case ItemCategory.special:
          isOwned = avatar.ownedItems.specialItems.contains(item.name);
          break;
      }
    }

    // 가격 계산 (VIP 할인)
    final discount = isVIP
        ? ItemShopProvider.getVIPDiscount(SubscriptionTypeExtension.fromValue(_currentUser!.subscription.type))
        : 0;
    final finalPrice = discount > 0
        ? (item.price * (100 - discount) / 100).round()
        : item.price;

    return GestureDetector(
      onTap: () => _showItemDialog(item, isOwned, isVIP),
      child: Container(
        decoration: BoxDecoration(
          color: isOwned
              ? AppColors.success.withOpacity(0.1)
              : (item.isVIPExclusive && !isVIP
                  ? AppColors.borderColor.withOpacity(0.5)
                  : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOwned
                ? AppColors.success
                : (item.isVIPExclusive
                    ? AppColors.vipGold
                    : AppColors.borderColor),
            width: isOwned ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 배지들
            if (item.isVIPExclusive || item.isLimitedEdition || isOwned)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 4,
                  children: [
                    if (item.isVIPExclusive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.vipGold,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'VIP',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    if (item.isLimitedEdition)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '한정',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    if (isOwned)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '보유',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // 아이템 이모지
            Text(
              item.emoji,
              style: TextStyle(
                fontSize: 64,
                color: item.isVIPExclusive && !isVIP
                    ? Colors.grey.withOpacity(0.5)
                    : null,
              ),
            ),

            const SizedBox(height: 8),

            // 아이템 이름
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.name,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 4),

            // 가격
            if (!isOwned)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (discount > 0) ...[
                    Text(
                      '${item.price}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  const Icon(
                    Icons.monetization_on,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$finalPrice',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

            // 잠금 아이콘
            if (item.isVIPExclusive && !isVIP)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.lock,
                  size: 20,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '아이템이 없습니다',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDialog(ShopItem item, bool isOwned, bool isVIP) {
    final discount = isVIP
        ? ItemShopProvider.getVIPDiscount(SubscriptionTypeExtension.fromValue(_currentUser!.subscription.type))
        : 0;
    final finalPrice = discount > 0
        ? (item.price * (100 - discount) / 100).round()
        : item.price;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(
              item.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.name,
                style: AppTextStyles.h3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (item.isVIPExclusive)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.vipGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      color: AppColors.vipGold,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'VIP 전용 아이템',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.vipGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            if (item.isLimitedEdition) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '한정판 아이템',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!isOwned) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '가격',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      if (discount > 0) ...[
                        Text(
                          '${item.price}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      const Icon(
                        Icons.monetization_on,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$finalPrice',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          if (!isOwned)
            ElevatedButton(
              onPressed: item.isVIPExclusive && !isVIP
                  ? null
                  : () => _handlePurchase(item, finalPrice, discount),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.borderColor,
              ),
              child: const Text('구매하기'),
            ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase(
    ShopItem item,
    int finalPrice,
    int discount,
  ) async {
    Navigator.pop(context); // 다이얼로그 닫기

    final authProvider = context.read<AuthProvider>();
    final itemShopProvider = context.read<ItemShopProvider>();
    final avatarProvider = context.read<AvatarProvider>();

    if (authProvider.user == null) return;

    final isVIP = _currentUser!.subscription.type == SubscriptionType.vip_basic.toValue() ||
        _currentUser!.subscription.type == SubscriptionType.vip_premium.toValue() ||
        _currentUser!.subscription.type == SubscriptionType.vip_platinum.toValue();

    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await itemShopProvider.purchaseItem(
      userId: authProvider.user!.uid,
      item: item,
      isVIP: isVIP,
      vipDiscount: discount,
    );

    // 로딩 닫기
    if (mounted) Navigator.pop(context);

    if (success && mounted) {
      // 아바타 새로고침
      await avatarProvider.loadAvatar(authProvider.user!.uid);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name}을(를) 구매했습니다!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (itemShopProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(itemShopProvider.error!),
          backgroundColor: AppColors.error,
        ),
      );
      itemShopProvider.clearError();
    }
  }

  void _showCoinChargeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('코인 충전'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '테스트 모드: 무료로 코인을 충전할 수 있습니다',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _buildCoinPackage(100, '무료'),
            const SizedBox(height: 8),
            _buildCoinPackage(500, '무료'),
            const SizedBox(height: 8),
            _buildCoinPackage(1000, '무료'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinPackage(int amount, String price) {
    return InkWell(
      onTap: () => _handleCoinCharge(amount),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  '$amount 코인',
                  style: AppTextStyles.h4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              price,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCoinCharge(int amount) async {
    Navigator.pop(context); // 다이얼로그 닫기

    final authProvider = context.read<AuthProvider>();
    final itemShopProvider = context.read<ItemShopProvider>();

    if (authProvider.user == null) return;

    final success = await itemShopProvider.addCoins(
      authProvider.user!.uid,
      amount,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$amount 코인이 충전되었습니다!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
