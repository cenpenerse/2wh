package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.CouponDto;
import com.bikerental.util.DBConnection;

public class CouponDao {
    private static CouponDao instance = new CouponDao();

    public static CouponDao getInstance() {
        return instance;
    }

    private CouponDao() {}

    // 1. 특정 사용자의 미사용 쿠폰 목록 조회
    public List<CouponDto> getCouponsByUser(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM coupons WHERE user_id = ? AND status = 'UNUSED' AND expire_date >= SYSDATE ORDER BY coupon_id DESC";
        List<CouponDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                CouponDto dto = new CouponDto();
                dto.setCouponId(rs.getInt("coupon_id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setCouponName(rs.getString("coupon_name"));
                dto.setDiscountAmount(rs.getInt("discount_amount"));
                dto.setIssueDate(rs.getTimestamp("issue_date"));
                dto.setExpireDate(rs.getDate("expire_date"));
                dto.setStatus(rs.getString("status"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 2. 쿠폰 생성 (관리자 일괄/단일 발행용)
    public int insertCoupon(CouponDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO coupons (coupon_id, user_id, coupon_name, discount_amount, issue_date, expire_date, status) "
                   + "VALUES (seq_coupons.NEXTVAL, ?, ?, ?, SYSDATE, ?, 'UNUSED')";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, dto.getUserId());
            pstmt.setString(2, dto.getCouponName());
            pstmt.setInt(3, dto.getDiscountAmount());
            pstmt.setDate(4, dto.getExpireDate());
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 3. 쿠폰 사용 완료 상태 업데이트
    public int updateCouponStatus(int couponId, String status) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "UPDATE coupons SET status = ? WHERE coupon_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, status);
            pstmt.setInt(2, couponId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }
}
