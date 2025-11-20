import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../avatar/widgets/avatar_renderer.dart';

class MatchingCard extends StatelessWidget {
  final UserModel user;
  final Avatar? avatar;
  final VoidCallback? onTap;

  const MatchingCard({
    super.key,
    required this.user,
    this.avatar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final basicInfo = user.profile.basicInfo;
    final lifestyle = user.profile.lifestyle;

    // 나이 계산
    int? age;
    if (basicInfo.birthDate != null) {
      age = DateTime.now().year - basicInfo.birthDate!.year;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
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
              // 배경 (아바타 또는 그라데이션)
              if (avatar != null)
                // 아바타 배경
                Center(
                  child: AvatarRenderer(
                    avatar: avatar!,
                    size: 400,
                    showEmotion: true,
                  ),
                )
              else
                // 기본 그라데이션
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.3),
                        AppColors.secondary.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              // 그라데이션 오버레이
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
              // 프로필 정보
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이름과 나이
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              basicInfo.name,
                              style: AppTextStyles.h2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (age != null)
                            Text(
                              ' $age',
                              style: AppTextStyles.h3.copyWith(
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 지역
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            basicInfo.region,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // MBTI, 혈액형
                      Row(
                        children: [
                          if (basicInfo.mbti != null) ...[
                            _buildInfoChip(basicInfo.mbti!),
                            const SizedBox(width: 8),
                          ],
                          if (basicInfo.bloodType != null) ...[
                            _buildInfoChip('${basicInfo.bloodType}형'),
                            const SizedBox(width: 8),
                          ],
                          if (basicInfo.religion != null)
                            _buildInfoChip(basicInfo.religion!),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // 한 줄 소개
                      if (basicInfo.oneLiner.isNotEmpty)
                        Text(
                          basicInfo.oneLiner,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.95),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 12),
                      // 취미
                      if (lifestyle.hobbies.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: lifestyle.hobbies.take(5).map((hobby) {
                            return _buildHobbyChip(hobby);
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              // 정보 버튼
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHobbyChip(String hobby) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        hobby,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
