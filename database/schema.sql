-- =====================================================
-- 1. 기존 테이블 및 시퀀스 삭제 (참조 무결성 순서 고려)
-- =====================================================
DROP TABLE comments CASCADE CONSTRAINTS;
DROP TABLE boards CASCADE CONSTRAINTS;
DROP TABLE inquiries CASCADE CONSTRAINTS;
DROP TABLE reviews CASCADE CONSTRAINTS;
DROP TABLE coupons CASCADE CONSTRAINTS;
DROP TABLE payments CASCADE CONSTRAINTS;
DROP TABLE penalties CASCADE CONSTRAINTS;
DROP TABLE booking_options CASCADE CONSTRAINTS;
DROP TABLE option_items CASCADE CONSTRAINTS;
DROP TABLE reservations CASCADE CONSTRAINTS;
DROP TABLE users CASCADE CONSTRAINTS;
DROP TABLE bike_images CASCADE CONSTRAINTS;
DROP TABLE motorcycles CASCADE CONSTRAINTS;
DROP TABLE rental_shops CASCADE CONSTRAINTS;
DROP TABLE brands CASCADE CONSTRAINTS;

DROP SEQUENCE seq_comments;
DROP SEQUENCE seq_boards;
DROP SEQUENCE seq_inquiries;
DROP SEQUENCE seq_reviews;
DROP SEQUENCE seq_coupons;
DROP SEQUENCE seq_payments;
DROP SEQUENCE seq_penalties;
DROP SEQUENCE seq_booking_options;
DROP SEQUENCE seq_option_items;
DROP SEQUENCE seq_reservations;
DROP SEQUENCE seq_users;
DROP SEQUENCE seq_bike_images;
DROP SEQUENCE seq_motorcycles;
DROP SEQUENCE seq_rental_shops;
DROP SEQUENCE seq_brands;

-- =====================================================
-- 2. 시퀀스 생성 (자동 증가 기본키용)
-- =====================================================
CREATE SEQUENCE seq_brands START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_rental_shops START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_motorcycles START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_bike_images START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_users START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_reservations START WITH 1000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_payments START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_penalties START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_option_items START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_booking_options START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_coupons START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_reviews START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_inquiries START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_boards START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_comments START WITH 1 INCREMENT BY 1 NOCACHE;

-- =====================================================
-- 3. 테이블 생성
-- =====================================================

-- 3-1. 제조사 (brands)
CREATE TABLE brands (
    brand_id    NUMBER PRIMARY KEY,
    brand_name  VARCHAR2(100) NOT NULL,
    country     VARCHAR2(100),
    description CLOB
);

-- 3-2. 렌탈지점 (rental_shops)
CREATE TABLE rental_shops (
    shop_id       NUMBER PRIMARY KEY,
    shop_name     VARCHAR2(100) NOT NULL,
    manager_name  VARCHAR2(100),
    tel           VARCHAR2(30),
    address       VARCHAR2(500),
    open_time     VARCHAR2(10), -- '09:00' 형태
    close_time    VARCHAR2(10)  -- '20:00' 형태
);

-- 3-3. 바이크 (motorcycles)
CREATE TABLE motorcycles (
    bike_id       NUMBER PRIMARY KEY,
    brand_id      NUMBER,
    shop_id       NUMBER,
    model_name    VARCHAR2(200) NOT NULL,
    cc            NUMBER,
    year          NUMBER(4),
    color         VARCHAR2(50),
    daily_price   NUMBER NOT NULL,
    mileage       NUMBER DEFAULT 0,
    status        VARCHAR2(50) DEFAULT 'AVAILABLE', -- AVAILABLE, RENTED, MAINTENANCE
    description   CLOB,
    CONSTRAINT fk_bike_brand FOREIGN KEY (brand_id) REFERENCES brands(brand_id) ON DELETE SET NULL,
    CONSTRAINT fk_bike_shop FOREIGN KEY (shop_id) REFERENCES rental_shops(shop_id) ON DELETE SET NULL
);

-- 3-4. 바이크 이미지 (bike_images)
CREATE TABLE bike_images (
    image_id      NUMBER PRIMARY KEY,
    bike_id       NUMBER NOT NULL,
    image_url     VARCHAR2(512) NOT NULL,
    is_thumbnail  CHAR(1) DEFAULT 'N',
    CONSTRAINT fk_img_bike FOREIGN KEY (bike_id) REFERENCES motorcycles(bike_id) ON DELETE CASCADE
);

-- 3-5. 회원 (users)
CREATE TABLE users (
    user_id         NUMBER PRIMARY KEY,
    email           VARCHAR2(100) NOT NULL UNIQUE,
    password        VARCHAR2(255) NOT NULL,
    name            VARCHAR2(100) NOT NULL,
    phone           VARCHAR2(30),
    birth_date      DATE,
    license_number  VARCHAR2(100),
    license_status  VARCHAR2(50) DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED
    role            VARCHAR2(50) DEFAULT 'USER', -- USER, ADMIN
    point           NUMBER DEFAULT 0,
    join_date       DATE DEFAULT SYSDATE NOT NULL
);

-- 3-6. 예약 (reservations)
CREATE TABLE reservations (
    reservation_id  NUMBER PRIMARY KEY,
    user_id         NUMBER NOT NULL,
    bike_id         NUMBER NOT NULL,
    pickup_shop_id  NUMBER,
    dropoff_shop_id NUMBER,
    start_date      TIMESTAMP NOT NULL,
    end_date        TIMESTAMP NOT NULL,
    rental_days     NUMBER NOT NULL,
    total_price     NUMBER NOT NULL,
    status          VARCHAR2(50) DEFAULT 'PENDING', -- PENDING, APPROVED, CANCELLED
    created_at      DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_res_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_res_bike FOREIGN KEY (bike_id) REFERENCES motorcycles(bike_id) ON DELETE CASCADE,
    CONSTRAINT fk_res_pickup_shop FOREIGN KEY (pickup_shop_id) REFERENCES rental_shops(shop_id) ON DELETE SET NULL,
    CONSTRAINT fk_res_dropoff_shop FOREIGN KEY (dropoff_shop_id) REFERENCES rental_shops(shop_id) ON DELETE SET NULL
);

-- 3-7. 결제 (payments)
CREATE TABLE payments (
    payment_id      NUMBER PRIMARY KEY,
    reservation_id  NUMBER NOT NULL,
    amount          NUMBER NOT NULL,
    payment_method  VARCHAR2(50) NOT NULL,
    payment_status  VARCHAR2(50) DEFAULT 'PAID', -- PAID, REFUNDED
    paid_at         DATE DEFAULT SYSDATE NOT NULL,
    refund_amount   NUMBER DEFAULT 0,
    CONSTRAINT fk_pay_res FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) ON DELETE CASCADE
);

-- 3-8. 쿠폰 (coupons)
CREATE TABLE coupons (
    coupon_id       NUMBER PRIMARY KEY,
    user_id         NUMBER NOT NULL,
    coupon_name     VARCHAR2(200) NOT NULL,
    discount_amount NUMBER NOT NULL,
    issue_date      DATE DEFAULT SYSDATE NOT NULL,
    expire_date     DATE NOT NULL,
    status          VARCHAR2(50) DEFAULT 'UNUSED', -- UNUSED, USED, EXPIRED
    CONSTRAINT fk_coupon_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 3-9. 리뷰 (reviews)
CREATE TABLE reviews (
    review_id       NUMBER PRIMARY KEY,
    user_id         NUMBER NOT NULL,
    reservation_id  NUMBER NOT NULL,
    bike_id         NUMBER NOT NULL,
    rating          NUMBER(1) NOT NULL,
    title           VARCHAR2(200),
    content         CLOB,
    created_at      DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_rev_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_rev_res FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) ON DELETE CASCADE,
    CONSTRAINT fk_rev_bike FOREIGN KEY (bike_id) REFERENCES motorcycles(bike_id) ON DELETE CASCADE
);

-- 3-10. 1:1 문의 (inquiries)
CREATE TABLE inquiries (
    inquiry_id      NUMBER PRIMARY KEY,
    user_id         NUMBER NOT NULL,
    title           VARCHAR2(300) NOT NULL,
    content         CLOB NOT NULL,
    answer_content  CLOB,
    status          VARCHAR2(50) DEFAULT 'PENDING', -- PENDING, ANSWERED
    created_at      DATE DEFAULT SYSDATE NOT NULL,
    answered_at     DATE,
    CONSTRAINT fk_inq_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 3-11. 게시판 (boards)
CREATE TABLE boards (
    board_id    NUMBER PRIMARY KEY,
    user_id     NUMBER NOT NULL,
    category    VARCHAR2(50) NOT NULL, -- FREE, REVIEW, NOTICE 등
    title       VARCHAR2(300) NOT NULL,
    content     CLOB NOT NULL,
    view_count  NUMBER DEFAULT 0,
    like_count  NUMBER DEFAULT 0,
    created_at  DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_brd_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 3-12. 댓글 (comments)
CREATE TABLE comments (
    comment_id  NUMBER PRIMARY KEY,
    board_id    NUMBER NOT NULL,
    user_id     NUMBER NOT NULL,
    content     CLOB NOT NULL,
    created_at  DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_cmt_board FOREIGN KEY (board_id) REFERENCES boards(board_id) ON DELETE CASCADE,
    CONSTRAINT fk_cmt_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 3-13. 옵션 장비 (option_items)
CREATE TABLE option_items (
    option_id       NUMBER PRIMARY KEY,
    option_name     VARCHAR2(200) NOT NULL,
    stock_quantity  NUMBER DEFAULT 0,
    daily_price     NUMBER NOT NULL,
    image_filename  VARCHAR2(500),
    status          VARCHAR2(50) DEFAULT 'AVAILABLE'
);

-- 3-14. 예약별 선택 옵션 (booking_options)
CREATE TABLE booking_options (
    booking_option_id NUMBER PRIMARY KEY,
    reservation_id    NUMBER NOT NULL,
    option_id         NUMBER NOT NULL,
    quantity          NUMBER DEFAULT 1,
    daily_price       NUMBER NOT NULL,
    CONSTRAINT fk_bo_res FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) ON DELETE CASCADE,
    CONSTRAINT fk_bo_opt FOREIGN KEY (option_id) REFERENCES option_items(option_id) ON DELETE CASCADE
);

-- 3-15. 패널티 (penalties)
CREATE TABLE penalties (
    penalty_id      NUMBER PRIMARY KEY,
    reservation_id  NUMBER NOT NULL,
    user_id         NUMBER NOT NULL,
    penalty_type    VARCHAR2(100) NOT NULL, -- '지연', '파손', '과태료', '주유량미달' 등
    amount          NUMBER NOT NULL,
    is_paid         CHAR(1) DEFAULT 'N', -- Y/N
    reason          VARCHAR2(1000),
    created_at      DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT fk_pen_res FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) ON DELETE CASCADE,
    CONSTRAINT fk_pen_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


-- =====================================================
-- 4. 기초 샘플 데이터 삽입
-- =====================================================

-- 4-1. 제조사 등록
INSERT INTO brands (brand_id, brand_name, country, description)
VALUES (seq_brands.NEXTVAL, 'Honda', 'Japan', '세계 최대의 이륜차 제조업체로, 높은 내구성과 신뢰성을 자랑합니다.');

INSERT INTO brands (brand_id, brand_name, country, description)
VALUES (seq_brands.NEXTVAL, 'Yamaha', 'Japan', '독창적인 기술력과 뛰어난 디자인, 스포티한 주행 감각이 돋보이는 브랜드입니다.');

INSERT INTO brands (brand_id, brand_name, country, description)
VALUES (seq_brands.NEXTVAL, 'BMW Motorrad', 'Germany', '장거리 투어러 및 고배기량 스포츠 바이크의 명가입니다.');

-- 4-2. 렌탈 지점 등록
INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time)
VALUES (seq_rental_shops.NEXTVAL, '대구 중앙 지점', '김철수', '053-123-4567', '대구 중구 달구벌대로 123', '09:00', '20:00');

INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time)
VALUES (seq_rental_shops.NEXTVAL, '대구 동대구역 지점', '이영희', '053-987-6543', '대구 동구 동대구로 456', '09:00', '21:00');

INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time)
VALUES (seq_rental_shops.NEXTVAL, '대구 수성못 지점', '박민수', '053-765-4321', '대구 수성구 수성못길 789', '09:00', '22:00');

INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time)
VALUES (seq_rental_shops.NEXTVAL, '대구 계명대 지점', '최진혁', '053-580-1234', '대구 달서구 달구벌대로 1000', '09:00', '20:00');

INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time)
VALUES (seq_rental_shops.NEXTVAL, '대구 엑스코 지점', '정수빈', '053-601-5678', '대구 북구 유통단지로 789', '09:00', '20:00');

INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time)
VALUES (seq_rental_shops.NEXTVAL, '대구 칠곡 지점', '강진우', '053-321-4567', '대구 북구 태전로 123', '09:00', '20:00');

INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time)
VALUES (seq_rental_shops.NEXTVAL, '대구 상인 지점', '윤지아', '053-643-9876', '대구 달서구 월배로 456', '09:00', '21:00');

INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time)
VALUES (seq_rental_shops.NEXTVAL, '대구 현풍 지점', '오태양', '053-611-3456', '대구 달성군 테크노중앙대로 789', '09:00', '20:00');

INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time)
VALUES (seq_rental_shops.NEXTVAL, '대구 경북대 지점', '한소희', '053-950-1234', '대구 북구 대학로 80', '09:00', '22:00');

-- 4-3. 회원 등록 (패스워드는 평문 보관 테스트용 또는 해싱 예정)
INSERT INTO users (user_id, email, password, name, phone, birth_date, license_number, role, point, join_date)
VALUES (101, 'admin@baren.com', 'admin123', '최고관리자', '010-1111-2222', TO_DATE('1990-01-01', 'YYYY-MM-DD'), '11-12-345678-01', 'ADMIN', 1000, SYSDATE);

INSERT INTO users (user_id, email, password, name, phone, birth_date, license_number, role, point, join_date)
VALUES (102, 'user1@test.com', 'pass1234', '홍길동', '010-3333-4444', TO_DATE('1995-05-15', 'YYYY-MM-DD'), '22-12-987654-02', 'USER', 100, SYSDATE);

-- 4-4. 바이크 및 이미지 등록 (9개 지점 * 9종 모델 = 81대)
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (1, 1, 1, 'PCX 125', 125, 2023, 'Pearl White', 45000, 0, 'AVAILABLE', '도심 주행의 최강자이자 연비와 내구성 모두를 만족시키는 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 1, 'resources/images/bikes/scooter_pcx.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (2, 2, 1, 'YZF-R3', 321, 2022, 'Icon Blue', 80000, 0, 'AVAILABLE', '입문용 쿼터급 최고의 스포츠 바이크입니다. 가볍고 민첩한 핸들링이 돋보입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 2, 'resources/images/bikes/sports_r3.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (3, 1, 1, 'Super Cub 110', 109, 2023, 'Classic Yellow', 35000, 0, 'AVAILABLE', '클래식한 디자인과 최고의 실용성을 겸비한 110cc 언더본 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 3, 'resources/images/bikes/classic_cub.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (4, 1, 1, 'CBR500R', 471, 2022, 'Grand Prix Red', 100000, 0, 'AVAILABLE', '스포티한 레이싱 룩과 일상 주행의 편안함을 모두 잡은 미들급 스포츠 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 4, 'resources/images/bikes/sports_cbr500r.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (5, 2, 1, 'MT-03', 321, 2023, 'Midnight Black', 85000, 0, 'AVAILABLE', '날렵하고 다이내믹한 주행성능을 선사하는 쿼터급 대표 네이키드 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 5, 'resources/images/bikes/naked_mt03.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (6, 1, 1, 'ADV350', 330, 2023, 'Spangle Silver Metallic', 90000, 0, 'AVAILABLE', '스마트한 주행 성능과 모험 심리를 자극하는 350cc 어드벤처 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 6, 'resources/images/bikes/scooter_adv350.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (7, 1, 1, 'C125', 125, 2023, 'Niltava Blue', 40000, 0, 'AVAILABLE', '초대 슈퍼커브의 오리지널 헤리티지를 계승한 프리미엄 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 7, 'resources/images/bikes/classic_c125.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (8, 3, 1, 'R nineT', 1170, 2022, 'Black Storm Metallic', 200000, 0, 'AVAILABLE', '클래식한 룩과 강력한 박서 엔진의 매력을 선사하는 프리미엄 로드스터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 8, 'resources/images/bikes/naked_rninet.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (9, 2, 1, 'YZF-R1', 998, 2023, 'Yamaha Black', 250000, 0, 'AVAILABLE', '야마하의 레이싱 기술이 총집약된 플래그십 리터급 슈퍼스포츠 머신입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 9, 'resources/images/bikes/sports_r1.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (10, 1, 2, 'PCX 125', 125, 2023, 'Pearl White', 45000, 0, 'AVAILABLE', '도심 주행의 최강자이자 연비와 내구성 모두를 만족시키는 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 10, 'resources/images/bikes/scooter_pcx.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (11, 2, 2, 'YZF-R3', 321, 2022, 'Icon Blue', 80000, 0, 'AVAILABLE', '입문용 쿼터급 최고의 스포츠 바이크입니다. 가볍고 민첩한 핸들링이 돋보입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 11, 'resources/images/bikes/sports_r3.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (12, 1, 2, 'Super Cub 110', 109, 2023, 'Classic Yellow', 35000, 0, 'AVAILABLE', '클래식한 디자인과 최고의 실용성을 겸비한 110cc 언더본 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 12, 'resources/images/bikes/classic_cub.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (13, 1, 2, 'CBR500R', 471, 2022, 'Grand Prix Red', 100000, 0, 'AVAILABLE', '스포티한 레이싱 룩과 일상 주행의 편안함을 모두 잡은 미들급 스포츠 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 13, 'resources/images/bikes/sports_cbr500r.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (14, 2, 2, 'MT-03', 321, 2023, 'Midnight Black', 85000, 0, 'AVAILABLE', '날렵하고 다이내믹한 주행성능을 선사하는 쿼터급 대표 네이키드 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 14, 'resources/images/bikes/naked_mt03.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (15, 1, 2, 'ADV350', 330, 2023, 'Spangle Silver Metallic', 90000, 0, 'AVAILABLE', '스마트한 주행 성능과 모험 심리를 자극하는 350cc 어드벤처 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 15, 'resources/images/bikes/scooter_adv350.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (16, 1, 2, 'C125', 125, 2023, 'Niltava Blue', 40000, 0, 'AVAILABLE', '초대 슈퍼커브의 오리지널 헤리티지를 계승한 프리미엄 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 16, 'resources/images/bikes/classic_c125.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (17, 3, 2, 'R nineT', 1170, 2022, 'Black Storm Metallic', 200000, 0, 'AVAILABLE', '클래식한 룩과 강력한 박서 엔진의 매력을 선사하는 프리미엄 로드스터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 17, 'resources/images/bikes/naked_rninet.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (18, 2, 2, 'YZF-R1', 998, 2023, 'Yamaha Black', 250000, 0, 'AVAILABLE', '야마하의 레이싱 기술이 총집약된 플래그십 리터급 슈퍼스포츠 머신입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 18, 'resources/images/bikes/sports_r1.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (19, 1, 3, 'PCX 125', 125, 2023, 'Pearl White', 45000, 0, 'AVAILABLE', '도심 주행의 최강자이자 연비와 내구성 모두를 만족시키는 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 19, 'resources/images/bikes/scooter_pcx.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (20, 2, 3, 'YZF-R3', 321, 2022, 'Icon Blue', 80000, 0, 'AVAILABLE', '입문용 쿼터급 최고의 스포츠 바이크입니다. 가볍고 민첩한 핸들링이 돋보입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 20, 'resources/images/bikes/sports_r3.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (21, 1, 3, 'Super Cub 110', 109, 2023, 'Classic Yellow', 35000, 0, 'AVAILABLE', '클래식한 디자인과 최고의 실용성을 겸비한 110cc 언더본 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 21, 'resources/images/bikes/classic_cub.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (22, 1, 3, 'CBR500R', 471, 2022, 'Grand Prix Red', 100000, 0, 'AVAILABLE', '스포티한 레이싱 룩과 일상 주행의 편안함을 모두 잡은 미들급 스포츠 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 22, 'resources/images/bikes/sports_cbr500r.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (23, 2, 3, 'MT-03', 321, 2023, 'Midnight Black', 85000, 0, 'AVAILABLE', '날렵하고 다이내믹한 주행성능을 선사하는 쿼터급 대표 네이키드 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 23, 'resources/images/bikes/naked_mt03.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (24, 1, 3, 'ADV350', 330, 2023, 'Spangle Silver Metallic', 90000, 0, 'AVAILABLE', '스마트한 주행 성능과 모험 심리를 자극하는 350cc 어드벤처 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 24, 'resources/images/bikes/scooter_adv350.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (25, 1, 3, 'C125', 125, 2023, 'Niltava Blue', 40000, 0, 'AVAILABLE', '초대 슈퍼커브의 오리지널 헤리티지를 계승한 프리미엄 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 25, 'resources/images/bikes/classic_c125.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (26, 3, 3, 'R nineT', 1170, 2022, 'Black Storm Metallic', 200000, 0, 'AVAILABLE', '클래식한 룩과 강력한 박서 엔진의 매력을 선사하는 프리미엄 로드스터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 26, 'resources/images/bikes/naked_rninet.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (27, 2, 3, 'YZF-R1', 998, 2023, 'Yamaha Black', 250000, 0, 'AVAILABLE', '야마하의 레이싱 기술이 총집약된 플래그십 리터급 슈퍼스포츠 머신입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 27, 'resources/images/bikes/sports_r1.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (28, 1, 4, 'PCX 125', 125, 2023, 'Pearl White', 45000, 0, 'AVAILABLE', '도심 주행의 최강자이자 연비와 내구성 모두를 만족시키는 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 28, 'resources/images/bikes/scooter_pcx.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (29, 2, 4, 'YZF-R3', 321, 2022, 'Icon Blue', 80000, 0, 'AVAILABLE', '입문용 쿼터급 최고의 스포츠 바이크입니다. 가볍고 민첩한 핸들링이 돋보입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 29, 'resources/images/bikes/sports_r3.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (30, 1, 4, 'Super Cub 110', 109, 2023, 'Classic Yellow', 35000, 0, 'AVAILABLE', '클래식한 디자인과 최고의 실용성을 겸비한 110cc 언더본 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 30, 'resources/images/bikes/classic_cub.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (31, 1, 4, 'CBR500R', 471, 2022, 'Grand Prix Red', 100000, 0, 'AVAILABLE', '스포티한 레이싱 룩과 일상 주행의 편안함을 모두 잡은 미들급 스포츠 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 31, 'resources/images/bikes/sports_cbr500r.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (32, 2, 4, 'MT-03', 321, 2023, 'Midnight Black', 85000, 0, 'AVAILABLE', '날렵하고 다이내믹한 주행성능을 선사하는 쿼터급 대표 네이키드 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 32, 'resources/images/bikes/naked_mt03.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (33, 1, 4, 'ADV350', 330, 2023, 'Spangle Silver Metallic', 90000, 0, 'AVAILABLE', '스마트한 주행 성능과 모험 심리를 자극하는 350cc 어드벤처 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 33, 'resources/images/bikes/scooter_adv350.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (34, 1, 4, 'C125', 125, 2023, 'Niltava Blue', 40000, 0, 'AVAILABLE', '초대 슈퍼커브의 오리지널 헤리티지를 계승한 프리미엄 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 34, 'resources/images/bikes/classic_c125.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (35, 3, 4, 'R nineT', 1170, 2022, 'Black Storm Metallic', 200000, 0, 'AVAILABLE', '클래식한 룩과 강력한 박서 엔진의 매력을 선사하는 프리미엄 로드스터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 35, 'resources/images/bikes/naked_rninet.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (36, 2, 4, 'YZF-R1', 998, 2023, 'Yamaha Black', 250000, 0, 'AVAILABLE', '야마하의 레이싱 기술이 총집약된 플래그십 리터급 슈퍼스포츠 머신입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 36, 'resources/images/bikes/sports_r1.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (37, 1, 5, 'PCX 125', 125, 2023, 'Pearl White', 45000, 0, 'AVAILABLE', '도심 주행의 최강자이자 연비와 내구성 모두를 만족시키는 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 37, 'resources/images/bikes/scooter_pcx.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (38, 2, 5, 'YZF-R3', 321, 2022, 'Icon Blue', 80000, 0, 'AVAILABLE', '입문용 쿼터급 최고의 스포츠 바이크입니다. 가볍고 민첩한 핸들링이 돋보입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 38, 'resources/images/bikes/sports_r3.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (39, 1, 5, 'Super Cub 110', 109, 2023, 'Classic Yellow', 35000, 0, 'AVAILABLE', '클래식한 디자인과 최고의 실용성을 겸비한 110cc 언더본 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 39, 'resources/images/bikes/classic_cub.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (40, 1, 5, 'CBR500R', 471, 2022, 'Grand Prix Red', 100000, 0, 'AVAILABLE', '스포티한 레이싱 룩과 일상 주행의 편안함을 모두 잡은 미들급 스포츠 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 40, 'resources/images/bikes/sports_cbr500r.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (41, 2, 5, 'MT-03', 321, 2023, 'Midnight Black', 85000, 0, 'AVAILABLE', '날렵하고 다이내믹한 주행성능을 선사하는 쿼터급 대표 네이키드 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 41, 'resources/images/bikes/naked_mt03.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (42, 1, 5, 'ADV350', 330, 2023, 'Spangle Silver Metallic', 90000, 0, 'AVAILABLE', '스마트한 주행 성능과 모험 심리를 자극하는 350cc 어드벤처 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 42, 'resources/images/bikes/scooter_adv350.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (43, 1, 5, 'C125', 125, 2023, 'Niltava Blue', 40000, 0, 'AVAILABLE', '초대 슈퍼커브의 오리지널 헤리티지를 계승한 프리미엄 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 43, 'resources/images/bikes/classic_c125.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (44, 3, 5, 'R nineT', 1170, 2022, 'Black Storm Metallic', 200000, 0, 'AVAILABLE', '클래식한 룩과 강력한 박서 엔진의 매력을 선사하는 프리미엄 로드스터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 44, 'resources/images/bikes/naked_rninet.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (45, 2, 5, 'YZF-R1', 998, 2023, 'Yamaha Black', 250000, 0, 'AVAILABLE', '야마하의 레이싱 기술이 총집약된 플래그십 리터급 슈퍼스포츠 머신입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 45, 'resources/images/bikes/sports_r1.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (46, 1, 6, 'PCX 125', 125, 2023, 'Pearl White', 45000, 0, 'AVAILABLE', '도심 주행의 최강자이자 연비와 내구성 모두를 만족시키는 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 46, 'resources/images/bikes/scooter_pcx.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (47, 2, 6, 'YZF-R3', 321, 2022, 'Icon Blue', 80000, 0, 'AVAILABLE', '입문용 쿼터급 최고의 스포츠 바이크입니다. 가볍고 민첩한 핸들링이 돋보입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 47, 'resources/images/bikes/sports_r3.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (48, 1, 6, 'Super Cub 110', 109, 2023, 'Classic Yellow', 35000, 0, 'AVAILABLE', '클래식한 디자인과 최고의 실용성을 겸비한 110cc 언더본 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 48, 'resources/images/bikes/classic_cub.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (49, 1, 6, 'CBR500R', 471, 2022, 'Grand Prix Red', 100000, 0, 'AVAILABLE', '스포티한 레이싱 룩과 일상 주행의 편안함을 모두 잡은 미들급 스포츠 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 49, 'resources/images/bikes/sports_cbr500r.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (50, 2, 6, 'MT-03', 321, 2023, 'Midnight Black', 85000, 0, 'AVAILABLE', '날렵하고 다이내믹한 주행성능을 선사하는 쿼터급 대표 네이키드 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 50, 'resources/images/bikes/naked_mt03.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (51, 1, 6, 'ADV350', 330, 2023, 'Spangle Silver Metallic', 90000, 0, 'AVAILABLE', '스마트한 주행 성능과 모험 심리를 자극하는 350cc 어드벤처 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 51, 'resources/images/bikes/scooter_adv350.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (52, 1, 6, 'C125', 125, 2023, 'Niltava Blue', 40000, 0, 'AVAILABLE', '초대 슈퍼커브의 오리지널 헤리티지를 계승한 프리미엄 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 52, 'resources/images/bikes/classic_c125.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (53, 3, 6, 'R nineT', 1170, 2022, 'Black Storm Metallic', 200000, 0, 'AVAILABLE', '클래식한 룩과 강력한 박서 엔진의 매력을 선사하는 프리미엄 로드스터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 53, 'resources/images/bikes/naked_rninet.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (54, 2, 6, 'YZF-R1', 998, 2023, 'Yamaha Black', 250000, 0, 'AVAILABLE', '야마하의 레이싱 기술이 총집약된 플래그십 리터급 슈퍼스포츠 머신입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 54, 'resources/images/bikes/sports_r1.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (55, 1, 7, 'PCX 125', 125, 2023, 'Pearl White', 45000, 0, 'AVAILABLE', '도심 주행의 최강자이자 연비와 내구성 모두를 만족시키는 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 55, 'resources/images/bikes/scooter_pcx.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (56, 2, 7, 'YZF-R3', 321, 2022, 'Icon Blue', 80000, 0, 'AVAILABLE', '입문용 쿼터급 최고의 스포츠 바이크입니다. 가볍고 민첩한 핸들링이 돋보입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 56, 'resources/images/bikes/sports_r3.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (57, 1, 7, 'Super Cub 110', 109, 2023, 'Classic Yellow', 35000, 0, 'AVAILABLE', '클래식한 디자인과 최고의 실용성을 겸비한 110cc 언더본 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 57, 'resources/images/bikes/classic_cub.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (58, 1, 7, 'CBR500R', 471, 2022, 'Grand Prix Red', 100000, 0, 'AVAILABLE', '스포티한 레이싱 룩과 일상 주행의 편안함을 모두 잡은 미들급 스포츠 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 58, 'resources/images/bikes/sports_cbr500r.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (59, 2, 7, 'MT-03', 321, 2023, 'Midnight Black', 85000, 0, 'AVAILABLE', '날렵하고 다이내믹한 주행성능을 선사하는 쿼터급 대표 네이키드 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 59, 'resources/images/bikes/naked_mt03.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (60, 1, 7, 'ADV350', 330, 2023, 'Spangle Silver Metallic', 90000, 0, 'AVAILABLE', '스마트한 주행 성능과 모험 심리를 자극하는 350cc 어드벤처 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 60, 'resources/images/bikes/scooter_adv350.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (61, 1, 7, 'C125', 125, 2023, 'Niltava Blue', 40000, 0, 'AVAILABLE', '초대 슈퍼커브의 오리지널 헤리티지를 계승한 프리미엄 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 61, 'resources/images/bikes/classic_c125.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (62, 3, 7, 'R nineT', 1170, 2022, 'Black Storm Metallic', 200000, 0, 'AVAILABLE', '클래식한 룩과 강력한 박서 엔진의 매력을 선사하는 프리미엄 로드스터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 62, 'resources/images/bikes/naked_rninet.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (63, 2, 7, 'YZF-R1', 998, 2023, 'Yamaha Black', 250000, 0, 'AVAILABLE', '야마하의 레이싱 기술이 총집약된 플래그십 리터급 슈퍼스포츠 머신입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 63, 'resources/images/bikes/sports_r1.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (64, 1, 8, 'PCX 125', 125, 2023, 'Pearl White', 45000, 0, 'AVAILABLE', '도심 주행의 최강자이자 연비와 내구성 모두를 만족시키는 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 64, 'resources/images/bikes/scooter_pcx.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (65, 2, 8, 'YZF-R3', 321, 2022, 'Icon Blue', 80000, 0, 'AVAILABLE', '입문용 쿼터급 최고의 스포츠 바이크입니다. 가볍고 민첩한 핸들링이 돋보입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 65, 'resources/images/bikes/sports_r3.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (66, 1, 8, 'Super Cub 110', 109, 2023, 'Classic Yellow', 35000, 0, 'AVAILABLE', '클래식한 디자인과 최고의 실용성을 겸비한 110cc 언더본 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 66, 'resources/images/bikes/classic_cub.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (67, 1, 8, 'CBR500R', 471, 2022, 'Grand Prix Red', 100000, 0, 'AVAILABLE', '스포티한 레이싱 룩과 일상 주행의 편안함을 모두 잡은 미들급 스포츠 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 67, 'resources/images/bikes/sports_cbr500r.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (68, 2, 8, 'MT-03', 321, 2023, 'Midnight Black', 85000, 0, 'AVAILABLE', '날렵하고 다이내믹한 주행성능을 선사하는 쿼터급 대표 네이키드 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 68, 'resources/images/bikes/naked_mt03.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (69, 1, 8, 'ADV350', 330, 2023, 'Spangle Silver Metallic', 90000, 0, 'AVAILABLE', '스마트한 주행 성능과 모험 심리를 자극하는 350cc 어드벤처 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 69, 'resources/images/bikes/scooter_adv350.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (70, 1, 8, 'C125', 125, 2023, 'Niltava Blue', 40000, 0, 'AVAILABLE', '초대 슈퍼커브의 오리지널 헤리티지를 계승한 프리미엄 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 70, 'resources/images/bikes/classic_c125.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (71, 3, 8, 'R nineT', 1170, 2022, 'Black Storm Metallic', 200000, 0, 'AVAILABLE', '클래식한 룩과 강력한 박서 엔진의 매력을 선사하는 프리미엄 로드스터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 71, 'resources/images/bikes/naked_rninet.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (72, 2, 8, 'YZF-R1', 998, 2023, 'Yamaha Black', 250000, 0, 'AVAILABLE', '야마하의 레이싱 기술이 총집약된 플래그십 리터급 슈퍼스포츠 머신입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 72, 'resources/images/bikes/sports_r1.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (73, 1, 9, 'PCX 125', 125, 2023, 'Pearl White', 45000, 0, 'AVAILABLE', '도심 주행의 최강자이자 연비와 내구성 모두를 만족시키는 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 73, 'resources/images/bikes/scooter_pcx.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (74, 2, 9, 'YZF-R3', 321, 2022, 'Icon Blue', 80000, 0, 'AVAILABLE', '입문용 쿼터급 최고의 스포츠 바이크입니다. 가볍고 민첩한 핸들링이 돋보입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 74, 'resources/images/bikes/sports_r3.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (75, 1, 9, 'Super Cub 110', 109, 2023, 'Classic Yellow', 35000, 0, 'AVAILABLE', '클래식한 디자인과 최고의 실용성을 겸비한 110cc 언더본 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 75, 'resources/images/bikes/classic_cub.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (76, 1, 9, 'CBR500R', 471, 2022, 'Grand Prix Red', 100000, 0, 'AVAILABLE', '스포티한 레이싱 룩과 일상 주행의 편안함을 모두 잡은 미들급 스포츠 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 76, 'resources/images/bikes/sports_cbr500r.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (77, 2, 9, 'MT-03', 321, 2023, 'Midnight Black', 85000, 0, 'AVAILABLE', '날렵하고 다이내믹한 주행성능을 선사하는 쿼터급 대표 네이키드 바이크입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 77, 'resources/images/bikes/naked_mt03.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (78, 1, 9, 'ADV350', 330, 2023, 'Spangle Silver Metallic', 90000, 0, 'AVAILABLE', '스마트한 주행 성능과 모험 심리를 자극하는 350cc 어드벤처 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 78, 'resources/images/bikes/scooter_adv350.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (79, 1, 9, 'C125', 125, 2023, 'Niltava Blue', 40000, 0, 'AVAILABLE', '초대 슈퍼커브의 오리지널 헤리티지를 계승한 프리미엄 125cc 스쿠터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 79, 'resources/images/bikes/classic_c125.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (80, 3, 9, 'R nineT', 1170, 2022, 'Black Storm Metallic', 200000, 0, 'AVAILABLE', '클래식한 룩과 강력한 박서 엔진의 매력을 선사하는 프리미엄 로드스터입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 80, 'resources/images/bikes/naked_rninet.png', 'Y');
INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) VALUES (81, 2, 9, 'YZF-R1', 998, 2023, 'Yamaha Black', 250000, 0, 'AVAILABLE', '야마하의 레이싱 기술이 총집약된 플래그십 리터급 슈퍼스포츠 머신입니다.');
INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, 81, 'resources/images/bikes/sports_r1.png', 'Y');


-- 4-6. 옵션 장비 등록
INSERT INTO option_items (option_id, option_name, stock_quantity, daily_price, image_filename, status)
VALUES (seq_option_items.NEXTVAL, '⛑️ 홍진 HJC 오픈페이스 헬멧', 50, 5000, 'helmet_hjc.png', 'AVAILABLE');

INSERT INTO option_items (option_id, option_name, stock_quantity, daily_price, image_filename, status)
VALUES (seq_option_items.NEXTVAL, '🛜 세나 50S 블루투스 인터콤', 30, 7000, 'sena_50s.png', 'AVAILABLE');

INSERT INTO option_items (option_id, option_name, stock_quantity, daily_price, image_filename, status)
VALUES (seq_option_items.NEXTVAL, '📦 알루미늄 대용량 탑박스', 20, 4000, 'topbox.png', 'AVAILABLE');

INSERT INTO option_items (option_id, option_name, stock_quantity, daily_price, image_filename, status)
VALUES (seq_option_items.NEXTVAL, '📱 초고속 자석 스마트폰 거치대', 40, 2000, 'phone_holder.png', 'AVAILABLE');

INSERT INTO option_items (option_id, option_name, stock_quantity, daily_price, image_filename, status)
VALUES (seq_option_items.NEXTVAL, '🛡️ 프리미엄 무릎 및 팔꿈치 보호대', 25, 3000, 'protectors.png', 'AVAILABLE');

-- 4-7. 예약 등록
INSERT INTO reservations (reservation_id, user_id, bike_id, pickup_shop_id, dropoff_shop_id, start_date, end_date, rental_days, total_price, status, created_at)
VALUES (
    1001, 
    102, -- 홍길동
    1,   -- PCX 125
    1,   -- 대구 중앙 지점
    2,   -- 대구 동대구역 지점
    TO_DATE('2026-06-20', 'YYYY-MM-DD'), 
    TO_DATE('2026-06-22', 'YYYY-MM-DD'), 
    2, 
    90000, 
    'APPROVED', 
    SYSDATE
);

-- 4-8. 결제 등록
INSERT INTO payments (payment_id, reservation_id, amount, payment_method, payment_status, paid_at)
VALUES (seq_payments.NEXTVAL, 1001, 90000, 'CARD', 'PAID', SYSDATE);

-- 4-9. 예약 옵션 매핑 등록
INSERT INTO booking_options (booking_option_id, reservation_id, option_id, quantity, daily_price)
VALUES (seq_booking_options.NEXTVAL, 1001, 1, 1, 5000);

-- 4-10. 패널티 등록 샘플
INSERT INTO penalties (penalty_id, reservation_id, user_id, penalty_type, amount, is_paid, reason, created_at)
VALUES (seq_penalties.NEXTVAL, 1001, 102, '과태료', 50000, 'N', '신천대로 속도 위반 과태료 고지서 발부', SYSDATE);

-- 4-8. 게시판 등록 (category: FREE, REVIEW, NOTICE)
INSERT INTO boards (board_id, user_id, category, title, content, view_count, like_count, created_at)
VALUES (
    seq_boards.NEXTVAL, 
    101, 
    'NOTICE', 
    'Baren 오토바이 렌탈 서비스 오픈 공지', 
    '안녕하세요. 프리미엄 모터사이클 렌탈 전문 Baren 사이트가 정식 오픈했습니다. 대구 중앙 지점(중구 달구벌대로 123), 동대구역 지점(동구 동대구로 456), 수성못 지점(수성구 수성못길 789), 계명대 지점(달서구 달구벌대로 1000), 엑스코 지점(북구 유통단지로 789), 칠곡 지점(북구 태전로 123), 상인 지점(달서구 월배로 456), 현풍 지점(달성군 테크노중앙대로 789), 경북대 지점(북구 대학로 80) 등 대구 전역 지점에서 예약하실 수 있습니다.', 
    12, 
    5, 
    SYSDATE
);

INSERT INTO boards (board_id, user_id, category, title, content, view_count, like_count, created_at)
VALUES (
    seq_boards.NEXTVAL, 
    102, 
    'REVIEW', 
    'PCX 125 대구 중앙점 대여 후기입니다.', 
    'PCX 신형 대여해서 강창역에서 달성보 방향으로 한 바퀴 돌고 왔는데 자전거 대여보다 훨씬 편리하고 주행성도 부드러웠습니다. 차량 외관 상태나 정비 상태도 정말 깔끔해서 감동했습니다. 다음에도 이용할게요.', 
    24, 
    8, 
    SYSDATE
);

-- 4-9. 댓글 등록
INSERT INTO comments (comment_id, board_id, user_id, content, created_at)
VALUES (seq_comments.NEXTVAL, 2, 101, '소중한 후기 감사드립니다! 앞으로도 안전하게 주행하실 수 있도록 최상의 상태로 정비하겠습니다.', SYSDATE);

COMMIT;
