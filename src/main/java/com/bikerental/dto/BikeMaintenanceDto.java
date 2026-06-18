package com.bikerental.dto;

import java.sql.Date;

public class BikeMaintenanceDto {
    private int maintenanceId;
    private int bikeId;
    private Date maintenanceDate;
    private String maintenanceType;
    private String content;
    private int cost;
    private String shopName;
    private Date nextCheckDate;

    // Join fields for UI rendering
    private String modelName;

    // Getters and Setters
    public int getMaintenanceId() { return maintenanceId; }
    public void setMaintenanceId(int maintenanceId) { this.maintenanceId = maintenanceId; }

    public int getBikeId() { return bikeId; }
    public void setBikeId(int bikeId) { this.bikeId = bikeId; }

    public Date getMaintenanceDate() { return maintenanceDate; }
    public void setMaintenanceDate(Date maintenanceDate) { this.maintenanceDate = maintenanceDate; }

    public String getMaintenanceType() { return maintenanceType; }
    public void setMaintenanceType(String maintenanceType) { this.maintenanceType = maintenanceType; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public int getCost() { return cost; }
    public void setCost(int cost) { this.cost = cost; }

    public String getShopName() { return shopName; }
    public void setShopName(String shopName) { this.shopName = shopName; }

    public Date getNextCheckDate() { return nextCheckDate; }
    public void setNextCheckDate(Date nextCheckDate) { this.nextCheckDate = nextCheckDate; }

    public String getModelName() { return modelName; }
    public void setModelName(String modelName) { this.modelName = modelName; }
}
