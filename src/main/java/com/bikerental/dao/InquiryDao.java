package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.InquiryDto;
import com.bikerental.util.DBConnection;

public class InquiryDao {
    private static InquiryDao instance = new InquiryDao();

    public static InquiryDao getInstance() {
        return instance;
    }

    private InquiryDao() {}

    // 1. 특정 사용자의 1:1 문의 목록 조회
    public List<InquiryDto> getInquiriesByUser(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM inquiries WHERE user_id = ? ORDER BY inquiry_id DESC";
        List<InquiryDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                InquiryDto dto = new InquiryDto();
                dto.setInquiryId(rs.getInt("inquiry_id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setTitle(rs.getString("title"));
                dto.setContent(rs.getString("content"));
                dto.setAnswerContent(rs.getString("answer_content"));
                dto.setStatus(rs.getString("status"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setAnsweredAt(rs.getTimestamp("answered_at"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 2. 전체 문의 목록 조회 (관리자용)
    public List<InquiryDto> getInquiriesAll() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT i.*, u.name AS user_nickname "
                   + "FROM inquiries i "
                   + "JOIN users u ON i.user_id = u.user_id "
                   + "ORDER BY i.inquiry_id DESC";
        List<InquiryDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                InquiryDto dto = new InquiryDto();
                dto.setInquiryId(rs.getInt("inquiry_id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setTitle(rs.getString("title"));
                dto.setContent(rs.getString("content"));
                dto.setAnswerContent(rs.getString("answer_content"));
                dto.setStatus(rs.getString("status"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setAnsweredAt(rs.getTimestamp("answered_at"));
                dto.setUserNickname(rs.getString("user_nickname"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 3. 문의글 등록 (사용자)
    public int insertInquiry(InquiryDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO inquiries (inquiry_id, user_id, title, content, status, created_at) "
                   + "VALUES (seq_inquiries.NEXTVAL, ?, ?, ?, 'PENDING', SYSDATE)";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, dto.getUserId());
            pstmt.setString(2, dto.getTitle());
            pstmt.setString(3, dto.getContent());
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 4. 문의글 답변 등록 (관리자)
    public int updateAnswer(int inquiryId, String answerContent) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "UPDATE inquiries SET answer_content = ?, status = 'ANSWERED', answered_at = SYSDATE WHERE inquiry_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, answerContent);
            pstmt.setInt(2, inquiryId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }
}
