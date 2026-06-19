package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.PointHistoryDto;
import com.bikerental.util.DBConnection;

public class PointHistoryDao {
    private static PointHistoryDao instance = new PointHistoryDao();

    public static PointHistoryDao getInstance() {
        return instance;
    }

    private PointHistoryDao() {}

    // 포인트 변동 내역 등록 및 사용자 포인트 업데이트 & 등급 조정 (트랜잭션/Connection 주입식 권장)
    public int insertPointHistory(Connection conn, int userId, int amount, String reason) throws Exception {
        PreparedStatement pstmtUserGet = null;
        PreparedStatement pstmtUserUp = null;
        PreparedStatement pstmtHist = null;
        ResultSet rsUser = null;
        int result = -1;
        try {
            // 1. 현재 포인트 및 누적 포인트(등급 판단용) 조회를 위해 회원 정보 조회
            String sqlUserGet = "SELECT point FROM users WHERE user_id = ?";
            pstmtUserGet = conn.prepareStatement(sqlUserGet);
            pstmtUserGet.setInt(1, userId);
            rsUser = pstmtUserGet.executeQuery();
            int currentPoints = 0;
            if (rsUser.next()) {
                currentPoints = rsUser.getInt("point");
            }
            rsUser.close();

            int newPoints = currentPoints + amount;
            if (newPoints < 0) newPoints = 0;

            // 2. 등급 판단용 누적 획득 포인트 계산 (모든 양수 amount의 합)
            String sqlSum = "SELECT SUM(amount) FROM point_history WHERE user_id = ? AND amount > 0";
            PreparedStatement pstmtSum = conn.prepareStatement(sqlSum);
            pstmtSum.setInt(1, userId);
            ResultSet rsSum = pstmtSum.executeQuery();
            int totalEarned = amount > 0 ? amount : 0;
            if (rsSum.next()) {
                totalEarned += rsSum.getInt(1);
            }
            rsSum.close();
            pstmtSum.close();

            // 등급 갱신 결정
            String newGrade = "SILVER";
            if (totalEarned >= 30000) {
                newGrade = "VIP";
            } else if (totalEarned >= 10000) {
                newGrade = "GOLD";
            }

            // 3. 사용자 테이블 업데이트
            String sqlUserUp = "UPDATE users SET point = ?, user_grade = ? WHERE user_id = ?";
            pstmtUserUp = conn.prepareStatement(sqlUserUp);
            pstmtUserUp.setInt(1, newPoints);
            pstmtUserUp.setString(2, newGrade);
            pstmtUserUp.setInt(3, userId);
            pstmtUserUp.executeUpdate();

            // 4. 포인트 이력 인서트
            String sqlHist = "INSERT INTO point_history (history_id, user_id, amount, reason, accumulated_points, created_at) "
                           + "VALUES (seq_point_history.NEXTVAL, ?, ?, ?, ?, SYSDATE)";
            pstmtHist = conn.prepareStatement(sqlHist);
            pstmtHist.setInt(1, userId);
            pstmtHist.setInt(2, amount);
            pstmtHist.setString(3, reason);
            pstmtHist.setInt(4, newPoints);
            result = pstmtHist.executeUpdate();
        } finally {
            if (rsUser != null) try { rsUser.close(); } catch(Exception e) {}
            if (pstmtUserGet != null) try { pstmtUserGet.close(); } catch(Exception e) {}
            if (pstmtUserUp != null) try { pstmtUserUp.close(); } catch(Exception e) {}
            if (pstmtHist != null) try { pstmtHist.close(); } catch(Exception e) {}
        }
        return result;
    }

    // 단독 실행용 (Connection 관리 포함)
    public int addPointHistory(int userId, int amount, String reason) {
        Connection conn = null;
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            result = insertPointHistory(conn, userId, amount, reason);
            conn.commit();
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch(Exception ex) {}
            }
        } finally {
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
        return result;
    }

    // 특정 회원의 포인트 변동 내역 조회
    public List<PointHistoryDto> getPointHistoriesByUser(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM point_history WHERE user_id = ? ORDER BY history_id DESC";
        List<PointHistoryDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                PointHistoryDto dto = new PointHistoryDto();
                dto.setHistoryId(rs.getInt("history_id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setAmount(rs.getInt("amount"));
                dto.setReason(rs.getString("reason"));
                dto.setAccumulatedPoints(rs.getInt("accumulated_points"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
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
