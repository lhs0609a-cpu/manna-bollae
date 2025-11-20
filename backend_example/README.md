# 만나볼래 백엔드 서버 예시

이 폴더는 Flutter 앱과 연동할 수 있는 간단한 Express.js 백엔드 서버 예시입니다.

## 설치 방법

```bash
cd backend_example
npm install
```

## 서버 실행

### 기본 실행
```bash
npm start
```

### 개발 모드 (자동 재시작)
```bash
npm run dev
```

서버는 http://localhost:8080 에서 실행됩니다.

## API 엔드포인트

### 헬스 체크
- **GET** `/health` - 서버 상태 확인

### 사용자 관련
- **GET** `/api/users` - 사용자 목록
- **GET** `/api/users/:id` - 특정 사용자 정보

### 매칭 관련
- **GET** `/api/matches` - 매칭 목록

### 채팅 관련
- **GET** `/api/chats/:matchId/messages` - 채팅 메시지 목록
- **POST** `/api/chats/:matchId/messages` - 메시지 전송

### 프로필 관련
- **PUT** `/api/profile` - 프로필 업데이트

### 진심지수/하트온도
- **GET** `/api/trust-score` - 진심지수 정보
- **GET** `/api/heart-temperature` - 하트 온도 정보

## 테스트

### cURL로 테스트
```bash
# 헬스 체크
curl http://localhost:8080/health

# 사용자 목록
curl http://localhost:8080/api/users

# 진심지수 확인
curl http://localhost:8080/api/trust-score
```

## Flutter 앱과 연결

Flutter 앱은 이미 `http://localhost:8080`을 백엔드 URL로 설정되어 있습니다.

백엔드 서버를 실행한 후 Flutter 앱을 실행하면 자동으로 연결됩니다.

## 포트 변경

다른 포트를 사용하려면:

```bash
PORT=3000 npm start
```

Flutter 앱의 `lib/core/constants/app_constants.dart` 파일도 같이 수정해야 합니다:

```dart
static const String apiBaseUrl = 'http://localhost:3000';
```
