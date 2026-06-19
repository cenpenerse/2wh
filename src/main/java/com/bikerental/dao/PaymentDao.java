package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.PaymentDto;
import com.bikerental.util.DBConnection;

public class PaymentDao {
    private static PaymentDao instance = new PaymentDao();

    public static PaymentDao getInstance() {
        return instance;
    }

    private PaymentDao() {}

    // 전체 결제 이력 조회 (관리자용)
    public List<PaymentDto> getPaymentsAll() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT p.*, u.name AS user_nickname, u.email AS user_email, m.model_name AS bike_name "
                   + "FROM payments p "
                   + "JOIN reservations r ON p.reservation_id = r.reservation_id "
                   + "JOIN users u ON r.user_id = u.user_id "
                   + "JOIN motorcycles m ON r.bike_id = m.bike_id "
                   + "ORDER BY p.payment_id DESC";
        List<PaymentDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                PaymentDto dto = new PaymentDto();
                dto.setPaymentId(rs.getInt("payment_id"));
                dto.setReservationId(rs.getInt("reservation_id"));
                dto.setAmount(rs.getInt("amount"));
                dto.setPaymentMethod(rs.getString("payment_method"));
                dto.setPgApprovalNum(rs.getString("pg_approval_num"));
                dto.setPaymentStatus(rs.getString("payment_status"));
                dto.setPaidAt(rs.getTimestamp("paid_at"));
                dto.setRefundAmount(rs.getInt("refund_amount"));
                dto.setUserNickname(rs.getString("user_nickname"));
                dto.setUserEmail(rs.getString("user_email"));
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

    // 특정 회원의 결제 이력 조회 (사용자용)
    public List<PaymentDto> getPaymentsByUser(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT p.*, u.name AS user_nickname, u.email AS user_email, m.model_name AS bike_name "
                   + "FROM payments p "
                   + "JOIN reservations r ON p.reservation_id = r.reservation_id "
                   + "JOIN users u ON r.user_id = u.user_id "
                   + "JOIN motorcycles m ON r.bike_id = m.bike_id "
                   + "WHERE u.user_id = ? "
                   + "ORDER BY p.payment_id DESC";
        List<PaymentDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                PaymentDto dto = new PaymentDto();
                dto.setPaymentId(rs.getInt("payment_id"));
                dto.setReservationId(rs.getInt("reservation_id"));
                dto.setAmount(rs.getInt("amount"));
                dto.setPaymentMethod(rs.getString("payment_method"));
                dto.setPgApprovalNum(rs.getString("pg_approval_num"));
                dto.setPaymentStatus(rs.getString("payment_status"));
                dto.setPaidAt(rs.getTimestamp("paid_at"));
                dto.setRefundAmount(rs.getInt("refund_amount"));
                dto.setUserNickname(rs.getString("user_nickname"));
                dto.setUserEmail(rs.getString("user_email"));
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

    // 결제 상태 및 취소 금액 업데이트
    public int updatePaymentStatus(int paymentId, String status, int refundAmount) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "UPDATE payments SET payment_status = ?, refund_amount = ? WHERE payment_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, status);
            pstmt.setInt(2, refundAmount);
            pstmt.setInt(3, paymentId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 단일 결제 정보 조회
    public PaymentDto getPayment(int paymentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT p.*, u.name AS user_nickname, u.email AS user_email, m.model_name AS bike_name "
                   + "FROM payments p "
                   + "JOIN reservations r ON p.reservation_id = r.reservation_id "
                   + "JOIN users u ON r.user_id = u.user_id "
                   + "JOIN motorcycles m ON r.bike_id = m.bike_id "
                   + "WHERE p.payment_id = ?";
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, paymentId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                PaymentDto dto = new PaymentDto();
                dto.setPaymentId(rs.getInt("payment_id"));
                dto.setReservationId(rs.getInt("reservation_id"));
                dto.setAmount(rs.getInt("amount"));
                dto.setPaymentMethod(rs.getString("payment_method"));
                dto.setPgApprovalNum(rs.getString("pg_approval_num"));
                dto.setPaymentStatus(rs.getString("payment_status"));
                dto.setPaidAt(rs.getTimestamp("paid_at"));
                dto.setRefundAmount(rs.getInt("refund_amount"));
                dto.setUserNickname(rs.getString("user_nickname"));
                dto.setUserEmail(rs.getString("user_email"));
                dto.setBikeName(rs.getString("bike_name"));
                return dto;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return null;
    }

    // 예약번호로 결제 정보 조회
    public PaymentDto getPaymentByReservation(int reservationId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT p.*, u.name AS user_nickname, u.email AS user_email, m.model_name AS bike_name "
                   + "FROM payments p "
                   + "JOIN reservations r ON p.reservation_id = r.reservation_id "
                   + "JOIN users u ON r.user_id = u.user_id "
                   + "JOIN motorcycles m ON r.bike_id = m.bike_id "
                   + "WHERE p.reservation_id = ?";
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, reservationId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                PaymentDto dto = new PaymentDto();
                dto.setPaymentId(rs.getInt("payment_id"));
                dto.setReservationId(rs.getInt("reservation_id"));
                dto.setAmount(rs.getInt("amount"));
                dto.setPaymentMethod(rs.getString("payment_method"));
                dto.setPgApprovalNum(rs.getString("pg_approval_num"));
                dto.setPaymentStatus(rs.getString("payment_status"));
                dto.setPaidAt(rs.getTimestamp("paid_at"));
                dto.setRefundAmount(rs.getInt("refund_amount"));
                dto.setUserNickname(rs.getString("user_nickname"));
                dto.setUserEmail(rs.getString("user_email"));
                dto.setBikeName(rs.getString("bike_name"));
                return dto;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return null;
    }
}
