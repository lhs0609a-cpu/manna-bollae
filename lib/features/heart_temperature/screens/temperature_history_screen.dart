import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/heart_temperature_provider.dart';

class TemperatureHistoryScreen extends StatefulWidget {
  const TemperatureHistoryScreen({super.key});

  @override
  State<TemperatureHistoryScreen> createState() =>
      _TemperatureHistoryScreenState();
}

class _TemperatureHistoryScreenState extends State<TemperatureHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final tempProvider = context.read<HeartTemperatureProvider>();

      if (authProvider.user != null) {
        tempProvider.loadHistory(authProvider.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final tempProvider = context.watch<HeartTemperatureProvider>();

    if (authProvider.user == null) {
      return const Scaffold(
        body: Center(child: Text('로그인이 필요합니다')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('온도 변경 이력'),
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
      body: tempProvider.history.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tempProvider.history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final history = tempProvider.history[index];
                return _buildHistoryItem(history);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 온도 변경 이력이 없습니다',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(TemperatureHistory history) {
    final info = _getHistoryInfo(history.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: info['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              info['icon'],
              color: info['color'],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      info['title'],
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      history.change > 0
                          ? '+${history.change.toStringAsFixed(1)}°'
                          : '${history.change.toStringAsFixed(1)}°',
                      style: AppTextStyles.h4.copyWith(
                        color: history.change > 0
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (history.reason != null && history.reason!.isNotEmpty) ...[
                  Text(
                    history.reason!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  _formatDate(history.timestamp),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getHistoryInfo(TemperatureChangeType type) {
    switch (type) {
      case TemperatureChangeType.positiveReview:
        return {
          'icon': Icons.thumb_up,
          'title': '긍정 리뷰',
          'color': AppColors.success,
        };
      case TemperatureChangeType.negativeReview:
        return {
          'icon': Icons.thumb_down,
          'title': '부정 리뷰',
          'color': AppColors.warning,
        };
      case TemperatureChangeType.report:
        return {
          'icon': Icons.report,
          'title': '신고 접수',
          'color': AppColors.error,
        };
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return '방금 전';
        }
        return '${diff.inMinutes}분 전';
      }
      return '${diff.inHours}시간 전';
    } else if (diff.inDays == 1) {
      return '어제 ${DateFormat('HH:mm').format(date)}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return DateFormat('yyyy.MM.dd HH:mm').format(date);
    }
  }
}
