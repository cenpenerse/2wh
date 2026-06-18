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
                    HttpSession session = request.getSession();
                    session.setAttribute("loginUser", member);
                    isRedirect = true;
                    viewPage = "index.do";
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
                        
                        request.setAttribute("bookingList", bookingList);
                        request.setAttribute("memberList", memberList);
                        request.setAttribute("adminInquiryList", adminInquiryList);
                        request.setAttribute("adminBikeList", adminBikeList);
                        request.setAttribute("adminBrandList", adminBrandList);
                        request.setAttribute("adminShopList", adminShopList);
                        request.setAttribute("adminPenaltyList", adminPenaltyList);
                    } else {
                        // 일반 회원이면 본인 예약 목록 조회
                        List<BookingDto> bookingList = BookingDao.getInstance().getBookingListByUser(loginUser.getMemberId());
                        List<CouponDto> couponList = CouponDao.getInstance().getCouponsByUser(loginUser.getMemberId());
                        List<InquiryDto> inquiryList = InquiryDao.getInstance().getInquiriesByUser(loginUser.getMemberId());
                        List<PenaltyDto> penaltyList = PenaltyDao.getInstance().getPenaltiesByUser(loginUser.getMemberId());
                        request.setAttribute("bookingList", bookingList);
                        request.setAttribute("couponList", couponList);
                        request.setAttribute("inquiryList", inquiryList);
                        request.setAttribute("penaltyList", penaltyList);
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
                    
                    HttpSession session = request.getSession(false);
                    MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                    if (loginUser != null) {
                        List<CouponDto> couponList = CouponDao.getInstance().getCouponsByUser(loginUser.getMemberId());
                        request.setAttribute("couponList", couponList);
                    }
                    
                    List<OptionItemDto> optionList = OptionItemDao.getInstance().getOptionList();
                    request.setAttribute("optionList", optionList);
                    
                    viewPage = "/WEB-INF/views/bike/bike_detail.jsp";
                } else {
                    isRedirect = true;
                    viewPage = "bikeList.do";
                }
                
            } else if (command.equals("/bookingAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = "login.do";
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
                        
                        request.setAttribute("bike", bike);
                        request.setAttribute("reviewList", reviewList);
                        request.setAttribute("shopList", shopList);
                        request.setAttribute("couponList", couponList);
                        request.setAttribute("optionList", optionList);
                        
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
                
            } else if (command.equals("/bookingCancelAction.do")) {
                // 예약 취소 (일반 회원 기능)
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser != null) {
                    int bookingId = Integer.parseInt(request.getParameter("bookingId"));
                    BookingDto booking = BookingDao.getInstance().getBooking(bookingId);
                    
                    if (booking != null && (booking.getMemberId() == loginUser.getMemberId() || "ADMIN".equals(loginUser.getMemberStatus()))) {
                        BookingDao.getInstance().updateBookingStatus(bookingId, "CANCELLED");
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
                    
                    BoardDto dto = new BoardDto();
                    dto.setMemberId(loginUser.getMemberId());
                    dto.setTitle(title);
                    dto.setContent(content);
                    dto.setBoardType(boardType);
                    
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
                
                BoardDto dto = new BoardDto();
                dto.setPostId(postId);
                dto.setTitle(title);
                dto.setContent(content);
                
                BoardDao.getInstance().updatePost(dto);
                
                isRedirect = true;
                viewPage = "boardDetail.do?postId=" + postId;
                
            } else if (command.equals("/boardDeleteAction.do")) {
                int postId = Integer.parseInt(request.getParameter("postId"));
                String boardType = request.getParameter("boardType");
                
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
                    BikeDao.getInstance().insertShop(shopName, managerName, tel, address, openTime, closeTime);
                }
                isRedirect = true;
                viewPage = "mypage.do";
                
            } else if (command.equals("/adminShopDeleteAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int shopId = Integer.parseInt(request.getParameter("shopId"));
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
