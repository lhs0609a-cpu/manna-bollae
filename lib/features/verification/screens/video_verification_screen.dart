import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/verification_provider.dart';

class VideoVerificationScreen extends StatefulWidget {
  const VideoVerificationScreen({super.key});

  @override
  State<VideoVerificationScreen> createState() =>
      _VideoVerificationScreenState();
}

class _VideoVerificationScreenState extends State<VideoVerificationScreen> {
  File? _selectedVideo;
  bool _isSubmitting = false;
  String? _videoPath;

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickVideo(
        source: source,
        maxDuration: const Duration(seconds: 30),
      );

      if (pickedFile != null) {
        setState(() {
          _selectedVideo = File(pickedFile.path);
          _videoPath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('영상을 선택하는데 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _submitVerification() async {
    if (_selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('영상을 선택해주세요')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final verificationProvider = context.read<VerificationProvider>();

    if (authProvider.user == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 파일 업로드
      final videoUrl = await verificationProvider.uploadFile(
        _selectedVideo!.path,
        VerificationType.video,
      );

      if (videoUrl == null) {
        throw Exception('파일 업로드 실패');
      }

      // 인증 요청 제출
      final success = await verificationProvider.submitVerification(
        userId: authProvider.user!.uid,
        type: VerificationType.video,
        videoUrl: videoUrl,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('영상 인증 요청이 제출되었습니다')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(verificationProvider.error ?? '인증 요청 제출에 실패했습니다')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('영상 인증'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 안내 카드
              Container(
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
                          '영상 인증 안내',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      VerificationProvider.getVerificationDescription(
                          VerificationType.video),
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• 조명이 밝은 곳에서 촬영해주세요\n'
                      '• 얼굴이 정면으로 나오도록 해주세요\n'
                      '• 최대 30초까지 녹화 가능합니다\n'
                      '• 마스크, 선글라스 등을 착용하지 말아주세요\n'
                      '• 승인 시 +${VerificationProvider.getVerificationPoints(VerificationType.video)} 신뢰점수',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 영상 미리보기
              Container(
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.dividerColor,
                    width: 2,
                  ),
                ),
                child: _selectedVideo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              color: Colors.black,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.play_circle_outline,
                                      size: 80,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '영상이 선택되었습니다',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _videoPath?.split('/').last ?? '',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedVideo = null;
                                    _videoPath = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.videocam_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '영상을 선택해주세요',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '최대 30초',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // 영상 선택 버튼
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () => _pickVideo(ImageSource.camera),
                      icon: const Icon(Icons.videocam),
                      label: const Text('영상 촬영'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () => _pickVideo(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('갤러리'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 제출 버튼
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '인증 요청 제출',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
