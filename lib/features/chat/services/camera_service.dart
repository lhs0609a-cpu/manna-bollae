import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> takePicture(BuildContext context) async {
    // 1. 권한 확인
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      if (context.mounted) {
        _showPermissionDialog(context, '카메라');
      }
      return null;
    }

    try {
      // 2. 카메라로 사진 촬영
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (photo != null) {
        return File(photo.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 촬영 실패: $e')),
        );
      }
    }

    return null;
  }

  Future<File?> takeVideo(BuildContext context) async {
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      if (context.mounted) {
        _showPermissionDialog(context, '카메라');
      }
      return null;
    }

    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 10),
      );

      if (video != null) {
        return File(video.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('영상 촬영 실패: $e')),
        );
      }
    }

    return null;
  }

  Future<void> showCameraOptions(
    BuildContext context,
    Function(File) onPhotoSelected,
  ) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '사진 촬영 방식',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildOption(
                context,
                icon: Icons.camera_alt,
                title: '일반 사진',
                subtitle: '카메라로 사진 촬영',
                color: Colors.blue,
                onTap: () async {
                  Navigator.pop(context);
                  final photo = await takePicture(context);
                  if (photo != null) {
                    onPhotoSelected(photo);
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildOption(
                context,
                icon: Icons.videocam,
                title: '짧은 동영상',
                subtitle: '10초 영상 촬영',
                color: Colors.red,
                onTap: () async {
                  Navigator.pop(context);
                  final video = await takeVideo(context);
                  if (video != null) {
                    onPhotoSelected(video);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showPermissionDialog(BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('권한이 필요해요'),
        content: Text('$permissionName 기능을 사용하려면 권한이 필요합니다.\n설정에서 권한을 허용해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('설정으로 이동'),
          ),
        ],
      ),
    );
  }
}
