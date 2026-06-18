package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.MemberDto;
import com.bikerental.util.DBConnection;

public class MemberDao {
    private static MemberDao instance = new MemberDao();

    public static MemberDao getInstance() {
        return instance;
    }

    private MemberDao() {}

    // 회원가입
    public int insertMember(MemberDto dto) throws Exception {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO users (user_id, email, password, name, phone, birth_date, license_number, role, point, join_date) "
                   + "VALUES (seq_users.NEXTVAL, ?, ?, ?, ?, ?, ?, 'USER', 0, SYSDATE)";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getEmail());
            pstmt.setString(2, dto.getPasswordHash());
            pstmt.setString(3, dto.getNickname());
            pstmt.setString(4, dto.getPhone());
            pstmt.setDate(5, dto.getBirthDate());
            pstmt.setString(6, dto.getLicenseNumber());
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 회원 상세 조회
    public MemberDto getMember(int memberId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM users WHERE user_id = ?";
        MemberDto dto = null;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, memberId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                dto = new MemberDto();
                dto.setMemberId(rs.getInt("user_id"));
                dto.setEmail(rs.getString("email"));
                dto.setPasswordHash(rs.getString("password"));
                dto.setNickname(rs.getString("name"));
                dto.setPhone(rs.getString("phone"));
                dto.setBirthDate(rs.getDate("birth_date"));
                dto.setLicenseNumber(rs.getString("license_number"));
                dto.setLicenseStatus(rs.getString("license_status"));
                dto.setMemberStatus(rs.getString("role"));
                dto.setPoint(rs.getInt("point"));
                dto.setCreatedAt(rs.getTimestamp("join_date"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return dto;
    }

    // 로그인
    public MemberDto getMemberByEmailAndPassword(String email, String passwordHash) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
        MemberDto dto = null;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, email);
            pstmt.setString(2, passwordHash);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                dto = new MemberDto();
                dto.setMemberId(rs.getInt("user_id"));
                dto.setEmail(rs.getString("email"));
                dto.setPasswordHash(rs.getString("password"));
                dto.setNickname(rs.getString("name"));
                dto.setPhone(rs.getString("phone"));
                dto.setBirthDate(rs.getDate("birth_date"));
                dto.setLicenseNumber(rs.getString("license_number"));
                dto.setLicenseStatus(rs.getString("license_status"));
                dto.setMemberStatus(rs.getString("role"));
                dto.setPoint(rs.getInt("point"));
                dto.setCreatedAt(rs.getTimestamp("join_date"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return dto;
    }

    // 회원 정보 수정
    public int updateMember(MemberDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "UPDATE users SET name = ?, password = ? WHERE user_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getNickname());
            pstmt.setString(2, dto.getPasswordHash());
            pstmt.setInt(3, dto.getMemberId());
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 회원 삭제 (탈퇴)
    public int deleteMember(int memberId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "DELETE FROM users WHERE user_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, memberId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 전체 회원 리스트 (관리자용)
    public List<MemberDto> getMemberList() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM users ORDER BY user_id DESC";
        List<MemberDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                MemberDto dto = new MemberDto();
                dto.setMemberId(rs.getInt("user_id"));
                dto.setEmail(rs.getString("email"));
                dto.setPasswordHash(rs.getString("password"));
                dto.setNickname(rs.getString("name"));
                dto.setPhone(rs.getString("phone"));
                dto.setBirthDate(rs.getDate("birth_date"));
                dto.setLicenseNumber(rs.getString("license_number"));
                dto.setLicenseStatus(rs.getString("license_status"));
                dto.setMemberStatus(rs.getString("role"));
                dto.setPoint(rs.getInt("point"));
                dto.setCreatedAt(rs.getTimestamp("join_date"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 면허 상태 변경 (승인 / 반려 / 대기) (관리자용)
    public int updateLicenseStatus(int memberId, String status) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "UPDATE users SET license_status = ? WHERE user_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, status);
            pstmt.setInt(2, memberId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 면허 번호 및 면허 상태 변경 (사용자 신청용)
    public int updateLicenseInfo(int memberId, String licenseNumber, String status) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "UPDATE users SET license_number = ?, license_status = ? WHERE user_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, licenseNumber);
            pstmt.setString(2, status);
            pstmt.setInt(3, memberId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }
}
