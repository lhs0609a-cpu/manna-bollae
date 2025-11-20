import 'package:intl/intl.dart';

/// 날짜 포맷 유틸리티
class DateFormatter {
  /// 상대적 시간 표시 (예: 방금 전, 3분 전, 1시간 전 등)
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}주 전';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}개월 전';
    } else {
      return '${(difference.inDays / 365).floor()}년 전';
    }
  }

  /// 채팅 시간 표시 (예: 오전 10:30, 어제, 2024.01.01)
  static String getChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // 오늘: 오전/오후 시:분
      return DateFormat('a h:mm', 'ko_KR').format(dateTime);
    } else if (messageDate == yesterday) {
      // 어제
      return '어제';
    } else if (now.difference(dateTime).inDays < 7) {
      // 일주일 이내: 요일
      final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      return '${weekdays[dateTime.weekday - 1]}요일';
    } else if (dateTime.year == now.year) {
      // 올해: MM월 DD일
      return DateFormat('M월 d일').format(dateTime);
    } else {
      // 그 외: YYYY.MM.DD
      return DateFormat('yyyy.MM.dd').format(dateTime);
    }
  }

  /// 메시지 시간 표시 (예: 오전 10:30)
  static String getMessageTime(DateTime dateTime) {
    return DateFormat('a h:mm', 'ko_KR').format(dateTime);
  }

  /// 전체 날짜 시간 (예: 2024년 1월 1일 오전 10:30)
  static String getFullDateTime(DateTime dateTime) {
    return DateFormat('yyyy년 M월 d일 a h:mm', 'ko_KR').format(dateTime);
  }

  /// 짧은 날짜 (예: 2024.01.01)
  static String getShortDate(DateTime dateTime) {
    return DateFormat('yyyy.MM.dd').format(dateTime);
  }

  /// 긴 날짜 (예: 2024년 1월 1일)
  static String getLongDate(DateTime dateTime) {
    return DateFormat('yyyy년 M월 d일').format(dateTime);
  }

  /// 요일 포함 날짜 (예: 2024년 1월 1일 월요일)
  static String getDateWithWeekday(DateTime dateTime) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final date = DateFormat('yyyy년 M월 d일').format(dateTime);
    return '$date ${weekdays[dateTime.weekday - 1]}요일';
  }

  /// 나이 계산
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// D-Day 계산 (예: D-7, D-Day, D+3)
  static String getDDay(DateTime targetDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final difference = target.difference(today).inDays;

    if (difference == 0) {
      return 'D-Day';
    } else if (difference > 0) {
      return 'D-$difference';
    } else {
      return 'D+${-difference}';
    }
  }

  /// 경과 시간 (예: 1시간 30분, 2일 3시간)
  static String getElapsedTime(DateTime startTime, DateTime endTime) {
    final duration = endTime.difference(startTime);

    if (duration.inDays > 0) {
      final hours = duration.inHours % 24;
      if (hours > 0) {
        return '${duration.inDays}일 $hours시간';
      }
      return '${duration.inDays}일';
    } else if (duration.inHours > 0) {
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '${duration.inHours}시간 $minutes분';
      }
      return '${duration.inHours}시간';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}분';
    } else {
      return '${duration.inSeconds}초';
    }
  }

  /// 시간 범위 표시 (예: 오전 10:00 - 오후 2:00)
  static String getTimeRange(DateTime startTime, DateTime endTime) {
    final start = DateFormat('a h:mm', 'ko_KR').format(startTime);
    final end = DateFormat('a h:mm', 'ko_KR').format(endTime);
    return '$start - $end';
  }

  /// 남은 시간 (예: 3시간 후, 2일 후)
  static String getTimeRemaining(DateTime targetTime) {
    final now = DateTime.now();
    final difference = targetTime.difference(now);

    if (difference.isNegative) {
      return '만료됨';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 후';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 후';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 후';
    } else {
      return '${difference.inSeconds}초 후';
    }
  }
}
