package com.bikerental.dto;

import java.sql.Date;
import java.sql.Timestamp;

public class BookingDto {
    private int bookingId; // reservation_id 필드 대응
    private int memberId;  // user_id 필드 대응
    private int bikeId;
    private Timestamp startDate;
    private Timestamp endDate;
    private int rentalDays;
    private int price;     // total_price 필드 대응
    private String bookingStatus; // status 필드 대응 (PENDING, APPROVED, CANCELLED)
    private Timestamp createdAt;

    // 결제 관련 확장 속성 (payments 테이블 조인 대응)
    private int paymentId;
    private String paymentMethod;
    private String paymentStatus;
    private Timestamp paidAt;

    // 조인용 확장 속성
    private String memberNickname; // users.name 필드 대응
    private String memberEmail;
    private String bikeName;       // motorcycles.model_name 필드 대응
    private String bikeImageUrl;
    private String bikeType;
    private int pickupShopId;
    private String pickupShopName;
    private int dropoffShopId;
    private String dropoffShopName;
    private java.util.List<BookingOptionDto> bookingOptions;

    // Getters and Setters
    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getMemberId() {
        return memberId;
    }

    public void setMemberId(int memberId) {
        this.memberId = memberId;
    }

    public int getBikeId() {
        return bikeId;
    }

    public void setBikeId(int bikeId) {
        this.bikeId = bikeId;
    }

    public Timestamp getStartDate() {
        return startDate;
    }

    public void setStartDate(Timestamp startDate) {
        this.startDate = startDate;
    }

    public Timestamp getEndDate() {
        return endDate;
    }

    public void setEndDate(Timestamp endDate) {
        this.endDate = endDate;
    }

    public int getRentalDays() {
        return rentalDays;
    }

    public void setRentalDays(int rentalDays) {
        this.rentalDays = rentalDays;
    }

    public int getPrice() {
        return price;
    }

    public void setPrice(int price) {
        this.price = price;
    }

    public String getBookingStatus() {
        return bookingStatus;
    }

    public void setBookingStatus(String bookingStatus) {
        this.bookingStatus = bookingStatus;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public int getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(int paymentId) {
        this.paymentId = paymentId;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public Timestamp getPaidAt() {
        return paidAt;
    }

    public void setPaidAt(Timestamp paidAt) {
        this.paidAt = paidAt;
    }

    public String getMemberNickname() {
        return memberNickname;
    }

    public void setMemberNickname(String memberNickname) {
        this.memberNickname = memberNickname;
    }

    public String getMemberEmail() {
        return memberEmail;
    }

    public void setMemberEmail(String memberEmail) {
        this.memberEmail = memberEmail;
    }

    public String getBikeName() {
        return bikeName;
    }

    public void setBikeName(String bikeName) {
        this.bikeName = bikeName;
    }

    public String getBikeImageUrl() {
        return bikeImageUrl;
    }

    public void setBikeImageUrl(String bikeImageUrl) {
        this.bikeImageUrl = bikeImageUrl;
    }

    public String getBikeType() {
        return bikeType;
    }

    public void setBikeType(String bikeType) {
        this.bikeType = bikeType;
    }

    public int getPickupShopId() {
        return pickupShopId;
    }

    public void setPickupShopId(int pickupShopId) {
        this.pickupShopId = pickupShopId;
    }

    public String getPickupShopName() {
        return pickupShopName;
    }

    public void setPickupShopName(String pickupShopName) {
        this.pickupShopName = pickupShopName;
    }

    public int getDropoffShopId() {
        return dropoffShopId;
    }

    public void setDropoffShopId(int dropoffShopId) {
        this.dropoffShopId = dropoffShopId;
    }

    public String getDropoffShopName() {
        return dropoffShopName;
    }

    public void setDropoffShopName(String dropoffShopName) {
        this.dropoffShopName = dropoffShopName;
    }

    public java.util.List<BookingOptionDto> getBookingOptions() {
        return bookingOptions;
    }

    public void setBookingOptions(java.util.List<BookingOptionDto> bookingOptions) {
        this.bookingOptions = bookingOptions;
    }

    private int insuranceId;
    private String insuranceName;
    private int insuranceFee;

    public int getInsuranceId() { return insuranceId; }
    public void setInsuranceId(int insuranceId) { this.insuranceId = insuranceId; }
    public String getInsuranceName() { return insuranceName; }
    public void setInsuranceName(String insuranceName) { this.insuranceName = insuranceName; }
    public int getInsuranceFee() { return insuranceFee; }
    public void setInsuranceFee(int insuranceFee) { this.insuranceFee = insuranceFee; }

    private int usePoints;

    public int getUsePoints() { return usePoints; }
    public void setUsePoints(int usePoints) { this.usePoints = usePoints; }
}
