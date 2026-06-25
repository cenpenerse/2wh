package com.bikerental.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.bikerental.dao.AccidentReportDao;
import com.bikerental.dao.BikeDao;
import com.bikerental.dao.BikeMaintenanceDao;
import com.bikerental.dao.BlacklistDao;
import com.bikerental.dao.BookingDao;
import com.bikerental.dao.CouponDao;
import com.bikerental.dao.FuelLogDao;
import com.bikerental.dao.InquiryDao;
import com.bikerental.dao.LicenseAuditDao;
import com.bikerental.dao.MemberDao;
import com.bikerental.dao.NotificationDao;
import com.bikerental.dao.OptionItemDao;
import com.bikerental.dao.PaymentDao;
import com.bikerental.dao.PenaltyDao;
import com.bikerental.dao.PointHistoryDao;
import com.bikerental.dao.RefundLogDao;
import com.bikerental.dto.BlacklistDto;
import com.bikerental.dto.CouponDto;
import com.bikerental.dto.LicenseAuditDto;
import com.bikerental.dto.MemberDto;

public class MemberService {
    private static MemberService instance = new MemberService();

    private MemberService() {}

    public static MemberService getInstance() {
        return instance;
    }

    public MemberDto login(String email, String password) {
        return MemberDao.getInstance().getMemberByEmailAndPassword(email, password);
    }

    public boolean isUserBanned(int memberId) {
        return BlacklistDao.getInstance().isUserBanned(memberId);
    }

    public String getBanReason(int memberId) {
        return BlacklistDao.getInstance().getBanReason(memberId);
    }

    public int join(MemberDto dto) throws Exception {
        return MemberDao.getInstance().insertMember(dto);
    }

    public MemberDto getMemberInfo(int memberId) {
        return MemberDao.getInstance().getMember(memberId);
    }

    public Map<String, Object> getMypageData(MemberDto loginUser) {
        Map<String, Object> data = new HashMap<>();
        int memberId = loginUser.getMemberId();
        
        if ("ADMIN".equals(loginUser.getMemberStatus())) {
            data.put("bookingList", BookingDao.getInstance().getBookingListAll());
            data.put("memberList", MemberDao.getInstance().getMemberList());
            data.put("adminInquiryList", InquiryDao.getInstance().getInquiriesAll());
            data.put("adminBikeList", BikeDao.getInstance().getBikeList());
            data.put("adminBrandList", BikeDao.getInstance().getBrandList());
            data.put("adminShopList", BikeDao.getInstance().getShopListAll());
            data.put("adminPenaltyList", PenaltyDao.getInstance().getPenaltiesAll());
            data.put("adminLicenseAuditList", LicenseAuditDao.getInstance().getAuditsAll());
            data.put("adminMaintenanceList", BikeMaintenanceDao.getInstance().getMaintenanceList());
            data.put("adminFuelLogList", FuelLogDao.getInstance().getFuelLogList());
            data.put("adminPaymentList", PaymentDao.getInstance().getPaymentsAll());
            data.put("adminNotificationList", NotificationDao.getInstance().getNotificationsAll());
            data.put("adminAccidentList", AccidentReportDao.getInstance().getReportsAll());
            data.put("adminBlacklist", BlacklistDao.getInstance().getBlacklistAll());
            data.put("adminRefundList", RefundLogDao.getInstance().getRefundsAll());
            data.put("adminOptionList", OptionItemDao.getInstance().getOptionListAll());
        } else {
            data.put("bookingList", BookingDao.getInstance().getBookingListByUser(memberId));
            data.put("couponList", CouponDao.getInstance().getCouponsByUser(memberId));
            data.put("inquiryList", InquiryDao.getInstance().getInquiriesByUser(memberId));
            data.put("penaltyList", PenaltyDao.getInstance().getPenaltiesByUser(memberId));
            data.put("userLicenseAuditList", LicenseAuditDao.getInstance().getAuditsByUser(memberId));
            data.put("userPaymentList", PaymentDao.getInstance().getPaymentsByUser(memberId));
            data.put("userNotificationList", NotificationDao.getInstance().getNotificationsByUser(memberId));
            data.put("userAccidentList", AccidentReportDao.getInstance().getReportsByUser(memberId));
            data.put("userPointList", PointHistoryDao.getInstance().getPointHistoriesByUser(memberId));
            data.put("userRefundList", RefundLogDao.getInstance().getRefundsByUser(memberId));
        }
        return data;
    }

    public int updateMember(MemberDto dto) {
        return MemberDao.getInstance().updateMember(dto);
    }

    public int deleteMember(int memberId) {
        return MemberDao.getInstance().deleteMember(memberId);
    }

    public int updateLicenseStatus(int memberId, String status) {
        return MemberDao.getInstance().updateLicenseStatus(memberId, status);
    }

    public void submitLicense(LicenseAuditDto auditDto, String licenseNumber) {
        LicenseAuditDao.getInstance().insertAudit(auditDto);
        MemberDao.getInstance().updateLicenseInfo(auditDto.getUserId(), licenseNumber, "PENDING");
    }

    public void auditLicense(int auditId, String status, String rejectReason, int adminId) {
        LicenseAuditDao.getInstance().updateAuditStatus(auditId, status, rejectReason, adminId);
    }

    public void addBlacklist(BlacklistDto dto) {
        BlacklistDao.getInstance().insertBlacklist(dto);
    }

    public void releaseBlacklist(int blacklistId) {
        BlacklistDao.getInstance().deleteBlacklist(blacklistId);
    }

    public void issueCoupon(String targetUser, String couponName, int discountAmount, java.sql.Date expireDate) {
        if ("all".equals(targetUser)) {
            List<MemberDto> members = MemberDao.getInstance().getMemberList();
            for (MemberDto m : members) {
                if (!"ADMIN".equals(m.getMemberStatus())) {
                    CouponDto dto = new CouponDto();
                    dto.setUserId(m.getMemberId());
                    dto.setCouponName(couponName);
                    dto.setDiscountAmount(discountAmount);
                    dto.setExpireDate(expireDate);
                    CouponDao.getInstance().insertCoupon(dto);
                }
            }
        } else {
            int userId = Integer.parseInt(targetUser);
            CouponDto dto = new CouponDto();
            dto.setUserId(userId);
            dto.setCouponName(couponName);
            dto.setDiscountAmount(discountAmount);
            dto.setExpireDate(expireDate);
            CouponDao.getInstance().insertCoupon(dto);
        }
    }
}
