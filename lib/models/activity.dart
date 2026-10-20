enum ActivityType { assignment, lecture, announcement }

enum DeadlineSource { lms, ai }

class Course {
  const Course(this.id, this.name, this.code, this.colorValue);
  final String id;
  final String name;
  final String code;
  final int colorValue;
}

class Activity {
  Activity({
    required this.id,
    required this.course,
    required this.title,
    required this.type,
    required this.body,
    required this.postedAt,
    this.dueAt,
    this.source = DeadlineSource.lms,
    this.evidence,
    this.week,
    this.videoDuration,
    this.videoUrl,
    this.completed = false,
    this.remindersEnabled = true,
    this.reminderMinutes,
  });

  final String id;
  final Course course;
  final String title;
  final ActivityType type;
  final String body;
  final DateTime postedAt;
  DateTime? dueAt;
  final DeadlineSource source;
  final String? evidence;
  final int? week;
  final Duration? videoDuration;
  final Uri? videoUrl;
  bool completed;
  bool remindersEnabled;
  int? reminderMinutes;
  bool deadlineEdited = false;
}

DateTime dayOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
bool sameDay(DateTime a, DateTime b) => dayOnly(a) == dayOnly(b);

List<Activity> createDemoActivities(DateTime now) {
  const courses = [
    Course('22232', '프로그래밍 기초', 'CSEE101', 0xFF7762D8),
    Course('22233', '데이터베이스', 'CSEE321', 0xFF378E86),
    Course('22234', '인간과 컴퓨터', 'CSEE354', 0xFFD58C47),
    Course('22235', '대학 글쓰기', 'GEK100', 0xFF658AC4),
  ];
  DateTime at(int offset, int hour, [int minute = 0]) =>
      DateTime(now.year, now.month, now.day + offset, hour, minute);
  final essayDeadline = at(2, 23, 59);
  final essayNotice =
      '에세이 초안은 ${essayDeadline.month}월 ${essayDeadline.day}일 23:59까지 온라인 게시판에 올려주세요.';
  return [
    Activity(
      id: 'a1',
      course: courses[0],
      title: '리스트와 반복문 실습 과제',
      type: ActivityType.assignment,
      dueAt: at(0, 23, 59),
      postedAt: at(-4, 9),
      week: 8,
      body: '이번 주에 학습한 리스트와 반복문을 활용하여 간단한 성적 관리 프로그램을 작성해주세요.\n\n1. 학생 이름과 점수를 리스트에 저장하기\n2. 반복문으로 전체 평균 구하기\n3. 가장 높은 점수와 낮은 점수 출력하기\n\n소스 코드와 실행 결과를 하나의 PDF 파일로 제출해주세요. 제출 전 파일이 정상적으로 열리는지 확인해주세요.',
    ),
    Activity(
      id: 'a2',
      course: courses[1],
      title: '8주차 · 정규화와 함수적 종속',
      type: ActivityType.lecture,
      dueAt: at(0, 23, 59),
      postedAt: at(-2, 9),
      week: 8,
      videoDuration: const Duration(minutes: 28, seconds: 34),
      videoUrl: Uri.parse(
        'https://lms.handong.edu/courses/22233/modules/items/622864?return_url=/courses/22233/external_tools/47',
      ),
      body: '',
    ),
    Activity(
      id: 'a3',
      course: courses[2],
      title: '사용자 인터뷰 결과 정리',
      type: ActivityType.assignment,
      dueAt: at(1, 18),
      postedAt: at(-3, 10),
      week: 8,
      body: '팀별 사용자 인터뷰 결과를 정리하여 제출해주세요.\n\n인터뷰 대상, 주요 질문, 관찰한 문제점, 인사이트를 포함해야 합니다. 팀원 중 한 명이 대표로 제출하면 됩니다.\n\n인터뷰 참여자의 개인정보는 익명으로 처리해주세요.',
    ),
    Activity(
      id: 'a4',
      course: courses[3],
      title: '에세이 초안 제출 안내',
      type: ActivityType.announcement,
      dueAt: essayDeadline,
      postedAt: at(-1, 14),
      source: DeadlineSource.ai,
      evidence: essayNotice,
      body:
          '다음 시간에는 서로의 에세이를 읽고 의견을 나눕니다.\n\n$essayNotice\n\n주장은 명확하게, 근거는 구체적으로 작성해주세요. 분량은 A4 두 장 내외이며 참고자료의 출처를 반드시 밝혀주세요.',
    ),
    Activity(
      id: 'a5',
      course: courses[0],
      title: '미니 프로젝트 계획서',
      type: ActivityType.assignment,
      dueAt: at(4, 23, 59),
      postedAt: at(-2, 9),
      week: 8,
      body: '직접 만들어보고 싶은 프로그램의 계획서를 작성해주세요.\n\n프로젝트 주제, 주요 기능 세 가지, 예상 화면 또는 실행 흐름, 개발 일정을 포함합니다. 한 페이지 분량으로 정리해주세요.',
    ),
    Activity(
      id: 'a6',
      course: courses[2],
      title: '9주차 · 프로토타이핑',
      type: ActivityType.lecture,
      dueAt: at(6, 23, 59),
      postedAt: at(0, 9),
      week: 9,
      videoDuration: const Duration(minutes: 32),
      body: '',
    ),
    Activity(
      id: 'a7',
      course: courses[1],
      title: 'SQL 연습 문제 3',
      type: ActivityType.assignment,
      dueAt: at(-1, 23, 59),
      postedAt: at(-6, 9),
      week: 7,
      body: 'JOIN과 GROUP BY를 활용하는 연습 문제입니다.\n\n각 문제의 SQL 쿼리와 실행 결과를 제출해주세요. 마감이 지났다면 LMS에서 추가 제출 가능 여부를 확인하세요.',
    ),
    Activity(
      id: 'a8',
      course: courses[3],
      title: '좋은 논증의 조건',
      type: ActivityType.lecture,
      dueAt: at(-1, 23, 59),
      postedAt: at(-7, 9),
      week: 7,
      completed: true,
      videoDuration: const Duration(minutes: 24),
      body: '',
    ),
    Activity(
      id: 'a9',
      course: courses[0],
      title: '프로젝트 참고 자료',
      type: ActivityType.announcement,
      postedAt: at(-1, 11),
      body: '미니 프로젝트에 참고할 수 있는 자료를 공유합니다.\n\nPython 공식 튜토리얼과 수업 실습 자료를 참고하세요. 이 게시물에는 별도의 마감기한이 없습니다.',
    ),
    Activity(
      id: 'a10',
      course: courses[1],
      title: '데이터 모델링 보고서',
      type: ActivityType.assignment,
      dueAt: at(10, 23, 59),
      postedAt: at(0, 9),
      week: 9,
      body:
          '팀 프로젝트의 데이터 모델링 결과를 보고서로 정리합니다.\n\nER 다이어그램, 테이블 명세, 설계 의도를 포함해주세요.',
    ),
  ];
}
