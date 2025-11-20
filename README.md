# 만나볼래 (Manna Bollae)

AI 아바타 기반 데이팅 앱 - Flutter Web + Express.js

## 프로젝트 개요

만나볼래는 AI 아바타를 통해 처음 만나는 안전하고 재미있는 데이팅 플랫폼입니다.

### 주요 기능

- 🤖 AI 아바타 커스터마이징
- 💘 스마트 매칭 시스템
- 💬 실시간 채팅
- 📈 진심지수 및 하트온도 시스템
- 🎯 일일 퀘스트 및 미션
- 🎁 가챠 시스템
- ✅ 다단계 본인인증

## 기술 스택

### 프론트엔드
- Flutter 3.27.1
- Provider (상태관리)
- Firebase (인증, DB, 스토리지)
- Dio (HTTP 클라이언트)

### 백엔드
- Node.js + Express
- Docker
- Oracle Cloud (무료 티어)

### 배포
- 프론트엔드: Vercel
- 백엔드: Oracle Cloud Free Tier

## 빠른 시작

### 로컬 개발 환경

#### 1. 프론트엔드 실행

```bash
# 의존성 설치
flutter pub get

# 웹 서버 실행 (포트 3012)
flutter run -d web-server --web-port 3012
```

#### 2. 백엔드 실행

```bash
cd backend_example

# 의존성 설치
npm install

# 서버 실행 (포트 8080)
npm start
```

접속:
- 프론트엔드: http://localhost:3012
- 백엔드 API: http://localhost:8080

### 프로덕션 배포

자세한 배포 가이드는 다음 문서를 참고하세요:

- **[빠른 시작 가이드](QUICK_START.md)** - 5분 안에 배포하기
- **[상세 배포 가이드](DEPLOYMENT_GUIDE.md)** - 전체 배포 프로세스
- **[로컬 서버 설정](README_SERVER_SETUP.md)** - 로컬 개발 환경 설정

## 프로젝트 구조

```
manna_bollae/
├── lib/
│   ├── core/
│   │   ├── constants/      # 앱 상수 및 설정
│   │   ├── services/       # API 서비스, Firebase 등
│   │   ├── utils/          # 유틸리티 함수
│   │   └── widgets/        # 공통 위젯
│   ├── features/           # 기능별 모듈
│   │   ├── auth/          # 인증
│   │   ├── profile/       # 프로필
│   │   ├── matching/      # 매칭
│   │   ├── chat/          # 채팅
│   │   ├── avatar/        # 아바타
│   │   ├── trust_score/   # 진심지수
│   │   ├── gacha/         # 가챠 시스템
│   │   └── ...
│   ├── models/            # 데이터 모델
│   ├── app.dart          # 앱 루트
│   └── main.dart         # 엔트리 포인트
├── backend_example/       # 백엔드 서버 예시
│   ├── server.js
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── deploy-oracle.sh
├── vercel.json           # Vercel 배포 설정
└── pubspec.yaml          # Flutter 의존성
```

## API 엔드포인트

### 헬스 체크
- `GET /health` - 서버 상태 확인

### 사용자
- `GET /api/users` - 사용자 목록
- `GET /api/users/:id` - 사용자 상세 정보

### 매칭
- `GET /api/matches` - 매칭 목록

### 채팅
- `GET /api/chats/:matchId/messages` - 메시지 목록
- `POST /api/chats/:matchId/messages` - 메시지 전송

### 프로필
- `PUT /api/profile` - 프로필 업데이트

### 진심지수/하트온도
- `GET /api/trust-score` - 진심지수 정보
- `GET /api/heart-temperature` - 하트온도 정보

## 환경 변수

### 프론트엔드 (.env)

```bash
API_URL=http://localhost:8080
```

빌드 시:
```bash
flutter build web --release --dart-define=API_URL=https://your-api-server.com
```

### 백엔드 (backend_example/.env)

```bash
PORT=8080
NODE_ENV=production
ALLOWED_ORIGINS=https://your-vercel-app.vercel.app,http://localhost:3012
```

## 배포 체크리스트

- [ ] Oracle Cloud 계정 생성 및 VM 인스턴스 설정
- [ ] 백엔드 서버 배포 및 테스트
- [ ] Vercel 계정 생성 및 GitHub 연동
- [ ] 환경 변수 설정 (API_URL)
- [ ] 프론트엔드 배포
- [ ] CORS 설정 확인
- [ ] API 연동 테스트
- [ ] Firebase 설정 (선택)
- [ ] 도메인 연결 (선택)
- [ ] HTTPS 설정 (선택)

## 비용

### 무료로 운영 가능!

- **Oracle Cloud**: Always Free Tier
  - VM: Ampere A1 (4 OCPU, 24GB RAM)
  - 스토리지: 200GB
  - 네트워크: 10TB/월

- **Vercel**: Free Tier
  - 대역폭: 100GB/월
  - 빌드: 6000분/월
  - 서버리스: 100GB-시간

- **Firebase**: Spark Plan (무료)
  - 인증: 무제한
  - Firestore: 1GB 저장, 50K 읽기/일
  - Storage: 5GB

## 개발 로드맵

### Phase 1: MVP (현재)
- [x] 기본 UI/UX 구현
- [x] Firebase 인증 연동
- [x] 로컬 개발 환경 구축
- [x] 배포 환경 구축

### Phase 2: 핵심 기능
- [ ] 실제 매칭 알고리즘 구현
- [ ] 실시간 채팅 구현
- [ ] 아바타 생성 AI 연동
- [ ] 결제 시스템 연동

### Phase 3: 확장
- [ ] 모바일 앱 (Android/iOS)
- [ ] 관리자 대시보드
- [ ] 분석 및 모니터링
- [ ] 성능 최적화

## 라이선스

이 프로젝트는 개인 학습 및 개발 목적으로 제작되었습니다.

## 문의

문제가 발생하거나 질문이 있으시면 이슈를 등록해주세요.

---

Made with ❤️ using Flutter & Node.js
