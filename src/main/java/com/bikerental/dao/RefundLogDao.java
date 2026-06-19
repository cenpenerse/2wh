package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.RefundLogDto;
import com.bikerental.util.DBConnection;

public class RefundLogDao {
    private static RefundLogDao instance = new RefundLogDao();

    public static RefundLogDao getInstance() {
        return instance;
    }

    private RefundLogDao() {}

    // 환불 로그 기록 등록 (Connection 전달받음 - 트랜잭션용)
    public int insertRefund(Connection conn, RefundLogDto dto) throws Exception {
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO refund_log (refund_id, payment_id, cancel_request_date, penalty_rate, refund_amount, refund_method, status) "
                   + "VALUES (seq_refund_log.NEXTVAL, ?, SYSDATE, ?, ?, ?, ?)";
        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, dto.getPaymentId());
            pstmt.setInt(2, dto.getPenaltyRate());
            pstmt.setInt(3, dto.getRefundAmount());
            pstmt.setString(4, dto.getRefundMethod());
            pstmt.setString(5, dto.getStatus());
            return pstmt.executeUpdate();
        } finally {
            if (pstmt != null) pstmt.close();
        }
    }

    // 환불 로그 기록 등록 (단독 실행용)
    public int insertRefund(RefundLogDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO refund_log (refund_id, payment_id, cancel_request_date, penalty_rate, refund_amount, refund_method, status) "
                   + "VALUES (seq_refund_log.NEXTVAL, ?, SYSDATE, ?, ?, ?, ?)";
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, dto.getPaymentId());
            pstmt.setInt(2, dto.getPenaltyRate());
            pstmt.setInt(3, dto.getRefundAmount());
            pstmt.setString(4, dto.getRefundMethod());
            pstmt.setString(5, dto.getStatus());
            return pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return -1;
    }

    // 전체 환불 내역 조회 (관리자용)
    public List<RefundLogDto> getRefundsAll() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<RefundLogDto> list = new ArrayList<>();
        String sql = "SELECT rf.*, p.reservation_id, p.amount AS payment_amount, u.name AS user_nickname, u.email AS user_email "
                   + "FROM refund_log rf "
                   + "JOIN payments p ON rf.payment_id = p.payment_id "
                   + "JOIN reservations r ON p.reservation_id = r.reservation_id "
                   + "JOIN users u ON r.user_id = u.user_id "
                   + "ORDER BY rf.refund_id DESC";
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                RefundLogDto dto = new RefundLogDto();
                dto.setRefundId(rs.getInt("refund_id"));
                dto.setPaymentId(rs.getInt("payment_id"));
                dto.setCancelRequestDate(rs.getTimestamp("cancel_request_date"));
                dto.setPenaltyRate(rs.getInt("penalty_rate"));
                dto.setRefundAmount(rs.getInt("refund_amount"));
                dto.setRefundMethod(rs.getString("refund_method"));
                dto.setStatus(rs.getString("status"));
                dto.setReservationId(rs.getInt("reservation_id"));
                dto.setPaymentAmount(rs.getInt("payment_amount"));
                dto.setUserNickname(rs.getString("user_nickname"));
                dto.setUserEmail(rs.getString("user_email"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 특정 회원의 환불 내역 조회 (사용자용)
    public List<RefundLogDto> getRefundsByUser(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<RefundLogDto> list = new ArrayList<>();
        String sql = "SELECT rf.*, p.reservation_id, p.amount AS payment_amount, u.name AS user_nickname, u.email AS user_email "
                   + "FROM refund_log rf "
                   + "JOIN payments p ON rf.payment_id = p.payment_id "
                   + "JOIN reservations r ON p.reservation_id = r.reservation_id "
                   + "JOIN users u ON r.user_id = u.user_id "
                   + "WHERE r.user_id = ? "
                   + "ORDER BY rf.refund_id DESC";
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                RefundLogDto dto = new RefundLogDto();
                dto.setRefundId(rs.getInt("refund_id"));
                dto.setPaymentId(rs.getInt("payment_id"));
                dto.setCancelRequestDate(rs.getTimestamp("cancel_request_date"));
                dto.setPenaltyRate(rs.getInt("penalty_rate"));
                dto.setRefundAmount(rs.getInt("refund_amount"));
                dto.setRefundMethod(rs.getString("refund_method"));
                dto.setStatus(rs.getString("status"));
                dto.setReservationId(rs.getInt("reservation_id"));
                dto.setPaymentAmount(rs.getInt("payment_amount"));
                dto.setUserNickname(rs.getString("user_nickname"));
                dto.setUserEmail(rs.getString("user_email"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }
}
