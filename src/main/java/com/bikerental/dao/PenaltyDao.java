package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.PenaltyDto;
import com.bikerental.util.DBConnection;

public class PenaltyDao {
    private static PenaltyDao instance = new PenaltyDao();

    public static PenaltyDao getInstance() {
        return instance;
    }

    private PenaltyDao() {}

    // 1. 특정 회원의 패널티 내역 조회
    public List<PenaltyDto> getPenaltiesByUser(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT p.*, u.email AS user_email, u.name AS user_name, m.model_name AS bike_name "
                   + "FROM penalties p "
                   + "JOIN users u ON p.user_id = u.user_id "
                   + "JOIN reservations r ON p.reservation_id = r.reservation_id "
                   + "JOIN motorcycles m ON r.bike_id = m.bike_id "
                   + "WHERE p.user_id = ? "
                   + "ORDER BY p.penalty_id DESC";
        List<PenaltyDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                PenaltyDto dto = new PenaltyDto();
                dto.setPenaltyId(rs.getInt("penalty_id"));
                dto.setReservationId(rs.getInt("reservation_id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setPenaltyType(rs.getString("penalty_type"));
                dto.setAmount(rs.getInt("amount"));
                dto.setIsPaid(rs.getString("is_paid"));
                dto.setReason(rs.getString("reason"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setUserEmail(rs.getString("user_email"));
                dto.setUserName(rs.getString("user_name"));
                dto.setBikeName(rs.getString("bike_name"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 2. 전체 회원의 패널티 목록 조회 (관리자용)
    public List<PenaltyDto> getPenaltiesAll() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT p.*, u.email AS user_email, u.name AS user_name, m.model_name AS bike_name "
                   + "FROM penalties p "
                   + "JOIN users u ON p.user_id = u.user_id "
                   + "JOIN reservations r ON p.reservation_id = r.reservation_id "
                   + "JOIN motorcycles m ON r.bike_id = m.bike_id "
                   + "ORDER BY p.penalty_id DESC";
        List<PenaltyDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                PenaltyDto dto = new PenaltyDto();
                dto.setPenaltyId(rs.getInt("penalty_id"));
                dto.setReservationId(rs.getInt("reservation_id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setPenaltyType(rs.getString("penalty_type"));
                dto.setAmount(rs.getInt("amount"));
                dto.setIsPaid(rs.getString("is_paid"));
                dto.setReason(rs.getString("reason"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setUserEmail(rs.getString("user_email"));
                dto.setUserName(rs.getString("user_name"));
                dto.setBikeName(rs.getString("bike_name"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 3. 패널티 부과 (관리자용)
    public int insertPenalty(PenaltyDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO penalties (penalty_id, reservation_id, user_id, penalty_type, amount, is_paid, reason, created_at) "
                   + "VALUES (seq_penalties.NEXTVAL, ?, ?, ?, ?, 'N', ?, SYSDATE)";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, dto.getReservationId());
            pstmt.setInt(2, dto.getUserId());
            pstmt.setString(3, dto.getPenaltyType());
            pstmt.setInt(4, dto.getAmount());
            pstmt.setString(5, dto.getReason());
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 4. 패널티 납부 (결제 완료 처리)
    public int payPenalty(int penaltyId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "UPDATE penalties SET is_paid = 'Y' WHERE penalty_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, penaltyId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }
}
