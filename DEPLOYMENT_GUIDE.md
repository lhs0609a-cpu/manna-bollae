# 만나볼래 - 배포 가이드

이 가이드는 프론트엔드를 Vercel에, 백엔드를 Oracle Cloud 무료 티어에 배포하는 방법을 설명합니다.

## 목차
1. [Oracle Cloud 백엔드 배포](#1-oracle-cloud-백엔드-배포)
2. [Vercel 프론트엔드 배포](#2-vercel-프론트엔드-배포)
3. [환경 변수 설정](#3-환경-변수-설정)
4. [배포 후 테스트](#4-배포-후-테스트)

---

## 1. Oracle Cloud 백엔드 배포

### 1.1 Oracle Cloud 무료 티어 가입

1. [Oracle Cloud](https://www.oracle.com/kr/cloud/free/) 접속
2. 무료 계정 생성 (Always Free 티어 제공)
3. VM 인스턴스 생성 (권장: ARM-based Ampere A1)
   - Shape: VM.Standard.A1.Flex
   - OCPU: 2, Memory: 12GB (무료 티어에서 최대 4 OCPU, 24GB RAM 가능)
   - OS: Ubuntu 22.04

### 1.2 VM 인스턴스 초기 설정

SSH로 인스턴스 접속 후:

```bash
# 시스템 업데이트
sudo apt update && sudo apt upgrade -y

# Docker 설치
sudo apt install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# 방화벽 설정 (포트 8080 오픈)
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 8080 -j ACCEPT
sudo netfilter-persistent save

# Oracle Cloud 콘솔에서도 Ingress Rule 추가 필요
# VCN > Security Lists > Default Security List
# Ingress Rule: Source 0.0.0.0/0, Destination Port 8080, Protocol TCP
```

### 1.3 백엔드 배포

#### 방법 A: 자동 배포 스크립트 사용 (로컬에서 실행)

```bash
cd backend_example

# 환경 변수 설정
export ORACLE_SERVER_IP=your.oracle.server.ip
export SSH_KEY_PATH=~/.ssh/your-oracle-key
export SSH_USER=ubuntu

# 배포 실행
chmod +x deploy-oracle.sh
./deploy-oracle.sh
```

#### 방법 B: 수동 배포 (서버에서 직접)

```bash
# 서버에 접속
ssh -i ~/.ssh/your-oracle-key ubuntu@your.oracle.server.ip

# 프로젝트 디렉토리 생성
mkdir -p ~/manna-bollae/backend
cd ~/manna-bollae/backend

# 파일 업로드 (로컬에서)
# scp -i ~/.ssh/your-oracle-key backend_example/* ubuntu@your.oracle.server.ip:~/manna-bollae/backend/

# 환경 변수 설정
cat > .env << EOF
PORT=8080
NODE_ENV=production
ALLOWED_ORIGINS=https://your-vercel-app.vercel.app
EOF

# Docker Compose로 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f
```

### 1.4 HTTPS 설정 (선택사항, 권장)

무료 SSL 인증서를 위해 Let's Encrypt 사용:

```bash
# Nginx 설치
sudo apt install -y nginx certbot python3-certbot-nginx

# 도메인 설정 (도메인이 있는 경우)
sudo nano /etc/nginx/sites-available/manna-bollae

# 내용:
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

# 심볼릭 링크 생성
sudo ln -s /etc/nginx/sites-available/manna-bollae /etc/nginx/sites-enabled/

# Nginx 재시작
sudo systemctl restart nginx

# SSL 인증서 발급
sudo certbot --nginx -d your-domain.com
```

---

## 2. Vercel 프론트엔드 배포

### 2.1 Vercel 계정 생성 및 프로젝트 연결

1. [Vercel](https://vercel.com) 가입 (GitHub 계정 연동 권장)
2. GitHub에 프로젝트 푸시
3. Vercel 대시보드에서 "New Project" 클릭
4. GitHub 리포지토리 선택

### 2.2 Vercel 프로젝트 설정

#### Build & Development Settings

Vercel 대시보드에서 프로젝트 설정:

- **Framework Preset**: Other
- **Build Command**:
  ```bash
  flutter build web --release --dart-define=API_URL=$API_URL
  ```
- **Output Directory**: `build/web`
- **Install Command**: (자동 감지 - vercel.json 참조)

#### 환경 변수 설정

Vercel Dashboard > Settings > Environment Variables:

```
API_URL=http://your.oracle.server.ip:8080
```

또는 도메인이 있는 경우:
```
API_URL=https://your-backend-domain.com
```

### 2.3 수동 배포 (CLI 사용)

```bash
# Vercel CLI 설치
npm i -g vercel

# 로그인
vercel login

# Flutter 웹 빌드
flutter build web --release --dart-define=API_URL=http://your.oracle.server.ip:8080

# 배포
vercel --prod
```

### 2.4 자동 배포 설정

GitHub에 푸시할 때마다 자동 배포되도록 설정:

1. Vercel 프로젝트 > Settings > Git
2. Production Branch: `main` 또는 `master`
3. Automatic deployments from Git 활성화

---

## 3. 환경 변수 설정

### 3.1 백엔드 환경 변수 (Oracle Cloud)

`backend_example/.env` 파일 생성:

```bash
PORT=8080
NODE_ENV=production
ALLOWED_ORIGINS=https://your-vercel-app.vercel.app,http://localhost:3012
```

### 3.2 프론트엔드 환경 변수 (Vercel)

Vercel 대시보드에서 설정하거나, 빌드 시 직접 지정:

```bash
flutter build web --release --dart-define=API_URL=http://your.oracle.server.ip:8080
```

---

## 4. 배포 후 테스트

### 4.1 백엔드 헬스 체크

```bash
# HTTP로 테스트
curl http://your.oracle.server.ip:8080/health

# 응답 예시:
# {"status":"ok","timestamp":"2025-01-20T...","message":"백엔드 서버가 정상 작동 중입니다."}
```

### 4.2 프론트엔드 접속

브라우저에서 Vercel URL로 접속:
```
https://your-vercel-app.vercel.app
```

### 4.3 API 연동 테스트

브라우저 개발자 도구 > Console에서:

```javascript
// Network 탭에서 API 요청 확인
// /api/users, /api/matches 등의 요청이 Oracle 서버로 가는지 확인
```

---

## 5. 문제 해결

### CORS 에러 발생 시

백엔드 `.env` 파일에서 `ALLOWED_ORIGINS`에 Vercel URL 추가:

```bash
ALLOWED_ORIGINS=https://your-vercel-app.vercel.app,https://your-vercel-app-git-branch.vercel.app
```

서버 재시작:
```bash
docker-compose restart
```

### Oracle Cloud 방화벽 이슈

```bash
# 서버에서
sudo iptables -L -n

# 포트 8080이 열려있는지 확인
# 없으면 추가:
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 8080 -j ACCEPT
sudo netfilter-persistent save
```

Oracle Cloud Console에서도 Ingress Rule 확인!

### Vercel 빌드 실패

Flutter가 제대로 설치되지 않은 경우, `vercel.json`의 `installCommand` 확인

또는 빌드를 로컬에서 하고 `build/web` 폴더만 배포:

```bash
# 로컬에서
flutter build web --release --dart-define=API_URL=http://your.oracle.server.ip:8080

# vercel.json 임시 수정
{
  "buildCommand": "echo 'Using pre-built files'",
  "outputDirectory": "build/web"
}

# 배포
vercel --prod
```

---

## 6. 비용 최적화 팁

### Oracle Cloud Always Free 리소스
- VM: Ampere A1 (ARM) - 4 OCPU, 24GB RAM
- 스토리지: 200GB Block Volume
- 네트워크: 10TB/월 아웃바운드

### Vercel Free Tier 제한
- 대역폭: 100GB/월
- 빌드 시간: 6000분/월
- 서버리스 함수 실행: 100GB-시간

---

## 7. 다음 단계

- [ ] 도메인 연결 (Vercel, Oracle Cloud)
- [ ] HTTPS 설정
- [ ] 데이터베이스 연동 (Oracle Autonomous Database 무료 티어)
- [ ] CI/CD 파이프라인 구축
- [ ] 모니터링 설정 (Uptime Robot, Sentry 등)
- [ ] 백업 자동화

---

## 참고 자료

- [Oracle Cloud Always Free](https://www.oracle.com/kr/cloud/free/)
- [Vercel 문서](https://vercel.com/docs)
- [Flutter 웹 배포](https://docs.flutter.dev/deployment/web)
- [Docker 문서](https://docs.docker.com/)
