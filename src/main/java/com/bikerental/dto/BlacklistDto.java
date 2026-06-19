package com.bikerental.dto;

import java.sql.Date;

public class BlacklistDto {
    private int blacklistId;
    private int userId;
    private String banType;
    private String reason;
    private Date startDate;
    private Date endDate;
    private int adminId;

    // Join fields
    private String userNickname;
    private String userEmail;
    private String adminNickname;

    // Getters and Setters
    public int getBlacklistId() { return blacklistId; }
    public void setBlacklistId(int blacklistId) { this.blacklistId = blacklistId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getBanType() { return banType; }
    public void setBanType(String banType) { this.banType = banType; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }
    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }
    public int getAdminId() { return adminId; }
    public void setAdminId(int adminId) { this.adminId = adminId; }

    public String getUserNickname() { return userNickname; }
    public void setUserNickname(String userNickname) { this.userNickname = userNickname; }
    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }
    public String getAdminNickname() { return adminNickname; }
    public void setAdminNickname(String adminNickname) { this.adminNickname = adminNickname; }
}
