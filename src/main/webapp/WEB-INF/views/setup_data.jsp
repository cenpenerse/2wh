<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.naming.*, javax.sql.DataSource" %>
<%
    Connection conn = null;
    Statement stmt = null;
    String resultMsg = "";
    
    // 1. 드롭 쿼리 목록
    String[] dropQueries = {
        "DROP TABLE comments CASCADE CONSTRAINTS",
        "DROP TABLE boards CASCADE CONSTRAINTS",
        "DROP TABLE inquiries CASCADE CONSTRAINTS",
        "DROP TABLE reviews CASCADE CONSTRAINTS",
        "DROP TABLE coupons CASCADE CONSTRAINTS",
        "DROP TABLE payments CASCADE CONSTRAINTS",
        "DROP TABLE penalties CASCADE CONSTRAINTS",
        "DROP TABLE booking_options CASCADE CONSTRAINTS",
        "DROP TABLE option_items CASCADE CONSTRAINTS",
        "DROP TABLE accident_reports CASCADE CONSTRAINTS",
        "DROP TABLE reservations CASCADE CONSTRAINTS",
        "DROP TABLE blacklist CASCADE CONSTRAINTS",
        "DROP TABLE point_history CASCADE CONSTRAINTS",
        "DROP TABLE users CASCADE CONSTRAINTS",
        "DROP TABLE bike_images CASCADE CONSTRAINTS",
        "DROP TABLE motorcycles CASCADE CONSTRAINTS",
        "DROP TABLE rental_shops CASCADE CONSTRAINTS",
        "DROP TABLE brands CASCADE CONSTRAINTS",
        "DROP TABLE license_audit CASCADE CONSTRAINTS",
        "DROP TABLE bike_maintenance CASCADE CONSTRAINTS",
        "DROP TABLE fuel_log CASCADE CONSTRAINTS",
        "DROP TABLE notifications CASCADE CONSTRAINTS",
        "DROP TABLE insurance_plans CASCADE CONSTRAINTS",
        "DROP TABLE refund_log CASCADE CONSTRAINTS",
        "DROP SEQUENCE seq_comments",
        "DROP SEQUENCE seq_boards",
        "DROP SEQUENCE seq_inquiries",
        "DROP SEQUENCE seq_reviews",
        "DROP SEQUENCE seq_coupons",
        "DROP SEQUENCE seq_payments",
        "DROP SEQUENCE seq_penalties",
        "DROP SEQUENCE seq_booking_options",
        "DROP SEQUENCE seq_option_items",
        "DROP SEQUENCE seq_reservations",
        "DROP SEQUENCE seq_users",
        "DROP SEQUENCE seq_bike_images",
        "DROP SEQUENCE seq_motorcycles",
        "DROP SEQUENCE seq_rental_shops",
        "DROP SEQUENCE seq_brands",
        "DROP SEQUENCE seq_license_audit",
        "DROP SEQUENCE seq_bike_maintenance",
        "DROP SEQUENCE seq_fuel_log",
        "DROP SEQUENCE seq_notifications",
        "DROP SEQUENCE seq_insurance_plans",
        "DROP SEQUENCE seq_accident_reports",
        "DROP SEQUENCE seq_blacklist",
        "DROP SEQUENCE seq_point_history",
        "DROP SEQUENCE seq_refund_log"
    };

    // 2. 생성 쿼리 목록 (시퀀스 및 테이블)
    String[] createQueries = {
        "CREATE SEQUENCE seq_brands START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_rental_shops START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_motorcycles START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_bike_images START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_users START WITH 100 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_reservations START WITH 1010 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_payments START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_penalties START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_option_items START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_booking_options START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_coupons START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_reviews START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_inquiries START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_boards START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_comments START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_license_audit START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_bike_maintenance START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_fuel_log START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_notifications START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_insurance_plans START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_accident_reports START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_blacklist START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_point_history START WITH 1 INCREMENT BY 1 NOCACHE",
        "CREATE SEQUENCE seq_refund_log START WITH 1 INCREMENT BY 1 NOCACHE",
        
        "CREATE TABLE brands ( brand_id NUMBER PRIMARY KEY, brand_name VARCHAR2(100) NOT NULL, country VARCHAR2(100), description CLOB )",
        "CREATE TABLE rental_shops ( shop_id NUMBER PRIMARY KEY, shop_name VARCHAR2(100) NOT NULL, manager_name VARCHAR2(100), tel VARCHAR2(30), address VARCHAR2(500), open_time VARCHAR2(10), close_time VARCHAR2(10), image_filename VARCHAR2(500) )",
        "CREATE TABLE motorcycles ( bike_id NUMBER PRIMARY KEY, brand_id NUMBER, shop_id NUMBER, model_name VARCHAR2(200) NOT NULL, cc NUMBER, year NUMBER(4), color VARCHAR2(50), daily_price NUMBER NOT NULL, mileage NUMBER DEFAULT 0, status VARCHAR2(50) DEFAULT 'AVAILABLE', description CLOB, CONSTRAINT fk_bike_brand FOREIGN KEY (brand_id) REFERENCES brands(brand_id) ON DELETE SET NULL, CONSTRAINT fk_bike_shop FOREIGN KEY (shop_id) REFERENCES rental_shops(shop_id) ON DELETE SET NULL )",
        "CREATE TABLE bike_images ( image_id NUMBER PRIMARY KEY, bike_id NUMBER NOT NULL, image_url VARCHAR2(512) NOT NULL, is_thumbnail CHAR(1) DEFAULT 'N', CONSTRAINT fk_img_bike FOREIGN KEY (bike_id) REFERENCES motorcycles(bike_id) ON DELETE CASCADE )",
        "CREATE TABLE users ( user_id NUMBER PRIMARY KEY, email VARCHAR2(100) NOT NULL UNIQUE, password VARCHAR2(255) NOT NULL, name VARCHAR2(100) NOT NULL, phone VARCHAR2(30), birth_date DATE, license_number VARCHAR2(100), license_status VARCHAR2(50) DEFAULT 'PENDING', role VARCHAR2(50) DEFAULT 'USER', point NUMBER DEFAULT 0, user_grade VARCHAR2(50) DEFAULT 'SILVER', join_date DATE DEFAULT SYSDATE NOT NULL )",
        "CREATE TABLE insurance_plans ( plan_id NUMBER PRIMARY KEY, plan_name VARCHAR2(100) NOT NULL, daily_fee NUMBER NOT NULL, deductible_limit NUMBER NOT NULL, coverage_limit NUMBER NOT NULL, terms_content CLOB )",
        "CREATE TABLE reservations ( reservation_id NUMBER PRIMARY KEY, user_id NUMBER NOT NULL, bike_id NUMBER NOT NULL, pickup_shop_id NUMBER, dropoff_shop_id NUMBER, start_date TIMESTAMP NOT NULL, end_date TIMESTAMP NOT NULL, rental_days NUMBER NOT NULL, total_price NUMBER NOT NULL, status VARCHAR2(50) DEFAULT 'PENDING', created_at DATE DEFAULT SYSDATE NOT NULL, insurance_id NUMBER, CONSTRAINT fk_res_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE, CONSTRAINT fk_res_bike FOREIGN KEY (bike_id) REFERENCES motorcycles(bike_id) ON DELETE CASCADE, CONSTRAINT fk_res_pickup_shop FOREIGN KEY (pickup_shop_id) REFERENCES rental_shops(shop_id) ON DELETE SET NULL, CONSTRAINT fk_res_dropoff_shop FOREIGN KEY (dropoff_shop_id) REFERENCES rental_shops(shop_id) ON DELETE SET NULL, CONSTRAINT fk_res_insurance FOREIGN KEY (insurance_id) REFERENCES insurance_plans(plan_id) ON DELETE SET NULL )",
        "CREATE TABLE payments ( payment_id NUMBER PRIMARY KEY, reservation_id NUMBER NOT NULL, amount NUMBER NOT NULL, payment_method VARCHAR2(50) NOT NULL, pg_approval_num VARCHAR2(100), payment_status VARCHAR2(50) DEFAULT '결제완료', paid_at TIMESTAMP DEFAULT SYSDATE NOT NULL, refund_amount NUMBER DEFAULT 0, CONSTRAINT fk_pay_res FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) ON DELETE CASCADE )",
        "CREATE TABLE coupons ( coupon_id NUMBER PRIMARY KEY, user_id NUMBER NOT NULL, coupon_name VARCHAR2(200) NOT NULL, discount_amount NUMBER NOT NULL, issue_date DATE DEFAULT SYSDATE NOT NULL, expire_date DATE NOT NULL, status VARCHAR2(50) DEFAULT 'UNUSED', CONSTRAINT fk_coupon_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE )",
        "CREATE TABLE reviews ( review_id NUMBER PRIMARY KEY, user_id NUMBER NOT NULL, reservation_id NUMBER NOT NULL, bike_id NUMBER NOT NULL, rating NUMBER(1) NOT NULL, title VARCHAR2(200), content CLOB, created_at DATE DEFAULT SYSDATE NOT NULL, CONSTRAINT fk_rev_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE, CONSTRAINT fk_rev_res FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) ON DELETE CASCADE, CONSTRAINT fk_rev_bike FOREIGN KEY (bike_id) REFERENCES motorcycles(bike_id) ON DELETE CASCADE )",
        "CREATE TABLE inquiries ( inquiry_id NUMBER PRIMARY KEY, user_id NUMBER NOT NULL, title VARCHAR2(300) NOT NULL, content CLOB NOT NULL, answer_content CLOB, status VARCHAR2(50) DEFAULT 'PENDING', created_at DATE DEFAULT SYSDATE NOT NULL, answered_at DATE, CONSTRAINT fk_inq_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE )",
        "CREATE TABLE boards ( board_id NUMBER PRIMARY KEY, user_id NUMBER NOT NULL, category VARCHAR2(50) NOT NULL, title VARCHAR2(300) NOT NULL, content CLOB NOT NULL, view_count NUMBER DEFAULT 0, like_count NUMBER DEFAULT 0, filename VARCHAR2(500), created_at DATE DEFAULT SYSDATE NOT NULL, CONSTRAINT fk_brd_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE )",
        "CREATE TABLE comments ( comment_id NUMBER PRIMARY KEY, board_id NUMBER NOT NULL, user_id NUMBER NOT NULL, content CLOB NOT NULL, created_at DATE DEFAULT SYSDATE NOT NULL, CONSTRAINT fk_cmt_board FOREIGN KEY (board_id) REFERENCES boards(board_id) ON DELETE CASCADE, CONSTRAINT fk_cmt_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE )",
        "CREATE TABLE option_items ( option_id NUMBER PRIMARY KEY, option_name VARCHAR2(200) NOT NULL, stock_quantity NUMBER DEFAULT 0, daily_price NUMBER NOT NULL, image_filename VARCHAR2(500), status VARCHAR2(50) DEFAULT 'AVAILABLE' )",
        "CREATE TABLE booking_options ( booking_option_id NUMBER PRIMARY KEY, reservation_id NUMBER NOT NULL, option_id NUMBER NOT NULL, quantity NUMBER DEFAULT 1, daily_price NUMBER NOT NULL, CONSTRAINT fk_bo_res FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) ON DELETE CASCADE, CONSTRAINT fk_bo_opt FOREIGN KEY (option_id) REFERENCES option_items(option_id) ON DELETE CASCADE )",
        "CREATE TABLE penalties ( penalty_id NUMBER PRIMARY KEY, reservation_id NUMBER NOT NULL, user_id NUMBER NOT NULL, penalty_type VARCHAR2(100) NOT NULL, amount NUMBER NOT NULL, is_paid CHAR(1) DEFAULT 'N', reason VARCHAR2(1000), created_at DATE DEFAULT SYSDATE NOT NULL, CONSTRAINT fk_pen_res FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) ON DELETE CASCADE, CONSTRAINT fk_pen_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE )",
        "CREATE TABLE license_audit ( audit_id NUMBER PRIMARY KEY, user_id NUMBER NOT NULL, license_type VARCHAR2(100), license_image VARCHAR2(500), status VARCHAR2(50) DEFAULT 'PENDING', reject_reason VARCHAR2(1000), audit_date DATE, admin_id NUMBER, CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE, CONSTRAINT fk_audit_admin FOREIGN KEY (admin_id) REFERENCES users(user_id) ON DELETE SET NULL )",
        "CREATE TABLE bike_maintenance ( maintenance_id NUMBER PRIMARY KEY, bike_id NUMBER NOT NULL, maintenance_date DATE NOT NULL, maintenance_type VARCHAR2(100), content CLOB, cost NUMBER, shop_name VARCHAR2(200), next_check_date DATE, CONSTRAINT fk_maint_bike FOREIGN KEY (bike_id) REFERENCES motorcycles(bike_id) ON DELETE CASCADE )",
        "CREATE TABLE fuel_log ( fuel_log_id NUMBER PRIMARY KEY, bike_id NUMBER NOT NULL, reservation_id NUMBER, fuel_level NUMBER, penalty_amount NUMBER, log_date DATE DEFAULT SYSDATE NOT NULL, CONSTRAINT fk_fuel_bike FOREIGN KEY (bike_id) REFERENCES motorcycles(bike_id) ON DELETE CASCADE, CONSTRAINT fk_fuel_res FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) ON DELETE SET NULL )",
        "CREATE TABLE notifications ( notification_id NUMBER PRIMARY KEY, user_id NUMBER NOT NULL, notification_type VARCHAR2(50) NOT NULL, content VARCHAR2(1000) NOT NULL, created_at TIMESTAMP DEFAULT SYSDATE NOT NULL, is_received CHAR(1) DEFAULT 'N', CONSTRAINT fk_noti_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE )",
        "CREATE TABLE accident_reports ( report_id NUMBER PRIMARY KEY, reservation_id NUMBER NOT NULL, user_id NUMBER NOT NULL, accident_date TIMESTAMP NOT NULL, accident_location VARCHAR2(500) NOT NULL, accident_description CLOB NOT NULL, photo_path VARCHAR2(500), insurance_claim_num VARCHAR2(100), fault_ratio NUMBER, status VARCHAR2(50) DEFAULT '접수', CONSTRAINT fk_ar_res FOREIGN KEY (reservation_id) REFERENCES reservations(reservation_id) ON DELETE CASCADE, CONSTRAINT fk_ar_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE )",
        "CREATE TABLE blacklist ( blacklist_id NUMBER PRIMARY KEY, user_id NUMBER NOT NULL, ban_type VARCHAR2(50) NOT NULL, reason VARCHAR2(1000) NOT NULL, start_date DATE DEFAULT SYSDATE NOT NULL, end_date DATE, admin_id NUMBER, CONSTRAINT fk_bl_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE, CONSTRAINT fk_bl_admin FOREIGN KEY (admin_id) REFERENCES users(user_id) ON DELETE SET NULL )",
        "CREATE TABLE point_history ( history_id NUMBER PRIMARY KEY, user_id NUMBER NOT NULL, amount NUMBER NOT NULL, reason VARCHAR2(500) NOT NULL, accumulated_points NUMBER NOT NULL, created_at TIMESTAMP DEFAULT SYSDATE NOT NULL, CONSTRAINT fk_ph_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE )",
        "CREATE TABLE refund_log ( refund_id NUMBER PRIMARY KEY, payment_id NUMBER NOT NULL, cancel_request_date TIMESTAMP DEFAULT SYSDATE NOT NULL, penalty_rate NUMBER NOT NULL, refund_amount NUMBER NOT NULL, refund_method VARCHAR2(50) NOT NULL, status VARCHAR2(50) DEFAULT '완료', CONSTRAINT fk_ref_pay FOREIGN KEY (payment_id) REFERENCES payments(payment_id) ON DELETE CASCADE )"
    };

    // 3. 테스트 데이터 삽입 쿼리 목록
    String[] insertQueries = {
        "INSERT INTO brands (brand_id, brand_name, country, description) VALUES (seq_brands.NEXTVAL, 'Honda', 'Japan', '세계 최대의 이륜차 제조업체로, 높은 내구성과 신뢰성을 자랑합니다.')",
        "INSERT INTO brands (brand_id, brand_name, country, description) VALUES (seq_brands.NEXTVAL, 'Yamaha', 'Japan', '독창적인 기술력과 뛰어난 디자인, 스포티한 주행 감각이 돋보이는 브랜드입니다.')",
        "INSERT INTO brands (brand_id, brand_name, country, description) VALUES (seq_brands.NEXTVAL, 'BMW', 'Germany', '장거리 투어러 및 고배기량 스포츠 바이크의 명가입니다.')",
        "INSERT INTO brands (brand_id, brand_name, country, description) VALUES (seq_brands.NEXTVAL, 'Harley-Davidson', 'USA', '클래식한 아메리칸 크루저 바이크의 상징적인 브랜드입니다.')",
        "INSERT INTO brands (brand_id, brand_name, country, description) VALUES (seq_brands.NEXTVAL, 'Vespa', 'Italy', '유려한 디자인과 감성을 겸비한 이탈리아 프리미엄 스쿠터 브랜드입니다.')",
        "INSERT INTO brands (brand_id, brand_name, country, description) VALUES (seq_brands.NEXTVAL, 'Ducati', 'Italy', '레이싱 유전자를 바탕으로 최고의 주행 성능을 자랑하는 프리미엄 스포츠 브랜드입니다.')",
        "INSERT INTO brands (brand_id, brand_name, country, description) VALUES (seq_brands.NEXTVAL, 'Kawasaki', 'Japan', '강력한 성능과 독특한 그린 컬러가 특징인 스포츠 바이크 명가입니다.')",
        
        "INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time, image_filename) VALUES (seq_rental_shops.NEXTVAL, '대구 중앙 지점', '김철수', '053-123-4567', '대구 중구 달구벌대로 123', '09:00', '20:00', 'shop_1.png')",
        "INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time, image_filename) VALUES (seq_rental_shops.NEXTVAL, '대구 동대구역 지점', '이영희', '053-987-6543', '대구 동구 동대구로 456', '09:00', '21:00', 'shop_2.png')",
        "INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time, image_filename) VALUES (seq_rental_shops.NEXTVAL, '대구 수성못 지점', '박민수', '053-765-4321', '대구 수성구 수성못길 789', '09:00', '22:00', 'shop_3.png')",
        "INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time, image_filename) VALUES (seq_rental_shops.NEXTVAL, '대구 계명대 지점', '최진혁', '053-580-1234', '대구 달서구 달구벌대로 1000', '09:00', '20:00', 'shop_4.png')",
        "INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time, image_filename) VALUES (seq_rental_shops.NEXTVAL, '대구 엑스코 지점', '정수빈', '053-601-5678', '대구 북구 유통단지로 789', '09:00', '20:00', 'shop_5.png')",
        "INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time, image_filename) VALUES (seq_rental_shops.NEXTVAL, '대구 칠곡 지점', '강진우', '053-321-4567', '대구 북구 태전로 123', '09:00', '20:00', 'shop_6.png')",
        "INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time, image_filename) VALUES (seq_rental_shops.NEXTVAL, '대구 상인 지점', '윤지아', '053-643-9876', '대구 달서구 월배로 456', '09:00', '21:00', 'shop_7.png')",
        "INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time, image_filename) VALUES (seq_rental_shops.NEXTVAL, '대구 현풍 지점', '오태양', '053-611-3456', '대구 달성군 테크노중앙대로 789', '09:00', '20:00', 'shop_8.png')",
        "INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time, image_filename) VALUES (seq_rental_shops.NEXTVAL, '대구 경북대 지점', '한소희', '053-950-1234', '대구 북구 대학로 80', '09:00', '22:00', 'shop_9.png')",
        
        "INSERT INTO users (user_id, email, password, name, phone, birth_date, license_number, license_status, role, point, user_grade, join_date) VALUES (101, 'admin@baren.com', 'admin123', '최고관리자', '010-1111-2222', TO_DATE('1990-01-01', 'YYYY-MM-DD'), '11-12-345678-01', 'APPROVED', 'ADMIN', 1000, 'VIP', SYSDATE)",
        "INSERT INTO users (user_id, email, password, name, phone, birth_date, license_number, license_status, role, point, user_grade, join_date) VALUES (102, 'user1@test.com', 'pass1234', '홍길동', '010-3333-4444', TO_DATE('1995-05-15', 'YYYY-MM-DD'), '22-12-987654-02', 'APPROVED', 'USER', 100, 'SILVER', SYSDATE)",
        
        "INSERT INTO insurance_plans (plan_id, plan_name, daily_fee, deductible_limit, coverage_limit, terms_content) VALUES (seq_insurance_plans.NEXTVAL, '완전자차 (Premium)', 20000, 0, 10000000, '대여 기간 중 사고 발생 시 본인 부담금(면책금)이 전혀 없는 완전자차 보장 플랜입니다. (대인/대물 보상한도 최대 1천만원)')",
        "INSERT INTO insurance_plans (plan_id, plan_name, daily_fee, deductible_limit, coverage_limit, terms_content) VALUES (seq_insurance_plans.NEXTVAL, '부분자차 (Standard)', 10000, 300000, 5000000, '대여 기간 중 사고 발생 시 최대 30만원의 면책금만 부담하는 보장 플랜입니다. (대인/대물 보상한도 최대 5백만원)')",
        "INSERT INTO insurance_plans (plan_id, plan_name, daily_fee, deductible_limit, coverage_limit, terms_content) VALUES (seq_insurance_plans.NEXTVAL, '일반대인대물 (Basic)', 3000, 1000000, 2000000, '의무 보험 성격으로 사고 발생 시 최대 100만원의 자기 부담금이 발생합니다. (대인/대물 보상한도 최대 2백만원)')",
        
        "INSERT INTO option_items (option_id, option_name, stock_quantity, daily_price, image_filename, status) VALUES (seq_option_items.NEXTVAL, '홍진 HJC 오픈페이스 헬멧', 50, 5000, 'gear_helmet.png', 'AVAILABLE')",
        "INSERT INTO option_items (option_id, option_name, stock_quantity, daily_price, image_filename, status) VALUES (seq_option_items.NEXTVAL, '세나 50S 블루투스 인터콤', 30, 7000, 'gear_intercom.png', 'AVAILABLE')",
        "INSERT INTO option_items (option_id, option_name, stock_quantity, daily_price, image_filename, status) VALUES (seq_option_items.NEXTVAL, '알루미늄 대용량 탑박스', 20, 4000, 'gear_topbox.png', 'AVAILABLE')",
        "INSERT INTO option_items (option_id, option_name, stock_quantity, daily_price, image_filename, status) VALUES (seq_option_items.NEXTVAL, '초고속 자석 스마트폰 거치대', 40, 2000, 'gear_holder.png', 'AVAILABLE')",
        "INSERT INTO option_items (option_id, option_name, stock_quantity, daily_price, image_filename, status) VALUES (seq_option_items.NEXTVAL, '프리미엄 무릎 및 팔꿈치 보호대', 25, 3000, 'gear_protector.png', 'AVAILABLE')",
        "INSERT INTO option_items (option_id, option_name, stock_quantity, daily_price, image_filename, status) VALUES (seq_option_items.NEXTVAL, '프리미엄 가죽 메쉬 장갑', 30, 3000, 'gear_gloves.png', 'AVAILABLE')",
        "INSERT INTO option_items (option_id, option_name, stock_quantity, daily_price, image_filename, status) VALUES (seq_option_items.NEXTVAL, '사계절 전천후 라이딩 재킷', 20, 8000, 'gear_jacket.png', 'AVAILABLE')",
        "INSERT INTO option_items (option_id, option_name, stock_quantity, daily_price, image_filename, status) VALUES (seq_option_items.NEXTVAL, '다기능 아머드 라이딩 팬츠', 20, 6000, 'gear_pants.png', 'AVAILABLE')",
        
        "INSERT INTO boards (board_id, user_id, category, title, content, view_count, like_count, created_at) VALUES (seq_boards.NEXTVAL, 101, 'NOTICE', 'Baren 오토바이 렌탈 서비스 오픈 공지', '안녕하세요. 프리미엄 모터사이클 렌탈 전문 Baren 사이트가 정식 오픈했습니다. 대구 중앙 지점(중구 달구벌대로 123), 동대구역 지점(동구 동대구로 456), 수성못 지점(수성구 수성못길 789), 계명대 지점(달서구 달구벌대로 1000), 엑스코 지점(북구 유통단지로 789), 칠곡 지점(북구 태전로 123), 상인 지점(달서구 월배로 456), 현풍 지점(달성군 테크노중앙대로 789), 경북대 지점(북구 대학로 80) 등 대구 전역 지점에서 예약하실 수 있습니다.', 12, 5, SYSDATE)",
        "INSERT INTO boards (board_id, user_id, category, title, content, view_count, like_count, created_at) VALUES (seq_boards.NEXTVAL, 102, 'REVIEW', 'PCX 125 대구 중앙점 대여 후기입니다.', 'PCX 신형 대여해서 강창역에서 달성보 방향으로 한 바퀴 돌고 왔는데 정말 편리했습니다.', 24, 8, SYSDATE)",
        
        "INSERT INTO comments (comment_id, board_id, user_id, content, created_at) VALUES (seq_comments.NEXTVAL, 2, 101, '소중한 후기 감사드립니다! 앞으로도 안전하게 주행하실 수 있도록 최상의 상태로 정비하겠습니다.', SYSDATE)"
    };

    String[] dependentInsertQueries = {
        "INSERT INTO reservations (reservation_id, user_id, bike_id, pickup_shop_id, dropoff_shop_id, start_date, end_date, rental_days, total_price, status, created_at, insurance_id) VALUES (1001, 102, (SELECT MIN(bike_id) FROM motorcycles), (SELECT MIN(shop_id) FROM rental_shops), (SELECT MAX(shop_id) FROM rental_shops), TO_DATE('2026-06-20', 'YYYY-MM-DD'), TO_DATE('2026-06-22', 'YYYY-MM-DD'), 2, 90000, 'APPROVED', SYSDATE, 1)",
        "INSERT INTO payments (payment_id, reservation_id, amount, payment_method, pg_approval_num, payment_status, paid_at, refund_amount) VALUES (seq_payments.NEXTVAL, 1001, 90000, '신용카드', 'TOSS_APPROV_1001', '결제완료', SYSDATE, 0)",
        "INSERT INTO booking_options (booking_option_id, reservation_id, option_id, quantity, daily_price) VALUES (seq_booking_options.NEXTVAL, 1001, (SELECT MIN(option_id) FROM option_items), 1, 5000)",
        "INSERT INTO penalties (penalty_id, reservation_id, user_id, penalty_type, amount, is_paid, reason, created_at) VALUES (seq_penalties.NEXTVAL, 1001, 102, '과태료', 50000, 'N', '신천대로 속도 위반 과태료 고지서 발부', SYSDATE)",
        "INSERT INTO license_audit (audit_id, user_id, license_type, license_image, status, reject_reason, audit_date, admin_id) VALUES (seq_license_audit.NEXTVAL, 102, '2종소형', 'resources/images/licenses/user_102.png', 'APPROVED', NULL, SYSDATE, 101)",
        "INSERT INTO bike_maintenance (maintenance_id, bike_id, maintenance_date, maintenance_type, content, cost, shop_name, next_check_date) VALUES (seq_bike_maintenance.NEXTVAL, (SELECT MIN(bike_id) FROM motorcycles), SYSDATE - 10, '소모품교체', '엔진오일 및 에어클리너 교체', 55000, '대구 바이크나라', SYSDATE + 90)",
        "INSERT INTO fuel_log (fuel_log_id, bike_id, reservation_id, fuel_level, penalty_amount, log_date) VALUES (seq_fuel_log.NEXTVAL, (SELECT MIN(bike_id) FROM motorcycles), 1001, 85, 4500, SYSDATE)",
        "INSERT INTO notifications (notification_id, user_id, notification_type, content, created_at, is_received) VALUES (seq_notifications.NEXTVAL, 102, '알림톡', '홍길동 님, 예약 번호 #1001 대여 예약이 완료되었습니다.', SYSDATE, 'N')",
        "INSERT INTO notifications (notification_id, user_id, notification_type, content, created_at, is_received) VALUES (seq_notifications.NEXTVAL, 102, 'SMS', '홍길동 님, 면허증 심사가 완료되었습니다. (승인 완료)', SYSDATE - 1, 'Y')",
        "INSERT INTO point_history (history_id, user_id, amount, reason, accumulated_points, created_at) VALUES (seq_point_history.NEXTVAL, 102, 1000, '회원가입 웰컴 포인트', 1000, SYSDATE - 2)",
        "INSERT INTO point_history (history_id, user_id, amount, reason, accumulated_points, created_at) VALUES (seq_point_history.NEXTVAL, 102, -900, '포인트 사용 예약 할인', 100, SYSDATE - 1)",
        "INSERT INTO refund_log (refund_id, payment_id, cancel_request_date, penalty_rate, refund_amount, refund_method, status) VALUES (seq_refund_log.NEXTVAL, 1, SYSDATE - 1, 0, 90000, '신용카드', '완료')"
    };

    try {
        Context ctx = new InitialContext();
        DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/myoracle");
        conn = ds.getConnection();
        conn.setAutoCommit(false);
        stmt = conn.createStatement();
        
        // 1. 기존 리소스 안전하게 드롭 (에러가 나도 통과)
        for (String sql : dropQueries) {
            try {
                stmt.executeUpdate(sql);
            } catch (Exception e) {
                // 이전 테이블/시퀀스가 없으면 무시
            }
        }
        
        // 2. 신규 스키마 생성
        for (String sql : createQueries) {
            stmt.executeUpdate(sql);
        }
        
        // 3. 초기 데이터 삽입
        for (String sql : insertQueries) {
            stmt.executeUpdate(sql);
        }
        
        String[][] models = {
            {"1", "PCX 125", "125", "2023", "Pearl White", "45000", "resources/images/bikes/scooter_pcx.png", "도심 주행의 최강자이자 연비와 내구성 모두를 만족시키는 125cc 스쿠터입니다."},
            {"2", "YZF-R3", "321", "2022", "Icon Blue", "80000", "resources/images/bikes/sports_r3.png", "입문용 쿼터급 최고의 스포츠 바이크입니다. 가볍고 민첩한 핸들링이 돋보입니다."},
            {"4", "Iron 883", "883", "2021", "Matte Black", "150000", "resources/images/bikes/cruiser_iron883.png", "클래식한 아메리칸 감성과 묵직한 고동감이 돋보이는 대표적인 크루저 바이크입니다."},
            {"5", "Primavera 125", "124", "2023", "Mint Green", "60000", "resources/images/bikes/scooter_primavera.png", "유려한 이탈리아 디자인과 감성적인 주행을 선사하는 클래식 스쿠터입니다."},
            {"3", "R 1250 GS", "1254", "2022", "Triple Black", "200000", "resources/images/bikes/adventure_r1250gs.png", "온로드와 오프로드를 가리지 않는 세계 최고 성능의 어드벤처 바이크입니다."},
            {"6", "Panigale V4", "1103", "2023", "Ducati Red", "250000", "resources/images/bikes/sports_panigale.png", "모토GP 레이싱 기술이 그대로 녹아든 고성능 이탈리아 레이싱 머신입니다."},
            {"1", "Super Cub 110", "109", "2023", "Classic Yellow", "35000", "resources/images/bikes/classic_cub.png", "최고의 내구성과 실용성을 자랑하는 110cc 클래식 언더본 바이크입니다."},
            {"3", "R nineT", "1170", "2022", "Black Storm Metallic", "180000", "resources/images/bikes/naked_rninet.png", "클래식한 로드스터 감성과 수평대향 박서 엔진을 탑재한 프리미엄 바이크입니다."},
            {"2", "YZF-R1", "998", "2023", "Yamaha Black", "220000", "resources/images/bikes/sports_r1.png", "야마하의 정교한 4기통 크로스플레인 엔진이 탑재된 플래그십 스포츠 모델입니다."},
            {"3", "S 1000 RR", "999", "2023", "M Motorsport", "240000", "resources/images/bikes/sports_s1000rr.png", "BMW의 플래그십 슈퍼 스포츠 바이크로, 레이스 현장에서 다듬어진 강력한 성능과 정교한 전자장비를 제공합니다."},
            {"1", "Rebel 500", "471", "2022", "Matte Armored Silver", "110000", "resources/images/bikes/cruiser_rebel500.png", "젊은 감각의 캐주얼 크루저로, 낮고 편안한 시트고와 다루기 쉬운 병렬 2기통 엔진을 갖췄습니다."},
            {"2", "MT-09", "890", "2023", "Cyan Storm", "140000", "resources/images/bikes/naked_mt09.png", "토크 마스터로 불리는 야마하의 대표 하이퍼 네이키드로, 폭발적인 가속력과 경쾌한 3기통 엔진이 특징입니다."},
            {"5", "GTS 300 SuperTech", "278", "2023", "Grey Materia", "90000", "resources/images/bikes/scooter_gts300.png", "베스파의 플래그십 대형 스쿠터로, 클래식한 감성과 현대적인 스마트 커넥티비티 기술을 융합했습니다."},
            {"1", "Goldwing Tour", "1833", "2022", "Candy Ardent Red", "280000", "resources/images/bikes/cruiser_goldwing.png", "대륙 횡단용 프리미엄 투어러의 대명사로, 수평대향 6기통 엔진과 최고급 편의 장비, DCT 변속기를 장착했습니다."},
            {"2", "TMAX 560", "562", "2023", "Icon Grey", "130000", "resources/images/bikes/scooter_tmax.png", "맥시 스쿠터의 끝판왕으로, 스포츠 바이크에 버금가는 섀시 밸런스와 장거리 주행의 편안함을 선사합니다."},
            {"6", "Monster 937", "937", "2023", "Aviator Grey", "170000", "resources/images/bikes/naked_monster.png", "가볍고 콤팩트한 섀시에 경쾌한 L-트윈 엔진을 얹어, 다이나믹하고 스포티한 네이키드 주행의 즐거움을 줍니다."},
            {"3", "F 850 GS", "853", "2022", "Racing Red", "170000", "resources/images/bikes/adventure_f850gs.png", "오프로드 모험을 위한 중형 어드벤처 바이크로, 뛰어난 서스펜션과 어떠한 지형도 주파 가능한 능력을 자랑합니다."},
            {"7", "Ninja 400", "399", "2023", "Lime Green", "95000", "resources/images/bikes/sports_ninja400.png", "가와사키의 엔트리 레벨 스포츠 바이크로, 공격적인 닌자 패밀리 룩과 다루기 쉬우면서도 강력한 병렬 2기통 엔진을 선사합니다."},
            {"4", "Fat Boy 114", "1868", "2023", "Vivid Black", "260000", "resources/images/bikes/cruiser_fatboy.png", "영화 터미네이터의 상징적인 크루저 모델로, 솔리드 알루미늄 휠과 우람한 차체, 강력한 밀워키에이트 엔진을 자랑합니다."}
        };

        try (PreparedStatement pstmtBike = conn.prepareStatement(
                "INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) " +
                "VALUES (seq_motorcycles.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, 0, 'AVAILABLE', ?)"
             );
             PreparedStatement pstmtImg = conn.prepareStatement(
                "INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, ?, ?, 'Y')"
             )) {
             
             for (int shopId = 1; shopId <= 9; shopId++) {
                 for (String[] m : models) {
                     pstmtBike.setInt(1, Integer.parseInt(m[0])); // brand_id
                     pstmtBike.setInt(2, shopId);                 // shop_id
                     pstmtBike.setString(3, m[1]);                // model_name
                     pstmtBike.setInt(4, Integer.parseInt(m[2])); // cc
                     pstmtBike.setInt(5, Integer.parseInt(m[3])); // year
                     pstmtBike.setString(6, m[4]);                // color
                     pstmtBike.setInt(7, Integer.parseInt(m[5])); // daily_price
                     pstmtBike.setString(8, m[7]);                // description
                     pstmtBike.executeUpdate();
                     
                     // Oracle seq_motorcycles CURRVAL 조회로 직전 인서트된 ID 확보
                     try (Statement sSeq = conn.createStatement();
                          ResultSet rsSeq = sSeq.executeQuery("SELECT seq_motorcycles.CURRVAL FROM dual")) {
                         if (rsSeq.next()) {
                             int bikeId = rsSeq.getInt(1);
                             pstmtImg.setInt(1, bikeId);
                             pstmtImg.setString(2, m[6]);        // image_url
                             pstmtImg.executeUpdate();
                         }
                     }
                 }
             }
        }
        
        // 5. 종속 테이블 데이터 삽입 (예약, 결제 등 바이크 ID 필요 항목)
        for (String sql : dependentInsertQueries) {
            stmt.executeUpdate(sql);
        }
        
        conn.commit();
        resultMsg = "Baren 데이터베이스 구조 생성 및 초기화 데이터 세팅이 완벽하게 완료되었습니다!";
    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch(Exception re) {}
        }
        e.printStackTrace();
        String errorMsg = e.getMessage().replace("'", "\\'").replace("\n", "\\n").replace("\r", "");
        resultMsg = "데이터베이스 초기화 중 에러 발생! 원인:\\n" + errorMsg;
    } finally {
        if (stmt != null) try { stmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
    out.println("<script>alert('" + resultMsg + "'); location.href='" + request.getContextPath() + "/index.do';</script>");
%>