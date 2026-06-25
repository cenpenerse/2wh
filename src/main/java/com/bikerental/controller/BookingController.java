package com.bikerental.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.bikerental.dto.AccidentReportDto;
import com.bikerental.dto.BookingDto;
import com.bikerental.dto.BookingOptionDto;
import com.bikerental.dto.MemberDto;
import com.bikerental.dto.PenaltyDto;
import com.bikerental.service.BikeService;
import com.bikerental.service.BookingService;
import com.bikerental.service.MemberService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/booking/*")
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 10,     // 10MB
    maxRequestSize = 1024 * 1024 * 20,   // 20MB
    fileSizeThreshold = 0
)
public class BookingController extends HttpServlet {
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
        
        System.out.println("[BookingController] Requested Command: " + command);

        String viewPage = null;
        boolean isRedirect = false;

        try {
            if (command.equals("/booking/bookingAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = contextPath + "/member/login.do";
                } else if (MemberService.getInstance().isUserBanned(loginUser.getMemberId())) {
                    request.setAttribute("errorMessage", "차단된 회원은 대여를 예약할 수 없습니다.");
                    isRedirect = true;
                    viewPage = contextPath + "/member/mypage.do";
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
                    MemberDto currentMember = MemberService.getInstance().getMemberInfo(loginUser.getMemberId());
                    if (currentMember == null || !"APPROVED".equals(currentMember.getLicenseStatus())) {
                        String statusKo = "미확인";
                        if (currentMember != null) {
                            if ("PENDING".equals(currentMember.getLicenseStatus())) statusKo = "승인 대기 중";
                            else if ("REJECTED".equals(currentMember.getLicenseStatus())) statusKo = "반려됨 (재등록 필요)";
                        }
                        request.setAttribute("errorMessage", "대여 예약을 하려면 관리자의 면허 승인이 필요합니다. (현재 상태: " + statusKo + ")");
                        
                        // 기존 bikeDetail 뷰 로딩용 데이터 셋업 (서비스 위임)
                        Map<String, Object> detailData = BikeService.getInstance().getBikeDetailData(bikeId, loginUser.getMemberId());
                        for (String key : detailData.keySet()) {
                            request.setAttribute(key, detailData.get(key));
                        }
                        request.setAttribute("selectedShopId", pickupShopIdStr);
                        
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
                        List<BookingOptionDto> bOptions = new ArrayList<>();
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
                        
                        int r = BookingService.getInstance().createBooking(dto, couponIdStr);
                        if (r > 0) {
                            // 세션 리프레시
                            loginUser = MemberService.getInstance().getMemberInfo(loginUser.getMemberId());
                            session.setAttribute("loginUser", loginUser);
                            
                            isRedirect = true;
                            viewPage = contextPath + "/member/mypage.do";
                        } else {
                            isRedirect = true;
                            viewPage = contextPath + "/bike/bikeDetail.do?bikeId=" + bikeId;
                        }
                    }
                }
                
            } else if (command.equals("/booking/bookingStatusAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int bookingId = Integer.parseInt(request.getParameter("bookingId"));
                    String status = request.getParameter("status"); // APPROVED, CANCELLED
                    
                    BookingService.getInstance().updateBookingStatus(bookingId, status);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/booking/bookingCancelAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser != null) {
                    int bookingId = Integer.parseInt(request.getParameter("bookingId"));
                    boolean isAdmin = "ADMIN".equals(loginUser.getMemberStatus());
                    
                    BookingService.getInstance().cancelBooking(bookingId, loginUser.getMemberId(), isAdmin);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/booking/paymentCancelAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser != null) {
                    int paymentId = Integer.parseInt(request.getParameter("paymentId"));
                    String cancelType = request.getParameter("cancelType"); // FULL, PARTIAL
                    int cancelAmt = Integer.parseInt(request.getParameter("cancelAmount"));
                    boolean isAdmin = "ADMIN".equals(loginUser.getMemberStatus());
                    
                    BookingService.getInstance().cancelPayment(paymentId, cancelType, cancelAmt, loginUser.getMemberId(), isAdmin);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/booking/payPenaltyAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null) {
                    int penaltyId = Integer.parseInt(request.getParameter("penaltyId"));
                    BookingService.getInstance().payPenalty(penaltyId);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/booking/adminAddPenaltyAction.do")) {
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
                    
                    BookingService.getInstance().addPenalty(dto);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/booking/userAccidentReportAction.do")) {
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

                    jakarta.servlet.http.Part filePart = request.getPart("photo");
                    String deployDir = request.getServletContext().getRealPath("/resources/images/accidents");
                    String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\images\\accidents";

                    AccidentReportDto dto = new AccidentReportDto();
                    dto.setReservationId(reservationId);
                    dto.setUserId(loginUser.getMemberId());
                    dto.setAccidentDate(accidentDate);
                    dto.setAccidentLocation(accidentLocation);
                    dto.setAccidentDescription(accidentDescription);
                    
                    BookingService.getInstance().reportAccident(dto, filePart, deployDir, srcDir);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/booking/adminAccidentReportUpdateAction.do")) {
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
                    
                    BookingService.getInstance().updateAccidentReport(reportId, status, claimNum, faultRatio);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/booking/adminFuelLogAddAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int reservationId = Integer.parseInt(request.getParameter("reservationId"));
                    int fuelLevel = Integer.parseInt(request.getParameter("fuelLevel"));
                    
                    BookingService.getInstance().addFuelLog(reservationId, fuelLevel);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
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
