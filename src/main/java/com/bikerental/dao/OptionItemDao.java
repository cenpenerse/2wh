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
}
