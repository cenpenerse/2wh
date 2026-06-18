package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.ReviewDto;
import com.bikerental.util.DBConnection;

public class ReviewDao {
    private static ReviewDao instance = new ReviewDao();

    public static ReviewDao getInstance() {
        return instance;
    }

    private ReviewDao() {}

    // 1. 특정 바이크에 대한 리뷰 목록 조회
    public List<ReviewDto> getReviewsByBike(int bikeId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT r.*, u.name AS user_nickname "
                   + "FROM reviews r "
                   + "JOIN users u ON r.user_id = u.user_id "
                   + "WHERE r.bike_id = ? "
                   + "ORDER BY r.review_id DESC";
        List<ReviewDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, bikeId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                ReviewDto dto = new ReviewDto();
                dto.setReviewId(rs.getInt("review_id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setReservationId(rs.getInt("reservation_id"));
                dto.setBikeId(rs.getInt("bike_id"));
                dto.setRating(rs.getInt("rating"));
                dto.setTitle(rs.getString("title"));
                dto.setContent(rs.getString("content"));
                dto.setCreatedAt(rs.getTimestamp("created_at"));
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

    // 2. 리뷰 작성
    public int insertReview(ReviewDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO reviews (review_id, user_id, reservation_id, bike_id, rating, title, content, created_at) "
                   + "VALUES (seq_reviews.NEXTVAL, ?, ?, ?, ?, ?, ?, SYSDATE)";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, dto.getUserId());
            pstmt.setInt(2, dto.getReservationId());
            pstmt.setInt(3, dto.getBikeId());
            pstmt.setInt(4, dto.getRating());
            pstmt.setString(5, dto.getTitle());
            pstmt.setString(6, dto.getContent());
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }
}
