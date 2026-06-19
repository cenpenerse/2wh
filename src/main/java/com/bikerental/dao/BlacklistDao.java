package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.BlacklistDto;
import com.bikerental.util.DBConnection;

public class BlacklistDao {
    private static BlacklistDao instance = new BlacklistDao();

    public static BlacklistDao getInstance() {
        return instance;
    }

    private BlacklistDao() {}

    // 블랙리스트 여부 확인 (현재 차단 상태인가?)
    public boolean isUserBanned(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        // 영구차단이거나, 기간차단이면서 현재 시간이 차단 시작일과 만료일 사이인 경우
        String sql = "SELECT COUNT(*) FROM blacklist "
                   + "WHERE user_id = ? AND ("
                   + "  ban_type = '영구차단' OR "
                   + "  (ban_type = '기간차단' AND SYSDATE >= start_date AND (end_date IS NULL OR SYSDATE <= end_date))"
                   + ")";
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return false;
    }

    // 차단 사유 조회
    public String getBanReason(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT reason, ban_type, end_date FROM blacklist "
                   + "WHERE user_id = ? AND ("
                   + "  ban_type = '영구차단' OR "
                   + "  (ban_type = '기간차단' AND SYSDATE >= start_date AND (end_date IS NULL OR SYSDATE <= end_date))"
                   + ") ORDER BY blacklist_id DESC";
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                String type = rs.getString("ban_type");
                String reason = rs.getString("reason");
                java.sql.Date end = rs.getDate("end_date");
                if ("기간차단".equals(type) && end != null) {
                    return reason + " (차단 만료일: " + end.toString() + ")";
                }
                return reason + " (" + type + ")";
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return "서비스 이용이 제한되었습니다.";
    }

    // 블랙리스트 등록
    public int insertBlacklist(BlacklistDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO blacklist (blacklist_id, user_id, ban_type, reason, start_date, end_date, admin_id) "
                   + "VALUES (seq_blacklist.NEXTVAL, ?, ?, ?, SYSDATE, ?, ?)";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, dto.getUserId());
            pstmt.setString(2, dto.getBanType());
            pstmt.setString(3, dto.getReason());
            pstmt.setDate(4, dto.getEndDate());
            if (dto.getAdminId() > 0) {
                pstmt.setInt(5, dto.getAdminId());
            } else {
                pstmt.setNull(5, java.sql.Types.NUMERIC);
            }
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 블랙리스트 해제 (기록 삭제)
    public int deleteBlacklist(int blacklistId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "DELETE FROM blacklist WHERE blacklist_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, blacklistId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 블랙리스트 전체 목록 조회 (관리자용)
    public List<BlacklistDto> getBlacklistAll() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT bl.*, u.name AS user_nickname, u.email AS user_email, a.name AS admin_nickname "
                   + "FROM blacklist bl "
                   + "JOIN users u ON bl.user_id = u.user_id "
                   + "LEFT JOIN users a ON bl.admin_id = a.user_id "
                   + "ORDER BY bl.blacklist_id DESC";
        List<BlacklistDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                BlacklistDto dto = new BlacklistDto();
                dto.setBlacklistId(rs.getInt("blacklist_id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setBanType(rs.getString("ban_type"));
                dto.setReason(rs.getString("reason"));
                dto.setStartDate(rs.getDate("start_date"));
                dto.setEndDate(rs.getDate("end_date"));
                dto.setAdminId(rs.getInt("admin_id"));
                dto.setUserNickname(rs.getString("user_nickname"));
                dto.setUserEmail(rs.getString("user_email"));
                dto.setAdminNickname(rs.getString("admin_nickname"));
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
