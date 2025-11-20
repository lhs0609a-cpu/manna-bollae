import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

class MatchingScreenInstagram extends StatefulWidget {
  const MatchingScreenInstagram({super.key});

  @override
  State<MatchingScreenInstagram> createState() => _MatchingScreenInstagramState();
}

class _MatchingScreenInstagramState extends State<MatchingScreenInstagram>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  List<MatchProfile> _profiles = [];
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadProfiles() {
    // Mock 데이터
    _profiles = [
      MatchProfile(
        name: '서연',
        age: 26,
        location: '서울 강남구',
        distance: '2km',
        mbti: 'ENFJ',
        interests: ['여행', '요리', '운동'],
        bio: '새로운 사람들과의 만남을 좋아해요 ✨\n함께 맛집 탐방하실 분!',
        photos: 3,
        trustScore: 88,
        temperature: 45.8,
        isVerified: true,
      ),
      MatchProfile(
        name: '민준',
        age: 28,
        location: '서울 서초구',
        distance: '3km',
        mbti: 'INFP',
        interests: ['영화', '음악', '사진'],
        bio: '영화 보고 산책하는 걸 좋아합니다 🎬\n감성적인 대화 환영해요!',
        photos: 4,
        trustScore: 92,
        temperature: 52.3,
        isVerified: true,
      ),
      MatchProfile(
        name: '지우',
        age: 25,
        location: '서울 마포구',
        distance: '5km',
        mbti: 'ESFP',
        interests: ['카페', '독서', '전시회'],
        bio: '힐링되는 카페 찾아다니는 중☕\n책 좋아하시는 분 연락주세요!',
        photos: 5,
        trustScore: 85,
        temperature: 48.5,
        isVerified: false,
      ),
      MatchProfile(
        name: '현우',
        age: 29,
        location: '서울 용산구',
        distance: '4km',
        mbti: 'ISTJ',
        interests: ['운동', '게임', '맛집'],
        bio: '헬스 5년차 PT 받고 있어요 💪\n건강한 라이프스타일 추구합니다',
        photos: 4,
        trustScore: 90,
        temperature: 50.2,
        isVerified: true,
      ),
      MatchProfile(
        name: '수민',
        age: 27,
        location: '서울 송파구',
        distance: '6km',
        mbti: 'ENFP',
        interests: ['여행', '맛집', '공연'],
        bio: '주말엔 공연 보러 다녀요 🎭\n같이 즐길 분 찾습니다!',
        photos: 6,
        trustScore: 87,
        temperature: 46.9,
        isVerified: true,
      ),
    ];
  }

  void _onLike() {
    setState(() {
      if (_currentIndex < _profiles.length - 1) {
        _currentIndex++;
      } else {
        _showNoMoreProfilesDialog();
      }
    });
  }

  void _onPass() {
    setState(() {
      if (_currentIndex < _profiles.length - 1) {
        _currentIndex++;
      } else {
        _showNoMoreProfilesDialog();
      }
    });
  }

  void _onSuperLike() {
    _showSuperLikeDialog();
    setState(() {
      if (_currentIndex < _profiles.length - 1) {
        _currentIndex++;
      }
    });
  }

  void _showSuperLikeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber[700]),
            const SizedBox(width: 8),
            const Text('슈퍼 좋아요!'),
          ],
        ),
        content: const Text('슈퍼 좋아요를 보냈습니다!\n상대방에게 우선적으로 표시됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showNoMoreProfilesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('모든 프로필을 확인했어요'),
        content: const Text('새로운 프로필이 곧 업데이트됩니다!\n조금만 기다려주세요 😊'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
              });
            },
            child: const Text('처음부터 다시 보기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _currentIndex < _profiles.length
                  ? _buildMatchingCard(_profiles[_currentIndex])
                  : _buildNoMoreProfiles(),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Colors.pink, size: 28),
          const SizedBox(width: 12),
          const Text(
            '매칭',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.tune, color: Colors.grey),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingCard(MatchProfile profile) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // 배경 그라데이션
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.primaries[profile.name.hashCode % Colors.primaries.length][100]!,
                        Colors.primaries[profile.name.hashCode % Colors.primaries.length][300]!,
                      ],
                    ),
                  ),
                ),
                // 프로필 내용
                Column(
                  children: [
                    _buildPhotoSection(profile),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildProfileInfo(profile),
                      ),
                    ),
                  ],
                ),
                // 상단 사진 인디케이터
                _buildPhotoIndicator(profile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoIndicator(MatchProfile profile) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        children: List.generate(
          profile.photos,
          (index) => Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: index < profile.photos - 1 ? 4 : 0),
              decoration: BoxDecoration(
                color: index == 0 ? Colors.white : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection(MatchProfile profile) {
    return Container(
      height: 300,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(40),
      child: Hero(
        tag: 'profile_${profile.name}',
        child: CircleAvatar(
          radius: 100,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 95,
            backgroundColor: Colors.primaries[profile.name.hashCode % Colors.primaries.length],
            child: Text(
              profile.name[0],
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(MatchProfile profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이름과 나이
          Row(
            children: [
              Text(
                profile.name,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${profile.age}',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.grey[600],
                ),
              ),
              if (profile.isVerified) ...[
                const SizedBox(width: 8),
                Icon(Icons.verified, color: Colors.blue[400], size: 28),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // 위치
          Row(
            children: [
              Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${profile.location} • ${profile.distance}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 통계
          Row(
            children: [
              _buildStatChip(
                Icons.verified_user,
                '신뢰 ${profile.trustScore}',
                Colors.blue,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                Icons.favorite,
                '온도 ${profile.temperature.toStringAsFixed(1)}°',
                Colors.red,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                Icons.psychology,
                profile.mbti,
                Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 소개
          const Text(
            '소개',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.bio,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // 관심사
          const Text(
            '관심사',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.interests.map((interest) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.primaries[interest.hashCode % Colors.primaries.length]
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.primaries[interest.hashCode % Colors.primaries.length]
                        .withOpacity(0.3),
                  ),
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    color: Colors.primaries[interest.hashCode % Colors.primaries.length],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMoreProfiles() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '새로운 프로필을 찾고 있어요',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '곧 새로운 매칭이 도착할 거예요!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentIndex = 0;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              '처음부터 다시 보기',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.close,
            color: Colors.grey[400]!,
            size: 60,
            iconSize: 32,
            onPressed: () {
              _animationController.forward().then((_) {
                _animationController.reverse();
                _onPass();
              });
            },
          ),
          _buildActionButton(
            icon: Icons.star,
            color: Colors.amber[400]!,
            size: 54,
            iconSize: 28,
            onPressed: () {
              _animationController.forward().then((_) {
                _animationController.reverse();
                _onSuperLike();
              });
            },
          ),
          _buildActionButton(
            icon: Icons.favorite,
            color: Colors.pink[400]!,
            size: 70,
            iconSize: 36,
            onPressed: () {
              _animationController.forward().then((_) {
                _animationController.reverse();
                _onLike();
              });
            },
          ),
          _buildActionButton(
            icon: Icons.flash_on,
            color: Colors.purple[400]!,
            size: 54,
            iconSize: 28,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required double iconSize,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}

class MatchProfile {
  final String name;
  final int age;
  final String location;
  final String distance;
  final String mbti;
  final List<String> interests;
  final String bio;
  final int photos;
  final int trustScore;
  final double temperature;
  final bool isVerified;

  MatchProfile({
    required this.name,
    required this.age,
    required this.location,
    required this.distance,
    required this.mbti,
    required this.interests,
    required this.bio,
    required this.photos,
    required this.trustScore,
    required this.temperature,
    required this.isVerified,
  });
}
