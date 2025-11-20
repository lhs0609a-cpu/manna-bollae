# 서버 설정 가이드

## 1. 프론트엔드 서버 (Flutter Web)

### 포트 3012에서 실행하기

```bash
flutter run -d web-server --web-port 3012
```

실행 후 브라우저에서 http://localhost:3012 로 접속하세요.

### Chrome에서 실행하기

```bash
flutter run -d chrome --web-port 3012
```

## 2. 백엔드 API 서버

현재 백엔드 API URL은 `http://localhost:8080`으로 설정되어 있습니다.

### API 서버 포트 변경하기

백엔드 서버를 다른 포트에서 실행하려면 `lib/core/constants/app_constants.dart` 파일을 수정하세요:

```dart
// Backend API Base URL
static const String apiBaseUrl = 'http://localhost:포트번호';
```

### API 서비스 사용 예시

```dart
import 'package:manna_bollae/core/services/api_service.dart';

final apiService = ApiService();

// GET 요청
final response = await apiService.get('/api/users');

// POST 요청
final response = await apiService.post(
  '/api/login',
  data: {'email': 'user@example.com', 'password': 'password123'},
);

// 인증 토큰 설정
apiService.setAuthToken('your-jwt-token');

// 인증이 필요한 요청
final response = await apiService.get('/api/profile');
```

## 3. 백엔드 서버가 없는 경우

백엔드 서버를 아직 구축하지 않았다면, 다음 중 하나를 선택하세요:

### 옵션 A: Node.js/Express 백엔드 샘플

```javascript
// server.js
const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// 헬스 체크
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// 샘플 API 엔드포인트
app.get('/api/users', (req, res) => {
  res.json({ users: [] });
});

const PORT = 8080;
app.listen(PORT, () => {
  console.log(`백엔드 서버가 포트 ${PORT}에서 실행 중입니다.`);
});
```

실행:
```bash
npm install express cors
node server.js
```

### 옵션 B: Python/Flask 백엔드 샘플

```python
# app.py
from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/health')
def health():
    return jsonify({'status': 'ok'})

@app.route('/api/users')
def get_users():
    return jsonify({'users': []})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
```

실행:
```bash
pip install flask flask-cors
python app.py
```

### 옵션 C: Firebase Cloud Functions 계속 사용

Firebase만 사용하려면 `app_constants.dart`의 `apiBaseUrl` 대신 `functionBaseUrl`을 사용하세요.

## 4. 환경별 API URL 설정

개발/프로덕션 환경에 따라 다른 URL을 사용하려면:

```dart
// lib/core/constants/app_constants.dart
static const String apiBaseUrl =
    String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8080');
```

실행 시 환경 변수 전달:
```bash
flutter run -d web-server --web-port 3012 --dart-define=API_URL=https://api.production.com
```

## 5. CORS 설정

백엔드 서버에서 Flutter 웹 앱의 요청을 허용하려면 CORS를 설정해야 합니다:

```javascript
// Express 예시
app.use(cors({
  origin: 'http://localhost:3012',
  credentials: true
}));
```

## 6. 연결 테스트

### API 서버 연결 확인

서버가 실행 중인지 확인:
```bash
curl http://localhost:8080/health
```

### Flutter 앱에서 연결 테스트

```dart
// 앱 시작 시 연결 테스트
try {
  final response = await ApiService().get('/health');
  print('✅ 백엔드 연결 성공: ${response.data}');
} catch (e) {
  print('❌ 백엔드 연결 실패: $e');
}
```

## 현재 설정 요약

- **프론트엔드**: http://localhost:3012
- **백엔드 API**: http://localhost:8080
- **API 서비스**: `lib/core/services/api_service.dart`
- **설정 파일**: `lib/core/constants/app_constants.dart`
