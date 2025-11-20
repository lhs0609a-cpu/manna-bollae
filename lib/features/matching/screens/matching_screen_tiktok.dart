import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../auth/providers/auth_provider.dart';

class MatchingScreenTiktok extends StatefulWidget {
  const MatchingScreenTiktok({super.key});

  @override
  State<MatchingScreenTiktok> createState() => _MatchingScreenTiktokState();
}

class _MatchingScreenTiktokState extends State<MatchingScreenTiktok> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<MatchProfile> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadProfiles() {
    setState(() {
      _profiles.addAll([
        MatchProfile(
          name: '서연',
          age: 26,
          location: '서울 강남구',
          distance: '2km',
          mbti: 'ENFJ',
          interests: ['여행', '요리', '운동', '카페'],
          bio: '새로운 사람들과의 만남을 좋아해요 ✨\n함께 맛집 탐방하실 분!\n주말엔 한강 러닝 🏃‍♀️',
          photos: 3,
          trustScore: 88,
          temperature: 45.8,
          isVerified: true,
          job: '마케터',
          height: '165cm',
        ),
        MatchProfile(
          name: '민준',
          age: 28,
          location: '서울 서초구',
          distance: '3km',
          mbti: 'INFP',
          interests: ['영화', '음악', '사진', '전시'],
          bio: '영화 보고 산책하는 걸 좋아합니다 🎬\n감성적인 대화 환영해요!\n독립영화 좋아하시는 분 🎥',
          photos: 4,
          trustScore: 92,
          temperature: 52.3,
          isVerified: true,
          job: 'UX 디자이너',
          height: '178cm',
        ),
        MatchProfile(
          name: '지우',
          age: 25,
          location: '서울 마포구',
          distance: '5km',
          mbti: 'ESFP',
          interests: ['카페', '독서', '전시회', '베이킹'],
          bio: '힐링되는 카페 찾아다니는 중☕\n책 좋아하시는 분 연락주세요!\n홈베이킹 취미 🧁',
          photos: 5,
          trustScore: 85,
          temperature: 48.5,
          isVerified: true,
          job: '콘텐츠 크리에이터',
          height: '162cm',
        ),
        MatchProfile(
          name: '현우',
          age: 29,
          location: '서울 용산구',
          distance: '4km',
          mbti: 'ISTJ',
          interests: ['운동', '게임', '맛집', '드라이브'],
          bio: '헬스 5년차 PT 받고 있어요 💪\n건강한 라이프스타일 추구합니다\n주말 드라이브 좋아해요 🚗',
          photos: 4,
          trustScore: 90,
          temperature: 50.2,
          isVerified: true,
          job: 'IT 개발자',
          height: '182cm',
        ),
        MatchProfile(
          name: '수민',
          age: 27,
          location: '서울 송파구',
          distance: '6km',
          mbti: 'ENFP',
          interests: ['여행', '맛집', '공연', '사진'],
          bio: '주말엔 공연 보러 다녀요 🎭\n같이 즐길 분 찾습니다!\n여행 계획 짜는 걸 좋아해요 ✈️',
          photos: 6,
          trustScore: 87,
          temperature: 46.9,
          isVerified: true,
          job: '여행 작가',
          height: '168cm',
        ),
      ]);
    });
  }

  void _handleLike() {
    _showReactionOverlay('💖', AppColors.primary);
    _nextProfile();
  }

  void _handlePass() {
    _showReactionOverlay('👋', Colors.grey);
    _nextProfile();
  }

  void _handleSuperLike() {
    _showReactionOverlay('⭐', Colors.amber);
    _showMatchDialog();
    _nextProfile();
  }

  void _nextProfile() {
    if (_currentPage < _profiles.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showNoMoreProfilesDialog();
    }
  }

  void _showReactionOverlay(String emoji, Color color) {
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
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 80),
                    ),
                  ),
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

  void _showMatchDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉',
                style: TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 16),
              Text(
                '매칭 성공!',
                style: AppTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '서로 관심을 보였어요',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '계속 탐색',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // 채팅으로 이동
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '메시지 보내기',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoMoreProfilesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('더 이상 프로필이 없어요'),
        content: const Text('잠시 후 다시 확인해주세요!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_profiles.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 세로 스와이프 PageView
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _profiles.length,
            itemBuilder: (context, index) {
              return _buildProfileCard(_profiles[index]);
            },
          ),

          // 상단 그라데이션 오버레이
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 상단 앱바
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune, color: Colors.white),
                        onPressed: () {
                          Navigator.pushNamed(context, '/matching-filter');
                        },
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.storyGradient.createShader(bounds),
                      child: Text(
                        '만나볼래',
                        style: AppTextStyles.h3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline,
                            color: Colors.white),
                        onPressed: () {
                          // 채팅 목록으로 이동
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 페이지 인디케이터
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_profiles.length, (index) {
                    return Container(
                      width: 6,
                      height: _currentPage == index ? 24 : 6,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(MatchProfile profile) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 배경 이미지 (실제로는 사진 URL 사용)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.3),
                AppColors.secondary.withOpacity(0.3),
                AppColors.highlight.withOpacity(0.3),
              ],
            ),
          ),
          child: Center(
            child: Text(
              profile.name[0],
              style: TextStyle(
                fontSize: 200,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
        ),

        // 하단 정보 오버레이
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 이름, 나이, 인증뱃지
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              profile.name,
                              style: AppTextStyles.h1.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 32,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${profile.age}',
                              style: AppTextStyles.h2.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            if (profile.isVerified) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 직업
                  if (profile.job != null)
                    Row(
                      children: [
                        const Icon(Icons.work_outline,
                            color: Colors.white70, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          profile.job!,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 4),

                  // 위치, 거리
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${profile.location} · ${profile.distance}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 바이오
                  Text(
                    profile.bio,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // 관심사 태그
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.interests.map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          interest,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // 액션 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Pass
                      _buildActionButton(
                        icon: Icons.close,
                        color: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        size: 60,
                        onTap: _handlePass,
                      ),

                      // Super Like
                      _buildActionButton(
                        icon: Icons.star,
                        color: Colors.amber,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        size: 50,
                        onTap: _handleSuperLike,
                      ),

                      // Like
                      _buildActionButton(
                        icon: Icons.favorite,
                        color: AppColors.primary,
                        backgroundColor: Colors.white,
                        size: 70,
                        onTap: _handleLike,
                      ),

                      // Message
                      _buildActionButton(
                        icon: Icons.chat_bubble,
                        color: AppColors.highlight,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        size: 50,
                        onTap: () {
                          // 메시지 보내기
                        },
                      ),

                      // More Info
                      _buildActionButton(
                        icon: Icons.info_outline,
                        color: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        size: 50,
                        onTap: () {
                          _showProfileDetail(profile);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
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

  void _showProfileDetail(MatchProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              // 드래그 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 기본 정보
              Row(
                children: [
                  Text(
                    profile.name,
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${profile.age}',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildInfoSection('기본 정보', [
                _buildInfoRow(Icons.work, '직업', profile.job ?? '미입력'),
                _buildInfoRow(
                    Icons.location_on, '위치', '${profile.location} · ${profile.distance}'),
                _buildInfoRow(Icons.height, '키', profile.height ?? '미입력'),
                _buildInfoRow(
                    Icons.psychology, 'MBTI', profile.mbti ?? '미입력'),
              ]),

              const SizedBox(height: 24),

              _buildInfoSection('소개', [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    profile.bio,
                    style: AppTextStyles.bodyLarge.copyWith(height: 1.5),
                  ),
                ),
              ]),

              const SizedBox(height: 24),

              _buildInfoSection('관심사', [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.interests.map((interest) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          interest,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ]),

              const SizedBox(height: 32),

              // 액션 버튼
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handlePass();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.border, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Pass',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleLike();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Like',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h4.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class MatchProfile {
  final String name;
  final int age;
  final String location;
  final String distance;
  final String? mbti;
  final List<String> interests;
  final String bio;
  final int photos;
  final int trustScore;
  final double temperature;
  final bool isVerified;
  final String? job;
  final String? height;

  MatchProfile({
    required this.name,
    required this.age,
    required this.location,
    required this.distance,
    this.mbti,
    required this.interests,
    required this.bio,
    required this.photos,
    required this.trustScore,
    required this.temperature,
    required this.isVerified,
    this.job,
    this.height,
  });
}
