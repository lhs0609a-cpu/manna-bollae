# 만나볼래 - 단계별 배포 가이드

**목표**: Vercel(프론트엔드) + Oracle Cloud(백엔드) 완전 무료로 배포하기

## 전체 진행 순서

1. ✅ Git 리포지토리 초기화 (완료!)
2. 🔄 GitHub에 코드 푸시
3. 🔄 Oracle Cloud 백엔드 배포
4. 🔄 Vercel 프론트엔드 배포
5. 🔄 연결 테스트

---

## 1단계: GitHub에 코드 푸시 ✅ (완료)

Git 리포지토리가 초기화되었습니다! 이제 GitHub에 푸시해야 합니다.

### 1-1. GitHub에서 새 리포지토리 생성

1. https://github.com 접속
2. 우측 상단 "+" → "New repository" 클릭
3. 설정:
   - **Repository name**: `manna-bollae` (또는 원하는 이름)
   - **Description**: `AI 아바타 기반 데이팅 앱`
   - **Public** 또는 **Private** 선택
   - ⚠️ **"Initialize this repository with a README" 체크 해제!** (이미 로컬에 파일이 있음)
4. "Create repository" 클릭

### 1-2. 로컬 리포지토리를 GitHub에 연결

GitHub에서 생성한 리포지토리 URL을 복사한 후 (예: `https://github.com/yourusername/manna-bollae.git`):

```bash
cd E:\u\manna_bollae

# GitHub 리포지토리 연결
git remote add origin https://github.com/yourusername/manna-bollae.git

# main 브랜치로 이름 변경 (master → main)
git branch -M main

# GitHub에 푸시
git push -u origin main
```

✅ **완료 확인**: GitHub 리포지토리 페이지에서 파일들이 업로드되었는지 확인

---

## 2단계: Oracle Cloud 백엔드 배포 🚀

### 2-1. Oracle Cloud 계정 생성

1. https://www.oracle.com/kr/cloud/free/ 접속
2. "무료로 시작하기" 클릭
3. 계정 정보 입력:
   - 이메일, 국가, 이름 등
   - 신용카드 등록 필요 (무료지만 본인 확인용, **과금 안 됨**)
4. 이메일 인증 완료

### 2-2. VM 인스턴스 생성

1. Oracle Cloud Console 로그인
2. 좌측 메뉴 > **Compute** > **Instances** 클릭
3. **"Create Instance"** 클릭
4. 설정:

   **Name**: `manna-bollae-backend`

   **Image and Shape**:
   - **Image**: `Canonical Ubuntu 22.04` (또는 최신 Ubuntu)
   - **Shape**: `VM.Standard.A1.Flex` 클릭
     - OCPU: `2`
     - Memory: `12 GB`
     - (Always Free 최대: 4 OCPU, 24GB RAM까지 가능)

   **Networking**:
   - VCN: 기본값 사용
   - Subnet: 기본값 사용
   - ✅ **"Assign a public IPv4 address"** 체크

   **Add SSH keys**:
   - ✅ **"Generate a key pair for me"** 선택
   - **"Save Private Key"** 클릭하여 SSH 키 다운로드 (예: `ssh-key-xxxx.key`)
   - 이 파일을 안전한 곳에 보관! (나중에 서버 접속 시 필요)

5. **"Create"** 클릭
6. 인스턴스 상태가 **"Running"** 될 때까지 대기 (1-2분)
7. **Public IP** 주소 복사 (예: `123.45.67.89`) 📝

### 2-3. 방화벽 설정 (포트 8080 열기)

#### Oracle Cloud 콘솔에서:

1. 생성한 인스턴스 클릭
2. **Subnet** 링크 클릭
3. **Security Lists** > **Default Security List** 클릭
4. **"Add Ingress Rules"** 클릭
5. 설정:
   - **Source CIDR**: `0.0.0.0/0`
   - **Destination Port Range**: `8080`
   - **Description**: `Backend API port`
6. **"Add Ingress Rules"** 클릭

### 2-4. SSH로 서버 접속

다운로드한 SSH 키의 권한 설정 (Windows Git Bash에서):

```bash
# SSH 키 파일이 있는 디렉토리로 이동
cd ~/Downloads

# 권한 설정 (중요!)
chmod 400 ssh-key-xxxx.key

# SSH 접속 (Public IP를 실제 IP로 변경)
ssh -i ssh-key-xxxx.key ubuntu@123.45.67.89
```

⚠️ **"Are you sure you want to continue connecting?"** → `yes` 입력

✅ 접속 성공하면 `ubuntu@instance-name:~$` 프롬프트 표시

### 2-5. 서버 초기 설정

SSH로 접속한 상태에서 다음 명령어 실행:

```bash
# 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# Docker 설치
sudo apt install -y docker.io docker-compose git

# Docker 시작
sudo systemctl start docker
sudo systemctl enable docker

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker ubuntu

# 방화벽 포트 열기
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 8080 -j ACCEPT
sudo apt install -y iptables-persistent
# 설정 저장 프롬프트 → Yes 선택

# 재접속 (Docker 권한 적용)
exit
```

다시 SSH 접속:
```bash
ssh -i ssh-key-xxxx.key ubuntu@123.45.67.89
```

### 2-6. 백엔드 코드 배포

서버에서 실행:

```bash
# 작업 디렉토리 생성
mkdir -p ~/manna-bollae-backend
cd ~/manna-bollae-backend

# server.js 생성
cat > server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const app = express();

const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3012'];

app.use(cors({
  origin: function(origin, callback) {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));

app.use(express.json());

// 로깅
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.path}`);
  next();
});

// 헬스 체크
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString(), message: '백엔드 서버가 정상 작동 중입니다.' });
});

// 사용자 API
app.get('/api/users', (req, res) => {
  res.json({ success: true, users: [
    { id: 1, name: '홍길동', age: 25, gender: '남성' },
    { id: 2, name: '김영희', age: 23, gender: '여성' },
  ]});
});

app.get('/api/users/:id', (req, res) => {
  const userId = parseInt(req.params.id);
  res.json({ success: true, user: { id: userId, name: '홍길동', age: 25, gender: '남성', bio: '안녕하세요!', hobbies: ['운동', '영화', '독서'] }});
});

// 매칭 API
app.get('/api/matches', (req, res) => {
  res.json({ success: true, matches: [{ id: 1, userId: 2, userName: '김영희', matchDate: new Date().toISOString(), intimacyScore: 500 }]});
});

// 채팅 API
app.get('/api/chats/:matchId/messages', (req, res) => {
  res.json({ success: true, messages: [
    { id: 1, senderId: 1, message: '안녕하세요!', timestamp: new Date().toISOString() },
    { id: 2, senderId: 2, message: '반가워요!', timestamp: new Date().toISOString() }
  ]});
});

app.post('/api/chats/:matchId/messages', (req, res) => {
  const { message } = req.body;
  res.json({ success: true, message: { id: Date.now(), senderId: 1, message: message, timestamp: new Date().toISOString() }});
});

// 프로필 API
app.put('/api/profile', (req, res) => {
  res.json({ success: true, message: '프로필이 업데이트되었습니다.', profile: req.body });
});

// 진심지수 API
app.get('/api/trust-score', (req, res) => {
  res.json({ success: true, trustScore: { score: 65.5, level: '믿음직한', dailyQuestCompleted: true, verifications: { phone: true, video: false, criminalRecord: false, job: true }}});
});

// 하트온도 API
app.get('/api/heart-temperature', (req, res) => {
  res.json({ success: true, temperature: { current: 36.5, level: '따뜻함', history: [
    { date: '2025-01-01', temperature: 35.0 },
    { date: '2025-01-02', temperature: 36.0 },
    { date: '2025-01-03', temperature: 36.5 }
  ]}});
});

// 에러 핸들링
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ success: false, error: '서버 오류가 발생했습니다.', message: err.message });
});

app.use((req, res) => {
  res.status(404).json({ success: false, error: '요청한 리소스를 찾을 수 없습니다.' });
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`\n✅ 백엔드 서버가 포트 ${PORT}에서 실행 중입니다.\n`);
});
EOF

# package.json 생성
cat > package.json << 'EOF'
{
  "name": "manna-bollae-backend",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5"
  }
}
EOF

# Dockerfile 생성
cat > Dockerfile << 'EOF'
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY server.js ./
EXPOSE 8080
CMD ["node", "server.js"]
EOF

# docker-compose.yml 생성 (Vercel URL은 나중에 업데이트)
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  backend:
    build: .
    ports:
      - "8080:8080"
    environment:
      - NODE_ENV=production
      - PORT=8080
      - ALLOWED_ORIGINS=https://your-app.vercel.app,http://localhost:3012
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
EOF

# Docker로 빌드 및 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f
```

**Ctrl+C**로 로그 모니터링 종료

### 2-7. 백엔드 테스트

로컬 터미널(Git Bash)에서:

```bash
# 헬스 체크 (IP를 실제 Oracle Public IP로 변경)
curl http://123.45.67.89:8080/health

# 사용자 API 테스트
curl http://123.45.67.89:8080/api/users
```

✅ **성공 응답 예시**:
```json
{"status":"ok","timestamp":"2025-01-20T...","message":"백엔드 서버가 정상 작동 중입니다."}
```

📝 **Oracle Public IP 주소를 메모하세요**: `http://123.45.67.89:8080`

---

## 3단계: Vercel 프론트엔드 배포 🎨

### 3-1. Vercel 계정 생성

1. https://vercel.com 접속
2. **"Sign Up"** 클릭
3. **GitHub 계정으로 로그인** (권장)
4. Vercel이 GitHub 리포지토리에 접근 권한 요청 → **"Authorize"** 클릭

### 3-2. 새 프로젝트 생성

1. Vercel 대시보드에서 **"Add New..."** > **"Project"** 클릭
2. GitHub 리포지토리 목록에서 **`manna-bollae`** 찾기
3. **"Import"** 클릭

### 3-3. 프로젝트 설정

**Configure Project** 화면에서:

1. **Framework Preset**: `Other` 선택

2. **Build and Output Settings**:
   - **Build Command**:
     ```
     flutter build web --release --dart-define=API_URL=$API_URL
     ```
   - **Output Directory**: `build/web`
   - **Install Command**: (자동 감지 - vercel.json 참조)

3. **Environment Variables** 추가:
   - **Key**: `API_URL`
   - **Value**: `http://123.45.67.89:8080` (실제 Oracle Public IP로 변경)
   - **Environment**: `Production`, `Preview`, `Development` 모두 체크
   - **"Add"** 클릭

4. **"Deploy"** 클릭

### 3-4. 배포 진행 상황 확인

- 배포 로그가 실시간으로 표시됩니다
- ⏱️ 첫 배포는 5-10분 소요될 수 있습니다 (Flutter 설치 포함)
- ✅ 배포 성공 시: **"Your project has been deployed"** 메시지 표시

### 3-5. 배포된 URL 확인

배포 성공 후:
- **"Visit"** 버튼 클릭 또는
- URL 복사 (예: `https://manna-bollae.vercel.app`)

📝 **Vercel URL을 메모하세요**: `https://manna-bollae.vercel.app`

---

## 4단계: CORS 설정 업데이트 🔄

Vercel URL을 백엔드 CORS 설정에 추가해야 합니다.

### 4-1. Oracle 서버에서 CORS 업데이트

SSH로 서버 접속:
```bash
ssh -i ssh-key-xxxx.key ubuntu@123.45.67.89
cd ~/manna-bollae-backend
```

`docker-compose.yml` 수정:
```bash
# 편집기로 파일 열기
nano docker-compose.yml
```

**`ALLOWED_ORIGINS`** 줄을 찾아서 Vercel URL 추가:
```yaml
- ALLOWED_ORIGINS=https://manna-bollae.vercel.app,http://localhost:3012
```

- **Ctrl+O** → Enter (저장)
- **Ctrl+X** (종료)

컨테이너 재시작:
```bash
docker-compose restart
docker-compose logs -f
```

**Ctrl+C**로 로그 종료

---

## 5단계: 연결 테스트 ✅

### 5-1. 브라우저에서 테스트

1. Vercel URL 접속: `https://manna-bollae.vercel.app`
2. **F12** (개발자 도구) 열기
3. **Network** 탭 확인
4. 앱 사용해보기 (로그인, 프로필 등)
5. Network 탭에서 `/api/` 요청이 Oracle 서버로 가는지 확인

### 5-2. API 직접 테스트

브라우저 주소창에서:
```
http://123.45.67.89:8080/health
https://123.45.67.89:8080/api/users
```

✅ **성공 조건**:
- JSON 응답이 표시됨
- CORS 에러가 없음

---

## 완료! 🎉

축하합니다! 모든 배포가 완료되었습니다.

### 배포된 서비스 정보

| 항목 | URL | 비용 |
|------|-----|------|
| **프론트엔드** | https://manna-bollae.vercel.app | 무료 |
| **백엔드 API** | http://123.45.67.89:8080 | 무료 |
| **헬스 체크** | http://123.45.67.89:8080/health | - |

### 다음 단계 (선택사항)

- [ ] 도메인 연결 (예: mannabollae.com)
- [ ] HTTPS 설정 (Nginx + Let's Encrypt)
- [ ] 데이터베이스 추가 (Oracle Autonomous DB 무료 티어)
- [ ] 모니터링 설정
- [ ] 자동 배포 설정 (GitHub Push → 자동 재배포)

---

## 문제 해결

### "Connection refused" 에러
```bash
# Oracle 서버에서
docker-compose ps  # 컨테이너 실행 확인
docker-compose logs  # 로그 확인
sudo iptables -L -n  # 방화벽 확인
```

### CORS 에러
```bash
# docker-compose.yml의 ALLOWED_ORIGINS 확인
# Vercel URL이 정확히 추가되었는지 확인
docker-compose restart
```

### Vercel 빌드 실패
- Environment Variables에 `API_URL`이 제대로 설정되었는지 확인
- Build Command가 올바른지 확인

---

## 도움말

- **Oracle 서버 로그 확인**: `ssh ubuntu@IP "cd ~/manna-bollae-backend && docker-compose logs"`
- **Vercel 재배포**: Vercel Dashboard > Deployments > 점 3개 메뉴 > Redeploy
- **GitHub 푸시 후 자동 배포**: Vercel은 GitHub의 main 브랜치에 푸시할 때마다 자동으로 재배포됩니다

