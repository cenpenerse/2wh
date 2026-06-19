package com.bikerental.dto;

public class InsurancePlanDto {
    private int planId;
    private String planName;
    private int dailyFee;
    private int deductibleLimit;
    private int coverageLimit;
    private String termsContent;

    // Getters and Setters
    public int getPlanId() { return planId; }
    public void setPlanId(int planId) { this.planId = planId; }
    public String getPlanName() { return planName; }
    public void setPlanName(String planName) { this.planName = planName; }
    public int getDailyFee() { return dailyFee; }
    public void setDailyFee(int dailyFee) { this.dailyFee = dailyFee; }
    public int getDeductibleLimit() { return deductibleLimit; }
    public void setDeductibleLimit(int deductibleLimit) { this.deductibleLimit = deductibleLimit; }
    public int getCoverageLimit() { return coverageLimit; }
    public void setCoverageLimit(int coverageLimit) { this.coverageLimit = coverageLimit; }
    public String getTermsContent() { return termsContent; }
    public void setTermsContent(String termsContent) { this.termsContent = termsContent; }
}
