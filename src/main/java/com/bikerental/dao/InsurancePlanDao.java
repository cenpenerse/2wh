package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.InsurancePlanDto;
import com.bikerental.util.DBConnection;

public class InsurancePlanDao {
    private static InsurancePlanDao instance = new InsurancePlanDao();

    public static InsurancePlanDao getInstance() {
        return instance;
    }

    private InsurancePlanDao() {}

    // 보험 상품 목록 전체 조회
    public List<InsurancePlanDto> getInsurancePlansAll() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM insurance_plans ORDER BY plan_id ASC";
        List<InsurancePlanDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                InsurancePlanDto dto = new InsurancePlanDto();
                dto.setPlanId(rs.getInt("plan_id"));
                dto.setPlanName(rs.getString("plan_name"));
                dto.setDailyFee(rs.getInt("daily_fee"));
                dto.setDeductibleLimit(rs.getInt("deductible_limit"));
                dto.setCoverageLimit(rs.getInt("coverage_limit"));
                dto.setTermsContent(rs.getString("terms_content"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 단일 보험 상품 조회
    public InsurancePlanDto getInsurancePlan(int planId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM insurance_plans WHERE plan_id = ?";
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, planId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                InsurancePlanDto dto = new InsurancePlanDto();
                dto.setPlanId(rs.getInt("plan_id"));
                dto.setPlanName(rs.getString("plan_name"));
                dto.setDailyFee(rs.getInt("daily_fee"));
                dto.setDeductibleLimit(rs.getInt("deductible_limit"));
                dto.setCoverageLimit(rs.getInt("coverage_limit"));
                dto.setTermsContent(rs.getString("terms_content"));
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
