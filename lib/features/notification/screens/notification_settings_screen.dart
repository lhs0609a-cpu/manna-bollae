import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notification_settings_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final authProvider = context.read<AuthProvider>();
    final notificationProvider = context.read<NotificationSettingsProvider>();

    if (authProvider.user != null) {
      await notificationProvider.loadSettings(authProvider.user!.uid);
    }
  }

  Future<void> _selectTime(
    BuildContext context,
    String currentTime,
    bool isStartTime,
  ) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null && mounted) {
      final authProvider = context.read<AuthProvider>();
      final notificationProvider = context.read<NotificationSettingsProvider>();
      final settings = notificationProvider.settings;

      final timeString =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

      if (authProvider.user != null) {
        await notificationProvider.setQuietTime(
          authProvider.user!.uid,
          isStartTime ? timeString : settings.quietStartTime,
          isStartTime ? settings.quietEndTime : timeString,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final notificationProvider = context.watch<NotificationSettingsProvider>();
    final settings = notificationProvider.settings;

    if (notificationProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
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
          // 전체 알림 설정
          Container(
            color: Colors.white,
            child: SwitchListTile(
              title: const Text(
                '푸시 알림',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('모든 알림을 받습니다'),
              value: settings.pushEnabled,
              activeColor: AppColors.primary,
              onChanged: authProvider.user != null
                  ? (value) {
                      notificationProvider.togglePushEnabled(
                        authProvider.user!.uid,
                        value,
                      );
                    }
                  : null,
            ),
          ),
          const SizedBox(height: 8),

          // 활동 알림
          _buildSection('활동 알림', [
            _buildSwitchTile(
              title: '새 매칭',
              subtitle: '새로운 매칭이 생겼을 때 알림을 받습니다',
              value: settings.newMatch,
              enabled: settings.pushEnabled,
              onChanged: authProvider.user != null
                  ? (value) {
                      notificationProvider.toggleNewMatch(
                        authProvider.user!.uid,
                        value,
                      );
                    }
                  : null,
            ),
            _buildSwitchTile(
              title: '새 메시지',
              subtitle: '새로운 메시지가 도착했을 때 알림을 받습니다',
              value: settings.newMessage,
              enabled: settings.pushEnabled,
              onChanged: authProvider.user != null
                  ? (value) {
                      notificationProvider.toggleNewMessage(
                        authProvider.user!.uid,
                        value,
                      );
                    }
                  : null,
            ),
            _buildSwitchTile(
              title: '좋아요',
              subtitle: '누군가 나를 좋아요 했을 때 알림을 받습니다',
              value: settings.newLike,
              enabled: settings.pushEnabled,
              onChanged: authProvider.user != null
                  ? (value) {
                      notificationProvider.toggleNewLike(
                        authProvider.user!.uid,
                        value,
                      );
                    }
                  : null,
            ),
            _buildSwitchTile(
              title: '점수 변경',
              subtitle: '신뢰점수나 하트온도가 변경되었을 때 알림을 받습니다',
              value: settings.scoreChange,
              enabled: settings.pushEnabled,
              onChanged: authProvider.user != null
                  ? (value) {
                      notificationProvider.toggleScoreChange(
                        authProvider.user!.uid,
                        value,
                      );
                    }
                  : null,
            ),
          ]),
          const SizedBox(height: 8),

          // 앱 알림
          _buildSection('앱 알림', [
            _buildSwitchTile(
              title: '데일리 퀘스트',
              subtitle: '매일 새로운 퀘스트가 등록되었을 때 알림을 받습니다',
              value: settings.dailyQuest,
              enabled: settings.pushEnabled,
              onChanged: authProvider.user != null
                  ? (value) {
                      notificationProvider.toggleDailyQuest(
                        authProvider.user!.uid,
                        value,
                      );
                    }
                  : null,
            ),
            _buildSwitchTile(
              title: '구독 관련',
              subtitle: '구독 만료, 갱신 등의 알림을 받습니다',
              value: settings.subscription,
              enabled: settings.pushEnabled,
              onChanged: authProvider.user != null
                  ? (value) {
                      notificationProvider.toggleSubscription(
                        authProvider.user!.uid,
                        value,
                      );
                    }
                  : null,
            ),
            _buildSwitchTile(
              title: '이벤트',
              subtitle: '새로운 이벤트 소식을 받습니다',
              value: settings.event,
              enabled: settings.pushEnabled,
              onChanged: authProvider.user != null
                  ? (value) {
                      notificationProvider.toggleEvent(
                        authProvider.user!.uid,
                        value,
                      );
                    }
                  : null,
            ),
            _buildSwitchTile(
              title: '마케팅 정보 수신',
              subtitle: '프로모션, 할인 등의 마케팅 정보를 받습니다',
              value: settings.marketing,
              enabled: settings.pushEnabled,
              onChanged: authProvider.user != null
                  ? (value) {
                      notificationProvider.toggleMarketing(
                        authProvider.user!.uid,
                        value,
                      );
                    }
                  : null,
            ),
          ]),
          const SizedBox(height: 8),

          // 알림 방식
          _buildSection('알림 방식', [
            _buildSwitchTile(
              title: '소리',
              subtitle: '알림 소리를 켭니다',
              value: settings.soundEnabled,
              enabled: settings.pushEnabled,
              onChanged: authProvider.user != null
                  ? (value) {
                      notificationProvider.toggleSound(
                        authProvider.user!.uid,
                        value,
                      );
                    }
                  : null,
            ),
            _buildSwitchTile(
              title: '진동',
              subtitle: '알림 시 진동을 켭니다',
              value: settings.vibrationEnabled,
              enabled: settings.pushEnabled,
              onChanged: authProvider.user != null
                  ? (value) {
                      notificationProvider.toggleVibration(
                        authProvider.user!.uid,
                        value,
                      );
                    }
                  : null,
            ),
          ]),
          const SizedBox(height: 8),

          // 방해금지 모드
          _buildSection('방해금지 모드', [
            _buildSwitchTile(
              title: '방해금지 모드',
              subtitle: '설정한 시간 동안 알림을 받지 않습니다',
              value: settings.quietModeEnabled,
              enabled: settings.pushEnabled,
              onChanged: authProvider.user != null
                  ? (value) {
                      notificationProvider.toggleQuietMode(
                        authProvider.user!.uid,
                        value,
                      );
                    }
                  : null,
            ),
            if (settings.quietModeEnabled) ...[
              ListTile(
                title: const Text('시작 시간'),
                trailing: InkWell(
                  onTap: settings.pushEnabled
                      ? () => _selectTime(context, settings.quietStartTime, true)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: settings.pushEnabled
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: settings.pushEnabled
                            ? AppColors.primary.withOpacity(0.3)
                            : Colors.grey[400]!,
                      ),
                    ),
                    child: Text(
                      settings.quietStartTime,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: settings.pushEnabled
                            ? AppColors.primary
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                enabled: settings.pushEnabled,
              ),
              ListTile(
                title: const Text('종료 시간'),
                trailing: InkWell(
                  onTap: settings.pushEnabled
                      ? () => _selectTime(context, settings.quietEndTime, false)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: settings.pushEnabled
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: settings.pushEnabled
                            ? AppColors.primary.withOpacity(0.3)
                            : Colors.grey[400]!,
                      ),
                    ),
                    child: Text(
                      settings.quietEndTime,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: settings.pushEnabled
                            ? AppColors.primary
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                enabled: settings.pushEnabled,
              ),
            ],
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    required void Function(bool)? onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? AppColors.textPrimary : Colors.grey[400],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: enabled ? AppColors.textSecondary : Colors.grey[400],
        ),
      ),
      value: value,
      activeColor: AppColors.primary,
      onChanged: enabled ? onChanged : null,
    );
  }
}
