#!/bin/bash

# Oracle Cloud 배포 스크립트
# 사용법: ./deploy-oracle.sh

set -e

echo "========================================="
echo "Oracle Cloud 백엔드 배포 시작"
echo "========================================="

# 환경 변수 확인
if [ -z "$ORACLE_SERVER_IP" ]; then
    echo "❌ ORACLE_SERVER_IP 환경 변수가 설정되지 않았습니다."
    echo "예: export ORACLE_SERVER_IP=xxx.xxx.xxx.xxx"
    exit 1
fi

if [ -z "$SSH_KEY_PATH" ]; then
    echo "❌ SSH_KEY_PATH 환경 변수가 설정되지 않았습니다."
    echo "예: export SSH_KEY_PATH=~/.ssh/oracle-key"
    exit 1
fi

SSH_USER=${SSH_USER:-ubuntu}

echo "서버 IP: $ORACLE_SERVER_IP"
echo "SSH 사용자: $SSH_USER"
echo ""

# 1. Docker 이미지 빌드
echo "1. Docker 이미지 빌드 중..."
docker build -t manna-bollae-backend:latest .

# 2. 이미지를 tar 파일로 저장
echo "2. Docker 이미지를 tar 파일로 저장 중..."
docker save manna-bollae-backend:latest | gzip > manna-backend.tar.gz

# 3. Oracle Cloud 서버로 파일 전송
echo "3. 서버로 파일 전송 중..."
ssh -i "$SSH_KEY_PATH" "$SSH_USER@$ORACLE_SERVER_IP" "mkdir -p ~/manna-bollae"
scp -i "$SSH_KEY_PATH" manna-backend.tar.gz docker-compose.yml "$SSH_USER@$ORACLE_SERVER_IP:~/manna-bollae/"

# 4. 서버에서 배포 실행
echo "4. 서버에서 배포 실행 중..."
ssh -i "$SSH_KEY_PATH" "$SSH_USER@$ORACLE_SERVER_IP" << 'ENDSSH'
    cd ~/manna-bollae

    # Docker 이미지 로드
    echo "Docker 이미지 로드 중..."
    docker load < manna-backend.tar.gz

    # 기존 컨테이너 중지 및 제거
    echo "기존 컨테이너 중지 중..."
    docker-compose down || true

    # 새 컨테이너 시작
    echo "새 컨테이너 시작 중..."
    docker-compose up -d

    # 로그 확인
    echo "컨테이너 로그:"
    docker-compose logs --tail=50

    # 상태 확인
    echo ""
    echo "컨테이너 상태:"
    docker-compose ps

    # 정리
    rm -f manna-backend.tar.gz
ENDSSH

# 5. 로컬 임시 파일 삭제
echo "5. 로컬 임시 파일 삭제 중..."
rm -f manna-backend.tar.gz

echo ""
echo "========================================="
echo "✅ 배포 완료!"
echo "========================================="
echo ""
echo "서버 주소: http://$ORACLE_SERVER_IP:8080"
echo "헬스 체크: http://$ORACLE_SERVER_IP:8080/health"
echo ""
echo "로그 확인: ssh -i $SSH_KEY_PATH $SSH_USER@$ORACLE_SERVER_IP 'cd ~/manna-bollae && docker-compose logs -f'"
echo ""
