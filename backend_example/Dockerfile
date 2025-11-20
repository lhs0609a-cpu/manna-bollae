# Node.js 백엔드를 위한 Dockerfile (Oracle Cloud용)
FROM node:18-alpine

# 작업 디렉토리 설정
WORKDIR /app

# 패키지 파일 복사 및 의존성 설치
COPY package*.json ./
RUN npm ci --only=production

# 애플리케이션 파일 복사
COPY server.js ./

# 포트 노출
EXPOSE 8080

# 헬스 체크
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:8080/health', (r) => { process.exit(r.statusCode === 200 ? 0 : 1); })"

# 프로덕션 모드로 실행
ENV NODE_ENV=production
CMD ["node", "server.js"]
