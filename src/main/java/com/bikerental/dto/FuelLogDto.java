package com.bikerental.dto;

import java.sql.Timestamp;

public class FuelLogDto {
    private int fuelLogId;
    private int bikeId;
    private int reservationId;
    private int fuelLevel;
    private int penaltyAmount;
    private Timestamp logDate;

    // Join fields for UI rendering
    private String modelName;
    private String userEmail;
    private String userNickname;

    // Getters and Setters
    public int getFuelLogId() { return fuelLogId; }
    public void setFuelLogId(int fuelLogId) { this.fuelLogId = fuelLogId; }

    public int getBikeId() { return bikeId; }
    public void setBikeId(int bikeId) { this.bikeId = bikeId; }

    public int getReservationId() { return reservationId; }
    public void setReservationId(int reservationId) { this.reservationId = reservationId; }

    public int getFuelLevel() { return fuelLevel; }
    public void setFuelLevel(int fuelLevel) { this.fuelLevel = fuelLevel; }

    public int getPenaltyAmount() { return penaltyAmount; }
    public void setPenaltyAmount(int penaltyAmount) { this.penaltyAmount = penaltyAmount; }

    public Timestamp getLogDate() { return logDate; }
    public void setLogDate(Timestamp logDate) { this.logDate = logDate; }

    public String getModelName() { return modelName; }
    public void setModelName(String modelName) { this.modelName = modelName; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getUserNickname() { return userNickname; }
    public void setUserNickname(String userNickname) { this.userNickname = userNickname; }
}
