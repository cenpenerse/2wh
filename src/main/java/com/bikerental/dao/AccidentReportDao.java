package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.AccidentReportDto;
import com.bikerental.util.DBConnection;

public class AccidentReportDao {
    private static AccidentReportDao instance = new AccidentReportDao();

    public static AccidentReportDao getInstance() {
        return instance;
    }

    private AccidentReportDao() {}

    // 사고 접수 등록
    public int insertReport(AccidentReportDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO accident_reports (report_id, reservation_id, user_id, accident_date, accident_location, accident_description, photo_path, status) "
                   + "VALUES (seq_accident_reports.NEXTVAL, ?, ?, ?, ?, ?, ?, '접수')";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, dto.getReservationId());
            pstmt.setInt(2, dto.getUserId());
            pstmt.setTimestamp(3, dto.getAccidentDate());
            pstmt.setString(4, dto.getAccidentLocation());
            pstmt.setString(5, dto.getAccidentDescription());
            pstmt.setString(6, dto.getPhotoPath());
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 전체 사고 접수 목록 (관리자용)
    public List<AccidentReportDto> getReportsAll() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT ar.*, u.name AS user_nickname, u.email AS user_email, m.model_name AS bike_name "
                   + "FROM accident_reports ar "
                   + "JOIN users u ON ar.user_id = u.user_id "
                   + "JOIN reservations r ON ar.reservation_id = r.reservation_id "
                   + "JOIN motorcycles m ON r.bike_id = m.bike_id "
                   + "ORDER BY ar.report_id DESC";
        List<AccidentReportDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                AccidentReportDto dto = new AccidentReportDto();
                dto.setReportId(rs.getInt("report_id"));
                dto.setReservationId(rs.getInt("reservation_id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setAccidentDate(rs.getTimestamp("accident_date"));
                dto.setAccidentLocation(rs.getString("accident_location"));
                dto.setAccidentDescription(rs.getString("accident_description"));
                dto.setPhotoPath(rs.getString("photo_path"));
                dto.setInsuranceClaimNum(rs.getString("insurance_claim_num"));
                dto.setFaultRatio(rs.getInt("fault_ratio"));
                dto.setStatus(rs.getString("status"));
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

    // 특정 회원의 사고 접수 목록 (사용자용)
    public List<AccidentReportDto> getReportsByUser(int userId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT ar.*, u.name AS user_nickname, u.email AS user_email, m.model_name AS bike_name "
                   + "FROM accident_reports ar "
                   + "JOIN users u ON ar.user_id = u.user_id "
                   + "JOIN reservations r ON ar.reservation_id = r.reservation_id "
                   + "JOIN motorcycles m ON r.bike_id = m.bike_id "
                   + "WHERE ar.user_id = ? "
                   + "ORDER BY ar.report_id DESC";
        List<AccidentReportDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                AccidentReportDto dto = new AccidentReportDto();
                dto.setReportId(rs.getInt("report_id"));
                dto.setReservationId(rs.getInt("reservation_id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setAccidentDate(rs.getTimestamp("accident_date"));
                dto.setAccidentLocation(rs.getString("accident_location"));
                dto.setAccidentDescription(rs.getString("accident_description"));
                dto.setPhotoPath(rs.getString("photo_path"));
                dto.setInsuranceClaimNum(rs.getString("insurance_claim_num"));
                dto.setFaultRatio(rs.getInt("fault_ratio"));
                dto.setStatus(rs.getString("status"));
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

    // 사고 처리 상태 및 보험 접수 정보 업데이트
    public int updateReportStatus(int reportId, String status, String claimNum, int faultRatio) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "UPDATE accident_reports SET status = ?, insurance_claim_num = ?, fault_ratio = ? WHERE report_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, status);
            pstmt.setString(2, claimNum);
            pstmt.setInt(3, faultRatio);
            pstmt.setInt(4, reportId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 단일 사고 정보 조회
    public AccidentReportDto getReport(int reportId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT ar.*, u.name AS user_nickname, u.email AS user_email, m.model_name AS bike_name "
                   + "FROM accident_reports ar "
                   + "JOIN users u ON ar.user_id = u.user_id "
                   + "JOIN reservations r ON ar.reservation_id = r.reservation_id "
                   + "JOIN motorcycles m ON r.bike_id = m.bike_id "
                   + "WHERE ar.report_id = ?";
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, reportId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                AccidentReportDto dto = new AccidentReportDto();
                dto.setReportId(rs.getInt("report_id"));
                dto.setReservationId(rs.getInt("reservation_id"));
                dto.setUserId(rs.getInt("user_id"));
                dto.setAccidentDate(rs.getTimestamp("accident_date"));
                dto.setAccidentLocation(rs.getString("accident_location"));
                dto.setAccidentDescription(rs.getString("accident_description"));
                dto.setPhotoPath(rs.getString("photo_path"));
                dto.setInsuranceClaimNum(rs.getString("insurance_claim_num"));
                dto.setFaultRatio(rs.getInt("fault_ratio"));
                dto.setStatus(rs.getString("status"));
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
