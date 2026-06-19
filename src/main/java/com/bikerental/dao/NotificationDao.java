package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.NotificationDto;
import com.bikerental.util.DBConnection;

public class NotificationDao {
    private static NotificationDao instance = new NotificationDao();

    public static NotificationDao getInstance() {
        return instance;
    }

    private NotificationDao() {}

    // 알림 발송 등록
    public int insertNotification(NotificationDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO notifications (notification_id, user_id, notification_type, content, created_at, is_received) "
                   + "VALUES (seq_notifications.NEXTVAL, ?, ?, ?, SYSDATE, 'N')";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, dto.getUserId());
            pstmt.setString(2, dto.getNotificationType());
            pstmt.setString(3, dto.getContent());
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 편의용 알림 전송 스태틱 헬퍼 메소드
    public static void send(int userId, String type, String content) {
        NotificationDto dto = new NotificationDto();
        dto.setUserId(userId);
        dto.setNotificationType(type);
        dto.setContent(content);
        getInstance().insertNotification(dto);
    }

    // 전체 알림 발송 이력 조회 (관리자용)
    public List<NotificationDto> getNotificationsAll() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT n.*, u.name AS user_nickname, u.email AS user_email "
                   + "FROM notifications n "
                   + "JOIN users u ON n.user_id = u.user_id "
                   + "ORDER BY n.notification_id DESC";
        List<NotificationDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                NotificationDto dto = new NotificationDto();
                dto.setNotificationId(rs.getInt("notification_id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setNotificationType(rs.getString("notification_type"));
                dto.setContent(rs.getString("content"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setIsReceived(rs.getString("is_received"));
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

    // 특정 사용자의 수신 알림 목록 조회 (사용자용)
    public List<NotificationDto> getNotificationsByUser(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT n.*, u.name AS user_nickname, u.email AS user_email "
                   + "FROM notifications n "
                   + "JOIN users u ON n.user_id = u.user_id "
                   + "WHERE n.user_id = ? "
                   + "ORDER BY n.notification_id DESC";
        List<NotificationDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                NotificationDto dto = new NotificationDto();
                dto.setNotificationId(rs.getInt("notification_id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setNotificationType(rs.getString("notification_type"));
                dto.setContent(rs.getString("content"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setIsReceived(rs.getString("is_received"));
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

    // 알림 수신 완료/읽음 처리
    public int markAsRead(int notificationId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "UPDATE notifications SET is_received = 'Y' WHERE notification_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, notificationId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }
}
