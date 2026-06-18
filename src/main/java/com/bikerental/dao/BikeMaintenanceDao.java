package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.BikeMaintenanceDto;
import com.bikerental.util.DBConnection;

public class BikeMaintenanceDao {
    private static BikeMaintenanceDao instance = new BikeMaintenanceDao();

    public static BikeMaintenanceDao getInstance() {
        return instance;
    }

    private BikeMaintenanceDao() {}

    // 전체 정비 이력 조회
    public List<BikeMaintenanceDto> getMaintenanceList() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT m.*, b.model_name "
                   + "FROM bike_maintenance m "
                   + "JOIN motorcycles b ON m.bike_id = b.bike_id "
                   + "ORDER BY m.maintenance_id DESC";
        List<BikeMaintenanceDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                BikeMaintenanceDto dto = new BikeMaintenanceDto();
                dto.setMaintenanceId(rs.getInt("maintenance_id"));
                dto.setBikeId(rs.getInt("bike_id"));
                dto.setMaintenanceDate(rs.getDate("maintenance_date"));
                dto.setMaintenanceType(rs.getString("maintenance_type"));
                dto.setContent(rs.getString("content"));
                dto.setCost(rs.getInt("cost"));
                dto.setShopName(rs.getString("shop_name"));
                dto.setNextCheckDate(rs.getDate("next_check_date"));
                dto.setModelName(rs.getString("model_name"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 정비 기록 등록
    public int insertMaintenance(BikeMaintenanceDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO bike_maintenance (maintenance_id, bike_id, maintenance_date, maintenance_type, content, cost, shop_name, next_check_date) "
                   + "VALUES (seq_bike_maintenance.NEXTVAL, ?, ?, ?, ?, ?, ?, ?)";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, dto.getBikeId());
            pstmt.setDate(2, dto.getMaintenanceDate());
            pstmt.setString(3, dto.getMaintenanceType());
            pstmt.setString(4, dto.getContent());
            pstmt.setInt(5, dto.getCost());
            pstmt.setString(6, dto.getShopName());
            pstmt.setDate(7, dto.getNextCheckDate());
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }
}
