package com.bikerental.dto;

import java.sql.Timestamp;

public class AccidentReportDto {
    private int reportId;
    private int reservationId;
    private int userId;
    private Timestamp accidentDate;
    private String accidentLocation;
    private String accidentDescription;
    private String photoPath;
    private String insuranceClaimNum;
    private int faultRatio;
    private String status;

    // Join fields
    private String userNickname;
    private String userEmail;
    private String bikeName;

    // Getters and Setters
    public int getReportId() { return reportId; }
    public void setReportId(int reportId) { this.reportId = reportId; }
    public int getReservationId() { return reservationId; }
    public void setReservationId(int reservationId) { this.reservationId = reservationId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public Timestamp getAccidentDate() { return accidentDate; }
    public void setAccidentDate(Timestamp accidentDate) { this.accidentDate = accidentDate; }
    public String getAccidentLocation() { return accidentLocation; }
    public void setAccidentLocation(String accidentLocation) { this.accidentLocation = accidentLocation; }
    public String getAccidentDescription() { return accidentDescription; }
    public void setAccidentDescription(String accidentDescription) { this.accidentDescription = accidentDescription; }
    public String getPhotoPath() { return photoPath; }
    public void setPhotoPath(String photoPath) { this.photoPath = photoPath; }
    public String getInsuranceClaimNum() { return insuranceClaimNum; }
    public void setInsuranceClaimNum(String insuranceClaimNum) { this.insuranceClaimNum = insuranceClaimNum; }
    public int getFaultRatio() { return faultRatio; }
    public void setFaultRatio(int faultRatio) { this.faultRatio = faultRatio; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getUserNickname() { return userNickname; }
    public void setUserNickname(String userNickname) { this.userNickname = userNickname; }
    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }
    public String getBikeName() { return bikeName; }
    public void setBikeName(String bikeName) { this.bikeName = bikeName; }
}
