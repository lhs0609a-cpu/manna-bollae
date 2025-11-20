import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class SwipeMatchingCard extends StatefulWidget {
  const SwipeMatchingCard({super.key});

  @override
  State<SwipeMatchingCard> createState() => _SwipeMatchingCardState();
}

class _SwipeMatchingCardState extends State<SwipeMatchingCard> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<MatchProfile> _profiles = [
    MatchProfile(
      name: '서연',
      age: 26,
      location: '서울 강남구',
      distance: '2km',
      mbti: 'ENFJ',
      interests: ['여행', '요리', '운동', '카페'],
      bio: '새로운 사람들과의 만남을 좋아해요 ✨',
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
      interests: ['영화', '음악', '사진', '전시'],
      bio: '영화 보고 산책하는 걸 좋아합니다 🎬',
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
      interests: ['카페', '독서', '전시회', '베이킹'],
      bio: '힐링되는 카페 찾아다니는 중☕',
      trustScore: 85,
      temperature: 48.5,
      isVerified: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextProfile() {
    if (_currentIndex < _profiles.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 550,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _profiles.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildProfileCard(_profiles[index]);
            },
          ),

          // 인디케이터
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentIndex + 1}/${_profiles.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(MatchProfile profile) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.purple[400]!,
            Colors.pink[400]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 배경 효과
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 프로필 내용
            Positioned(
              left: 24,
              right: 24,
              bottom: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이름 & 나이
                  Row(
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${profile.age}',
                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                        ),
                      ),
                      if (profile.isVerified) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 위치
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${profile.location} • ${profile.distance}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Bio
                  Text(
                    profile.bio,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // 관심사
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.interests.take(4).map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          interest,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // 하단 버튼들
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pass
                  _buildActionButton(
                    icon: Icons.close,
                    color: Colors.grey,
                    size: 60,
                    onTap: () {
                      _showReaction('👋');
                      _nextProfile();
                    },
                  ),

                  // Super Like
                  _buildActionButton(
                    icon: Icons.star,
                    color: Colors.amber,
                    size: 70,
                    onTap: () {
                      _showReaction('⭐');
                      _showMatchDialog(profile);
                    },
                  ),

                  // Like
                  _buildActionButton(
                    icon: Icons.favorite,
                    color: Colors.pink,
                    size: 60,
                    onTap: () {
                      _showReaction('💖');
                      _nextProfile();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
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
          color: color,
          size: size * 0.5,
        ),
      ),
    );
  }

  void _showReaction(String emoji) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: 1.0 - value,
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 100),
                ),
              ),
            );
          },
          onEnd: () {
            overlayEntry.remove();
          },
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }

  void _showMatchDialog(MatchProfile profile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink[400]!, Colors.purple[400]!],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              const Text(
                '매칭 성공!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${profile.name}님과 매칭되었어요',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _nextProfile();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('메시지 보내기'),
              ),
            ],
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
    required this.trustScore,
    required this.temperature,
    required this.isVerified,
  });
}
