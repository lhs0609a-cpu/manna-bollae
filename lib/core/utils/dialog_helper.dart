import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

/// 다이얼로그 헬퍼 유틸리티
class DialogHelper {
  /// 확인 다이얼로그
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDanger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmText,
              style: TextStyle(
                color: isDanger ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// 알림 다이얼로그
  static Future<void> showAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = '확인',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// 성공 다이얼로그
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = '확인',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: message != null ? Text(message) : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// 에러 다이얼로그
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = '확인',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error,
              color: AppColors.error,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: message != null ? Text(message) : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// 로딩 다이얼로그 표시
  static void showLoadingDialog({
    required BuildContext context,
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 로딩 다이얼로그 닫기
  static void dismissLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }

  /// 선택 다이얼로그 (리스트에서 선택)
  static Future<T?> showSelectionDialog<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) itemBuilder,
    T? selectedItem,
  }) async {
    return await showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) {
              final isSelected = item == selectedItem;
              return ListTile(
                title: Text(
                  itemBuilder(item),
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.pop(context, item),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  /// 입력 다이얼로그
  static Future<String?> showInputDialog({
    required BuildContext context,
    required String title,
    String? hint,
    String? initialValue,
    int? maxLength,
    String confirmText = '확인',
    String cancelText = '취소',
  }) async {
    final controller = TextEditingController(text: initialValue);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLength: maxLength,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  /// 바텀 시트 표시
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
  }) async {
    return await showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: child,
      ),
    );
  }

  /// 액션 시트 표시
  static Future<T?> showActionSheet<T>({
    required BuildContext context,
    required String title,
    required List<ActionSheetItem<T>> actions,
    bool showCancel = true,
  }) async {
    return await showBottomSheet<T>(
      context: context,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ...actions.map((action) {
              return ListTile(
                leading: action.icon != null
                    ? Icon(
                        action.icon,
                        color: action.isDestructive
                            ? AppColors.error
                            : AppColors.textPrimary,
                      )
                    : null,
                title: Text(
                  action.label,
                  style: TextStyle(
                    color: action.isDestructive
                        ? AppColors.error
                        : AppColors.textPrimary,
                  ),
                ),
                onTap: () => Navigator.pop(context, action.value),
              );
            }).toList(),
            if (showCancel) ...[
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
          ],
        ),
      ),
    );
  }

  /// 날짜 선택 다이얼로그
  static Future<DateTime?> showDatePickerDialog({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
      locale: const Locale('ko', 'KR'),
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
  }

  /// 시간 선택 다이얼로그
  static Future<TimeOfDay?> showTimePickerDialog({
    required BuildContext context,
    TimeOfDay? initialTime,
  }) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
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
  }
}

/// 액션 시트 아이템
class ActionSheetItem<T> {
  final String label;
  final T value;
  final IconData? icon;
  final bool isDestructive;

  ActionSheetItem({
    required this.label,
    required this.value,
    this.icon,
    this.isDestructive = false,
  });
}
