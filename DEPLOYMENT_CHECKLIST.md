# 배포 체크리스트

다음 단계를 순서대로 진행하세요. 각 단계를 완료하면 체크 표시하세요.

## 사전 준비

- [ ] GitHub 계정 준비
- [ ] Oracle Cloud 계정 가입 (신용카드 필요, 무료)
- [ ] Vercel 계정 가입 (GitHub 연동)

---

## 1단계: GitHub 푸시

- [x] Git 리포지토리 초기화 (완료!)
- [ ] GitHub에서 새 리포지토리 생성
- [ ] 로컬 리포지토리 연결
  ```bash
  git remote add origin https://github.com/yourusername/manna-bollae.git
  git branch -M main
  git push -u origin main
  ```
- [ ] GitHub에서 파일 업로드 확인

---

## 2단계: Oracle Cloud 백엔드

### VM 생성
- [ ] Oracle Cloud 로그인
- [ ] VM 인스턴스 생성
  - Name: `manna-bollae-backend`
  - Image: `Ubuntu 22.04`
  - Shape: `VM.Standard.A1.Flex` (2 OCPU, 12GB RAM)
- [ ] SSH 키 다운로드 및 저장
- [ ] Public IP 주소 메모: `________________`

### 방화벽 설정
- [ ] Security List에서 Ingress Rule 추가
  - Port: `8080`
  - Source: `0.0.0.0/0`

### 서버 설정
- [ ] SSH 접속 성공
  ```bash
  ssh -i ssh-key.key ubuntu@YOUR_IP
  ```
- [ ] Docker 설치
  ```bash
  sudo apt update && sudo apt install -y docker.io docker-compose git
  sudo systemctl start docker
  sudo usermod -aG docker ubuntu
  ```
- [ ] 방화벽 포트 열기
  ```bash
  sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 8080 -j ACCEPT
  sudo apt install -y iptables-persistent
  ```

### 백엔드 배포
- [ ] 백엔드 파일 생성 (server.js, package.json, Dockerfile, docker-compose.yml)
- [ ] Docker Compose로 실행
  ```bash
  docker-compose up -d
  ```
- [ ] 로그 확인
  ```bash
  docker-compose logs -f
  ```

### 백엔드 테스트
- [ ] 헬스 체크 성공
  ```bash
  curl http://YOUR_IP:8080/health
  ```
- [ ] API 테스트 성공
  ```bash
  curl http://YOUR_IP:8080/api/users
  ```

---

## 3단계: Vercel 프론트엔드

### 프로젝트 생성
- [ ] Vercel 로그인
- [ ] New Project 클릭
- [ ] GitHub 리포지토리 `manna-bollae` 선택

### 설정
- [ ] Framework Preset: `Other`
- [ ] Build Command 설정
  ```
  flutter build web --release --dart-define=API_URL=$API_URL
  ```
- [ ] Output Directory: `build/web`
- [ ] Environment Variable 추가
  - Key: `API_URL`
  - Value: `http://YOUR_ORACLE_IP:8080`

### 배포
- [ ] Deploy 클릭
- [ ] 배포 완료 대기 (5-10분)
- [ ] Vercel URL 메모: `https://________________.vercel.app`

---

## 4단계: CORS 설정

- [ ] Oracle 서버 SSH 접속
- [ ] `docker-compose.yml` 수정
  ```yaml
  ALLOWED_ORIGINS=https://your-app.vercel.app,http://localhost:3012
  ```
- [ ] 컨테이너 재시작
  ```bash
  docker-compose restart
  ```

---

## 5단계: 연결 테스트

- [ ] Vercel URL 접속
- [ ] 개발자 도구 (F12) 열기
- [ ] Network 탭에서 API 요청 확인
- [ ] CORS 에러 없음 확인
- [ ] 앱 기능 테스트
  - [ ] 로그인/회원가입
  - [ ] 프로필 보기
  - [ ] 매칭 기능
  - [ ] 채팅 기능

---

## 완료! 🎉

모든 체크리스트를 완료하셨나요? 축하합니다!

### 배포된 서비스 정보

- **프론트엔드**: `https://________________.vercel.app`
- **백엔드**: `http://________________:8080`

### 다음 단계 (선택)

- [ ] 커스텀 도메인 연결
- [ ] HTTPS 설정
- [ ] 데이터베이스 추가
- [ ] 모니터링 설정

---

## 유용한 명령어

### Oracle 서버 관리
```bash
# SSH 접속
ssh -i ssh-key.key ubuntu@YOUR_IP

# 컨테이너 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs -f

# 재시작
docker-compose restart

# 중지
docker-compose down

# 시작
docker-compose up -d
```

### Vercel 관리
- **재배포**: Vercel Dashboard > Deployments > ... > Redeploy
- **환경 변수 수정**: Settings > Environment Variables
- **로그 확인**: Deployments > 해당 배포 클릭 > Logs

### Git 명령어
```bash
# 변경사항 푸시 (자동 재배포)
git add .
git commit -m "Update message"
git push origin main
```

---

## 문제 발생 시

**백엔드 접속 안 됨**:
1. Oracle Security List 확인 (포트 8080 열림?)
2. `sudo iptables -L -n` 확인
3. `docker-compose ps` 컨테이너 실행 확인

**CORS 에러**:
1. `docker-compose.yml`의 ALLOWED_ORIGINS 확인
2. Vercel URL이 정확한지 확인
3. `docker-compose restart`

**Vercel 빌드 실패**:
1. Environment Variables의 API_URL 확인
2. Build Command 확인
3. Deployment Logs 확인

자세한 내용은 `STEP_BY_STEP_DEPLOYMENT.md`를 참고하세요!
