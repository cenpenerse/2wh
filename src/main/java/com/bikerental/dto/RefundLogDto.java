package com.bikerental.dto;

import java.sql.Timestamp;

public class RefundLogDto {
    private int refundId;
    private int paymentId;
    private Timestamp cancelRequestDate;
    private int penaltyRate;
    private int refundAmount;
    private String refundMethod;
    private String status;

    // Join fields for display
    private int reservationId;
    private String userNickname;
    private String userEmail;
    private int paymentAmount;

    public RefundLogDto() {}

    public int getRefundId() {
        return refundId;
    }

    public void setRefundId(int refundId) {
        this.refundId = refundId;
    }

    public int getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(int paymentId) {
        this.paymentId = paymentId;
    }

    public Timestamp getCancelRequestDate() {
        return cancelRequestDate;
    }

    public void setCancelRequestDate(Timestamp cancelRequestDate) {
        this.cancelRequestDate = cancelRequestDate;
    }

    public int getPenaltyRate() {
        return penaltyRate;
    }

    public void setPenaltyRate(int penaltyRate) {
        this.penaltyRate = penaltyRate;
    }

    public int getRefundAmount() {
        return refundAmount;
    }

    public void setRefundAmount(int refundAmount) {
        this.refundAmount = refundAmount;
    }

    public String getRefundMethod() {
        return refundMethod;
    }

    public void setRefundMethod(String refundMethod) {
        this.refundMethod = refundMethod;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getReservationId() {
        return reservationId;
    }

    public void setReservationId(int reservationId) {
        this.reservationId = reservationId;
    }

    public String getUserNickname() {
        return userNickname;
    }

    public void setUserNickname(String userNickname) {
        this.userNickname = userNickname;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public int getPaymentAmount() {
        return paymentAmount;
    }

    public void setPaymentAmount(int paymentAmount) {
        this.paymentAmount = paymentAmount;
    }
}
