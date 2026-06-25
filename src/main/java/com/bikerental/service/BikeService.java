package com.bikerental.service;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.bikerental.dao.BikeDao;
import com.bikerental.dao.OptionItemDao;
import com.bikerental.dao.ReviewDao;
import com.bikerental.dao.CouponDao;
import com.bikerental.dao.InsurancePlanDao;
import com.bikerental.dao.BikeMaintenanceDao;
import com.bikerental.dto.BikeDto;
import com.bikerental.dto.OptionItemDto;
import com.bikerental.dto.ReviewDto;
import com.bikerental.dto.CouponDto;
import com.bikerental.dto.InsurancePlanDto;
import com.bikerental.dto.BikeMaintenanceDto;

public class BikeService {
    private static BikeService instance = new BikeService();

    private BikeService() {}

    public static BikeService getInstance() {
        return instance;
    }

    public List<BikeDto> getBikeList() {
        return BikeDao.getInstance().getBikeList();
    }

    public List<OptionItemDto> getGearList() {
        return OptionItemDao.getInstance().getOptionList();
    }

    public List<Map<String, Object>> getShopListAll() {
        return BikeDao.getInstance().getShopListAll();
    }

    public Map<String, Object> getBikeSelectData(String shopId, String brandId, String ccType) {
        Map<String, Object> result = new HashMap<>();
        List<BikeDto> bikeList = BikeDao.getInstance().getBikeListFiltered(shopId, brandId, ccType);
        List<Map<String, Object>> shopList = BikeDao.getInstance().getShopListAll();
        List<Map<String, Object>> brandList = BikeDao.getInstance().getBrandList();
        
        Map<String, Object> selectedShop = null;
        try {
            int targetShopId = Integer.parseInt(shopId);
            for (Map<String, Object> shop : shopList) {
                if (((Integer) shop.get("shopId")) == targetShopId) {
                    selectedShop = shop;
                    break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        result.put("bikeList", bikeList);
        result.put("shopList", shopList);
        result.put("brandList", brandList);
        result.put("selectedShop", selectedShop);
        return result;
    }

    public Map<String, Object> getBikeDetailData(int bikeId, Integer memberId) {
        Map<String, Object> result = new HashMap<>();
        BikeDto bike = BikeDao.getInstance().getBike(bikeId);
        
        if (bike != null) {
            List<ReviewDto> reviewList = ReviewDao.getInstance().getReviewsByBike(bikeId);
            List<Map<String, Object>> shopList = BikeDao.getInstance().getShopList();
            List<OptionItemDto> optionList = OptionItemDao.getInstance().getOptionList();
            List<InsurancePlanDto> insuranceList = InsurancePlanDao.getInstance().getInsurancePlansAll();
            
            result.put("bike", bike);
            result.put("reviewList", reviewList);
            result.put("shopList", shopList);
            result.put("optionList", optionList);
            result.put("insuranceList", insuranceList);
            
            if (memberId != null) {
                List<CouponDto> couponList = CouponDao.getInstance().getCouponsByUser(memberId);
                result.put("couponList", couponList);
            }
        }
        return result;
    }

    public void addBike(BikeDto dto, String imageUrl) {
        int bikeResult = BikeDao.getInstance().insertBike(dto);
        if (bikeResult > 0 && imageUrl != null && !imageUrl.trim().isEmpty()) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            try {
                conn = com.bikerental.util.DBConnection.getConnection();
                pstmt = conn.prepareStatement("INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, seq_motorcycles.CURRVAL, ?, 'Y')");
                pstmt.setString(1, imageUrl);
                pstmt.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                com.bikerental.util.DBConnection.close(conn, pstmt, null);
            }
        }
    }

    public void deleteBike(int bikeId) {
        BikeDao.getInstance().deleteBike(bikeId);
    }

    public void addOption(String optionName, int stockQuantity, int dailyPrice, String status, jakarta.servlet.http.Part filePart, String deployDir, String srcDir) throws Exception {
        String imageFilename = "gear_default.png";
        if (filePart != null && filePart.getSize() > 0) {
            String originalName = filePart.getSubmittedFileName();
            String extension = "";
            int dotIndex = originalName.lastIndexOf('.');
            if (dotIndex > 0) {
                extension = originalName.substring(dotIndex);
            }
            imageFilename = "gear_" + System.currentTimeMillis() + extension;
            
            File uploadDir = new File(deployDir);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            String deployFilePath = deployDir + File.separator + imageFilename;
            filePart.write(deployFilePath);
            
            File srcUploadDir = new File(srcDir);
            if (srcUploadDir.exists()) {
                try {
                    Files.copy(
                        Paths.get(deployFilePath),
                        Paths.get(srcDir + File.separator + imageFilename),
                        StandardCopyOption.REPLACE_EXISTING
                    );
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        
        OptionItemDto dto = new OptionItemDto();
        dto.setOptionName(optionName);
        dto.setStockQuantity(stockQuantity);
        dto.setDailyPrice(dailyPrice);
        dto.setImageFilename(imageFilename);
        dto.setStatus(status);
        
        OptionItemDao.getInstance().insertOption(dto);
    }

    public void updateOption(int optionId, String optionName, int stockQuantity, int dailyPrice, String status, jakarta.servlet.http.Part filePart, String deployDir, String srcDir) throws Exception {
        OptionItemDto dto = OptionItemDao.getInstance().getOption(optionId);
        if (dto != null) {
            dto.setOptionName(optionName);
            dto.setStockQuantity(stockQuantity);
            dto.setDailyPrice(dailyPrice);
            dto.setStatus(status);
            
            if (filePart != null && filePart.getSize() > 0) {
                String originalName = filePart.getSubmittedFileName();
                String extension = "";
                int dotIndex = originalName.lastIndexOf('.');
                if (dotIndex > 0) {
                    extension = originalName.substring(dotIndex);
                }
                String imageFilename = "gear_" + System.currentTimeMillis() + extension;
                
                File uploadDir = new File(deployDir);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
                String deployFilePath = deployDir + File.separator + imageFilename;
                filePart.write(deployFilePath);
                
                File srcUploadDir = new File(srcDir);
                if (srcUploadDir.exists()) {
                    try {
                        Files.copy(
                            Paths.get(deployFilePath),
                            Paths.get(srcDir + File.separator + imageFilename),
                            StandardCopyOption.REPLACE_EXISTING
                        );
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                dto.setImageFilename(imageFilename);
            }
            OptionItemDao.getInstance().updateOption(dto);
        }
    }

    public void deleteOption(int optionId) {
        OptionItemDao.getInstance().deleteOption(optionId);
    }

    public void addBrand(String brandName, String country, String description) {
        BikeDao.getInstance().insertBrand(brandName, country, description);
    }

    public void deleteBrand(int brandId) {
        BikeDao.getInstance().deleteBrand(brandId);
    }

    public void addShop(String shopName, String managerName, String tel, String address, String openTime, String closeTime, jakarta.servlet.http.Part filePart, String deployDir, String srcDir) throws Exception {
        String imageFilename = null;
        if (filePart != null && filePart.getSize() > 0) {
            String originalName = filePart.getSubmittedFileName();
            String extension = "";
            int dotIndex = originalName.lastIndexOf('.');
            if (dotIndex > 0) {
                extension = originalName.substring(dotIndex);
            }
            imageFilename = "shop_" + System.currentTimeMillis() + extension;
            
            File uploadDir = new File(deployDir);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            String deployFilePath = deployDir + File.separator + imageFilename;
            filePart.write(deployFilePath);
            
            File srcUploadDir = new File(srcDir);
            if (srcUploadDir.exists()) {
                try {
                    Files.copy(
                        Paths.get(deployFilePath),
                        Paths.get(srcDir + File.separator + imageFilename),
                        StandardCopyOption.REPLACE_EXISTING
                    );
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        BikeDao.getInstance().insertShop(shopName, managerName, tel, address, openTime, closeTime, imageFilename);
    }

    public void uploadShopImage(int shopId, jakarta.servlet.http.Part filePart, String deployDir, String srcDir) throws Exception {
        if (filePart != null && filePart.getSize() > 0) {
            String originalName = filePart.getSubmittedFileName();
            String extension = "";
            int dotIndex = originalName.lastIndexOf('.');
            if (dotIndex > 0) {
                extension = originalName.substring(dotIndex);
            }
            String imageFilename = "shop_" + System.currentTimeMillis() + extension;
            
            File uploadDir = new File(deployDir);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            String deployFilePath = deployDir + File.separator + imageFilename;
            filePart.write(deployFilePath);
            
            File srcUploadDir = new File(srcDir);
            if (srcUploadDir.exists()) {
                try {
                    Files.copy(
                        Paths.get(deployFilePath),
                        Paths.get(srcDir + File.separator + imageFilename),
                        StandardCopyOption.REPLACE_EXISTING
                    );
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            BikeDao.getInstance().updateShopImage(shopId, imageFilename);
        }
    }

    public void deleteShopImage(int shopId, String deployDir, String srcDir) {
        List<Map<String, Object>> shopList = BikeDao.getInstance().getShopListAll();
        String imageFilename = null;
        for (Map<String, Object> shop : shopList) {
            if (((Integer) shop.get("shopId")) == shopId) {
                imageFilename = (String) shop.get("imageFilename");
                break;
            }
        }
        
        if (imageFilename != null && imageFilename.startsWith("shop_") && imageFilename.length() > 15) {
            try {
                File deployFile = new File(deployDir + File.separator + imageFilename);
                if (deployFile.exists()) {
                    deployFile.delete();
                }
                File srcFile = new File(srcDir + File.separator + imageFilename);
                if (srcFile.exists()) {
                    srcFile.delete();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        BikeDao.getInstance().updateShopImage(shopId, null);
    }

    public void deleteShop(int shopId, String deployDir, String srcDir) {
        List<Map<String, Object>> shopList = BikeDao.getInstance().getShopListAll();
        String imageFilename = null;
        for (Map<String, Object> shop : shopList) {
            if (((Integer) shop.get("shopId")) == shopId) {
                imageFilename = (String) shop.get("imageFilename");
                break;
            }
        }
        if (imageFilename != null && imageFilename.startsWith("shop_") && imageFilename.length() > 15) {
            try {
                File deployFile = new File(deployDir + File.separator + imageFilename);
                if (deployFile.exists()) {
                    deployFile.delete();
                }
                File srcFile = new File(srcDir + File.separator + imageFilename);
                if (srcFile.exists()) {
                    srcFile.delete();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        BikeDao.getInstance().deleteShop(shopId);
    }

    public void addMaintenance(BikeMaintenanceDto dto) {
        BikeMaintenanceDao.getInstance().insertMaintenance(dto);
    }
}
