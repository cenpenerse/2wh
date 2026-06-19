package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.LicenseAuditDto;
import com.bikerental.util.DBConnection;

public class LicenseAuditDao {
    private static LicenseAuditDao instance = new LicenseAuditDao();

    public static LicenseAuditDao getInstance() {
        return instance;
    }

    private LicenseAuditDao() {}

    // 특정 회원의 면허증 검증 심사 목록 조회
    public List<LicenseAuditDto> getAuditsByUser(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT a.*, u.email AS user_email, u.name AS user_name, "
                   + "       adm.email AS admin_email, adm.name AS admin_name "
                   + "FROM license_audit a "
                   + "JOIN users u ON a.user_id = u.user_id "
                   + "LEFT JOIN users adm ON a.admin_id = adm.user_id "
                   + "WHERE a.user_id = ? "
                   + "ORDER BY a.audit_id DESC";
        List<LicenseAuditDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                LicenseAuditDto dto = new LicenseAuditDto();
                dto.setAuditId(rs.getInt("audit_id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setLicenseType(rs.getString("license_type"));
                dto.setLicenseImage(rs.getString("license_image"));
                dto.setStatus(rs.getString("status"));
                dto.setRejectReason(rs.getString("reject_reason"));
                dto.setAuditDate(rs.getTimestamp("audit_date"));
                dto.setAdminId(rs.getInt("admin_id"));
                dto.setUserEmail(rs.getString("user_email"));
                dto.setUserNickname(rs.getString("user_name"));
                dto.setAdminEmail(rs.getString("admin_email"));
                dto.setAdminNickname(rs.getString("admin_name"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 전체 회원의 면허증 검증 심사 목록 조회 (관리자용)
    public List<LicenseAuditDto> getAuditsAll() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT a.*, u.email AS user_email, u.name AS user_name, "
                   + "       adm.email AS admin_email, adm.name AS admin_name "
                   + "FROM license_audit a "
                   + "JOIN users u ON a.user_id = u.user_id "
                   + "LEFT JOIN users adm ON a.admin_id = adm.user_id "
                   + "ORDER BY a.audit_id DESC";
        List<LicenseAuditDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                LicenseAuditDto dto = new LicenseAuditDto();
                dto.setAuditId(rs.getInt("audit_id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setLicenseType(rs.getString("license_type"));
                dto.setLicenseImage(rs.getString("license_image"));
                dto.setStatus(rs.getString("status"));
                dto.setRejectReason(rs.getString("reject_reason"));
                dto.setAuditDate(rs.getTimestamp("audit_date"));
                dto.setAdminId(rs.getInt("admin_id"));
                dto.setUserEmail(rs.getString("user_email"));
                dto.setUserNickname(rs.getString("user_name"));
                dto.setAdminEmail(rs.getString("admin_email"));
                dto.setAdminNickname(rs.getString("admin_name"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 면허증 검증 심사 신청 등록
    public int insertAudit(LicenseAuditDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO license_audit (audit_id, user_id, license_type, license_image, status, reject_reason, audit_date, admin_id) "
                   + "VALUES (seq_license_audit.NEXTVAL, ?, ?, ?, 'PENDING', NULL, NULL, NULL)";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, dto.getUserId());
            pstmt.setString(2, dto.getLicenseType());
            pstmt.setString(3, dto.getLicenseImage());
            result = pstmt.executeUpdate();
            if (result > 0) {
                NotificationDao.send(dto.getUserId(), "알림톡", "🪪 면허증 검증 심사 신청이 정상적으로 접수되었습니다. 영업일 기준 1~2일 내에 심사가 완료됩니다.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 면허증 검증 심사 처리 (승인/반려)
    public int updateAuditStatus(int auditId, String status, String rejectReason, int adminId) {
        Connection conn = null;
        PreparedStatement pstmt1 = null;
        PreparedStatement pstmt2 = null;
        ResultSet rs = null;
        String sqlAudit = "UPDATE license_audit SET status = ?, reject_reason = ?, audit_date = SYSDATE, admin_id = ? WHERE audit_id = ?";
        String sqlUser = "UPDATE users SET license_status = ? WHERE user_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. 심사 상태 업데이트
            pstmt1 = conn.prepareStatement(sqlAudit);
            pstmt1.setString(1, status);
            pstmt1.setString(2, rejectReason);
            pstmt1.setInt(3, adminId);
            pstmt1.setInt(4, auditId);
            result = pstmt1.executeUpdate();

            if (result > 0) {
                // 2. 심사 대상 user_id 조회
                int targetUserId = -1;
                String sqlGetUserId = "SELECT user_id FROM license_audit WHERE audit_id = ?";
                try (PreparedStatement pstmtGet = conn.prepareStatement(sqlGetUserId)) {
                    pstmtGet.setInt(1, auditId);
                    try (ResultSet rsGet = pstmtGet.executeQuery()) {
                        if (rsGet.next()) {
                            targetUserId = rsGet.getInt("user_id");
                        }
                    }
                }

                if (targetUserId > 0) {
                    // 3. 사용자 테이블의 면허 상태 업데이트
                    pstmt2 = conn.prepareStatement(sqlUser);
                    pstmt2.setString(1, status);
                    pstmt2.setInt(2, targetUserId);
                    pstmt2.executeUpdate();
                    try {
                        String notiContent = "🪪 면허증 검증 심사 결과: [" + (status.equals("APPROVED") ? "승인 완료" : "반려됨") + "]";
                        if (status.equals("REJECTED") && rejectReason != null) {
                            notiContent += " (반려 사유: " + rejectReason + ")";
                        }
                        NotificationDao.send(targetUserId, "알림톡", notiContent);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
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
            try { if (pstmt2 != null) pstmt2.close(); } catch (Exception e) {}
            try { if (pstmt1 != null) pstmt1.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return result;
    }
}
