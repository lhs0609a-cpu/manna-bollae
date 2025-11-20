import '../models/daily_question_model.dart';
import 'dart:math';

/// 30일 온보딩 질문 데이터 (하루 3개씩, 총 90개)
/// 민감도: Low (1-10일) → Medium (11-20일) → High (21-30일)
class DailyQuestionsData {
  /// 각 날짜의 3개 질문 (index 0, 1, 2)
  static Map<String, DailyQuestion> get _allQuestions => {
        // === Day 1: 가벼운 시작 (취미, 선호) ===
        '1_0': DailyQuestion(
          day: 1,
          category: '취미',
          question: '주말에 가장 좋아하는 활동은?',
          type: QuestionType.singleChoice,
          options: ['집에서 휴식', '외출/모임', '운동', '취미 활동', '쇼핑', '카페 투어'],
          rewardPoints: 10,
          profileField: 'lifestyle.weekendActivity',
        ),
        '1_1': DailyQuestion(
          day: 1,
          category: '음식',
          question: '가장 좋아하는 음식 종류는?',
          type: QuestionType.multipleChoice,
          options: ['한식', '중식', '일식', '양식', '분식', '고기', '해산물', '디저트'],
          rewardPoints: 10,
          profileField: 'preference.favoriteFood',
        ),
        '1_2': DailyQuestion(
          day: 1,
          category: '취향',
          question: '카페에서 주로 마시는 음료는?',
          type: QuestionType.singleChoice,
          options: ['아메리카노', '라떼', '티', '에이드', '스무디', '논카페인'],
          rewardPoints: 10,
          profileField: 'preference.favoriteDrink',
        ),

        // === Day 2: 문화 취향 ===
        '2_0': DailyQuestion(
          day: 2,
          category: '영화',
          question: '선호하는 영화 장르는?',
          type: QuestionType.multipleChoice,
          options: ['액션', '로맨스', '코미디', '스릴러', '호러', 'SF', '드라마', '애니'],
          rewardPoints: 10,
          profileField: 'preference.movieGenre',
        ),
        '2_1': DailyQuestion(
          day: 2,
          category: '음악',
          question: '평소 즐겨 듣는 음악 장르는?',
          type: QuestionType.multipleChoice,
          options: ['발라드', '힙합', '록', '재즈', '클래식', 'EDM', 'R&B', '인디', 'K-POP'],
          rewardPoints: 10,
          profileField: 'preference.musicGenre',
        ),
        '2_2': DailyQuestion(
          day: 2,
          category: '독서',
          question: '독서는 얼마나 자주 하시나요?',
          type: QuestionType.singleChoice,
          options: ['매일', '주 2-3회', '월 1-2권', '가끔', '거의 안 함'],
          rewardPoints: 10,
          profileField: 'lifestyle.readingFrequency',
        ),

        // === Day 3: 운동/건강 ===
        '3_0': DailyQuestion(
          day: 3,
          category: '운동',
          question: '운동은 얼마나 자주 하시나요?',
          type: QuestionType.singleChoice,
          options: ['매일', '주 4-5회', '주 2-3회', '주 1회', '가끔', '안 함'],
          rewardPoints: 10,
          profileField: 'lifestyle.exerciseFrequency',
        ),
        '3_1': DailyQuestion(
          day: 3,
          category: '운동',
          question: '선호하는 운동 종류는?',
          type: QuestionType.multipleChoice,
          options: ['헬스', '러닝', '수영', '요가/필라테스', '등산', '자전거', '구기종목', '기타'],
          rewardPoints: 10,
          profileField: 'lifestyle.favoriteExercise',
        ),
        '3_2': DailyQuestion(
          day: 3,
          category: '건강',
          question: '건강 관리에서 가장 신경 쓰는 부분은?',
          type: QuestionType.multipleChoice,
          options: ['규칙적 운동', '건강한 식단', '충분한 수면', '정기 검진', '영양제', '스트레스 관리'],
          rewardPoints: 10,
          profileField: 'lifestyle.healthCare',
        ),

        // === Day 4: 여행 ===
        '4_0': DailyQuestion(
          day: 4,
          category: '여행',
          question: '여행 스타일은?',
          type: QuestionType.singleChoice,
          options: ['완벽한 계획', '대략적 계획', '반반', '즉흥적', '완전 자유'],
          rewardPoints: 10,
          profileField: 'lifestyle.travelStyle',
        ),
        '4_1': DailyQuestion(
          day: 4,
          category: '여행',
          question: '선호하는 여행지 타입은?',
          type: QuestionType.multipleChoice,
          options: ['바다', '산', '도시', '시골', '해외', '국내', '유적지', '휴양지'],
          rewardPoints: 10,
          profileField: 'preference.travelDestination',
        ),
        '4_2': DailyQuestion(
          day: 4,
          category: '여행',
          question: '여행 시 가장 중요한 것은?',
          type: QuestionType.singleChoice,
          options: ['맛집 탐방', '관광명소', '휴식', '액티비티', '사진', '쇼핑'],
          rewardPoints: 10,
          profileField: 'preference.travelPriority',
        ),

        // === Day 5: 패션/스타일 ===
        '5_0': DailyQuestion(
          day: 5,
          category: '패션',
          question: '평소 패션 스타일은?',
          type: QuestionType.multipleChoice,
          options: ['캐주얼', '스트릿', '오피스', '스포티', '빈티지', '모던', '페미닌', '미니멀'],
          rewardPoints: 10,
          profileField: 'lifestyle.fashionStyle',
        ),
        '5_1': DailyQuestion(
          day: 5,
          category: '쇼핑',
          question: '옷을 살 때 가장 중요한 것은?',
          type: QuestionType.singleChoice,
          options: ['디자인', '편안함', '품질', '가격', '브랜드', '트렌드'],
          rewardPoints: 10,
          profileField: 'preference.shoppingPriority',
        ),
        '5_2': DailyQuestion(
          day: 5,
          category: '액세서리',
          question: '액세서리를 자주 착용하시나요?',
          type: QuestionType.singleChoice,
          options: ['매일 착용', '자주 착용', '가끔', '특별한 날만', '안 함'],
          rewardPoints: 10,
          profileField: 'lifestyle.accessoryUsage',
        ),

        // === Day 6: 음식 취향 ===
        '6_0': DailyQuestion(
          day: 6,
          category: '음식',
          question: '매운 음식 괜찮으세요?',
          type: QuestionType.singleChoice,
          options: ['매우 좋아함', '좋아함', '보통', '별로', '전혀 못 먹음'],
          rewardPoints: 10,
          profileField: 'preference.spicyTolerance',
        ),
        '6_1': DailyQuestion(
          day: 6,
          category: '음식',
          question: '선호하는 음식 온도는?',
          type: QuestionType.singleChoice,
          options: ['뜨거운 음식', '따뜻한 음식', '상온', '시원한 음식', '차가운 음식'],
          rewardPoints: 10,
          profileField: 'preference.foodTemperature',
        ),
        '6_2': DailyQuestion(
          day: 6,
          category: '요리',
          question: '요리는 얼마나 자주 하시나요?',
          type: QuestionType.singleChoice,
          options: ['거의 매일', '주 3-4회', '주 1-2회', '가끔', '거의 안 함'],
          rewardPoints: 10,
          profileField: 'lifestyle.cookingFrequency',
        ),

        // === Day 7: 반려동물/자연 ===
        '7_0': DailyQuestion(
          day: 7,
          category: '반려동물',
          question: '반려동물을 키우고 계신가요?',
          type: QuestionType.singleChoice,
          options: ['강아지', '고양이', '강아지+고양이', '기타 동물', '키우지 않음'],
          rewardPoints: 10,
          profileField: 'lifestyle.hasPet',
        ),
        '7_1': DailyQuestion(
          day: 7,
          category: '동물',
          question: '강아지 vs 고양이?',
          type: QuestionType.singleChoice,
          options: ['강아지파', '고양이파', '둘 다 좋아', '둘 다 별로', '알레르기 있음'],
          rewardPoints: 10,
          profileField: 'preference.petPreference',
        ),
        '7_2': DailyQuestion(
          day: 7,
          category: '자연',
          question: '실내 vs 야외 활동?',
          type: QuestionType.singleChoice,
          options: ['완전 실내파', '약간 실내파', '반반', '약간 야외파', '완전 야외파'],
          rewardPoints: 10,
          profileField: 'preference.indoorOutdoor',
        ),

        // === Day 8: 생활 패턴 ===
        '8_0': DailyQuestion(
          day: 8,
          category: '수면',
          question: '아침형 vs 저녁형?',
          type: QuestionType.singleChoice,
          options: ['완전 아침형', '약간 아침형', '중간', '약간 저녁형', '완전 저녁형'],
          rewardPoints: 10,
          profileField: 'lifestyle.sleepPattern',
        ),
        '8_1': DailyQuestion(
          day: 8,
          category: '습관',
          question: '평균 취침 시간은?',
          type: QuestionType.singleChoice,
          options: ['10시 이전', '10-11시', '11-12시', '12-1시', '1-2시', '2시 이후'],
          rewardPoints: 10,
          profileField: 'lifestyle.sleepTime',
        ),
        '8_2': DailyQuestion(
          day: 8,
          category: '습관',
          question: '아침 루틴은 얼마나 걸리나요?',
          type: QuestionType.singleChoice,
          options: ['30분 이내', '30분-1시간', '1-1.5시간', '1.5-2시간', '2시간 이상'],
          rewardPoints: 10,
          profileField: 'lifestyle.morningRoutine',
        ),

        // === Day 9: SNS/디지털 ===
        '9_0': DailyQuestion(
          day: 9,
          category: 'SNS',
          question: '가장 자주 사용하는 SNS는?',
          type: QuestionType.multipleChoice,
          options: ['인스타그램', '페이스북', '트위터', '유튜브', '틱톡', '거의 안 함'],
          rewardPoints: 10,
          profileField: 'lifestyle.favoriteSNS',
        ),
        '9_1': DailyQuestion(
          day: 9,
          category: '디지털',
          question: '스마트폰 하루 사용 시간은?',
          type: QuestionType.singleChoice,
          options: ['2시간 이하', '2-4시간', '4-6시간', '6-8시간', '8시간 이상'],
          rewardPoints: 10,
          profileField: 'lifestyle.phoneUsage',
        ),
        '9_2': DailyQuestion(
          day: 9,
          category: '게임',
          question: '게임은 즐기시나요?',
          type: QuestionType.singleChoice,
          options: ['매일', '자주', '가끔', '거의 안 함', '전혀 안 함'],
          rewardPoints: 10,
          profileField: 'lifestyle.gamingFrequency',
        ),

        // === Day 10: 기본 정보 ===
        '10_0': DailyQuestion(
          day: 10,
          category: '기본 정보',
          question: '혈액형은?',
          type: QuestionType.singleChoice,
          options: ['A형', 'B형', 'O형', 'AB형', '모르겠어요'],
          rewardPoints: 10,
          profileField: 'basicInfo.bloodType',
        ),
        '10_1': DailyQuestion(
          day: 10,
          category: '기본 정보',
          question: 'MBTI는?',
          type: QuestionType.singleChoice,
          options: [
            'INTJ', 'INTP', 'ENTJ', 'ENTP',
            'INFJ', 'INFP', 'ENFJ', 'ENFP',
            'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
            'ISTP', 'ISFP', 'ESTP', 'ESFP',
            '모르겠어요'
          ],
          rewardPoints: 10,
          profileField: 'basicInfo.mbti',
        ),
        '10_2': DailyQuestion(
          day: 10,
          category: '기본 정보',
          question: '어느 지역에 살고 계신가요?',
          type: QuestionType.singleChoice,
          options: ['서울', '경기', '인천', '부산', '대구', '광주', '대전', '울산', '세종', '강원', '충청', '전라', '경상', '제주'],
          rewardPoints: 10,
          profileField: 'basicInfo.region',
        ),

        // === Day 11: 성격 (Medium 난이도 시작) ===
        '11_0': DailyQuestion(
          day: 11,
          category: '성격',
          question: '내향형 vs 외향형?',
          type: QuestionType.singleChoice,
          options: ['완전 내향', '약간 내향', '중간', '약간 외향', '완전 외향'],
          rewardPoints: 15,
          profileField: 'personality.introExtro',
        ),
        '11_1': DailyQuestion(
          day: 11,
          category: '성격',
          question: '계획형 vs 즉흥형?',
          type: QuestionType.singleChoice,
          options: ['완전 계획', '약간 계획', '중간', '약간 즉흥', '완전 즉흥'],
          rewardPoints: 15,
          profileField: 'personality.planningStyle',
        ),
        '11_2': DailyQuestion(
          day: 11,
          category: '성격',
          question: '당신을 한 단어로 표현한다면?',
          type: QuestionType.singleChoice,
          options: ['열정적', '차분함', '유머러스', '진지함', '활발함', '온화함', '독립적', '사교적'],
          rewardPoints: 15,
          profileField: 'personality.trait',
        ),

        // === Day 12: 소통 스타일 ===
        '12_0': DailyQuestion(
          day: 12,
          category: '소통',
          question: '선호하는 연락 수단은?',
          type: QuestionType.singleChoice,
          options: ['전화', '영상통화', '문자', '음성메시지', '상관없음'],
          rewardPoints: 15,
          profileField: 'preference.contactMethod',
        ),
        '12_1': DailyQuestion(
          day: 12,
          category: '소통',
          question: '연락 빈도는?',
          type: QuestionType.singleChoice,
          options: ['항상 연락', '자주 연락', '적당히', '필요할 때만', '자유롭게'],
          rewardPoints: 15,
          profileField: 'preference.contactFrequency',
        ),
        '12_2': DailyQuestion(
          day: 12,
          category: '소통',
          question: '갈등이 생기면?',
          type: QuestionType.singleChoice,
          options: ['바로 대화', '시간 두고 대화', '참고 넘어감', '화해 먼저', '상황 따라'],
          rewardPoints: 15,
          profileField: 'personality.conflictStyle',
        ),

        // === Day 13: 데이트 스타일 ===
        '13_0': DailyQuestion(
          day: 13,
          category: '데이트',
          question: '이상적인 데이트는?',
          type: QuestionType.singleChoice,
          options: ['영화', '맛집 탐방', '카페 대화', '액티비티', '드라이브', '집에서 편하게'],
          rewardPoints: 15,
          profileField: 'preference.idealDate',
        ),
        '13_1': DailyQuestion(
          day: 13,
          category: '데이트',
          question: '데이트 비용은?',
          type: QuestionType.singleChoice,
          options: ['남자가 전부', '대부분 남자', '반반', '상황 따라', '각자'],
          rewardPoints: 15,
          profileField: 'values.dateCost',
        ),
        '13_2': DailyQuestion(
          day: 13,
          category: '데이트',
          question: '데이트 빈도는?',
          type: QuestionType.singleChoice,
          options: ['거의 매일', '주 3-4회', '주 1-2회', '주 1회', '2주에 1회', '월 1-2회'],
          rewardPoints: 15,
          profileField: 'preference.dateFrequency',
        ),

        // === Day 14: 연애 스타일 ===
        '14_0': DailyQuestion(
          day: 14,
          category: '연애',
          question: '연애 스타일은?',
          type: QuestionType.singleChoice,
          options: ['적극적', '소극적', '로맨틱', '현실적', '자유로운'],
          rewardPoints: 15,
          profileField: 'personality.datingStyle',
        ),
        '14_1': DailyQuestion(
          day: 14,
          category: '연애',
          question: '스킨십은?',
          type: QuestionType.singleChoice,
          options: ['매우 중요', '중요함', '보통', '별로 중요하지 않음', '중요하지 않음'],
          rewardPoints: 15,
          profileField: 'values.skinshipImportance',
        ),
        '14_2': DailyQuestion(
          day: 14,
          category: '연애',
          question: '애정 표현은?',
          type: QuestionType.singleChoice,
          options: ['자주 표현', '가끔 표현', '보통', '별로 안 함', '잘 안 함'],
          rewardPoints: 15,
          profileField: 'personality.affectionExpression',
        ),

        // === Day 15: 가치관 ===
        '15_0': DailyQuestion(
          day: 15,
          category: '가치관',
          question: '인생에서 가장 중요한 것은?',
          type: QuestionType.singleChoice,
          options: ['건강', '가족', '돈', '사랑', '자유', '성공', '행복'],
          rewardPoints: 15,
          profileField: 'values.mostImportant',
        ),
        '15_1': DailyQuestion(
          day: 15,
          category: '가치관',
          question: '일과 삶의 균형은?',
          type: QuestionType.singleChoice,
          options: ['일 우선', '약간 일 우선', '균형', '약간 삶 우선', '삶 우선'],
          rewardPoints: 15,
          profileField: 'values.workLifeBalance',
        ),
        '15_2': DailyQuestion(
          day: 15,
          category: '가치관',
          question: '돈에 대한 생각은?',
          type: QuestionType.singleChoice,
          options: ['매우 중요', '중요함', '보통', '별로 중요하지 않음', '중요하지 않음'],
          rewardPoints: 15,
          profileField: 'values.moneyImportance',
        ),

        // === Day 16: 소비 성향 ===
        '16_0': DailyQuestion(
          day: 16,
          category: '소비',
          question: '소비 성향은?',
          type: QuestionType.singleChoice,
          options: ['매우 아낌', '약간 아낌', '보통', '약간 씀씀이', '매우 씀씀이'],
          rewardPoints: 15,
          profileField: 'lifestyle.spendingStyle',
        ),
        '16_1': DailyQuestion(
          day: 16,
          category: '소비',
          question: '저축은 얼마나 하시나요?',
          type: QuestionType.singleChoice,
          options: ['수입의 50% 이상', '30-50%', '10-30%', '10% 미만', '거의 안 함'],
          rewardPoints: 15,
          profileField: 'lifestyle.savingRate',
        ),
        '16_2': DailyQuestion(
          day: 16,
          category: '소비',
          question: '충동구매는?',
          type: QuestionType.singleChoice,
          options: ['자주 함', '가끔 함', '보통', '별로 안 함', '전혀 안 함'],
          rewardPoints: 15,
          profileField: 'personality.impulseBuying',
        ),

        // === Day 17: 외모 정보 ===
        '17_0': DailyQuestion(
          day: 17,
          category: '외모',
          question: '키는 어떻게 되시나요?',
          type: QuestionType.singleChoice,
          options: ['150cm 미만', '150-160cm', '160-170cm', '170-180cm', '180-190cm', '190cm 이상'],
          rewardPoints: 15,
          profileField: 'appearance.heightRange',
        ),
        '17_1': DailyQuestion(
          day: 17,
          category: '외모',
          question: '체형은?',
          type: QuestionType.singleChoice,
          options: ['마른 편', '보통', '근육질', '통통한 편', '건장한 편'],
          rewardPoints: 15,
          profileField: 'appearance.bodyType',
        ),
        '17_2': DailyQuestion(
          day: 17,
          category: '외모',
          question: '외모에서 가장 자신 있는 부분은?',
          type: QuestionType.singleChoice,
          options: ['얼굴', '눈', '미소', '체형', '스타일', '분위기', '전체적 조화'],
          rewardPoints: 15,
          profileField: 'appearance.strength',
        ),

        // === Day 18: 이상형 (외모) ===
        '18_0': DailyQuestion(
          day: 18,
          category: '이상형',
          question: '선호하는 상대방 키는?',
          type: QuestionType.singleChoice,
          options: ['150cm 이하', '150-160cm', '160-170cm', '170-180cm', '180cm 이상', '상관없음'],
          rewardPoints: 15,
          profileField: 'preference.partnerHeight',
        ),
        '18_1': DailyQuestion(
          day: 18,
          category: '이상형',
          question: '선호하는 체형은?',
          type: QuestionType.singleChoice,
          options: ['마른 편', '보통', '근육질', '통통한 편', '건장한 편', '상관없음'],
          rewardPoints: 15,
          profileField: 'preference.partnerBodyType',
        ),
        '18_2': DailyQuestion(
          day: 18,
          category: '이상형',
          question: '외모 vs 성격?',
          type: QuestionType.singleChoice,
          options: ['외모 우선', '약간 외모', '반반', '약간 성격', '성격 우선'],
          rewardPoints: 15,
          profileField: 'values.appearancePersonality',
        ),

        // === Day 19: 이상형 (성격) ===
        '19_0': DailyQuestion(
          day: 19,
          category: '이상형',
          question: '이상형의 성격은?',
          type: QuestionType.multipleChoice,
          options: ['밝고 긍정적', '차분하고 신중', '유머러스', '진지함', '적극적', '배려심 많음', '독립적', '가정적'],
          rewardPoints: 15,
          profileField: 'preference.idealPersonality',
        ),
        '19_1': DailyQuestion(
          day: 19,
          category: '이상형',
          question: '나이 차이는?',
          type: QuestionType.singleChoice,
          options: ['동갑만', '±1살', '±2살', '±3살', '±5살', '상관없음'],
          rewardPoints: 15,
          profileField: 'preference.ageDifference',
        ),
        '19_2': DailyQuestion(
          day: 19,
          category: '이상형',
          question: '상대방의 과거 연애는?',
          type: QuestionType.singleChoice,
          options: ['매우 신경 씀', '신경 씀', '보통', '별로 신경 안 씀', '전혀 신경 안 씀'],
          rewardPoints: 15,
          profileField: 'values.pastRelationship',
        ),

        // === Day 20: 흡연/음주 ===
        '20_0': DailyQuestion(
          day: 20,
          category: '생활습관',
          question: '흡연은?',
          type: QuestionType.singleChoice,
          options: ['비흡연', '가끔', '자주', '금연 중'],
          rewardPoints: 15,
          profileField: 'basicInfo.smoking',
        ),
        '20_1': DailyQuestion(
          day: 20,
          category: '생활습관',
          question: '음주 빈도는?',
          type: QuestionType.singleChoice,
          options: ['안 마심', '거의 안 마심', '월 1-2회', '주 1-2회', '주 3-4회', '거의 매일'],
          rewardPoints: 15,
          profileField: 'basicInfo.drinking',
        ),
        '20_2': DailyQuestion(
          day: 20,
          category: '생활습관',
          question: '상대방의 흡연은?',
          type: QuestionType.singleChoice,
          options: ['절대 안 됨', '별로 선호 안 함', '상관없음', '괜찮음'],
          rewardPoints: 15,
          profileField: 'preference.partnerSmoking',
        ),

        // === Day 21: 직업 (High 난이도 시작) ===
        '21_0': DailyQuestion(
          day: 21,
          category: '직업',
          question: '직업 분야는?',
          type: QuestionType.singleChoice,
          options: ['IT/기술', '금융', '의료', '교육', '서비스', '예술/문화', '공무원', '자영업', '학생', '구직중', '기타'],
          rewardPoints: 20,
          profileField: 'vipInfo.jobField',
        ),
        '21_1': DailyQuestion(
          day: 21,
          category: '직업',
          question: '직업 만족도는?',
          type: QuestionType.singleChoice,
          options: ['매우 만족', '만족', '보통', '불만족', '매우 불만족', '해당없음'],
          rewardPoints: 20,
          profileField: 'lifestyle.jobSatisfaction',
        ),
        '21_2': DailyQuestion(
          day: 21,
          category: '직업',
          question: '근무 형태는?',
          type: QuestionType.singleChoice,
          options: ['정규직', '계약직', '프리랜서', '자영업', '학생', '무직', '기타'],
          rewardPoints: 20,
          profileField: 'vipInfo.employmentType',
        ),

        // === Day 22: 학력/교육 ===
        '22_0': DailyQuestion(
          day: 22,
          category: '학력',
          question: '최종 학력은?',
          type: QuestionType.singleChoice,
          options: ['고졸', '전문대졸', '대졸', '석사', '박사', '기타'],
          rewardPoints: 20,
          profileField: 'vipInfo.education',
        ),
        '22_1': DailyQuestion(
          day: 22,
          category: '학력',
          question: '전공은?',
          type: QuestionType.singleChoice,
          options: ['인문', '사회', '자연', '공학', '의약', '예체능', '교육', '기타'],
          rewardPoints: 20,
          profileField: 'vipInfo.major',
        ),
        '22_2': DailyQuestion(
          day: 22,
          category: '학력',
          question: '상대방의 학력은?',
          type: QuestionType.singleChoice,
          options: ['매우 중요', '중요함', '보통', '별로 중요하지 않음', '중요하지 않음'],
          rewardPoints: 20,
          profileField: 'values.educationImportance',
        ),

        // === Day 23: 경제력 ===
        '23_0': DailyQuestion(
          day: 23,
          category: '경제',
          question: '연봉 수준은? (선택사항)',
          type: QuestionType.singleChoice,
          options: ['3천만원 미만', '3-4천만원', '4-5천만원', '5-6천만원', '6-7천만원', '7천만원 이상', '답변 안 함'],
          rewardPoints: 20,
          profileField: 'vipInfo.salaryRange',
        ),
        '23_1': DailyQuestion(
          day: 23,
          category: '경제',
          question: '주거 형태는?',
          type: QuestionType.singleChoice,
          options: ['자가', '전세', '월세', '부모님 집', '기숙사', '기타'],
          rewardPoints: 20,
          profileField: 'vipInfo.housing',
        ),
        '23_2': DailyQuestion(
          day: 23,
          category: '경제',
          question: '차량 소유는?',
          type: QuestionType.singleChoice,
          options: ['있음', '없음 (계획 있음)', '없음 (필요없음)'],
          rewardPoints: 20,
          profileField: 'vipInfo.carOwnership',
        ),

        // === Day 24: 결혼관 ===
        '24_0': DailyQuestion(
          day: 24,
          category: '결혼',
          question: '결혼에 대한 생각은?',
          type: QuestionType.singleChoice,
          options: ['빨리 하고 싶음', '2-3년 내', '3-5년 내', '천천히', '생각 없음', '아직 모르겠음'],
          rewardPoints: 20,
          profileField: 'vipInfo.marriagePlan',
        ),
        '24_1': DailyQuestion(
          day: 24,
          category: '결혼',
          question: '결혼식 스타일은?',
          type: QuestionType.singleChoice,
          options: ['성대하게', '보통 규모', '작은 규모', '스몰웨딩', '혼인신고만', '아직 생각 안 해봄'],
          rewardPoints: 20,
          profileField: 'values.weddingStyle',
        ),
        '24_2': DailyQuestion(
          day: 24,
          category: '결혼',
          question: '결혼 후 거주지는?',
          type: QuestionType.singleChoice,
          options: ['신혼집 마련', '전세', '월세', '부모님 근처', '상의 후 결정'],
          rewardPoints: 20,
          profileField: 'values.marriageResidence',
        ),

        // === Day 25: 자녀계획 ===
        '25_0': DailyQuestion(
          day: 25,
          category: '자녀',
          question: '자녀 계획은?',
          type: QuestionType.singleChoice,
          options: ['꼭 갖고 싶음', '1명', '2명', '3명 이상', '상황 따라', '생각 없음'],
          rewardPoints: 20,
          profileField: 'vipInfo.childcarePlan',
        ),
        '25_1': DailyQuestion(
          day: 25,
          category: '자녀',
          question: '자녀 양육 방식은?',
          type: QuestionType.singleChoice,
          options: ['엄격하게', '약간 엄격', '보통', '자유롭게', '매우 자유롭게'],
          rewardPoints: 20,
          profileField: 'values.parentingStyle',
        ),
        '25_2': DailyQuestion(
          day: 25,
          category: '자녀',
          question: '맞벌이 vs 전업?',
          type: QuestionType.singleChoice,
          options: ['맞벌이', '전업 선호', '상황 따라', '아직 모르겠음'],
          rewardPoints: 20,
          profileField: 'values.dualIncome',
        ),

        // === Day 26: 가족관 ===
        '26_0': DailyQuestion(
          day: 26,
          category: '가족',
          question: '부모님과의 관계는?',
          type: QuestionType.singleChoice,
          options: ['매우 좋음', '좋음', '보통', '별로', '좋지 않음'],
          rewardPoints: 20,
          profileField: 'lifestyle.familyRelationship',
        ),
        '26_1': DailyQuestion(
          day: 26,
          category: '가족',
          question: '명절은 어떻게?',
          type: QuestionType.singleChoice,
          options: ['양가 번갈아', '부모님 집', '우리 집', '각자', '상의 후 결정'],
          rewardPoints: 20,
          profileField: 'values.holidayPlan',
        ),
        '26_2': DailyQuestion(
          day: 26,
          category: '가족',
          question: '시댁/처가 방문 빈도는?',
          type: QuestionType.singleChoice,
          options: ['주 1회 이상', '월 2-3회', '월 1회', '명절만', '상의 후 결정'],
          rewardPoints: 20,
          profileField: 'values.inLawVisit',
        ),

        // === Day 27: 종교/정치 ===
        '27_0': DailyQuestion(
          day: 27,
          category: '종교',
          question: '종교는?',
          type: QuestionType.singleChoice,
          options: ['기독교', '천주교', '불교', '이슬람', '무교', '기타'],
          rewardPoints: 20,
          profileField: 'basicInfo.religion',
        ),
        '27_1': DailyQuestion(
          day: 27,
          category: '종교',
          question: '상대방의 종교는?',
          type: QuestionType.singleChoice,
          options: ['같은 종교만', '비슷한 종교', '상관없음', '무교 선호'],
          rewardPoints: 20,
          profileField: 'preference.partnerReligion',
        ),
        '27_2': DailyQuestion(
          day: 27,
          category: '정치',
          question: '정치 성향은? (선택사항)',
          type: QuestionType.singleChoice,
          options: ['진보', '중도진보', '중도', '중도보수', '보수', '답변 안 함'],
          rewardPoints: 20,
          profileField: 'values.politicalView',
        ),

        // === Day 28: 과거 연애 ===
        '28_0': DailyQuestion(
          day: 28,
          category: '연애 경험',
          question: '연애 경험은?',
          type: QuestionType.singleChoice,
          options: ['없음', '1-2회', '3-4회', '5회 이상', '답변 안 함'],
          rewardPoints: 20,
          profileField: 'vipInfo.datingExperience',
        ),
        '28_1': DailyQuestion(
          day: 28,
          category: '연애 경험',
          question: '가장 긴 연애 기간은?',
          type: QuestionType.singleChoice,
          options: ['없음', '6개월 미만', '6개월-1년', '1-2년', '2-3년', '3년 이상'],
          rewardPoints: 20,
          profileField: 'vipInfo.longestRelationship',
        ),
        '28_2': DailyQuestion(
          day: 28,
          category: '연애 경험',
          question: '이별 후 지난 기간은?',
          type: QuestionType.singleChoice,
          options: ['현재 연애 중', '3개월 미만', '3-6개월', '6개월-1년', '1년 이상', '해당없음'],
          rewardPoints: 20,
          profileField: 'vipInfo.timeSinceBreakup',
        ),

        // === Day 29: 미래 계획 ===
        '29_0': DailyQuestion(
          day: 29,
          category: '미래',
          question: '5년 후 목표는?',
          type: QuestionType.text,
          options: [],
          placeholder: '자유롭게 작성해주세요',
          rewardPoints: 30,
          profileField: 'values.futureGoal',
        ),
        '29_1': DailyQuestion(
          day: 29,
          category: '미래',
          question: '은퇴 후 하고 싶은 일은?',
          type: QuestionType.text,
          options: [],
          placeholder: '꿈꾸는 것을 적어주세요',
          rewardPoints: 30,
          profileField: 'values.retirementPlan',
        ),
        '29_2': DailyQuestion(
          day: 29,
          category: '미래',
          question: '버킷리스트 1순위는?',
          type: QuestionType.text,
          options: [],
          placeholder: '꼭 하고 싶은 것',
          rewardPoints: 30,
          profileField: 'values.bucketList',
        ),

        // === Day 30: 완성 ===
        '30_0': DailyQuestion(
          day: 30,
          category: '완성',
          question: '나를 가장 잘 표현하는 한 문장은?',
          type: QuestionType.text,
          options: [],
          placeholder: '자유롭게 작성해주세요',
          rewardPoints: 50,
          profileField: 'profile.oneLiner',
        ),
        '30_1': DailyQuestion(
          day: 30,
          category: '완성',
          question: '30일간의 여정을 마치며... 소감은?',
          type: QuestionType.text,
          options: [],
          placeholder: '솔직한 마음을 들려주세요',
          rewardPoints: 50,
          profileField: 'profile.finalMessage',
        ),
        '30_2': DailyQuestion(
          day: 30,
          category: '완성',
          question: '이 앱을 통해 만나고 싶은 사람은?',
          type: QuestionType.text,
          options: [],
          placeholder: '이상적인 상대를 표현해주세요',
          rewardPoints: 50,
          profileField: 'preference.idealPartnerDescription',
        ),
      };

  /// 특정 날짜의 특정 인덱스 질문 가져오기
  static DailyQuestion? getQuestionForDayAndIndex(int day, int index, {int? seed}) {
    final key = '${day}_$index';
    return _allQuestions[key];
  }

  /// 특정 날짜의 랜덤 질문 가져오기 (호환성)
  static DailyQuestion getRandomQuestionForDay(int day, {int? seed}) {
    return getQuestionForDayAndIndex(day, 0, seed: seed)!;
  }

  /// 호환성을 위한 기존 questions getter
  static List<DailyQuestion> get questions {
    final List<DailyQuestion> allQuestions = [];
    for (int day = 1; day <= 30; day++) {
      for (int index = 0; index < 3; index++) {
        final question = getQuestionForDayAndIndex(day, index);
        if (question != null) {
          allQuestions.add(question);
        }
      }
    }
    return allQuestions;
  }
}
