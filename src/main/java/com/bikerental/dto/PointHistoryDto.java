package com.bikerental.dto;

import java.sql.Timestamp;

public class PointHistoryDto {
    private int historyId;
    private int userId;
    private int amount;
    private String reason;
    private int accumulatedPoints;
    private Timestamp createdAt;

    // Join fields
    private String userNickname;
    private String userEmail;

    // Getters and Setters
    public int getHistoryId() { return historyId; }
    public void setHistoryId(int historyId) { this.historyId = historyId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getAmount() { return amount; }
    public void setAmount(int amount) { this.amount = amount; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public int getAccumulatedPoints() { return accumulatedPoints; }
    public void setAccumulatedPoints(int accumulatedPoints) { this.accumulatedPoints = accumulatedPoints; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getUserNickname() { return userNickname; }
    public void setUserNickname(String userNickname) { this.userNickname = userNickname; }
    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }
}
