package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.BookingDto;
import com.bikerental.dto.BookingOptionDto;
import com.bikerental.util.DBConnection;

public class BookingDao {
    private static BookingDao instance = new BookingDao();

    public static BookingDao getInstance() {
        return instance;
    }

    private BookingDao() {}

    // 1. 대여 예약 등록 및 결제 승인 (트랜잭션 일원화)
    // 1. 대여 예약 등록 및 결제 승인 (트랜잭션 일원화)
    public int insertBooking(BookingDto dto) {
        Connection conn = null;
        PreparedStatement pstmt1 = null;
        PreparedStatement pstmt2 = null;
        PreparedStatement pstmtOptPrice = null;
        PreparedStatement pstmtOptIns = null;
        ResultSet rsOptPrice = null;
        
        String sqlRes = "INSERT INTO reservations (reservation_id, user_id, bike_id, pickup_shop_id, dropoff_shop_id, start_date, end_date, rental_days, total_price, status, created_at, insurance_id) "
                      + "VALUES (seq_reservations.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', SYSDATE, ?)";
                      
        String sqlPay = "INSERT INTO payments (payment_id, reservation_id, amount, payment_method, pg_approval_num, payment_status, paid_at, refund_amount) "
                      + "VALUES (seq_payments.NEXTVAL, seq_reservations.CURRVAL, ?, ?, ?, '결제완료', SYSDATE, 0)";

        String sqlOptPrice = "SELECT daily_price FROM option_items WHERE option_id = ?";
        String sqlOptIns = "INSERT INTO booking_options (booking_option_id, reservation_id, option_id, quantity, daily_price) "
                         + "VALUES (seq_booking_options.NEXTVAL, seq_reservations.CURRVAL, ?, ?, ?)";
                      
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // 트랜잭션 모드 전환
            
            // 1. 예약 테이블 인서트
            pstmt1 = conn.prepareStatement(sqlRes);
            pstmt1.setInt(1, dto.getMemberId());
            pstmt1.setInt(2, dto.getBikeId());
            if (dto.getPickupShopId() > 0) {
                pstmt1.setInt(3, dto.getPickupShopId());
            } else {
                pstmt1.setNull(3, java.sql.Types.NUMERIC);
            }
            if (dto.getDropoffShopId() > 0) {
                pstmt1.setInt(4, dto.getDropoffShopId());
            } else {
                pstmt1.setNull(4, java.sql.Types.NUMERIC);
            }
            pstmt1.setTimestamp(5, dto.getStartDate());
            pstmt1.setTimestamp(6, dto.getEndDate());
            pstmt1.setInt(7, dto.getRentalDays());
            pstmt1.setInt(8, dto.getPrice());
            if (dto.getInsuranceId() > 0) {
                pstmt1.setInt(9, dto.getInsuranceId());
            } else {
                pstmt1.setNull(9, java.sql.Types.NUMERIC);
            }
            result = pstmt1.executeUpdate();
            
            if (result > 0) {
                // 2. 결제 테이블 인서트
                pstmt2 = conn.prepareStatement(sqlPay);
                pstmt2.setInt(1, dto.getPrice());
                pstmt2.setString(2, dto.getPaymentMethod());
                String mockPgNum = "TOSS_APP_" + (int)(Math.random() * 900000 + 100000);
                pstmt2.setString(3, mockPgNum);
                pstmt2.executeUpdate();

                // 3. 대여 옵션 인서트
                if (dto.getBookingOptions() != null && !dto.getBookingOptions().isEmpty()) {
                    pstmtOptPrice = conn.prepareStatement(sqlOptPrice);
                    pstmtOptIns = conn.prepareStatement(sqlOptIns);
                    for (BookingOptionDto opt : dto.getBookingOptions()) {
                        // DB에서 최신 장비 일일 렌탈가 조회
                        pstmtOptPrice.setInt(1, opt.getOptionId());
                        rsOptPrice = pstmtOptPrice.executeQuery();
                        int dailyPrice = 0;
                        if (rsOptPrice.next()) {
                            dailyPrice = rsOptPrice.getInt("daily_price");
                        }
                        rsOptPrice.close();

                        pstmtOptIns.setInt(1, opt.getOptionId());
                        pstmtOptIns.setInt(2, opt.getQuantity());
                        pstmtOptIns.setInt(3, dailyPrice);
                        pstmtOptIns.executeUpdate();
                    }
                }

                // 4. 포인트 차감 및 적립 처리
                if (dto.getUsePoints() > 0) {
                    PointHistoryDao.getInstance().insertPointHistory(conn, dto.getMemberId(), -dto.getUsePoints(), "대여 예약 시 포인트 사용");
                }
                
                String sqlUserGrade = "SELECT user_grade FROM users WHERE user_id = ?";
                String grade = "SILVER";
                try (PreparedStatement pstmtUG = conn.prepareStatement(sqlUserGrade)) {
                    pstmtUG.setInt(1, dto.getMemberId());
                    try (ResultSet rsUG = pstmtUG.executeQuery()) {
                        if (rsUG.next()) {
                            grade = rsUG.getString("user_grade");
                        }
                    }
                }
                
                double rate = 0.05;
                if ("GOLD".equals(grade)) rate = 0.07;
                else if ("VIP".equals(grade)) rate = 0.10;
                int earnPoints = (int)(dto.getPrice() * rate);
                
                if (earnPoints > 0) {
                    PointHistoryDao.getInstance().insertPointHistory(conn, dto.getMemberId(), earnPoints, "대여 예약 완료 적립");
                }
            }
            
            conn.commit(); // 커밋
            try {
                NotificationDao.send(dto.getMemberId(), "알림톡", "🏍️ 대여 예약 및 결제가 정상적으로 완료되었습니다. 마이페이지에서 대여 현황을 확인하세요.");
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    System.out.println("[BookingDao] Transaction rollback due to error!");
                    conn.rollback(); // 에러 발생 시 롤백
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            result = -1;
        } finally {
            try { if (rsOptPrice != null) rsOptPrice.close(); } catch (Exception e) {}
            try { if (pstmtOptIns != null) pstmtOptIns.close(); } catch (Exception e) {}
            try { if (pstmtOptPrice != null) pstmtOptPrice.close(); } catch (Exception e) {}
            try { if (pstmt2 != null) pstmt2.close(); } catch (Exception e) {}
            try { if (pstmt1 != null) pstmt1.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return result;
    }

    // 2. 특정 회원의 예약 조회 (마이페이지용)
    public List<BookingDto> getBookingListByUser(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT r.*, m.model_name, m.cc, p.payment_method, p.payment_status, "
                   + "       ps.shop_name AS pickup_shop_name, ds.shop_name AS dropoff_shop_name, "
                   + "       (SELECT image_url FROM bike_images WHERE bike_id = m.bike_id AND is_thumbnail = 'Y' AND ROWNUM = 1) AS bike_image_url, "
                   + "       ip.plan_name AS insurance_plan_name, ip.daily_fee AS insurance_daily_fee "
                   + "FROM reservations r "
                   + "JOIN motorcycles m ON r.bike_id = m.bike_id "
                   + "LEFT JOIN rental_shops ps ON r.pickup_shop_id = ps.shop_id "
                   + "LEFT JOIN rental_shops ds ON r.dropoff_shop_id = ds.shop_id "
                   + "LEFT JOIN payments p ON r.reservation_id = p.reservation_id "
                   + "LEFT JOIN insurance_plans ip ON r.insurance_id = ip.plan_id "
                   + "WHERE r.user_id = ? "
                   + "ORDER BY r.reservation_id DESC";
        List<BookingDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                BookingDto dto = new BookingDto();
                dto.setBookingId(rs.getInt("reservation_id"));
                dto.setMemberId(rs.getInt("user_id"));
                dto.setBikeId(rs.getInt("bike_id"));
                dto.setStartDate(rs.getTimestamp("start_date"));
                dto.setEndDate(rs.getTimestamp("end_date"));
                dto.setRentalDays(rs.getInt("rental_days"));
                dto.setPrice(rs.getInt("total_price"));
                dto.setBookingStatus(rs.getString("status"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                
                dto.setBikeName(rs.getString("model_name"));
                dto.setBikeType("배기량: " + rs.getInt("cc") + " cc");
                dto.setBikeImageUrl(rs.getString("bike_image_url"));
                dto.setPaymentMethod(rs.getString("payment_method"));
                dto.setPaymentStatus(rs.getString("payment_status"));
                dto.setPickupShopId(rs.getInt("pickup_shop_id"));
                dto.setPickupShopName(rs.getString("pickup_shop_name"));
                dto.setDropoffShopId(rs.getInt("dropoff_shop_id"));
                dto.setDropoffShopName(rs.getString("dropoff_shop_name"));
                dto.setInsuranceId(rs.getInt("insurance_id"));
                dto.setInsuranceName(rs.getString("insurance_plan_name"));
                dto.setInsuranceFee(rs.getInt("insurance_daily_fee"));
                
                // 대여 옵션 로드
                dto.setBookingOptions(getBookingOptions(conn, dto.getBookingId()));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 3. 전체 예약 조회 (관리자용)
    public List<BookingDto> getBookingListAll() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT r.*, u.name AS user_nickname, u.email AS user_email, m.model_name, p.payment_method, "
                   + "       ps.shop_name AS pickup_shop_name, ds.shop_name AS dropoff_shop_name, "
                   + "       ip.plan_name AS insurance_plan_name, ip.daily_fee AS insurance_daily_fee "
                   + "FROM reservations r "
                   + "JOIN users u ON r.user_id = u.user_id "
                   + "JOIN motorcycles m ON r.bike_id = m.bike_id "
                   + "LEFT JOIN rental_shops ps ON r.pickup_shop_id = ps.shop_id "
                   + "LEFT JOIN rental_shops ds ON r.dropoff_shop_id = ds.shop_id "
                   + "LEFT JOIN payments p ON r.reservation_id = p.reservation_id "
                   + "LEFT JOIN insurance_plans ip ON r.insurance_id = ip.plan_id "
                   + "ORDER BY r.reservation_id DESC";
        List<BookingDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                BookingDto dto = new BookingDto();
                dto.setBookingId(rs.getInt("reservation_id"));
                dto.setMemberId(rs.getInt("user_id"));
                dto.setBikeId(rs.getInt("bike_id"));
                dto.setStartDate(rs.getTimestamp("start_date"));
                dto.setEndDate(rs.getTimestamp("end_date"));
                dto.setRentalDays(rs.getInt("rental_days"));
                dto.setPrice(rs.getInt("total_price"));
                dto.setBookingStatus(rs.getString("status"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                
                dto.setMemberNickname(rs.getString("user_nickname"));
                dto.setMemberEmail(rs.getString("user_email"));
                dto.setBikeName(rs.getString("model_name"));
                dto.setPaymentMethod(rs.getString("payment_method"));
                dto.setPickupShopId(rs.getInt("pickup_shop_id"));
                dto.setPickupShopName(rs.getString("pickup_shop_name"));
                dto.setDropoffShopId(rs.getInt("dropoff_shop_id"));
                dto.setDropoffShopName(rs.getString("dropoff_shop_name"));
                dto.setInsuranceId(rs.getInt("insurance_id"));
                dto.setInsuranceName(rs.getString("insurance_plan_name"));
                dto.setInsuranceFee(rs.getInt("insurance_daily_fee"));
                
                // 대여 옵션 로드
                dto.setBookingOptions(getBookingOptions(conn, dto.getBookingId()));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 4. 예약 상태 변경 (승인 / 거절 / 취소)
    public int updateBookingStatus(int reservationId, String status) {
        Connection conn = null;
        PreparedStatement pstmt1 = null;
        PreparedStatement pstmt2 = null;
        PreparedStatement pstmt3 = null;
        String sqlRes = "UPDATE reservations SET status = ? WHERE reservation_id = ?";
        String sqlPay = "UPDATE payments SET payment_status = ? WHERE reservation_id = ?";
        String sqlBike = "UPDATE motorcycles SET status = ? WHERE bike_id = (SELECT bike_id FROM reservations WHERE reservation_id = ?)";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            pstmt1 = conn.prepareStatement(sqlRes);
            pstmt1.setString(1, status);
            pstmt1.setInt(2, reservationId);
            result = pstmt1.executeUpdate();
            
            if (result > 0) {
                // 상태에 맞춰 오토바이 상태 업데이트
                String bikeStatus = null;
                if ("APPROVED".equals(status)) {
                    bikeStatus = "RENTED";
                } else if ("CANCELLED".equals(status)) {
                    bikeStatus = "AVAILABLE";
                }
                
                if (bikeStatus != null) {
                    pstmt3 = conn.prepareStatement(sqlBike);
                    pstmt3.setString(1, bikeStatus);
                    pstmt3.setInt(2, reservationId);
                    pstmt3.executeUpdate();
                }
                
                if ("CANCELLED".equals(status)) {
                    // 예약 취소 시 결제 상태도 환불(REFUNDED)로 변경
                    pstmt2 = conn.prepareStatement(sqlPay);
                    pstmt2.setString(1, "REFUNDED");
                    pstmt2.setInt(2, reservationId);
                    pstmt2.executeUpdate();
                }
            }
            conn.commit();
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            result = -1;
        } finally {
            try { if (pstmt3 != null) pstmt3.close(); } catch (Exception e) {}
            try { if (pstmt2 != null) pstmt2.close(); } catch (Exception e) {}
            try { if (pstmt1 != null) pstmt1.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return result;
    }

    // 5. 단일 예약 상세 조회
    public BookingDto getBooking(int reservationId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT r.*, m.model_name, p.payment_method, "
                   + "       ps.shop_name AS pickup_shop_name, ds.shop_name AS dropoff_shop_name, "
                   + "       ip.plan_name AS insurance_plan_name, ip.daily_fee AS insurance_daily_fee "
                   + "FROM reservations r "
                   + "JOIN motorcycles m ON r.bike_id = m.bike_id "
                   + "LEFT JOIN rental_shops ps ON r.pickup_shop_id = ps.shop_id "
                   + "LEFT JOIN rental_shops ds ON r.dropoff_shop_id = ds.shop_id "
                   + "LEFT JOIN payments p ON r.reservation_id = p.reservation_id "
                   + "LEFT JOIN insurance_plans ip ON r.insurance_id = ip.plan_id "
                   + "WHERE r.reservation_id = ?";
        BookingDto dto = null;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, reservationId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                dto = new BookingDto();
                dto.setBookingId(rs.getInt("reservation_id"));
                dto.setMemberId(rs.getInt("user_id"));
                dto.setBikeId(rs.getInt("bike_id"));
                dto.setStartDate(rs.getTimestamp("start_date"));
                dto.setEndDate(rs.getTimestamp("end_date"));
                dto.setRentalDays(rs.getInt("rental_days"));
                dto.setPrice(rs.getInt("total_price"));
                dto.setBookingStatus(rs.getString("status"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setBikeName(rs.getString("model_name"));
                dto.setPaymentMethod(rs.getString("payment_method"));
                dto.setPickupShopId(rs.getInt("pickup_shop_id"));
                dto.setPickupShopName(rs.getString("pickup_shop_name"));
                dto.setDropoffShopId(rs.getInt("dropoff_shop_id"));
                dto.setDropoffShopName(rs.getString("dropoff_shop_name"));
                dto.setInsuranceId(rs.getInt("insurance_id"));
                dto.setInsuranceName(rs.getString("insurance_plan_name"));
                dto.setInsuranceFee(rs.getInt("insurance_daily_fee"));
                
                // 대여 옵션 로드
                dto.setBookingOptions(getBookingOptions(conn, dto.getBookingId()));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return dto;
    }

    // 6. 예약별 선택 옵션 조회 (내부 헬퍼)
    private List<BookingOptionDto> getBookingOptions(Connection conn, int reservationId) throws SQLException {
        String sql = "SELECT bo.*, oi.option_name "
                   + "FROM booking_options bo "
                   + "JOIN option_items oi ON bo.option_id = oi.option_id "
                   + "WHERE bo.reservation_id = ?";
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<BookingOptionDto> list = new ArrayList<>();
        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, reservationId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                BookingOptionDto dto = new BookingOptionDto();
                dto.setBookingOptionId(rs.getInt("booking_option_id"));
                dto.setReservationId(rs.getInt("reservation_id"));
                dto.setOptionId(rs.getInt("option_id"));
                dto.setQuantity(rs.getInt("quantity"));
                dto.setDailyPrice(rs.getInt("daily_price"));
                dto.setOptionName(rs.getString("option_name"));
                list.add(dto);
            }
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
        }
        return list;
    }
}
