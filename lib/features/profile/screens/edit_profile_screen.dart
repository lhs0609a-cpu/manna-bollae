import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import 'edit_basic_info_screen.dart';
import 'edit_personality_screen.dart';
import 'edit_hobbies_intro_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
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
    }
  }

  Future<void> _navigateToEditScreen(Widget screen) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    if (result == true && mounted) {
      // 데이터 새로고침
      setState(() {
        _isLoading = true;
      });
      await _loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('사용자 정보를 불러올 수 없습니다')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.dividerColor,
            height: 1,
          ),
        ),
      ),
      body: ListView(
        children: [
          // 안내 배너
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '프로필을 업데이트하세요',
                      style: AppTextStyles.h4.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '정확한 정보로 더 나은 매칭을 받아보세요!',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          // 수정 섹션들
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              '정보 수정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 기본 정보
          _buildEditSection(
            icon: Icons.person,
            title: '기본 정보',
            description: '이름, 생년월일, 지역',
            onTap: () => _navigateToEditScreen(
              EditBasicInfoScreen(currentUser: _currentUser!),
            ),
          ),

          // 성격 & 습관
          _buildEditSection(
            icon: Icons.psychology,
            title: '성격 & 습관',
            description: 'MBTI, 혈액형, 흡연, 음주, 종교',
            onTap: () => _navigateToEditScreen(
              EditPersonalityScreen(currentUser: _currentUser!),
            ),
          ),

          // 취미 & 소개
          _buildEditSection(
            icon: Icons.favorite,
            title: '취미 & 소개',
            description: '취미, 한 줄 소개',
            onTap: () => _navigateToEditScreen(
              EditHobbiesIntroScreen(currentUser: _currentUser!),
            ),
          ),

          const SizedBox(height: 16),

          // 추가 안내
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '프로필 사진과 아바타는 각각의 관리 메뉴에서 수정할 수 있습니다.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.blue[900],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEditSection({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}
