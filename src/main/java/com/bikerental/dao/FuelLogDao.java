package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.FuelLogDto;
import com.bikerental.util.DBConnection;

public class FuelLogDao {
    private static FuelLogDao instance = new FuelLogDao();

    public static FuelLogDao getInstance() {
        return instance;
    }

    private FuelLogDao() {}

    // 전체 반납/주유 기록 조회
    public List<FuelLogDto> getFuelLogList() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT f.*, m.model_name, u.email AS user_email, u.name AS user_name "
                   + "FROM fuel_log f "
                   + "JOIN motorcycles m ON f.bike_id = m.bike_id "
                   + "LEFT JOIN reservations r ON f.reservation_id = r.reservation_id "
                   + "LEFT JOIN users u ON r.user_id = u.user_id "
                   + "ORDER BY f.fuel_log_id DESC";
        List<FuelLogDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                FuelLogDto dto = new FuelLogDto();
                dto.setFuelLogId(rs.getInt("fuel_log_id"));
                dto.setBikeId(rs.getInt("bike_id"));
                dto.setReservationId(rs.getInt("reservation_id"));
                dto.setFuelLevel(rs.getInt("fuel_level"));
                dto.setPenaltyAmount(rs.getInt("penalty_amount"));
                dto.setLogDate(rs.getTimestamp("log_date"));
                dto.setModelName(rs.getString("model_name"));
                dto.setUserEmail(rs.getString("user_email"));
                dto.setUserNickname(rs.getString("user_name"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 반납 등록 및 주유 기록 등록 + 패널티 부과 + 예약 및 바이크 상태 변경 (트랜잭션)
    public int insertFuelLogAndUpdateBooking(FuelLogDto dto) {
        Connection conn = null;
        PreparedStatement pstmtLog = null;
        PreparedStatement pstmtRes = null;
        PreparedStatement pstmtBike = null;
        PreparedStatement pstmtPen = null;
        PreparedStatement pstmtGetRes = null;
        ResultSet rsRes = null;
        
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 0. 예약을 조회하여 user_id, bike_id, 반납 지점(dropoff_shop_id) 정보 조회
            int userId = -1;
            int bikeId = -1;
            int dropoffShopId = -1;
            String sqlGetRes = "SELECT user_id, bike_id, dropoff_shop_id FROM reservations WHERE reservation_id = ?";
            pstmtGetRes = conn.prepareStatement(sqlGetRes);
            pstmtGetRes.setInt(1, dto.getReservationId());
            rsRes = pstmtGetRes.executeQuery();
            if (rsRes.next()) {
                userId = rsRes.getInt("user_id");
                bikeId = rsRes.getInt("bike_id");
                dropoffShopId = rsRes.getInt("dropoff_shop_id");
            }
            rsRes.close();
            pstmtGetRes.close();

            if (userId == -1 || bikeId == -1) {
                throw new SQLException("Reservation not found for ID: " + dto.getReservationId());
            }

            dto.setBikeId(bikeId);

            // 1. 주유 기록 추가
            String sqlLog = "INSERT INTO fuel_log (fuel_log_id, bike_id, reservation_id, fuel_level, penalty_amount, log_date) "
                          + "VALUES (seq_fuel_log.NEXTVAL, ?, ?, ?, ?, SYSDATE)";
            pstmtLog = conn.prepareStatement(sqlLog);
            pstmtLog.setInt(1, bikeId);
            pstmtLog.setInt(2, dto.getReservationId());
            pstmtLog.setInt(3, dto.getFuelLevel());
            pstmtLog.setInt(4, dto.getPenaltyAmount());
            result = pstmtLog.executeUpdate();

            if (result > 0) {
                // 2. 패널티 부과 (패널티 금액이 0보다 큰 경우)
                if (dto.getPenaltyAmount() > 0) {
                    String sqlPen = "INSERT INTO penalties (penalty_id, reservation_id, user_id, penalty_type, amount, is_paid, reason, created_at) "
                                  + "VALUES (seq_penalties.NEXTVAL, ?, ?, '주유량미달', ?, 'N', ?, SYSDATE)";
                    pstmtPen = conn.prepareStatement(sqlPen);
                    pstmtPen.setInt(1, dto.getReservationId());
                    pstmtPen.setInt(2, userId);
                    pstmtPen.setInt(3, dto.getPenaltyAmount());
                    pstmtPen.setString(4, "반납 주유량 미달 (" + dto.getFuelLevel() + "%)");
                    pstmtPen.executeUpdate();
                }

                // 3. 예약 상태를 'RETURNED'로 변경
                String sqlRes = "UPDATE reservations SET status = 'RETURNED' WHERE reservation_id = ?";
                pstmtRes = conn.prepareStatement(sqlRes);
                pstmtRes.setInt(1, dto.getReservationId());
                pstmtRes.executeUpdate();

                // 4. 오토바이 상태를 'AVAILABLE'로 변경하고 위치(shop_id)를 반납 지점(dropoff_shop_id)으로 변경
                String sqlBike;
                if (dropoffShopId > 0) {
                    sqlBike = "UPDATE motorcycles SET status = 'AVAILABLE', shop_id = ? WHERE bike_id = ?";
                    pstmtBike = conn.prepareStatement(sqlBike);
                    pstmtBike.setInt(1, dropoffShopId);
                    pstmtBike.setInt(2, bikeId);
                } else {
                    sqlBike = "UPDATE motorcycles SET status = 'AVAILABLE' WHERE bike_id = ?";
                    pstmtBike = conn.prepareStatement(sqlBike);
                    pstmtBike.setInt(1, bikeId);
                }
                pstmtBike.executeUpdate();
            }

            conn.commit();
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            result = -1;
        } finally {
            try { if (rsRes != null) rsRes.close(); } catch (Exception e) {}
            try { if (pstmtGetRes != null) pstmtGetRes.close(); } catch (Exception e) {}
            try { if (pstmtPen != null) pstmtPen.close(); } catch (Exception e) {}
            try { if (pstmtBike != null) pstmtBike.close(); } catch (Exception e) {}
            try { if (pstmtRes != null) pstmtRes.close(); } catch (Exception e) {}
            try { if (pstmtLog != null) pstmtLog.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return result;
    }
}
