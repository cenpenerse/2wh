package com.bikerental.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Timestamp;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.bikerental.dao.*;
import com.bikerental.dto.*;
import com.bikerental.util.Pagination;

@WebServlet("*.do")
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 10,     // 10MB
    maxRequestSize = 1024 * 1024 * 20,   // 20MB
    fileSizeThreshold = 0
)
public class FrontController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String command = uri.substring(contextPath.length());
        
        System.out.println("[FrontController] Requested Command: " + command);

        String viewPage = null;
        boolean isRedirect = false;

        try {
            if (command.equals("/index.do") || command.equals("/")) {
                // 대여 가능한 대표 바이크 3개 메인 화면 로딩
                List<BikeDto> bikeList = BikeDao.getInstance().getBikeList();
                List<java.util.Map<String, Object>> shopList = BikeDao.getInstance().getShopList();
                request.setAttribute("bikeList", bikeList);
                request.setAttribute("shopList", shopList);
                viewPage = "/WEB-INF/views/index.jsp";
            } else if (command.equals("/login.do")) {
                viewPage = "/WEB-INF/views/login.jsp";
                
            } else if (command.equals("/loginAction.do")) {
                String email = request.getParameter("email");
                String password = request.getParameter("password_hash");
                
                MemberDto member = MemberDao.getInstance().getMemberByEmailAndPassword(email, password);
                if (member != null) {
                    // 블랙리스트 차단 여부 확인
                    if (BlacklistDao.getInstance().isUserBanned(member.getMemberId())) {
                        String banReason = BlacklistDao.getInstance().getBanReason(member.getMemberId());
                        request.setAttribute("errorMessage", "해당 계정은 서비스 이용이 차단되었습니다. (사유: " + banReason + ")");
                        viewPage = "/WEB-INF/views/login.jsp";
                    } else {
                        HttpSession session = request.getSession();
                        session.setAttribute("loginUser", member);
                        isRedirect = true;
                        viewPage = "index.do";
                    }
                } else {
                    request.setAttribute("errorMessage", "이메일 또는 비밀번호가 올바르지 않습니다.");
                    viewPage = "/WEB-INF/views/login.jsp";
                }
                
            } else if (command.equals("/join.do")) {
                viewPage = "/WEB-INF/views/join.jsp";
                
            } else if (command.equals("/joinAction.do")) {
                String email = request.getParameter("email");
                String password = request.getParameter("password_hash");
                String nickname = request.getParameter("nickname");
                String phone = request.getParameter("phone");
                String birthDateStr = request.getParameter("birth_date");
                String licenseNumber = request.getParameter("license_number");
                
                MemberDto dto = new MemberDto();
                dto.setEmail(email);
                dto.setPasswordHash(password);
                dto.setNickname(nickname);
                dto.setPhone(phone);
                if (birthDateStr != null && !birthDateStr.isEmpty()) {
                    try {
                        dto.setBirthDate(java.sql.Date.valueOf(birthDateStr));
                    } catch (IllegalArgumentException e) {
                        e.printStackTrace();
                    }
                }
                dto.setLicenseNumber(licenseNumber);
                
                int r = MemberDao.getInstance().insertMember(dto);
                if (r > 0) {
                    isRedirect = true;
                    viewPage = "login.do";
                } else {
                    request.setAttribute("errorMessage", "회원 가입에 실패했습니다. 다시 시도해 주세요.");
                    viewPage = "/WEB-INF/views/join.jsp";
                }
                
            } else if (command.equals("/logout.do")) {
                HttpSession session = request.getSession(false);
                if (session != null) {
                    session.invalidate();
                }
                isRedirect = true;
                viewPage = "index.do";
                
            } else if (command.equals("/mypage.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = "login.do";
                } else {
                    // 최신 회원 정보 동기화 (면허 상태, 포인트 등 실시간 갱신)
                    loginUser = MemberDao.getInstance().getMember(loginUser.getMemberId());
                    session.setAttribute("loginUser", loginUser);
                    // 회원의 예약 내역 로드
                    if ("ADMIN".equals(loginUser.getMemberStatus())) {
                        // 관리자면 모든 사용자 예약 및 모든 회원 리스트 조회
                        List<BookingDto> bookingList = BookingDao.getInstance().getBookingListAll();
                        List<MemberDto> memberList = MemberDao.getInstance().getMemberList();
                        List<InquiryDto> adminInquiryList = InquiryDao.getInstance().getInquiriesAll();
                        List<BikeDto> adminBikeList = BikeDao.getInstance().getBikeList();
                        List<java.util.Map<String, Object>> adminBrandList = BikeDao.getInstance().getBrandList();
                        List<java.util.Map<String, Object>> adminShopList = BikeDao.getInstance().getShopListAll();
                        List<PenaltyDto> adminPenaltyList = PenaltyDao.getInstance().getPenaltiesAll();
                        
                        // 신규 추가: 면허 검증 심사, 차량 정비, 반납/주유 기록 조회
                        List<LicenseAuditDto> adminLicenseAuditList = LicenseAuditDao.getInstance().getAuditsAll();
                        List<BikeMaintenanceDto> adminMaintenanceList = BikeMaintenanceDao.getInstance().getMaintenanceList();
                        List<FuelLogDto> adminFuelLogList = FuelLogDao.getInstance().getFuelLogList();
                        List<PaymentDto> adminPaymentList = PaymentDao.getInstance().getPaymentsAll();
                        List<NotificationDto> adminNotificationList = NotificationDao.getInstance().getNotificationsAll();
                        List<AccidentReportDto> adminAccidentList = AccidentReportDao.getInstance().getReportsAll();
                        List<BlacklistDto> adminBlacklist = BlacklistDao.getInstance().getBlacklistAll();
                        List<RefundLogDto> adminRefundList = RefundLogDao.getInstance().getRefundsAll();
                        List<OptionItemDto> adminOptionList = OptionItemDao.getInstance().getOptionListAll();
                        
                        request.setAttribute("bookingList", bookingList);
                        request.setAttribute("memberList", memberList);
                        request.setAttribute("adminInquiryList", adminInquiryList);
                        request.setAttribute("adminBikeList", adminBikeList);
                        request.setAttribute("adminBrandList", adminBrandList);
                        request.setAttribute("adminShopList", adminShopList);
                        request.setAttribute("adminPenaltyList", adminPenaltyList);
                        
                        request.setAttribute("adminLicenseAuditList", adminLicenseAuditList);
                        request.setAttribute("adminMaintenanceList", adminMaintenanceList);
                        request.setAttribute("adminFuelLogList", adminFuelLogList);
                        request.setAttribute("adminPaymentList", adminPaymentList);
                        request.setAttribute("adminNotificationList", adminNotificationList);
                        request.setAttribute("adminAccidentList", adminAccidentList);
                        request.setAttribute("adminBlacklist", adminBlacklist);
                        request.setAttribute("adminRefundList", adminRefundList);
                        request.setAttribute("adminOptionList", adminOptionList);
                    } else {
                        // 일반 회원이면 본인 예약 목록 조회
                        List<BookingDto> bookingList = BookingDao.getInstance().getBookingListByUser(loginUser.getMemberId());
                        List<CouponDto> couponList = CouponDao.getInstance().getCouponsByUser(loginUser.getMemberId());
                        List<InquiryDto> inquiryList = InquiryDao.getInstance().getInquiriesByUser(loginUser.getMemberId());
                        List<PenaltyDto> penaltyList = PenaltyDao.getInstance().getPenaltiesByUser(loginUser.getMemberId());
                        
                        // 신규 추가: 본인 면허 심사 이력 조회
                        List<LicenseAuditDto> userLicenseAuditList = LicenseAuditDao.getInstance().getAuditsByUser(loginUser.getMemberId());
                        List<PaymentDto> userPaymentList = PaymentDao.getInstance().getPaymentsByUser(loginUser.getMemberId());
                        List<NotificationDto> userNotificationList = NotificationDao.getInstance().getNotificationsByUser(loginUser.getMemberId());
                        List<AccidentReportDto> userAccidentList = AccidentReportDao.getInstance().getReportsByUser(loginUser.getMemberId());
                        List<PointHistoryDto> userPointList = PointHistoryDao.getInstance().getPointHistoriesByUser(loginUser.getMemberId());
                        List<RefundLogDto> userRefundList = RefundLogDao.getInstance().getRefundsByUser(loginUser.getMemberId());
                        
                        request.setAttribute("bookingList", bookingList);
                        request.setAttribute("couponList", couponList);
                        request.setAttribute("inquiryList", inquiryList);
                        request.setAttribute("penaltyList", penaltyList);
                        request.setAttribute("userLicenseAuditList", userLicenseAuditList);
                        request.setAttribute("userPaymentList", userPaymentList);
                        request.setAttribute("userNotificationList", userNotificationList);
                        request.setAttribute("userAccidentList", userAccidentList);
                        request.setAttribute("userPointList", userPointList);
                        request.setAttribute("userRefundList", userRefundList);
                    }
                    viewPage = "/WEB-INF/views/member/mypage.jsp";
                }
                
            } else if (command.equals("/memberUpdateAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = "login.do";
                } else {
                    String nickname = request.getParameter("nickname");
                    String password = request.getParameter("password_hash");
                    
                    MemberDto updateDto = new MemberDto();
                    updateDto.setMemberId(loginUser.getMemberId());
                    updateDto.setNickname(nickname);
                    updateDto.setPasswordHash(password);
                    
                    int r = MemberDao.getInstance().updateMember(updateDto);
                    if (r > 0) {
                        // 세션 동기화
                        loginUser.setNickname(nickname);
                        loginUser.setPasswordHash(password);
                        session.setAttribute("loginUser", loginUser);
                        isRedirect = true;
                        viewPage = "mypage.do";
                    } else {
                        request.setAttribute("errorMessage", "정보 수정에 실패했습니다.");
                        isRedirect = true;
                        viewPage = "mypage.do";
                    }
                }
                
            } else if (command.equals("/memberDeleteAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = "login.do";
                } else {
                    int r = MemberDao.getInstance().deleteMember(loginUser.getMemberId());
                    if (r > 0) {
                        session.invalidate();
                        isRedirect = true;
                        viewPage = "index.do";
                    } else {
                        isRedirect = true;
                        viewPage = "mypage.do";
                    }
                }
                
            } else if (command.equals("/bikeInfo.do")) {
                List<BikeDto> bikeList = BikeDao.getInstance().getBikeList();
                request.setAttribute("bikeList", bikeList);
                viewPage = "/WEB-INF/views/bike/bike_info.jsp";
                
            } else if (command.equals("/gearInfo.do")) {
                List<OptionItemDto> gearList = OptionItemDao.getInstance().getOptionList();
                request.setAttribute("gearList", gearList);
                viewPage = "/WEB-INF/views/bike/gear_info.jsp";
                
            } else if (command.equals("/bikeList.do")) {
                List<java.util.Map<String, Object>> shopList = BikeDao.getInstance().getShopListAll();
                request.setAttribute("shopList", shopList);
                viewPage = "/WEB-INF/views/bike/bike_list.jsp";
                
            } else if (command.equals("/bikeSelect.do")) {
                String shopId = request.getParameter("shopId");
                if (shopId == null || shopId.trim().isEmpty()) {
                    isRedirect = true;
                    viewPage = "bikeList.do";
                } else {
                    String brandId = request.getParameter("brandId");
                    String ccType = request.getParameter("ccType");
                    
                    List<BikeDto> bikeList = BikeDao.getInstance().getBikeListFiltered(shopId, brandId, ccType);
                    List<java.util.Map<String, Object>> shopList = BikeDao.getInstance().getShopListAll();
                    List<java.util.Map<String, Object>> brandList = BikeDao.getInstance().getBrandList();
                    
                    // Find selected shop info
                    java.util.Map<String, Object> selectedShop = null;
                    try {
                        int targetShopId = Integer.parseInt(shopId);
                        for (java.util.Map<String, Object> shop : shopList) {
                            if (((Integer) shop.get("shopId")) == targetShopId) {
                                selectedShop = shop;
                                break;
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    
                    request.setAttribute("bikeList", bikeList);
                    request.setAttribute("shopList", shopList);
                    request.setAttribute("brandList", brandList);
                    request.setAttribute("selectedShop", selectedShop);
                    request.setAttribute("selectedShopId", shopId);
                    request.setAttribute("selectedBrandId", brandId);
                    request.setAttribute("selectedCcType", ccType);
                    
                    viewPage = "/WEB-INF/views/bike/bike_select.jsp";
                }
                
            } else if (command.equals("/bikeDetail.do")) {
                int bikeId = Integer.parseInt(request.getParameter("bikeId"));
                BikeDto bike = BikeDao.getInstance().getBike(bikeId);
                
                if (bike != null) {
                    List<ReviewDto> reviewList = ReviewDao.getInstance().getReviewsByBike(bikeId);
                    request.setAttribute("bike", bike);
                    request.setAttribute("reviewList", reviewList);
                    
                    List<java.util.Map<String, Object>> shopList = BikeDao.getInstance().getShopList();
                    request.setAttribute("shopList", shopList);
                    
                    String selectedShopId = request.getParameter("shopId");
                    request.setAttribute("selectedShopId", selectedShopId);
                    
                    HttpSession session = request.getSession(false);
                    MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                    if (loginUser != null) {
                        List<CouponDto> couponList = CouponDao.getInstance().getCouponsByUser(loginUser.getMemberId());
                        request.setAttribute("couponList", couponList);
                    }
                    
                    List<OptionItemDto> optionList = OptionItemDao.getInstance().getOptionList();
                    request.setAttribute("optionList", optionList);
                    
                    List<InsurancePlanDto> insuranceList = InsurancePlanDao.getInstance().getInsurancePlansAll();
                    request.setAttribute("insuranceList", insuranceList);
                }
                viewPage = "/WEB-INF/views/bike/bike_detail.jsp";
                
            } else if (command.equals("/bookingAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = "login.do";
                } else if (BlacklistDao.getInstance().isUserBanned(loginUser.getMemberId())) {
                    request.setAttribute("errorMessage", "차단된 회원은 대여를 예약할 수 없습니다.");
                    isRedirect = true;
                    viewPage = "mypage.do";
                } else {
                    int bikeId = Integer.parseInt(request.getParameter("bikeId"));
                    String startDateStr = request.getParameter("start_date");
                    String endDateStr = request.getParameter("end_date");
                    int rentalDays = Integer.parseInt(request.getParameter("rental_days"));
                    int totalPrice = Integer.parseInt(request.getParameter("total_price"));
                    String paymentMethod = request.getParameter("payment_method");
                    String couponIdStr = request.getParameter("couponId");
                    String pickupShopIdStr = request.getParameter("pickupShopId");
                    String dropoffShopIdStr = request.getParameter("dropoffShopId");
                    
                    int insuranceId = 0;
                    try {
                        insuranceId = Integer.parseInt(request.getParameter("insuranceId"));
                    } catch(Exception e) {}
                    
                    int usePoints = 0;
                    try {
                        usePoints = Integer.parseInt(request.getParameter("usePoints"));
                    } catch(Exception e) {}
                    
                    // 면허 상태 검증
                    MemberDto currentMember = MemberDao.getInstance().getMember(loginUser.getMemberId());
                    if (currentMember == null || !"APPROVED".equals(currentMember.getLicenseStatus())) {
                        String statusKo = "미확인";
                        if (currentMember != null) {
                            if ("PENDING".equals(currentMember.getLicenseStatus())) statusKo = "승인 대기 중";
                            else if ("REJECTED".equals(currentMember.getLicenseStatus())) statusKo = "반려됨 (재등록 필요)";
                        }
                        request.setAttribute("errorMessage", "대여 예약을 하려면 관리자의 면허 승인이 필요합니다. (현재 상태: " + statusKo + ")");
                        
                        BikeDto bike = BikeDao.getInstance().getBike(bikeId);
                        List<ReviewDto> reviewList = ReviewDao.getInstance().getReviewsByBike(bikeId);
                        List<java.util.Map<String, Object>> shopList = BikeDao.getInstance().getShopList();
                        List<CouponDto> couponList = CouponDao.getInstance().getCouponsByUser(loginUser.getMemberId());
                        List<OptionItemDto> optionList = OptionItemDao.getInstance().getOptionList();
                        List<InsurancePlanDto> insuranceList = InsurancePlanDao.getInstance().getInsurancePlansAll();
                        
                        request.setAttribute("bike", bike);
                        request.setAttribute("reviewList", reviewList);
                        request.setAttribute("shopList", shopList);
                        request.setAttribute("couponList", couponList);
                        request.setAttribute("optionList", optionList);
                        request.setAttribute("insuranceList", insuranceList);
                        
                        isRedirect = false;
                        viewPage = "/WEB-INF/views/bike/bike_detail.jsp";
                    } else {
                        BookingDto dto = new BookingDto();
                        dto.setMemberId(loginUser.getMemberId());
                        dto.setBikeId(bikeId);
                        if (pickupShopIdStr != null && !pickupShopIdStr.trim().isEmpty()) {
                            dto.setPickupShopId(Integer.parseInt(pickupShopIdStr));
                        }
                        if (dropoffShopIdStr != null && !dropoffShopIdStr.trim().isEmpty()) {
                            dto.setDropoffShopId(Integer.parseInt(dropoffShopIdStr));
                        }
                        try {
                            dto.setStartDate(java.sql.Timestamp.valueOf(startDateStr + " 09:00:00"));
                            dto.setEndDate(java.sql.Timestamp.valueOf(endDateStr + " 18:00:00"));
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        dto.setRentalDays(rentalDays);
                        dto.setPrice(totalPrice);
                        dto.setPaymentMethod(paymentMethod);
                        dto.setInsuranceId(insuranceId);
                        dto.setUsePoints(usePoints);
 
                        // 대여 옵션 장비 수신
                        String[] optionIds = request.getParameterValues("optionId");
                        List<BookingOptionDto> bOptions = new java.util.ArrayList<>();
                        if (optionIds != null) {
                            for (String optIdStr : optionIds) {
                                int optId = Integer.parseInt(optIdStr);
                                String qtyStr = request.getParameter("quantity_" + optId);
                                int qty = (qtyStr != null) ? Integer.parseInt(qtyStr) : 1;
                                BookingOptionDto boDto = new BookingOptionDto();
                                boDto.setOptionId(optId);
                                boDto.setQuantity(qty);
                                bOptions.add(boDto);
                            }
                        }
                        dto.setBookingOptions(bOptions);
                        
                        int r = BookingDao.getInstance().insertBooking(dto);
                        if (r > 0) {
                            if (couponIdStr != null && !couponIdStr.trim().isEmpty() && !"none".equals(couponIdStr)) {
                                try {
                                    int couponId = Integer.parseInt(couponIdStr);
                                    CouponDao.getInstance().updateCouponStatus(couponId, "USED");
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            }
                            // 세션 로그인 유저 정보 리프레시 (포인트 차감/적립 상태 반영)
                            loginUser = MemberDao.getInstance().getMember(loginUser.getMemberId());
                            session.setAttribute("loginUser", loginUser);
                            
                            isRedirect = true;
                            viewPage = "mypage.do";
                        } else {
                            isRedirect = true;
                            viewPage = "bikeDetail.do?bikeId=" + bikeId;
                        }
                    }
                }
            } else if (command.equals("/bookingStatusAction.do")) {
                // 예약 상태 승인/반려 (관리자 기능)
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int bookingId = Integer.parseInt(request.getParameter("bookingId"));
                    String status = request.getParameter("status"); // APPROVED, CANCELLED
                    
                    BookingDao.getInstance().updateBookingStatus(bookingId, status);
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/adminLicenseAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int memberId = Integer.parseInt(request.getParameter("memberId"));
                    String status = request.getParameter("status"); // APPROVED, REJECTED
                    MemberDao.getInstance().updateLicenseStatus(memberId, status);
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/userLicenseSubmitAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser != null) {
                    String licenseType = request.getParameter("licenseType");
                    String licenseNumber = request.getParameter("licenseNumber");
                    
                    String imageFilename = null;
                    try {
                        jakarta.servlet.http.Part filePart = request.getPart("licenseImage");
                        if (filePart != null && filePart.getSize() > 0) {
                            String originalName = filePart.getSubmittedFileName();
                            String extension = "";
                            int dotIndex = originalName.lastIndexOf('.');
                            if (dotIndex > 0) {
                                extension = originalName.substring(dotIndex);
                            }
                            imageFilename = "license_" + System.currentTimeMillis() + extension;
                            
                            // 톰캣 배포 경로에 저장
                            String deployDir = request.getServletContext().getRealPath("/resources/images/licenses");
                            java.io.File uploadDir = new java.io.File(deployDir);
                            if (!uploadDir.exists()) {
                                uploadDir.mkdirs();
                            }
                            String deployFilePath = deployDir + java.io.File.separator + imageFilename;
                            filePart.write(deployFilePath);
                            
                            // 소스 폴더 경로에도 복사
                            String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\images\\licenses";
                            java.io.File srcUploadDir = new java.io.File(srcDir);
                            if (srcUploadDir.exists()) {
                                try {
                                    java.nio.file.Files.copy(
                                        java.nio.file.Paths.get(deployFilePath),
                                        java.nio.file.Paths.get(srcDir + java.io.File.separator + imageFilename),
                                        java.nio.file.StandardCopyOption.REPLACE_EXISTING
                                    );
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    
                    if (imageFilename != null) {
                        LicenseAuditDto auditDto = new LicenseAuditDto();
                        auditDto.setUserId(loginUser.getMemberId());
                        auditDto.setLicenseType(licenseType);
                        auditDto.setLicenseImage("resources/images/licenses/" + imageFilename);
                        
                        LicenseAuditDao.getInstance().insertAudit(auditDto);
                        MemberDao.getInstance().updateLicenseInfo(loginUser.getMemberId(), licenseNumber, "PENDING");
                    }
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/adminLicenseAuditAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int auditId = Integer.parseInt(request.getParameter("auditId"));
                    String status = request.getParameter("status"); // APPROVED, REJECTED
                    String rejectReason = request.getParameter("rejectReason");
                    
                    LicenseAuditDao.getInstance().updateAuditStatus(auditId, status, rejectReason, loginUser.getMemberId());
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/adminMaintenanceAddAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int bikeId = Integer.parseInt(request.getParameter("bikeId"));
                    String maintType = request.getParameter("maintenanceType");
                    String content = request.getParameter("content");
                    int cost = 0;
                    try {
                        cost = Integer.parseInt(request.getParameter("cost"));
                    } catch (Exception e) {}
                    String shopName = request.getParameter("shopName");
                    
                    String maintDateStr = request.getParameter("maintenanceDate");
                    java.sql.Date maintDate = null;
                    if (maintDateStr != null && !maintDateStr.trim().isEmpty()) {
                        try {
                            maintDate = java.sql.Date.valueOf(maintDateStr);
                        } catch (Exception e) {}
                    }
                    if (maintDate == null) {
                        maintDate = new java.sql.Date(System.currentTimeMillis());
                    }
                    
                    String nextCheckDateStr = request.getParameter("nextCheckDate");
                    java.sql.Date nextCheckDate = null;
                    if (nextCheckDateStr != null && !nextCheckDateStr.trim().isEmpty()) {
                        try {
                            nextCheckDate = java.sql.Date.valueOf(nextCheckDateStr);
                        } catch (Exception e) {}
                    }
                    
                    BikeMaintenanceDto dto = new BikeMaintenanceDto();
                    dto.setBikeId(bikeId);
                    dto.setMaintenanceDate(maintDate);
                    dto.setMaintenanceType(maintType);
                    dto.setContent(content);
                    dto.setCost(cost);
                    dto.setShopName(shopName);
                    dto.setNextCheckDate(nextCheckDate);
                    
                    BikeMaintenanceDao.getInstance().insertMaintenance(dto);
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/adminFuelLogAddAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int reservationId = Integer.parseInt(request.getParameter("reservationId"));
                    int fuelLevel = Integer.parseInt(request.getParameter("fuelLevel"));
                    
                    // 패널티 부과 계산: 100% 미만일 경우 1%당 1,000원
                    int penaltyAmount = 0;
                    if (fuelLevel < 100) {
                        penaltyAmount = (100 - fuelLevel) * 1000;
                    }
                    
                    FuelLogDto dto = new FuelLogDto();
                    dto.setReservationId(reservationId);
                    dto.setFuelLevel(fuelLevel);
                    dto.setPenaltyAmount(penaltyAmount);
                    
                    FuelLogDao.getInstance().insertFuelLogAndUpdateBooking(dto);
                    
                    try {
                        BookingDto booking = BookingDao.getInstance().getBooking(reservationId);
                        if (booking != null) {
                            String notiText = "🏍️ 바이크 반납 처리가 완료되었습니다. (반납 시 주유량: " + fuelLevel + "%)";
                            if (penaltyAmount > 0) {
                                notiText += " 주유량 미달 패널티 ₩" + String.format("%,d", penaltyAmount) + "원이 고지되었습니다. 마이페이지에서 상세 내역을 확인해 주세요.";
                            } else {
                                notiText += " 주유 상태 정상 확인되었습니다. 이용해 주셔서 감사합니다!";
                            }
                            NotificationDao.send(booking.getMemberId(), "알림톡", notiText);
                        }
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/paymentCancelAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser != null) {
                    int paymentId = Integer.parseInt(request.getParameter("paymentId"));
                    String cancelType = request.getParameter("cancelType"); // FULL, PARTIAL
                    int cancelAmt = Integer.parseInt(request.getParameter("cancelAmount"));
                    
                    PaymentDto pay = PaymentDao.getInstance().getPayment(paymentId);
                    if (pay != null) {
                        boolean isAuthorized = "ADMIN".equals(loginUser.getMemberStatus());
                        if (!isAuthorized) {
                            BookingDto booking = BookingDao.getInstance().getBooking(pay.getReservationId());
                            if (booking != null && booking.getMemberId() == loginUser.getMemberId()) {
                                isAuthorized = true;
                            }
                        }
                        
                        if (isAuthorized) {
                            String newStatus = "전체취소";
                            if ("PARTIAL".equals(cancelType)) {
                                newStatus = "부분취소";
                            }
                            
                            int newRefundAmt = pay.getRefundAmount() + cancelAmt;
                            if (newRefundAmt > pay.getAmount()) {
                                newRefundAmt = pay.getAmount();
                            }
                            PaymentDao.getInstance().updatePaymentStatus(paymentId, newStatus, newRefundAmt);
                            
                            if ("전체취소".equals(newStatus)) {
                                BookingDao.getInstance().updateBookingStatus(pay.getReservationId(), "CANCELLED");
                            }

                            // Log refund in refund_log
                            int penaltyRate = (int) Math.round((1.0 - (double)cancelAmt / pay.getAmount()) * 100.0);
                            if (penaltyRate < 0) penaltyRate = 0;
                            if (penaltyRate > 100) penaltyRate = 100;
                            
                            RefundLogDto rlog = new RefundLogDto();
                            rlog.setPaymentId(paymentId);
                            rlog.setPenaltyRate(penaltyRate);
                            rlog.setRefundAmount(cancelAmt);
                            rlog.setRefundMethod(pay.getPaymentMethod());
                            rlog.setStatus("완료");
                            RefundLogDao.getInstance().insertRefund(rlog);
                            
                            try {
                                BookingDto booking = BookingDao.getInstance().getBooking(pay.getReservationId());
                                if (booking != null) {
                                    String notiContent = "💳 결제 취소 안내: [" + newStatus + "] 처리 완료 (취소 및 환불금액: ₩" + String.format("%,d", cancelAmt) + "원)";
                                    NotificationDao.send(booking.getMemberId(), "알림톡", notiContent);
                                }
                            } catch (Exception ex) {
                                ex.printStackTrace();
                            }
                        }
                    }
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/adminNotificationAddAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int targetUserId = Integer.parseInt(request.getParameter("userId"));
                    String notiType = request.getParameter("notificationType");
                    String notiContent = request.getParameter("content");
                    
                    NotificationDao.send(targetUserId, notiType, notiContent);
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/userNotificationReadAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser != null) {
                    int notiId = Integer.parseInt(request.getParameter("notificationId"));
                    NotificationDao.getInstance().markAsRead(notiId);
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/bookingCancelAction.do")) {
                // 예약 취소 (일반 회원 기능)
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser != null) {
                    int bookingId = Integer.parseInt(request.getParameter("bookingId"));
                    BookingDto booking = BookingDao.getInstance().getBooking(bookingId);
                    
                    if (booking != null && (booking.getMemberId() == loginUser.getMemberId() || "ADMIN".equals(loginUser.getMemberStatus()))) {
                        BookingDao.getInstance().updateBookingStatus(bookingId, "CANCELLED");

                        // Refund policy calculation and log logging
                        PaymentDto payment = PaymentDao.getInstance().getPaymentByReservation(bookingId);
                        if (payment != null) {
                            java.sql.Timestamp startDate = booking.getStartDate();
                            java.time.LocalDate startLocalDate = startDate.toLocalDateTime().toLocalDate();
                            java.time.LocalDate currentLocalDate = java.time.LocalDate.now();
                            long diffDays = java.time.temporal.ChronoUnit.DAYS.between(currentLocalDate, startLocalDate);

                            int penaltyRate = 0;
                            if (diffDays >= 3) {
                                penaltyRate = 0;
                            } else if (diffDays >= 1) {
                                penaltyRate = 50;
                            } else {
                                penaltyRate = 100;
                            }

                            int refundAmt = (int) (payment.getAmount() * (100 - penaltyRate) / 100.0);
                            PaymentDao.getInstance().updatePaymentStatus(payment.getPaymentId(), "전체취소", refundAmt);

                            RefundLogDto rlog = new RefundLogDto();
                            rlog.setPaymentId(payment.getPaymentId());
                            rlog.setPenaltyRate(penaltyRate);
                            rlog.setRefundAmount(refundAmt);
                            rlog.setRefundMethod(payment.getPaymentMethod());
                            rlog.setStatus("완료");
                            RefundLogDao.getInstance().insertRefund(rlog);

                            String notiContent = "💳 결제 취소 및 환불 안내: 예약 #" + bookingId + "이 취소되었습니다. (위약금 " + penaltyRate + "%, 환불금액: ₩" + String.format("%,d", refundAmt) + "원)";
                            NotificationDao.send(booking.getMemberId(), "알림톡", notiContent);
                        }
                    }
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/boardList.do")) {
                String boardType = request.getParameter("boardType");
                if (boardType == null || boardType.isEmpty()) {
                    boardType = "FREE"; // 기본값 자유게시판
                }
                
                int currentPage = 1;
                String pageParam = request.getParameter("page");
                if (pageParam != null && !pageParam.isEmpty()) {
                    currentPage = Integer.parseInt(pageParam);
                }
                
                int totalItems = BoardDao.getInstance().getPostCount(boardType);
                Pagination paging = new Pagination(totalItems, currentPage);
                
                List<BoardDto> postList = BoardDao.getInstance().getPostList(boardType, paging.getStartRow(), paging.getEndRow());
                
                request.setAttribute("postList", postList);
                request.setAttribute("paging", paging);
                request.setAttribute("boardType", boardType);
                
                viewPage = "/WEB-INF/views/board/list.jsp";
                
            } else if (command.equals("/boardDetail.do")) {
                int postId = Integer.parseInt(request.getParameter("postId"));
                
                // 조회수 1 증가
                BoardDao.getInstance().updateViewCount(postId);
                
                BoardDto post = BoardDao.getInstance().getPost(postId);
                List<CommentDto> commentList = CommentDao.getInstance().getCommentList(postId);
                
                request.setAttribute("post", post);
                request.setAttribute("commentList", commentList);
                
                viewPage = "/WEB-INF/views/board/detail.jsp";
                
            } else if (command.equals("/boardWrite.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = "login.do";
                } else {
                    request.setAttribute("boardType", request.getParameter("boardType"));
                    viewPage = "/WEB-INF/views/board/write.jsp";
                }
                
            } else if (command.equals("/boardWriteAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = "login.do";
                } else {
                    String boardType = request.getParameter("boardType");
                    String title = request.getParameter("title");
                    String content = request.getParameter("content");
                    
                    String imageFilename = null;
                    try {
                        jakarta.servlet.http.Part filePart = request.getPart("attachedFile");
                        if (filePart != null && filePart.getSize() > 0) {
                            String originalName = filePart.getSubmittedFileName();
                            String safeName = originalName != null ? originalName.replaceAll("[\\\\/:*?\"<>|\\s]", "_") : "file";
                            imageFilename = "board_" + System.currentTimeMillis() + "_" + safeName;
                            
                            // 톰캣 배포 경로에 저장
                            String deployDir = request.getServletContext().getRealPath("/resources/upload");
                            java.io.File uploadDir = new java.io.File(deployDir);
                            if (!uploadDir.exists()) {
                                uploadDir.mkdirs();
                            }
                            String deployFilePath = deployDir + java.io.File.separator + imageFilename;
                            filePart.write(deployFilePath);
                            
                            // 소스 폴더 경로에도 복사
                            String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\upload";
                            java.io.File srcUploadDir = new java.io.File(srcDir);
                            if (!srcUploadDir.exists()) {
                                srcUploadDir.mkdirs();
                            }
                            try {
                                java.nio.file.Files.copy(
                                    java.nio.file.Paths.get(deployFilePath),
                                    java.nio.file.Paths.get(srcDir + java.io.File.separator + imageFilename),
                                    java.nio.file.StandardCopyOption.REPLACE_EXISTING
                                );
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    
                    BoardDto dto = new BoardDto();
                    dto.setMemberId(loginUser.getMemberId());
                    dto.setTitle(title);
                    dto.setContent(content);
                    dto.setBoardType(boardType);
                    dto.setFilename(imageFilename);
                    
                    int r = BoardDao.getInstance().insertPost(dto);
                    isRedirect = true;
                    viewPage = "boardList.do?boardType=" + boardType;
                }
                
            } else if (command.equals("/boardUpdate.do")) {
                int postId = Integer.parseInt(request.getParameter("postId"));
                BoardDto post = BoardDao.getInstance().getPost(postId);
                request.setAttribute("post", post);
                viewPage = "/WEB-INF/views/board/update.jsp";
                
            } else if (command.equals("/boardUpdateAction.do")) {
                int postId = Integer.parseInt(request.getParameter("postId"));
                String title = request.getParameter("title");
                String content = request.getParameter("content");
                String deleteExistingStr = request.getParameter("deleteExistingFile");
                boolean deleteExisting = "true".equals(deleteExistingStr);
                
                BoardDto existingPost = BoardDao.getInstance().getPost(postId);
                String filename = (existingPost != null) ? existingPost.getFilename() : null;
                
                jakarta.servlet.http.Part filePart = null;
                try {
                    filePart = request.getPart("attachedFile");
                } catch (Exception e) {
                    e.printStackTrace();
                }
                
                boolean hasNewFile = filePart != null && filePart.getSize() > 0;
                
                if (deleteExisting || hasNewFile) {
                    // 기존 파일 삭제
                    if (filename != null && !filename.isEmpty()) {
                        try {
                            String deployDir = request.getServletContext().getRealPath("/resources/upload");
                            java.io.File deployFile = new java.io.File(deployDir + java.io.File.separator + filename);
                            if (deployFile.exists()) {
                                deployFile.delete();
                            }
                            String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\upload";
                            java.io.File srcFile = new java.io.File(srcDir + java.io.File.separator + filename);
                            if (srcFile.exists()) {
                                srcFile.delete();
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        filename = null;
                    }
                    
                    // 새 파일 저장
                    if (hasNewFile) {
                        try {
                            String originalName = filePart.getSubmittedFileName();
                            String safeName = originalName != null ? originalName.replaceAll("[\\\\/:*?\"<>|\\s]", "_") : "file";
                            filename = "board_" + System.currentTimeMillis() + "_" + safeName;
                            
                            String deployDir = request.getServletContext().getRealPath("/resources/upload");
                            java.io.File uploadDir = new java.io.File(deployDir);
                            if (!uploadDir.exists()) {
                                uploadDir.mkdirs();
                            }
                            String deployFilePath = deployDir + java.io.File.separator + filename;
                            filePart.write(deployFilePath);
                            
                            String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\upload";
                            java.io.File srcUploadDir = new java.io.File(srcDir);
                            if (!srcUploadDir.exists()) {
                                srcUploadDir.mkdirs();
                            }
                            try {
                                java.nio.file.Files.copy(
                                    java.nio.file.Paths.get(deployFilePath),
                                    java.nio.file.Paths.get(srcDir + java.io.File.separator + filename),
                                    java.nio.file.StandardCopyOption.REPLACE_EXISTING
                                );
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
                
                BoardDto dto = new BoardDto();
                dto.setPostId(postId);
                dto.setTitle(title);
                dto.setContent(content);
                dto.setFilename(filename);
                
                BoardDao.getInstance().updatePost(dto);
                
                isRedirect = true;
                viewPage = "boardDetail.do?postId=" + postId;
                
            } else if (command.equals("/boardDeleteAction.do")) {
                int postId = Integer.parseInt(request.getParameter("postId"));
                String boardType = request.getParameter("boardType");
                
                // 첨부파일 삭제
                try {
                    BoardDto post = BoardDao.getInstance().getPost(postId);
                    if (post != null && post.getFilename() != null && !post.getFilename().isEmpty()) {
                        String filename = post.getFilename();
                        String deployDir = request.getServletContext().getRealPath("/resources/upload");
                        java.io.File deployFile = new java.io.File(deployDir + java.io.File.separator + filename);
                        if (deployFile.exists()) {
                            deployFile.delete();
                        }
                        String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\upload";
                        java.io.File srcFile = new java.io.File(srcDir + java.io.File.separator + filename);
                        if (srcFile.exists()) {
                            srcFile.delete();
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                
                BoardDao.getInstance().deletePost(postId);
                
                isRedirect = true;
                viewPage = "boardList.do?boardType=" + boardType;
                
            } else if (command.equals("/commentWriteAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = "login.do";
                } else {
                    int postId = Integer.parseInt(request.getParameter("postId"));
                    String content = request.getParameter("content");
                    
                    CommentDto dto = new CommentDto();
                    dto.setPostId(postId);
                    dto.setMemberId(loginUser.getMemberId());
                    dto.setContent(content);
                    
                    CommentDao.getInstance().insertComment(dto);
                    
                    isRedirect = true;
                    viewPage = "boardDetail.do?postId=" + postId;
                }
                
            } else if (command.equals("/commentDeleteAction.do")) {
                int commentId = Integer.parseInt(request.getParameter("commentId"));
                int postId = Integer.parseInt(request.getParameter("postId"));
                
                CommentDao.getInstance().deleteComment(commentId);
                
                isRedirect = true;
                viewPage = "boardDetail.do?postId=" + postId;
                
            } else if (command.equals("/inquiryAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = "login.do";
                } else {
                    String title = request.getParameter("title");
                    String content = request.getParameter("content");
                    InquiryDto dto = new InquiryDto();
                    dto.setUserId(loginUser.getMemberId());
                    dto.setTitle(title);
                    dto.setContent(content);
                    InquiryDao.getInstance().insertInquiry(dto);
                    isRedirect = true;
                    viewPage = "mypage.do";
                }
                
            } else if (command.equals("/reviewAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = "login.do";
                } else {
                    int bikeId = Integer.parseInt(request.getParameter("bikeId"));
                    int reservationId = Integer.parseInt(request.getParameter("reservationId"));
                    int rating = Integer.parseInt(request.getParameter("rating"));
                    String title = request.getParameter("title");
                    String content = request.getParameter("content");
                    
                    ReviewDto dto = new ReviewDto();
                    dto.setUserId(loginUser.getMemberId());
                    dto.setReservationId(reservationId);
                    dto.setBikeId(bikeId);
                    dto.setRating(rating);
                    dto.setTitle(title);
                    dto.setContent(content);
                    ReviewDao.getInstance().insertReview(dto);
                    
                    isRedirect = true;
                    viewPage = "bikeDetail.do?bikeId=" + bikeId;
                }
                
            } else if (command.equals("/adminInquiryAnswer.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int inquiryId = Integer.parseInt(request.getParameter("inquiryId"));
                    String answerContent = request.getParameter("answerContent");
                    InquiryDao.getInstance().updateAnswer(inquiryId, answerContent);
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/adminCouponIssue.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    String targetUser = request.getParameter("targetUser");
                    String couponName = request.getParameter("couponName");
                    int discountAmount = Integer.parseInt(request.getParameter("discountAmount"));
                    String expireDateStr = request.getParameter("expireDate");
                    
                    java.sql.Date expireDate = java.sql.Date.valueOf(expireDateStr);
                    
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
                isRedirect = true;
                viewPage = "mypage.do";

            } else if (command.equals("/adminBikeAddAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    String brandIdStr = request.getParameter("brandId");
                    String shopIdStr = request.getParameter("shopId");
                    String modelName = request.getParameter("modelName");
                    int cc = Integer.parseInt(request.getParameter("cc"));
                    int year = Integer.parseInt(request.getParameter("year"));
                    String color = request.getParameter("color");
                    int dailyPrice = Integer.parseInt(request.getParameter("dailyPrice"));
                    int mileage = Integer.parseInt(request.getParameter("mileage"));
                    String description = request.getParameter("description");
                    String imageUrl = request.getParameter("imageUrl");
                    
                    BikeDto dto = new BikeDto();
                    dto.setBrandCountry(brandIdStr);
                    dto.setShopAddress(shopIdStr);
                    dto.setBikeName(modelName);
                    dto.setCc(cc);
                    dto.setYear(year);
                    dto.setColor(color);
                    dto.setDailyPrice(dailyPrice);
                    dto.setMileage(mileage);
                    dto.setDescription(description);
                    
                    int bikeResult = BikeDao.getInstance().insertBike(dto);
                    if (bikeResult > 0 && imageUrl != null && !imageUrl.trim().isEmpty()) {
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        try {
                            conn = com.bikerental.util.DBConnection.getConnection();
                            pstmt = conn.prepareStatement("INSERT INTO bike_images (image_id, bike_id, image_url, is_thumbnail) VALUES (seq_bike_images.NEXTVAL, seq_motorcycles.CURRVAL, ?, 'Y')");
                            pstmt.setString(1, imageUrl);
                            pstmt.executeUpdate();
                        } catch (Exception e) {
                            e.printStackTrace();
                        } finally {
                            com.bikerental.util.DBConnection.close(conn, pstmt, null);
                        }
                    }
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/adminBikeDeleteAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int bikeId = Integer.parseInt(request.getParameter("bikeId"));
                    BikeDao.getInstance().deleteBike(bikeId);
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/adminOptionAddAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    String optionName = request.getParameter("optionName");
                    int stockQuantity = Integer.parseInt(request.getParameter("stockQuantity"));
                    int dailyPrice = Integer.parseInt(request.getParameter("dailyPrice"));
                    String status = request.getParameter("status");
                    
                    String imageFilename = "gear_default.png";
                    try {
                        jakarta.servlet.http.Part filePart = request.getPart("gearImage");
                        if (filePart != null && filePart.getSize() > 0) {
                            String originalName = filePart.getSubmittedFileName();
                            String extension = "";
                            int dotIndex = originalName.lastIndexOf('.');
                            if (dotIndex > 0) {
                                extension = originalName.substring(dotIndex);
                            }
                            imageFilename = "gear_" + System.currentTimeMillis() + extension;
                            
                            String deployDir = request.getServletContext().getRealPath("/resources/images/gears");
                            java.io.File uploadDir = new java.io.File(deployDir);
                            if (!uploadDir.exists()) {
                                uploadDir.mkdirs();
                            }
                            String deployFilePath = deployDir + java.io.File.separator + imageFilename;
                            filePart.write(deployFilePath);
                            
                            String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\images\\gears";
                            java.io.File srcUploadDir = new java.io.File(srcDir);
                            if (srcUploadDir.exists()) {
                                try {
                                    java.nio.file.Files.copy(
                                        java.nio.file.Paths.get(deployFilePath),
                                        java.nio.file.Paths.get(srcDir + java.io.File.separator + imageFilename),
                                        java.nio.file.StandardCopyOption.REPLACE_EXISTING
                                    );
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    
                    OptionItemDto dto = new OptionItemDto();
                    dto.setOptionName(optionName);
                    dto.setStockQuantity(stockQuantity);
                    dto.setDailyPrice(dailyPrice);
                    dto.setImageFilename(imageFilename);
                    dto.setStatus(status);
                    
                    OptionItemDao.getInstance().insertOption(dto);
                }
                isRedirect = true;
                viewPage = "mypage.do?tab=tab-admin-gears";
                
            } else if (command.equals("/adminOptionUpdateAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int optionId = Integer.parseInt(request.getParameter("optionId"));
                    String optionName = request.getParameter("optionName");
                    int stockQuantity = Integer.parseInt(request.getParameter("stockQuantity"));
                    int dailyPrice = Integer.parseInt(request.getParameter("dailyPrice"));
                    String status = request.getParameter("status");
                    
                    OptionItemDto dto = OptionItemDao.getInstance().getOption(optionId);
                    if (dto != null) {
                        dto.setOptionName(optionName);
                        dto.setStockQuantity(stockQuantity);
                        dto.setDailyPrice(dailyPrice);
                        dto.setStatus(status);
                        
                        try {
                            jakarta.servlet.http.Part filePart = request.getPart("gearImage");
                            if (filePart != null && filePart.getSize() > 0) {
                                String originalName = filePart.getSubmittedFileName();
                                String extension = "";
                                int dotIndex = originalName.lastIndexOf('.');
                                if (dotIndex > 0) {
                                    extension = originalName.substring(dotIndex);
                                }
                                String imageFilename = "gear_" + System.currentTimeMillis() + extension;
                                
                                String deployDir = request.getServletContext().getRealPath("/resources/images/gears");
                                java.io.File uploadDir = new java.io.File(deployDir);
                                if (!uploadDir.exists()) {
                                    uploadDir.mkdirs();
                                }
                                String deployFilePath = deployDir + java.io.File.separator + imageFilename;
                                filePart.write(deployFilePath);
                                
                                String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\images\\gears";
                                java.io.File srcUploadDir = new java.io.File(srcDir);
                                if (srcUploadDir.exists()) {
                                    try {
                                        java.nio.file.Files.copy(
                                            java.nio.file.Paths.get(deployFilePath),
                                            java.nio.file.Paths.get(srcDir + java.io.File.separator + imageFilename),
                                            java.nio.file.StandardCopyOption.REPLACE_EXISTING
                                        );
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }
                                }
                                dto.setImageFilename(imageFilename);
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        OptionItemDao.getInstance().updateOption(dto);
                    }
                }
                isRedirect = true;
                viewPage = "mypage.do?tab=tab-admin-gears";
                
            } else if (command.equals("/adminOptionDeleteAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int optionId = Integer.parseInt(request.getParameter("optionId"));
                    OptionItemDao.getInstance().deleteOption(optionId);
                }
                isRedirect = true;
                viewPage = "mypage.do?tab=tab-admin-gears";
                
            } else if (command.equals("/adminBrandAddAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    String brandName = request.getParameter("brandName");
                    String country = request.getParameter("country");
                    String description = request.getParameter("description");
                    BikeDao.getInstance().insertBrand(brandName, country, description);
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/adminBrandDeleteAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int brandId = Integer.parseInt(request.getParameter("brandId"));
                    BikeDao.getInstance().deleteBrand(brandId);
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/adminShopAddAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    String shopName = request.getParameter("shopName");
                    String managerName = request.getParameter("managerName");
                    String tel = request.getParameter("tel");
                    String address = request.getParameter("address");
                    String openTime = request.getParameter("openTime");
                    String closeTime = request.getParameter("closeTime");
                    
                    String imageFilename = null;
                    try {
                        jakarta.servlet.http.Part filePart = request.getPart("shopImage");
                        if (filePart != null && filePart.getSize() > 0) {
                            String originalName = filePart.getSubmittedFileName();
                            String extension = "";
                            int dotIndex = originalName.lastIndexOf('.');
                            if (dotIndex > 0) {
                                extension = originalName.substring(dotIndex);
                            }
                            imageFilename = "shop_" + System.currentTimeMillis() + extension;
                            
                            // 톰캣 배포 경로에 저장
                            String deployDir = request.getServletContext().getRealPath("/resources/images/shops");
                            java.io.File uploadDir = new java.io.File(deployDir);
                            if (!uploadDir.exists()) {
                                uploadDir.mkdirs();
                            }
                            String deployFilePath = deployDir + java.io.File.separator + imageFilename;
                            filePart.write(deployFilePath);
                            
                            // 소스 폴더 경로에도 복사
                            String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\images\\shops";
                            java.io.File srcUploadDir = new java.io.File(srcDir);
                            if (srcUploadDir.exists()) {
                                try {
                                    java.nio.file.Files.copy(
                                        java.nio.file.Paths.get(deployFilePath),
                                        java.nio.file.Paths.get(srcDir + java.io.File.separator + imageFilename),
                                        java.nio.file.StandardCopyOption.REPLACE_EXISTING
                                    );
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    
                    BikeDao.getInstance().insertShop(shopName, managerName, tel, address, openTime, closeTime, imageFilename);
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/adminShopImageUploadAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    try {
                        int shopId = Integer.parseInt(request.getParameter("shopId"));
                        jakarta.servlet.http.Part filePart = request.getPart("shopImage");
                        if (filePart != null && filePart.getSize() > 0) {
                            String originalName = filePart.getSubmittedFileName();
                            String extension = "";
                            int dotIndex = originalName.lastIndexOf('.');
                            if (dotIndex > 0) {
                                extension = originalName.substring(dotIndex);
                            }
                            String imageFilename = "shop_" + System.currentTimeMillis() + extension;
                            
                            // 톰캣 배포 경로에 저장
                            String deployDir = request.getServletContext().getRealPath("/resources/images/shops");
                            java.io.File uploadDir = new java.io.File(deployDir);
                            if (!uploadDir.exists()) {
                                uploadDir.mkdirs();
                            }
                            String deployFilePath = deployDir + java.io.File.separator + imageFilename;
                            filePart.write(deployFilePath);
                            
                            // 소스 폴더 경로에도 복사
                            String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\images\\shops";
                            java.io.File srcUploadDir = new java.io.File(srcDir);
                            if (srcUploadDir.exists()) {
                                try {
                                    java.nio.file.Files.copy(
                                        java.nio.file.Paths.get(deployFilePath),
                                        java.nio.file.Paths.get(srcDir + java.io.File.separator + imageFilename),
                                        java.nio.file.StandardCopyOption.REPLACE_EXISTING
                                    );
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            }
                            
                            // DB 업데이트
                            BikeDao.getInstance().updateShopImage(shopId, imageFilename);
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                isRedirect = true;
                viewPage = "mypage.do";

            } else if (command.equals("/adminShopImageDeleteAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    try {
                        int shopId = Integer.parseInt(request.getParameter("shopId"));
                        
                        // 지점 정보 조회해서 기존 파일명 찾기
                        List<java.util.Map<String, Object>> shopList = BikeDao.getInstance().getShopListAll();
                        String imageFilename = null;
                        for (java.util.Map<String, Object> shop : shopList) {
                            if (((Integer) shop.get("shopId")) == shopId) {
                                imageFilename = (String) shop.get("imageFilename");
                                break;
                            }
                        }
                        
                        // 파일 삭제 (shop_1.png 등 기본 적재 파일이 아닐 경우에만 삭제)
                        if (imageFilename != null && imageFilename.startsWith("shop_") && imageFilename.length() > 15) {
                            String deployDir = request.getServletContext().getRealPath("/resources/images/shops");
                            java.io.File deployFile = new java.io.File(deployDir + java.io.File.separator + imageFilename);
                            if (deployFile.exists()) {
                                deployFile.delete();
                            }
                            
                            String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\images\\shops";
                            java.io.File srcFile = new java.io.File(srcDir + java.io.File.separator + imageFilename);
                            if (srcFile.exists()) {
                                srcFile.delete();
                            }
                        }
                        
                        // DB 컬럼 null로 업데이트
                        BikeDao.getInstance().updateShopImage(shopId, null);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/adminShopDeleteAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int shopId = Integer.parseInt(request.getParameter("shopId"));
                    
                    // 지점의 파일 삭제 시도
                    List<java.util.Map<String, Object>> shopList = BikeDao.getInstance().getShopListAll();
                    String imageFilename = null;
                    for (java.util.Map<String, Object> shop : shopList) {
                        if (((Integer) shop.get("shopId")) == shopId) {
                            imageFilename = (String) shop.get("imageFilename");
                            break;
                        }
                    }
                    if (imageFilename != null && imageFilename.startsWith("shop_") && imageFilename.length() > 15) {
                        try {
                            String deployDir = request.getServletContext().getRealPath("/resources/images/shops");
                            java.io.File deployFile = new java.io.File(deployDir + java.io.File.separator + imageFilename);
                            if (deployFile.exists()) {
                                deployFile.delete();
                            }
                            
                            String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\images\\shops";
                            java.io.File srcFile = new java.io.File(srcDir + java.io.File.separator + imageFilename);
                            if (srcFile.exists()) {
                                srcFile.delete();
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                    
                    BikeDao.getInstance().deleteShop(shopId);
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/payPenaltyAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null) {
                    int penaltyId = Integer.parseInt(request.getParameter("penaltyId"));
                    PenaltyDao.getInstance().payPenalty(penaltyId);
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/adminAddPenaltyAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int reservationId = Integer.parseInt(request.getParameter("reservationId"));
                    int userId = Integer.parseInt(request.getParameter("userId"));
                    String penaltyType = request.getParameter("penaltyType");
                    int amount = Integer.parseInt(request.getParameter("amount"));
                    String reason = request.getParameter("reason");
                    
                    PenaltyDto dto = new PenaltyDto();
                    dto.setReservationId(reservationId);
                    dto.setUserId(userId);
                    dto.setPenaltyType(penaltyType);
                    dto.setAmount(amount);
                    dto.setReason(reason);
                    
                    PenaltyDao.getInstance().insertPenalty(dto);
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/guide.do")) {
                viewPage = "/WEB-INF/views/guide.jsp";
            } else if (command.equals("/pricing.do")) {
                viewPage = "/WEB-INF/views/pricing.jsp";
            } else if (command.equals("/support.do")) {
                viewPage = "/WEB-INF/views/support.jsp";
            } else if (command.equals("/notice.do")) {
                viewPage = "/WEB-INF/views/notice.jsp";
            } else if (command.equals("/setupData.do")) {
                viewPage = "/WEB-INF/views/setup_data.jsp";
            } else if (command.equals("/userAccidentReportAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null) {
                    int reservationId = Integer.parseInt(request.getParameter("reservationId"));
                    String accidentDateStr = request.getParameter("accidentDate");
                    String accidentLocation = request.getParameter("accidentLocation");
                    String accidentDescription = request.getParameter("accidentDescription");
                    
                    java.sql.Timestamp accidentDate = null;
                    if (accidentDateStr != null && !accidentDateStr.trim().isEmpty()) {
                        try {
                            String formattedDate = accidentDateStr.replace("T", " ") + ":00";
                            accidentDate = java.sql.Timestamp.valueOf(formattedDate);
                        } catch(Exception e) {
                            e.printStackTrace();
                        }
                    }
                    if (accidentDate == null) {
                        accidentDate = new java.sql.Timestamp(System.currentTimeMillis());
                    }

                    String imageFilename = null;
                    try {
                        jakarta.servlet.http.Part filePart = request.getPart("photo");
                        if (filePart != null && filePart.getSize() > 0) {
                            String originalName = filePart.getSubmittedFileName();
                            String extension = "";
                            int dotIndex = originalName.lastIndexOf('.');
                            if (dotIndex > 0) {
                                extension = originalName.substring(dotIndex);
                            }
                            imageFilename = "accident_" + System.currentTimeMillis() + extension;
                            
                            String deployDir = request.getServletContext().getRealPath("/resources/images/accidents");
                            java.io.File uploadDir = new java.io.File(deployDir);
                            if (!uploadDir.exists()) {
                                uploadDir.mkdirs();
                            }
                            String deployFilePath = deployDir + java.io.File.separator + imageFilename;
                            filePart.write(deployFilePath);
                            
                            String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\images\\accidents";
                            java.io.File srcUploadDir = new java.io.File(srcDir);
                            if (!srcUploadDir.exists()) {
                                srcUploadDir.mkdirs();
                            }
                            try {
                                java.nio.file.Files.copy(
                                    java.nio.file.Paths.get(deployFilePath),
                                    java.nio.file.Paths.get(srcDir + java.io.File.separator + imageFilename),
                                    java.nio.file.StandardCopyOption.REPLACE_EXISTING
                                );
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    } catch(Exception e) {
                        e.printStackTrace();
                    }

                    AccidentReportDto dto = new AccidentReportDto();
                    dto.setReservationId(reservationId);
                    dto.setUserId(loginUser.getMemberId());
                    dto.setAccidentDate(accidentDate);
                    dto.setAccidentLocation(accidentLocation);
                    dto.setAccidentDescription(accidentDescription);
                    if (imageFilename != null) {
                        dto.setPhotoPath("resources/images/accidents/" + imageFilename);
                    }
                    
                    AccidentReportDao.getInstance().insertReport(dto);
                    
                    try {
                        NotificationDao.send(loginUser.getMemberId(), "앱푸시", "🚨 사고 접수가 완료되었습니다. 담당자가 신속히 확인하여 보험 처리를 도와드리겠습니다.");
                    } catch(Exception ex) {
                        ex.printStackTrace();
                    }
                }
                isRedirect = true;
                viewPage = "mypage.do";

            } else if (command.equals("/adminAccidentReportUpdateAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int reportId = Integer.parseInt(request.getParameter("reportId"));
                    String status = request.getParameter("status"); // 접수, 손해사정중, 종결
                    String claimNum = request.getParameter("insuranceClaimNum");
                    int faultRatio = 0;
                    try {
                        faultRatio = Integer.parseInt(request.getParameter("faultRatio"));
                    } catch(Exception e) {}
                    
                    AccidentReportDao.getInstance().updateReportStatus(reportId, status, claimNum, faultRatio);
                    
                    try {
                        AccidentReportDto report = AccidentReportDao.getInstance().getReport(reportId);
                        if (report != null) {
                            String notiText = "🚨 사고 접수 #" + reportId + "번의 처리 상태가 [" + status + "]으로 변경되었습니다.";
                            if ("손해사정중".equals(status)) {
                                notiText += " (보험접수번호: " + claimNum + ", 과실비율: " + faultRatio + "%)";
                            } else if ("종결".equals(status)) {
                                notiText += " 보험 처리가 최종 종결되었습니다. 마이페이지에서 상세 내역을 확인하세요.";
                            }
                            NotificationDao.send(report.getUserId(), "알림톡", notiText);
                        }
                    } catch(Exception ex) {
                        ex.printStackTrace();
                    }
                }
                isRedirect = true;
                viewPage = "mypage.do";

            } else if (command.equals("/adminBlacklistAddAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int targetUserId = Integer.parseInt(request.getParameter("userId"));
                    String banType = request.getParameter("banType"); // 영구차단, 기간차단
                    String reason = request.getParameter("reason");
                    String endDateStr = request.getParameter("endDate");
                    
                    java.sql.Date endDate = null;
                    if (endDateStr != null && !endDateStr.trim().isEmpty() && "기간차단".equals(banType)) {
                        try {
                            endDate = java.sql.Date.valueOf(endDateStr);
                        } catch(Exception e) {
                            e.printStackTrace();
                        }
                    }
                    
                    BlacklistDto dto = new BlacklistDto();
                    dto.setUserId(targetUserId);
                    dto.setBanType(banType);
                    dto.setReason(reason);
                    dto.setEndDate(endDate);
                    dto.setAdminId(loginUser.getMemberId());
                    
                    BlacklistDao.getInstance().insertBlacklist(dto);
                    
                    try {
                        NotificationDao.send(targetUserId, "SMS", "🚫 회원님의 계정이 정책 위반으로 인해 서비스 이용 차단(" + banType + ") 조치되었습니다. (사유: " + reason + ")");
                    } catch(Exception ex) {
                        ex.printStackTrace();
                    }
                }
                isRedirect = true;
                viewPage = "mypage.do";

            } else if (command.equals("/adminBlacklistReleaseAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int blacklistId = Integer.parseInt(request.getParameter("blacklistId"));
                    int targetUserId = Integer.parseInt(request.getParameter("userId"));
                    
                    BlacklistDao.getInstance().deleteBlacklist(blacklistId);
                    
                    try {
                        NotificationDao.send(targetUserId, "SMS", "🔓 회원님의 계정 차단 조치가 해제되었습니다. 정상적으로 서비스 이용이 가능합니다.");
                    } catch(Exception ex) {
                        ex.printStackTrace();
                    }
                }
                isRedirect = true;
                viewPage = "mypage.do";
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }

        if (viewPage != null) {
            if (isRedirect) {
                response.sendRedirect(viewPage);
            } else {
                request.getRequestDispatcher(viewPage).forward(request, response);
            }
        }
    }
}
