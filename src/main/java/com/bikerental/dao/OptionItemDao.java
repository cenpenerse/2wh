package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import com.bikerental.dto.OptionItemDto;
import com.bikerental.util.DBConnection;

public class OptionItemDao {
    private static OptionItemDao instance = new OptionItemDao();

    public static OptionItemDao getInstance() {
        return instance;
    }

    private OptionItemDao() {}

    public List<OptionItemDto> getOptionList() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM option_items WHERE status = 'AVAILABLE' ORDER BY option_id ASC";
        List<OptionItemDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                OptionItemDto dto = new OptionItemDto();
                dto.setOptionId(rs.getInt("option_id"));
                dto.setOptionName(rs.getString("option_name"));
                dto.setStockQuantity(rs.getInt("stock_quantity"));
                dto.setDailyPrice(rs.getInt("daily_price"));
                dto.setImageFilename(rs.getString("image_filename"));
                dto.setStatus(rs.getString("status"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    public List<OptionItemDto> getOptionListAll() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM option_items ORDER BY option_id ASC";
        List<OptionItemDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                OptionItemDto dto = new OptionItemDto();
                dto.setOptionId(rs.getInt("option_id"));
                dto.setOptionName(rs.getString("option_name"));
                dto.setStockQuantity(rs.getInt("stock_quantity"));
                dto.setDailyPrice(rs.getInt("daily_price"));
                dto.setImageFilename(rs.getString("image_filename"));
                dto.setStatus(rs.getString("status"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    public OptionItemDto getOption(int optionId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM option_items WHERE option_id = ?";
        OptionItemDto dto = null;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, optionId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                dto = new OptionItemDto();
                dto.setOptionId(rs.getInt("option_id"));
                dto.setOptionName(rs.getString("option_name"));
                dto.setStockQuantity(rs.getInt("stock_quantity"));
                dto.setDailyPrice(rs.getInt("daily_price"));
                dto.setImageFilename(rs.getString("image_filename"));
                dto.setStatus(rs.getString("status"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return dto;
    }

    public int insertOption(OptionItemDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO option_items (option_id, option_name, stock_quantity, daily_price, image_filename, status) " +
                     "VALUES (seq_option_items.NEXTVAL, ?, ?, ?, ?, ?)";
        int result = 0;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getOptionName());
            pstmt.setInt(2, dto.getStockQuantity());
            pstmt.setInt(3, dto.getDailyPrice());
            pstmt.setString(4, dto.getImageFilename());
            pstmt.setString(5, dto.getStatus());
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    public int updateOption(OptionItemDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "UPDATE option_items SET option_name = ?, stock_quantity = ?, daily_price = ?, image_filename = ?, status = ? WHERE option_id = ?";
        int result = 0;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getOptionName());
            pstmt.setInt(2, dto.getStockQuantity());
            pstmt.setInt(3, dto.getDailyPrice());
            pstmt.setString(4, dto.getImageFilename());
            pstmt.setString(5, dto.getStatus());
            pstmt.setInt(6, dto.getOptionId());
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    public int deleteOption(int optionId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "DELETE FROM option_items WHERE option_id = ?";
        int result = 0;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, optionId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }
}
