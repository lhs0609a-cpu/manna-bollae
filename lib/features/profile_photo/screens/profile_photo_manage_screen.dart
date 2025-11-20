import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/utils/dialog_helper.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_photo_provider.dart';

class ProfilePhotoManageScreen extends StatefulWidget {
  const ProfilePhotoManageScreen({super.key});

  @override
  State<ProfilePhotoManageScreen> createState() =>
      _ProfilePhotoManageScreenState();
}

class _ProfilePhotoManageScreenState extends State<ProfilePhotoManageScreen> {
  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final authProvider = context.read<AuthProvider>();
    final photoProvider = context.read<ProfilePhotoProvider>();

    if (authProvider.user != null) {
      await photoProvider.loadPhotos(authProvider.user!.uid);
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final authProvider = context.read<AuthProvider>();
        final photoProvider = context.read<ProfilePhotoProvider>();

        if (authProvider.user == null) return;

        final success = await photoProvider.addPhoto(
          authProvider.user!.uid,
          pickedFile.path,
        );

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('사진이 추가되었습니다')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(photoProvider.error ?? '사진 추가에 실패했습니다'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 선택에 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _deletePhoto(String photoUrl) async {
    final confirmed = await DialogHelper.showConfirmDialog(
      context: context,
      title: '사진 삭제',
      message: '이 사진을 삭제하시겠습니까?',
      confirmText: '삭제',
      cancelText: '취소',
      isDanger: true,
    );

    if (!confirmed) return;

    final authProvider = context.read<AuthProvider>();
    final photoProvider = context.read<ProfilePhotoProvider>();

    if (authProvider.user == null) return;

    final success = await photoProvider.deletePhoto(
      authProvider.user!.uid,
      photoUrl,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진이 삭제되었습니다')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(photoProvider.error ?? '사진 삭제에 실패했습니다'),
          ),
        );
      }
    }
  }

  Future<void> _setMainPhoto(String photoUrl) async {
    final authProvider = context.read<AuthProvider>();
    final photoProvider = context.read<ProfilePhotoProvider>();

    if (authProvider.user == null) return;

    final success = await photoProvider.setMainPhoto(
      authProvider.user!.uid,
      photoUrl,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('메인 사진이 변경되었습니다')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(photoProvider.error ?? '메인 사진 설정에 실패했습니다'),
          ),
        );
      }
    }
  }

  void _showPhotoOptions(String photoUrl, bool isMainPhoto) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMainPhoto)
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('메인 사진으로 설정'),
                onTap: () {
                  Navigator.pop(context);
                  _setMainPhoto(photoUrl);
                },
              ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: Text(
                '사진 삭제',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _deletePhoto(photoUrl);
              },
            ),
            const Divider(height: 8, thickness: 8),
            ListTile(
              title: const Text(
                '취소',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photoProvider = context.watch<ProfilePhotoProvider>();

    if (photoProvider.isLoading && photoProvider.photoUrls.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 사진 관리'),
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
          // 안내 메시지
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '프로필 사진 안내',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• 최대 6장까지 등록할 수 있습니다\n'
                  '• 첫 번째 사진이 메인 사진으로 표시됩니다\n'
                  '• 얼굴이 잘 보이는 사진을 등록해주세요',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 사진 그리드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '내 사진 (${photoProvider.photoUrls.length}/6)',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: photoProvider.photoUrls.length < 6
                ? photoProvider.photoUrls.length + 1
                : 6,
            itemBuilder: (context, index) {
              // 사진 추가 버튼
              if (index == photoProvider.photoUrls.length &&
                  photoProvider.photoUrls.length < 6) {
                return InkWell(
                  onTap: _pickPhoto,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.dividerColor,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '사진 추가',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 사진 표시
              final photoUrl = photoProvider.photoUrls[index];
              final isMainPhoto = photoUrl == photoProvider.mainPhotoUrl;

              return GestureDetector(
                onTap: () => _showPhotoOptions(photoUrl, isMainPhoto),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isMainPhoto
                              ? AppColors.primary
                              : AppColors.dividerColor,
                          width: isMainPhoto ? 3 : 1,
                        ),
                        image: DecorationImage(
                          image: FileImage(File(photoUrl)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (isMainPhoto)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '메인',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
