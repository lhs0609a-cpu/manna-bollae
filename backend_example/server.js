const express = require('express');
const cors = require('cors');
const app = express();

// 미들웨어
// CORS 설정 - 환경 변수로 허용할 오리진 설정
const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',')
  : ['http://localhost:3012'];

app.use(cors({
  origin: function(origin, callback) {
    // origin이 없거나 (서버 간 요청) allowedOrigins에 포함되어 있으면 허용
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));
app.use(express.json());

// 로깅 미들웨어
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.path}`);
  next();
});

// 헬스 체크
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    message: '백엔드 서버가 정상 작동 중입니다.'
  });
});

// API 엔드포인트 예시

// 사용자 목록
app.get('/api/users', (req, res) => {
  res.json({
    success: true,
    users: [
      { id: 1, name: '홍길동', age: 25, gender: '남성' },
      { id: 2, name: '김영희', age: 23, gender: '여성' },
    ]
  });
});

// 사용자 상세 정보
app.get('/api/users/:id', (req, res) => {
  const userId = parseInt(req.params.id);
  res.json({
    success: true,
    user: {
      id: userId,
      name: '홍길동',
      age: 25,
      gender: '남성',
      bio: '안녕하세요!',
      hobbies: ['운동', '영화', '독서']
    }
  });
});

// 매칭 목록
app.get('/api/matches', (req, res) => {
  res.json({
    success: true,
    matches: [
      {
        id: 1,
        userId: 2,
        userName: '김영희',
        matchDate: new Date().toISOString(),
        intimacyScore: 500
      }
    ]
  });
});

// 채팅 메시지 목록
app.get('/api/chats/:matchId/messages', (req, res) => {
  const matchId = req.params.matchId;
  res.json({
    success: true,
    messages: [
      {
        id: 1,
        senderId: 1,
        message: '안녕하세요!',
        timestamp: new Date().toISOString()
      },
      {
        id: 2,
        senderId: 2,
        message: '반가워요!',
        timestamp: new Date().toISOString()
      }
    ]
  });
});

// 메시지 전송
app.post('/api/chats/:matchId/messages', (req, res) => {
  const { message } = req.body;
  res.json({
    success: true,
    message: {
      id: Date.now(),
      senderId: 1,
      message: message,
      timestamp: new Date().toISOString()
    }
  });
});

// 프로필 업데이트
app.put('/api/profile', (req, res) => {
  const profileData = req.body;
  res.json({
    success: true,
    message: '프로필이 업데이트되었습니다.',
    profile: profileData
  });
});

// 진심지수 정보
app.get('/api/trust-score', (req, res) => {
  res.json({
    success: true,
    trustScore: {
      score: 65.5,
      level: '믿음직한',
      dailyQuestCompleted: true,
      verifications: {
        phone: true,
        video: false,
        criminalRecord: false,
        job: true
      }
    }
  });
});

// 하트 온도 정보
app.get('/api/heart-temperature', (req, res) => {
  res.json({
    success: true,
    temperature: {
      current: 36.5,
      level: '따뜻함',
      history: [
        { date: '2025-01-01', temperature: 35.0 },
        { date: '2025-01-02', temperature: 36.0 },
        { date: '2025-01-03', temperature: 36.5 }
      ]
    }
  });
});

// 에러 핸들링
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    error: '서버 오류가 발생했습니다.',
    message: err.message
  });
});

// 404 처리
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: '요청한 리소스를 찾을 수 없습니다.'
  });
});

// 서버 시작
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log('\n========================================');
  console.log(`✅ 백엔드 서버가 포트 ${PORT}에서 실행 중입니다.`);
  console.log(`   http://localhost:${PORT}`);
  console.log('========================================\n');
  console.log('사용 가능한 API 엔드포인트:');
  console.log(`  GET  http://localhost:${PORT}/health`);
  console.log(`  GET  http://localhost:${PORT}/api/users`);
  console.log(`  GET  http://localhost:${PORT}/api/users/:id`);
  console.log(`  GET  http://localhost:${PORT}/api/matches`);
  console.log(`  GET  http://localhost:${PORT}/api/chats/:matchId/messages`);
  console.log(`  POST http://localhost:${PORT}/api/chats/:matchId/messages`);
  console.log(`  PUT  http://localhost:${PORT}/api/profile`);
  console.log(`  GET  http://localhost:${PORT}/api/trust-score`);
  console.log(`  GET  http://localhost:${PORT}/api/heart-temperature`);
  console.log('\n========================================\n');
});
