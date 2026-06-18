package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.CommentDto;
import com.bikerental.util.DBConnection;

public class CommentDao {
    private static CommentDao instance = new CommentDao();

    public static CommentDao getInstance() {
        return instance;
    }

    private CommentDao() {}

    // 1. 댓글 등록
    public int insertComment(CommentDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO comments (comment_id, board_id, user_id, content, created_at) "
                   + "VALUES (seq_comments.NEXTVAL, ?, ?, ?, SYSDATE)";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, dto.getPostId());
            pstmt.setInt(2, dto.getMemberId());
            pstmt.setString(3, dto.getContent());
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 2. 특정 게시글의 댓글 목록 조회
    public List<CommentDto> getCommentList(int postId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT c.*, u.name AS member_nickname "
                   + "FROM comments c "
                   + "JOIN users u ON c.user_id = u.user_id "
                   + "WHERE c.board_id = ? "
                   + "ORDER BY c.comment_id ASC";
        List<CommentDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, postId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                CommentDto dto = new CommentDto();
                dto.setCommentId(rs.getInt("comment_id"));
                dto.setPostId(rs.getInt("board_id"));
                dto.setMemberId(rs.getInt("user_id"));
                dto.setContent(rs.getString("content"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setMemberNickname(rs.getString("member_nickname"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 3. 댓글 삭제
    public int deleteComment(int commentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "DELETE FROM comments WHERE comment_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, commentId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }
}
