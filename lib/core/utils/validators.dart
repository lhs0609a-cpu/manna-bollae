/// 입력 검증 유틸리티
class Validators {
  /// 이메일 유효성 검사
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// 이메일 검증 메시지
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    if (!isValidEmail(value)) {
      return '올바른 이메일 형식이 아닙니다';
    }
    return null;
  }

  /// 비밀번호 유효성 검사 (최소 8자, 영문, 숫자 포함)
  static bool isValidPassword(String password) {
    if (password.length < 8) return false;

    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    return hasLetter && hasNumber;
  }

  /// 비밀번호 검증 메시지
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다';
    }
    if (!isValidPassword(value)) {
      return '영문과 숫자를 포함해야 합니다';
    }
    return null;
  }

  /// 비밀번호 확인 검증
  static String? validatePasswordConfirm(String? value, String password) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 다시 입력해주세요';
    }
    if (value != password) {
      return '비밀번호가 일치하지 않습니다';
    }
    return null;
  }

  /// 이름 유효성 검사 (2-10자의 한글/영문)
  static bool isValidName(String name) {
    if (name.length < 2 || name.length > 10) return false;

    final nameRegex = RegExp(r'^[가-힣a-zA-Z]+$');
    return nameRegex.hasMatch(name);
  }

  /// 이름 검증 메시지
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '이름을 입력해주세요';
    }
    if (value.length < 2) {
      return '이름은 2자 이상이어야 합니다';
    }
    if (value.length > 10) {
      return '이름은 10자 이하여야 합니다';
    }
    if (!isValidName(value)) {
      return '한글 또는 영문만 입력 가능합니다';
    }
    return null;
  }

  /// 전화번호 유효성 검사 (010-1234-5678 형식)
  static bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^01[0-9]-[0-9]{3,4}-[0-9]{4}$');
    return phoneRegex.hasMatch(phone);
  }

  /// 전화번호 검증 메시지
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '전화번호를 입력해주세요';
    }
    if (!isValidPhoneNumber(value)) {
      return '올바른 전화번호 형식이 아닙니다 (예: 010-1234-5678)';
    }
    return null;
  }

  /// 닉네임 유효성 검사 (2-12자)
  static bool isValidNickname(String nickname) {
    return nickname.length >= 2 && nickname.length <= 12;
  }

  /// 닉네임 검증 메시지
  static String? validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return '닉네임을 입력해주세요';
    }
    if (value.length < 2) {
      return '닉네임은 2자 이상이어야 합니다';
    }
    if (value.length > 12) {
      return '닉네임은 12자 이하여야 합니다';
    }
    return null;
  }

  /// 나이 유효성 검사 (19-99세)
  static bool isValidAge(int age) {
    return age >= 19 && age <= 99;
  }

  /// 나이 검증 메시지
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return '나이를 입력해주세요';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return '올바른 나이를 입력해주세요';
    }

    if (age < 19) {
      return '만 19세 이상만 이용 가능합니다';
    }
    if (age > 99) {
      return '올바른 나이를 입력해주세요';
    }
    return null;
  }

  /// 한 줄 소개 검증 (최대 100자)
  static String? validateOneLiner(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 선택사항
    }
    if (value.length > 100) {
      return '한 줄 소개는 100자 이하여야 합니다';
    }
    return null;
  }

  /// 자기소개 검증 (최대 500자)
  static String? validateBio(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 선택사항
    }
    if (value.length > 500) {
      return '자기소개는 500자 이하여야 합니다';
    }
    return null;
  }

  /// 필수 입력 검증
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName을(를) 입력해주세요';
    }
    return null;
  }

  /// 최소 길이 검증
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName을(를) 입력해주세요';
    }
    if (value.length < minLength) {
      return '$fieldName은(는) $minLength자 이상이어야 합니다';
    }
    return null;
  }

  /// 최대 길이 검증
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName은(는) $maxLength자 이하여야 합니다';
    }
    return null;
  }

  /// 범위 검증
  static String? validateRange(
    String? value,
    int min,
    int max,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName을(를) 입력해주세요';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return '올바른 숫자를 입력해주세요';
    }

    if (number < min || number > max) {
      return '$fieldName은(는) $min~$max 사이여야 합니다';
    }
    return null;
  }

  /// URL 유효성 검사
  static bool isValidUrl(String url) {
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(url);
  }

  /// URL 검증 메시지
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 선택사항
    }
    if (!isValidUrl(value)) {
      return '올바른 URL 형식이 아닙니다';
    }
    return null;
  }

  /// 욕설/비속어 필터 (간단한 버전)
  static bool containsProfanity(String text) {
    final profanityList = [
      '시발',
      '씨발',
      '개새',
      '병신',
      '미친',
      '좆',
      '꺼져',
      '닥쳐',
      // 더 많은 단어 추가 가능
    ];

    final lowerText = text.toLowerCase();
    return profanityList.any((word) => lowerText.contains(word));
  }

  /// 욕설/비속어 검증 메시지
  static String? validateProfanity(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (containsProfanity(value)) {
      return '부적절한 단어가 포함되어 있습니다';
    }
    return null;
  }
}
