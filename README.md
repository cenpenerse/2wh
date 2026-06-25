# Baren - 프리미엄 바이크 렌탈 서비스 🏍️

도심 라이딩부터 오프로드 투어링까지 최상의 모빌리티 경험을 제공하는 웹 기반 **프리미엄 바이크 렌탈 서비스 Baren** 프로젝트입니다. 순수 JSP/Servlet 환경에서 현대적인 디자인과 고도화된 비즈니스 로직(멀티 컨트롤러, 서비스 레이어, JNDI DBCP, 복합 예약 요금 정산 등)을 접목하여 리팩토링한 프로젝트입니다.

---

## 🛠️ 기술 스택 (Tech Stack)

### Backend
- **Language**: Java 21 (JDK 21)
- **Framework/API**: Servlet 6.0, JSP (Jakarta EE 10 / Tomcat 11.0 의존성)
- **Database**: Oracle Database (ojdbc)
- **Connection Pool**: Tomcat 내장 DBCP (JNDI DataSource)

### Frontend
- **Markup/Logic**: HTML5, Vanilla JavaScript
- **Styling**: Vanilla CSS (CSS Variables, Grid & Flexbox layout)
- **Libraries**: Flatpickr (달력 예약 전용 라이브러리)

---

## 📐 핵심 아키텍처 및 구조 개편

기존의 비대했던 단일 컨트롤러 구조를 분산화하고, UI 레이아웃과 CSS 및 비즈니스 책임을 명확히 분리하여 품질을 강화했습니다.

```text
src/main/java/com/bikerental/
├── controller/        # [도메인별 멀티 서블릿 컨트롤러]
│   ├── MemberController.java      - 회원가입, 로그인/로그아웃, 대시보드 로드, 면허 심사
│   ├── BoardController.java       - 자유/리뷰 게시판 CRUD, 댓글, 1:1 문의
│   ├── BikeController.java        - 지점/바이크 필터 검색, 신규 지점/바이크 등록 및 관리
│   ├── BookingController.java     - 실시간 예약 신청, 환불 위약금 계산, 사고 접수, 주유량 패널티
│   └── CommonController.java      - 메인 홈, 요금안내, FAQ, 테스트 데이터 초기화
│
├── service/           # [비즈니스 로직 전담 싱글톤 서비스 레이어]
│   ├── MemberService.java
│   ├── BoardService.java
│   ├── BikeService.java
│   └── BookingService.java
│
├── util/              # [DBCP 커넥션 획득 및 페이징 도구]
│   ├── DBConnection.java (JNDI Lookup & DriverManager Fallback 이중 구조)
│   └── Pagination.java (JSP EL 연동 이전/다음 블록 자동 연산 지원)
│
└── dto / dao          # [데이터 바인딩 객체 및 SQL 처리 계층]
```

### 🔒 보안 및 리소스 제어
- **WEB-INF/views 하위 배치**: 모든 주요 JSP 뷰 템플릿 파일은 브라우저에서 직접 접근할 수 없도록 `WEB-INF/views/` 경로 하위에서 통제하며, 반드시 컨트롤러 서블릿의 `forward` 동작을 거치도록 설계되었습니다.
- **CSS 스타일시트 모듈화**: `style.css`(1,700줄)를 완전 분해하여 `common.css`, `auth.css`, `board.css`, `bike.css`, `bike_detail.css`, `support.css`, `mypage.css`로 모듈 분할 연동함으로써 네트워크 리소스 절약 및 성능을 극대화했습니다.

---

## 🌟 주요 핵심 기능

### 1. 회원 및 면허/차단 관리
- **회원 등급 세분화**: 회원 등급(일반, GOLD, VIP)에 따라 바이크 예약 신청 시 기본 대여료 할인율(0%, 5%, 10%)이 다르게 자동 적용됩니다.
- **2종 소형/원동기 면허 심사**: 마이페이지를 통해 사용자가 면허 이미지를 업로드하면, 관리자가 면허 등급 및 정보를 확인하고 승인/반려합니다. (미승인 회원은 바이크 예약 불가)
- **블랙리스트 차단 및 쿠폰 발행**: 관리자가 특정 불량 회원을 제재하거나, 마케팅용 쿠폰(정액 할인)을 직접 발행하여 부여할 수 있습니다.

### 2. 고도화된 바이크 실시간 예약 프로세스
- **지점별 바이크 동적 필터 검색**: 원하는 지점(대구 중앙점 등)을 선택한 뒤, 제조사 및 배기량별(스쿠터, 쿼터급, 리터급)로 대여 가능한 바이크를 검색합니다.
- **복합 요금 정산 요약**:
  - 기본 일일 대여료 × 예약 일수 자동 산정.
  - 선택한 추가 옵션 장비(헬멧, 탑박스, 보호대 등) 요금 합산.
  - 필수 보험 요금(일반 면책, 완전 면책) 적용.
  - **할인 혜택 동시 적용**: 등급 할인, 쿠폰 할인, 보유 포인트 사용액을 최종 차감하여 복합 연산 및 예약 신청.

### 3. 예약 취소, 패널티 및 사후 조치
- **날짜별 환불 위약금 자동 차등 계산**: 
  - 대여일 기준 3일 전 취소: 100% 환불 (위약금 0%)
  - 대여일 기준 1일 전 취소: 50% 위약금 차감 후 환불
  - 대여일 당일 취소: 환불 불가 (100% 위약금)
- **반납 및 주유량 패널티**: 반납 처리 시 반납 주유율이 100% 미만인 경우, 부족한 주유량 **1%당 1,000원의 패널티**를 산정하여 관리자가 패널티를 부과하고, 사용자가 마이페이지에서 즉시 결제할 수 있습니다.
- **사고 보고서 제출**: 운행 중 사고 발생 시 사용자가 사고 정보와 사진을 기재하여 보고서를 제출하면, 관리자가 과실비율과 보험 접수 번호를 심사하여 갱신합니다.

### 4. 게시판 및 1:1 고객지원
- **페이징 및 이미지 파일 업로드**: 자유게시판/이용후기 CRUD 과정에서 썸네일 이미지 파일 업로드 처리를 수행하며, 삭제 시 WAS 내의 파일과 이클립스 로컬 소스 디렉토리의 파일을 동시 물리 삭제합니다.
- **1:1 문의**: 비회원/회원이 올린 문의 내역에 관리자가 어드민 탭에서 직접 답변을 등록합니다.

---

## 🚀 설치 및 로컬 구동 방법 (Setup Guide)

### 1. 데이터베이스 구축
- 보유하고 계신 Oracle Database에 접속하여 `database/` 폴더 하위에 위치한 SQL 스키마 및 더미 생성 파일을 실행해 테이블 구조를 생성합니다.

### 2. Tomcat 11.0 JNDI 커넥션 풀(DBCP) 설정
톰캣의 내장 DBCP 방식을 사용하므로 아래와 같이 설정을 진행합니다. (프로젝트 내부에는 기본 완료되어 있습니다.)

- **context.xml 정의**:
  `src/main/webapp/META-INF/context.xml` 파일 내에 Oracle JNDI 리소스 선언이 들어있습니다.
  ```xml
  <Resource name="jdbc/myoracle"
            auth="Container"
            type="javax.sql.DataSource"
            driverClassName="oracle.jdbc.OracleDriver"
            url="jdbc:oracle:thin:@localhost:1521:xe"
            username="your_username"
            password="your_password"
            maxTotal="20"
            maxIdle="10"
            maxWaitMillis="-1"/>
  ```
  *(필요시 사용 중인 Oracle DB의 URL, ID, Password 정보를 수정해 주세요.)*

- **Tomcat lib 확인**:
  WAS 톰캣 설치 디렉토리의 `lib` 폴더 내에 Oracle JDBC 드라이버(`ojdbc8.jar` 또는 `ojdbc6.jar`)가 존재하는지 반드시 확인해 주세요.

- **db.properties 확인**:
  `src/main/resources/db.properties` 파일 내 JNDI 이름이 명시되어 있는지 확인합니다.
  ```properties
  db.jndi=java:comp/env/jdbc/myoracle
  ```

### 3. 파일 업로드 로컬 경로 수정 (선택)
- 자바 서비스 클래스([BikeService.java](file:///d:/CHJ/GitProjects/2wh/src/main/java/com/bikerental/service/BikeService.java) 및 [MemberService.java](file:///d:/CHJ/GitProjects/2wh/src/main/java/com/bikerental/service/MemberService.java)) 등 파일 쓰기 로직에서는 이클립스 Clean 시 업로드 리소스가 날아가는 것을 방지하기 위해 로컬 경로로 동시 복사 연동을 수행하고 있습니다.
- 코드 내부에 선언된 로컬 소스 디렉토리(예: `c:\\2_eclipse\\hp\\bikerental\\...`) 경로를 본인의 로컬 프로젝트 경로에 맞추어 수정하시면 파일 업로드 이중 안전 복사가 원활하게 작동합니다.

### 4. 웰컴 브릿지 및 구동
- 이클립스 Dynamic Web Project로 프로젝트를 가져온 뒤, `Run on Server`를 통해 기동합니다.
- 서버가 켜지면 루트 경로 접속 시 브라우저가 자동적으로 `index.html`을 읽어 `index.do` 컨트롤러 메인 화면으로 리다이렉션합니다.
- **초기 데이터 셋업**: 메인 화면 진입 후 `http://localhost:8080/2wh/setupData.do` 에 접근하면 지점 정보, 기본 바이크 사양, 보험 상품, 추가 옵션 기어 등 대여 서비스를 구동하는 데 필수적인 **모든 기초 더미 데이터들이 데이터베이스에 일괄 적재**됩니다.
