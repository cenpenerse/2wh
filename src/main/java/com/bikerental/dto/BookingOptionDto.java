package com.bikerental.dto;

public class BookingOptionDto {
    private int bookingOptionId;
    private int reservationId;
    private int optionId;
    private int quantity;
    private int dailyPrice;

    // 조인용 필드
    private String optionName;

    public int getBookingOptionId() {
        return bookingOptionId;
    }

    public void setBookingOptionId(int bookingOptionId) {
        this.bookingOptionId = bookingOptionId;
    }

    public int getReservationId() {
        return reservationId;
    }

    public void setReservationId(int reservationId) {
        this.reservationId = reservationId;
    }

    public int getOptionId() {
        return optionId;
    }

    public void setOptionId(int optionId) {
        this.optionId = optionId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public int getDailyPrice() {
        return dailyPrice;
    }

    public void setDailyPrice(int dailyPrice) {
        this.dailyPrice = dailyPrice;
    }

    public String getOptionName() {
        return optionName;
    }

    public void setOptionName(String optionName) {
        this.optionName = optionName;
    }
}
