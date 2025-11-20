# 빠른 시작 가이드

## 프론트엔드 (Vercel) 배포 - 5분

### 1단계: GitHub에 푸시
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/yourusername/manna-bollae.git
git push -u origin main
```

### 2단계: Vercel 배포
1. https://vercel.com 접속 및 로그인
2. "New Project" 클릭
3. GitHub 리포지토리 선택
4. **Environment Variables** 추가:
   - `API_URL`: `http://your-oracle-ip:8080` (나중에 Oracle 서버 만든 후 업데이트)
5. "Deploy" 클릭

완료! 몇 분 후 `https://your-app.vercel.app`에서 확인 가능

---

## 백엔드 (Oracle Cloud) 배포 - 30분

### 1단계: Oracle Cloud VM 생성

1. https://www.oracle.com/kr/cloud/free/ 가입
2. Compute > Instances > Create Instance
   - Name: `manna-bollae-backend`
   - Image: `Ubuntu 22.04`
   - Shape: `VM.Standard.A1.Flex` (ARM, 무료)
   - OCPU: 2, Memory: 12GB
   - **SSH 키 다운로드** (중요!)
3. Public IP 확인 (예: `123.45.67.89`)

### 2단계: 방화벽 설정

Oracle Cloud Console:
1. VCN > Security Lists > Default Security List
2. "Add Ingress Rules" 클릭
3. 설정:
   - Source CIDR: `0.0.0.0/0`
   - Destination Port Range: `8080`
   - IP Protocol: `TCP`

### 3단계: 서버 초기 설정

SSH 접속:
```bash
ssh -i ~/Downloads/ssh-key.key ubuntu@123.45.67.89
```

서버에서 실행:
```bash
# Docker 설치
sudo apt update && sudo apt install -y docker.io docker-compose
sudo systemctl start docker
sudo usermod -aG docker ubuntu

# 방화벽 열기
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 8080 -j ACCEPT
sudo apt install -y iptables-persistent
sudo netfilter-persistent save

# 재접속 (Docker 그룹 권한 적용)
exit
```

### 4단계: 백엔드 배포

재접속 후:
```bash
ssh -i ~/Downloads/ssh-key.key ubuntu@123.45.67.89

# 프로젝트 디렉토리 생성
mkdir -p ~/backend && cd ~/backend

# 파일 생성 - server.js
cat > server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const app = express();

const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3012'];
app.use(cors({ origin: (origin, cb) => cb(null, !origin || allowedOrigins.includes(origin)), credentials: true }));
app.use(express.json());

app.get('/health', (req, res) => res.json({ status: 'ok', timestamp: new Date().toISOString() }));
app.get('/api/users', (req, res) => res.json({ success: true, users: [] }));

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
EOF

# package.json 생성
cat > package.json << 'EOF'
{
  "name": "backend",
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

# docker-compose.yml 생성
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
      - ALLOWED_ORIGINS=https://your-app.vercel.app
    restart: unless-stopped
EOF

# 배포
docker-compose up -d

# 로그 확인
docker-compose logs -f
```

### 5단계: 테스트

로컬 터미널에서:
```bash
curl http://123.45.67.89:8080/health
```

성공 응답:
```json
{"status":"ok","timestamp":"2025-01-20T..."}
```

### 6단계: Vercel 환경 변수 업데이트

1. Vercel Dashboard > Settings > Environment Variables
2. `API_URL` 수정: `http://123.45.67.89:8080`
3. Deployments > 최근 배포 > "Redeploy"

---

## 완료!

- **프론트엔드**: https://your-app.vercel.app
- **백엔드**: http://123.45.67.89:8080
- **헬스 체크**: http://123.45.67.89:8080/health

---

## 문제 해결

### "Connection refused" 에러
```bash
# 서버에서 확인
docker-compose ps  # 컨테이너 실행 확인
docker-compose logs  # 로그 확인
sudo iptables -L -n  # 방화벽 확인
```

### CORS 에러
`docker-compose.yml`의 `ALLOWED_ORIGINS`에 Vercel URL 추가:
```bash
nano docker-compose.yml
# ALLOWED_ORIGINS=https://your-app.vercel.app,https://your-app-git-main.vercel.app
docker-compose restart
```

### Vercel 빌드 실패
로컬에서 빌드 후 업로드:
```bash
flutter build web --release --dart-define=API_URL=http://123.45.67.89:8080
vercel --prod
```

---

## 다음 단계

- [ ] 도메인 연결 및 HTTPS 설정
- [ ] 데이터베이스 추가
- [ ] 실제 API 엔드포인트 구현
- [ ] 모니터링 설정

자세한 내용은 `DEPLOYMENT_GUIDE.md`를 참고하세요.
