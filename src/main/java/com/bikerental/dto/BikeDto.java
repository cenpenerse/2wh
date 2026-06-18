package com.bikerental.dto;

public class BikeDto {
    private int bikeId;
    private String bikeName; // model_name 필드 대응
    private String bikeType; // motorcycles에는 명시적 type 필드가 없으므로, 필요시 제조사나 배기량으로 유추하거나 model_name의 분류로 사용. 또는 category 역할로 호환 유지.
    private int cc;
    private int year;
    private String color;
    private int dailyPrice; // daily_price 필드 대응
    private int mileage;
    private String description;
    private String bikeImageUrl; // bike_images 테이블 대표 이미지 조인 결과 대응
    private double ratingAvg;
    private int reviewCount;
    private String status; // AVAILABLE, RENTED, MAINTENANCE

    // 조인용 확장 속성
    private String brandName;
    private String brandCountry;
    private String shopName;
    private String shopAddress;
    private int brandId;
    private int shopId;

    // Getters and Setters
    public int getBikeId() {
        return bikeId;
    }

    public void setBikeId(int bikeId) {
        this.bikeId = bikeId;
    }

    public String getBikeName() {
        return bikeName;
    }

    public void setBikeName(String bikeName) {
        this.bikeName = bikeName;
    }

    public String getBikeType() {
        // motorcycles에 Type 필드가 없으므로 배기량을 기준으로 유형을 반환하는 가상 필드로 호환을 맞춥니다.
        if (bikeType != null) return bikeType;
        if (cc < 125) return "SCOOTER (스쿠터)";
        if (cc <= 400) return "QUARTER (쿼터급)";
        return "OVER 600cc (리터급)";
    }

    public void setBikeType(String bikeType) {
        this.bikeType = bikeType;
    }

    public int getCc() {
        return cc;
    }

    public void setCc(int cc) {
        this.cc = cc;
    }

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public int getDailyPrice() {
        return dailyPrice;
    }

    public void setDailyPrice(int dailyPrice) {
        this.dailyPrice = dailyPrice;
    }

    public int getMileage() {
        return mileage;
    }

    public void setMileage(int mileage) {
        this.mileage = mileage;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getBikeImageUrl() {
        return bikeImageUrl;
    }

    public void setBikeImageUrl(String bikeImageUrl) {
        this.bikeImageUrl = bikeImageUrl;
    }

    public double getRatingAvg() {
        return ratingAvg;
    }

    public void setRatingAvg(double ratingAvg) {
        this.ratingAvg = ratingAvg;
    }

    public int getReviewCount() {
        return reviewCount;
    }

    public void setReviewCount(int reviewCount) {
        this.reviewCount = reviewCount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public String getBrandCountry() {
        return brandCountry;
    }

    public void setBrandCountry(String brandCountry) {
        this.brandCountry = brandCountry;
    }

    public String getShopName() {
        return shopName;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
    }

    public String getShopAddress() {
        return shopAddress;
    }

    public void setShopAddress(String shopAddress) {
        this.shopAddress = shopAddress;
    }

    public int getBrandId() {
        return brandId;
    }

    public void setBrandId(int brandId) {
        this.brandId = brandId;
    }

    public int getShopId() {
        return shopId;
    }

    public void setShopId(int shopId) {
        this.shopId = shopId;
    }
}
