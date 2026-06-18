package com.bikerental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.bikerental.dto.BikeDto;
import com.bikerental.util.DBConnection;

public class BikeDao {
    private static BikeDao instance = new BikeDao();

    public static BikeDao getInstance() {
        return instance;
    }

    private BikeDao() {}

    // 바이크 등록 (관리자용)
    public int insertBike(BikeDto dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO motorcycles (bike_id, brand_id, shop_id, model_name, cc, year, color, daily_price, mileage, status, description) "
                   + "VALUES (seq_motorcycles.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?, 'AVAILABLE', ?)";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(dto.getBrandCountry())); // brandId를 임시로 사용하거나 필드 주입
            pstmt.setInt(2, Integer.parseInt(dto.getShopAddress()));   // shopId를 임시로 사용하거나 필드 주입
            pstmt.setString(3, dto.getBikeName());
            pstmt.setInt(4, dto.getCc());
            pstmt.setInt(5, dto.getYear());
            pstmt.setString(6, dto.getColor());
            pstmt.setInt(7, dto.getDailyPrice());
            pstmt.setInt(8, dto.getMileage());
            pstmt.setString(9, dto.getDescription());
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 바이크 1개 상세 정보 조회 (조인 처리)
    public BikeDto getBike(int bikeId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT m.*, b.brand_name, b.country AS brand_country, s.shop_name, s.address AS shop_address, "
                   + "       (SELECT image_url FROM bike_images WHERE bike_id = m.bike_id AND is_thumbnail = 'Y' AND ROWNUM = 1) AS bike_image_url "
                   + "FROM motorcycles m "
                   + "LEFT JOIN brands b ON m.brand_id = b.brand_id "
                   + "LEFT JOIN rental_shops s ON m.shop_id = s.shop_id "
                   + "WHERE m.bike_id = ?";
        BikeDto dto = null;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, bikeId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                dto = new BikeDto();
                dto.setBikeId(rs.getInt("bike_id"));
                dto.setBikeName(rs.getString("model_name"));
                dto.setCc(rs.getInt("cc"));
                dto.setYear(rs.getInt("year"));
                dto.setColor(rs.getString("color"));
                dto.setDailyPrice(rs.getInt("daily_price"));
                dto.setMileage(rs.getInt("mileage"));
                dto.setStatus(rs.getString("status"));
                dto.setDescription(rs.getString("description"));
                dto.setBikeImageUrl(rs.getString("bike_image_url"));
                dto.setBrandName(rs.getString("brand_name"));
                dto.setBrandCountry(rs.getString("brand_country"));
                dto.setShopName(rs.getString("shop_name"));
                dto.setShopAddress(rs.getString("shop_address"));
                
                // 가상 평점 연동
                dto.setRatingAvg(5.0);
                dto.setReviewCount(3);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return dto;
    }

    // 바이크 전체 목록 조회 (대표 이미지 포함)
    public List<BikeDto> getBikeList() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT m.*, b.brand_name, s.shop_name, "
                   + "       (SELECT image_url FROM bike_images WHERE bike_id = m.bike_id AND is_thumbnail = 'Y' AND ROWNUM = 1) AS bike_image_url "
                   + "FROM motorcycles m "
                   + "LEFT JOIN brands b ON m.brand_id = b.brand_id "
                   + "LEFT JOIN rental_shops s ON m.shop_id = s.shop_id "
                   + "WHERE m.shop_id = 1 "
                   + "ORDER BY m.bike_id ASC";
        List<BikeDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                BikeDto dto = new BikeDto();
                dto.setBikeId(rs.getInt("bike_id"));
                dto.setBikeName(rs.getString("model_name"));
                dto.setCc(rs.getInt("cc"));
                dto.setYear(rs.getInt("year"));
                dto.setColor(rs.getString("color"));
                dto.setDailyPrice(rs.getInt("daily_price"));
                dto.setMileage(rs.getInt("mileage"));
                dto.setStatus(rs.getString("status"));
                dto.setDescription(rs.getString("description"));
                dto.setBikeImageUrl(rs.getString("bike_image_url"));
                dto.setBrandName(rs.getString("brand_name"));
                dto.setShopName(rs.getString("shop_name"));
                
                dto.setRatingAvg(5.0);
                dto.setReviewCount(2);
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 다중 필터링 검색 (지점, 제조사, 배기량)
    public List<BikeDto> getBikeListFiltered(String shopId, String brandId, String ccType) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        StringBuilder sql = new StringBuilder(
            "SELECT m.*, b.brand_name, s.shop_name, " +
            "       (SELECT image_url FROM bike_images WHERE bike_id = m.bike_id AND is_thumbnail = 'Y' AND ROWNUM = 1) AS bike_image_url " +
            "FROM motorcycles m " +
            "LEFT JOIN brands b ON m.brand_id = b.brand_id " +
            "LEFT JOIN rental_shops s ON m.shop_id = s.shop_id " +
            "WHERE 1=1"
        );
        List<Object> params = new ArrayList<>();
        
        if (shopId != null && !shopId.trim().isEmpty() && !shopId.equals("all")) {
            sql.append(" AND m.shop_id = ?");
            params.add(Integer.parseInt(shopId));
        }
        if (brandId != null && !brandId.trim().isEmpty() && !brandId.equals("all")) {
            sql.append(" AND m.brand_id = ?");
            params.add(Integer.parseInt(brandId));
        }
        if (ccType != null && !ccType.trim().isEmpty() && !ccType.equals("all")) {
            if (ccType.equals("SCOOTER")) {
                sql.append(" AND m.cc < 125");
            } else if (ccType.equals("QUARTER")) {
                sql.append(" AND m.cc >= 125 AND m.cc <= 400");
            } else if (ccType.equals("LITER")) {
                sql.append(" AND m.cc > 400");
            }
        }
        sql.append(" ORDER BY m.bike_id ASC");
        
        List<BikeDto> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }
            rs = pstmt.executeQuery();
            while (rs.next()) {
                BikeDto dto = new BikeDto();
                dto.setBikeId(rs.getInt("bike_id"));
                dto.setBikeName(rs.getString("model_name"));
                dto.setCc(rs.getInt("cc"));
                dto.setYear(rs.getInt("year"));
                dto.setColor(rs.getString("color"));
                dto.setDailyPrice(rs.getInt("daily_price"));
                dto.setMileage(rs.getInt("mileage"));
                dto.setStatus(rs.getString("status"));
                dto.setDescription(rs.getString("description"));
                dto.setBikeImageUrl(rs.getString("bike_image_url"));
                dto.setBrandName(rs.getString("brand_name"));
                dto.setShopName(rs.getString("shop_name"));
                
                dto.setRatingAvg(5.0);
                dto.setReviewCount(1);
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 렌탈 지점 리스트 로드 (지점 필터링 드롭다운용)
    public List<Map<String, Object>> getShopList() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT shop_id, shop_name FROM rental_shops ORDER BY shop_id ASC";
        List<Map<String, Object>> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("shopId", rs.getInt("shop_id"));
                map.put("shopName", rs.getString("shop_name"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 브랜드 리스트 로드 (브랜드 필터링 드롭다운용)
    public List<Map<String, Object>> getBrandList() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT brand_id, brand_name, country, description FROM brands ORDER BY brand_id ASC";
        List<Map<String, Object>> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("brandId", rs.getInt("brand_id"));
                map.put("brandName", rs.getString("brand_name"));
                map.put("country", rs.getString("country"));
                map.put("description", rs.getString("description"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 렌탈 지점 리스트 로드 확장 (관리자용)
    public List<Map<String, Object>> getShopListAll() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT shop_id, shop_name, manager_name, tel, address, open_time, close_time FROM rental_shops ORDER BY shop_id ASC";
        List<Map<String, Object>> list = new ArrayList<>();
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("shopId", rs.getInt("shop_id"));
                map.put("shopName", rs.getString("shop_name"));
                map.put("managerName", rs.getString("manager_name"));
                map.put("tel", rs.getString("tel"));
                map.put("address", rs.getString("address"));
                map.put("openTime", rs.getString("open_time"));
                map.put("closeTime", rs.getString("close_time"));
                list.add(map);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, rs);
        }
        return list;
    }

    // 바이크 삭제 (관리자용)
    public int deleteBike(int bikeId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "DELETE FROM motorcycles WHERE bike_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, bikeId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 브랜드 추가 (관리자용)
    public int insertBrand(String brandName, String country, String description) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO brands (brand_id, brand_name, country, description) VALUES (seq_brands.NEXTVAL, ?, ?, ?)";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, brandName);
            pstmt.setString(2, country);
            pstmt.setString(3, description);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 브랜드 삭제 (관리자용)
    public int deleteBrand(int brandId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "DELETE FROM brands WHERE brand_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, brandId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 지점 추가 (관리자용)
    public int insertShop(String shopName, String managerName, String tel, String address, String openTime, String closeTime) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO rental_shops (shop_id, shop_name, manager_name, tel, address, open_time, close_time) VALUES (seq_rental_shops.NEXTVAL, ?, ?, ?, ?, ?, ?)";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, shopName);
            pstmt.setString(2, managerName);
            pstmt.setString(3, tel);
            pstmt.setString(4, address);
            pstmt.setString(5, openTime);
            pstmt.setString(6, closeTime);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }

    // 지점 삭제 (관리자용)
    public int deleteShop(int shopId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String sql = "DELETE FROM rental_shops WHERE shop_id = ?";
        int result = -1;
        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, shopId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(conn, pstmt, null);
        }
        return result;
    }
}

