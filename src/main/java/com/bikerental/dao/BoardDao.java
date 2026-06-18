package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.BoardDto;
import com.bikerental.util.DBConnection;

public class BoardDao {
    private static BoardDao instance = new BoardDao();

    public static BoardDao getInstance() {
        return instance;
    }

    private BoardDao() {}

    // 1. 게시글 등록
    public int insertPost(BoardDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO boards (board_id, user_id, category, title, content, view_count, like_count, filename, created_at) "
                   + "VALUES (seq_boards.NEXTVAL, ?, ?, ?, ?, 0, 0, ?, SYSDATE)";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, dto.getMemberId());
            pstmt.setString(2, dto.getBoardType()); // boardType -> category 매핑
            pstmt.setString(3, dto.getTitle());
            pstmt.setString(4, dto.getContent());
            pstmt.setString(5, dto.getFilename());
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 2. 단일 게시글 조회
    public BoardDto getPost(int postId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT b.*, u.name AS user_nickname "
                   + "FROM boards b "
                   + "JOIN users u ON b.user_id = u.user_id "
                   + "WHERE b.board_id = ?";
        BoardDto dto = null;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, postId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                dto = new BoardDto();
                dto.setPostId(rs.getInt("board_id"));
                dto.setMemberId(rs.getInt("user_id"));
                dto.setTitle(rs.getString("title"));
                dto.setContent(rs.getString("content"));
                dto.setViewCount(rs.getInt("view_count"));
                dto.setBoardType(rs.getString("category"));
                dto.setFilename(rs.getString("filename"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setMemberNickname(rs.getString("user_nickname"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return dto;
    }

    // 3. 게시글 목록 조회 (페이징 적용)
    public List<BoardDto> getPostList(String category, int startRow, int endRow) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        String sql = "SELECT * FROM ("
                   + "  SELECT ROWNUM rnum, a.* FROM ("
                   + "    SELECT b.*, u.name AS user_nickname "
                   + "    FROM boards b "
                   + "    JOIN users u ON b.user_id = u.user_id "
                   + "    WHERE b.category = ? "
                   + "    ORDER BY b.board_id DESC"
                   + "  ) a "
                   + "  WHERE ROWNUM <= ?"
                   + ") "
                   + "WHERE rnum >= ?";
                   
        List<BoardDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, category);
            pstmt.setInt(2, endRow);
            pstmt.setInt(3, startRow);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                BoardDto dto = new BoardDto();
                dto.setPostId(rs.getInt("board_id"));
                dto.setMemberId(rs.getInt("user_id"));
                dto.setTitle(rs.getString("title"));
                dto.setContent(rs.getString("content"));
                dto.setViewCount(rs.getInt("view_count"));
                dto.setBoardType(rs.getString("category"));
                dto.setFilename(rs.getString("filename"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
                dto.setMemberNickname(rs.getString("user_nickname"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 4. 특정 게시판의 전체 글 수 조회
    public int getPostCount(String category) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT COUNT(*) FROM boards WHERE category = ?";
        int count = 0;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, category);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return count;
    }

    // 5. 조회수 1 증가
    public void updateViewCount(int postId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "UPDATE boards SET view_count = view_count + 1 WHERE board_id = ?";
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, postId);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
    }

    // 6. 게시글 수정
    public int updatePost(BoardDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "UPDATE boards SET title = ?, content = ?, filename = ? WHERE board_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getTitle());
            pstmt.setString(2, dto.getContent());
            pstmt.setString(3, dto.getFilename());
            pstmt.setInt(4, dto.getPostId());
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 7. 게시글 삭제 (물리 삭제 적용)
    public int deletePost(int postId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "DELETE FROM boards WHERE board_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, postId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }
}
