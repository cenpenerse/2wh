package com.bikerental.controller;

import java.io.File;
import java.io.IOException;
import java.sql.Date;
import java.util.Map;

import com.bikerental.dto.BlacklistDto;
import com.bikerental.dto.LicenseAuditDto;
import com.bikerental.dto.MemberDto;
import com.bikerental.service.MemberService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/member/*")
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 10,     // 10MB
    maxRequestSize = 1024 * 1024 * 20,   // 20MB
    fileSizeThreshold = 0
)
public class MemberController extends HttpServlet {
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
        
        System.out.println("[MemberController] Requested Command: " + command);

        String viewPage = null;
        boolean isRedirect = false;

        try {
            if (command.equals("/member/login.do")) {
                viewPage = "/WEB-INF/views/login.jsp";
                
            } else if (command.equals("/member/loginAction.do")) {
                String email = request.getParameter("email");
                String password = request.getParameter("password_hash");
                
                MemberDto member = MemberService.getInstance().login(email, password);
                if (member != null) {
                    if (MemberService.getInstance().isUserBanned(member.getMemberId())) {
                        String banReason = MemberService.getInstance().getBanReason(member.getMemberId());
                        request.setAttribute("errorMessage", "해당 계정은 서비스 이용이 차단되었습니다. (사유: " + banReason + ")");
                        viewPage = "/WEB-INF/views/login.jsp";
                    } else {
                        HttpSession session = request.getSession();
                        session.setAttribute("loginUser", member);
                        isRedirect = true;
                        viewPage = contextPath + "/index.do";
                    }
                } else {
                    request.setAttribute("errorMessage", "이메일 또는 비밀번호가 올바르지 않습니다.");
                    viewPage = "/WEB-INF/views/login.jsp";
                }
                
            } else if (command.equals("/member/join.do")) {
                viewPage = "/WEB-INF/views/join.jsp";
                
            } else if (command.equals("/member/joinAction.do")) {
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
                        dto.setBirthDate(Date.valueOf(birthDateStr));
                    } catch (IllegalArgumentException e) {
                        e.printStackTrace();
                    }
                }
                dto.setLicenseNumber(licenseNumber);
                
                int r = MemberService.getInstance().join(dto);
                if (r > 0) {
                    isRedirect = true;
                    viewPage = contextPath + "/member/login.do";
                } else {
                    request.setAttribute("errorMessage", "회원 가입에 실패했습니다. 다시 시도해 주세요.");
                    viewPage = "/WEB-INF/views/join.jsp";
                }
                
            } else if (command.equals("/member/logout.do")) {
                HttpSession session = request.getSession(false);
                if (session != null) {
                    session.invalidate();
                }
                isRedirect = true;
                viewPage = contextPath + "/index.do";
                
            } else if (command.equals("/member/mypage.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = contextPath + "/member/login.do";
                } else {
                    loginUser = MemberService.getInstance().getMemberInfo(loginUser.getMemberId());
                    session.setAttribute("loginUser", loginUser);
                    
                    Map<String, Object> mypageData = MemberService.getInstance().getMypageData(loginUser);
                    for (String key : mypageData.keySet()) {
                        request.setAttribute(key, mypageData.get(key));
                    }
                    viewPage = "/WEB-INF/views/member/mypage.jsp";
                }
                
            } else if (command.equals("/member/memberUpdateAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = contextPath + "/member/login.do";
                } else {
                    String nickname = request.getParameter("nickname");
                    String password = request.getParameter("password_hash");
                    
                    MemberDto updateDto = new MemberDto();
                    updateDto.setMemberId(loginUser.getMemberId());
                    updateDto.setNickname(nickname);
                    updateDto.setPasswordHash(password);
                    
                    int r = MemberService.getInstance().updateMember(updateDto);
                    if (r > 0) {
                        loginUser.setNickname(nickname);
                        loginUser.setPasswordHash(password);
                        session.setAttribute("loginUser", loginUser);
                    } else {
                        request.setAttribute("errorMessage", "정보 수정에 실패했습니다.");
                    }
                    isRedirect = true;
                    viewPage = contextPath + "/member/mypage.do";
                }
                
            } else if (command.equals("/member/memberDeleteAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = contextPath + "/member/login.do";
                } else {
                    int r = MemberService.getInstance().deleteMember(loginUser.getMemberId());
                    if (r > 0) {
                        session.invalidate();
                        isRedirect = true;
                        viewPage = contextPath + "/index.do";
                    } else {
                        isRedirect = true;
                        viewPage = contextPath + "/member/mypage.do";
                    }
                }
                
            } else if (command.equals("/member/adminLicenseAction.do")) {
                // 이전 레거시: MemberDao.updateLicenseStatus 호출
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int memberId = Integer.parseInt(request.getParameter("memberId"));
                    String status = request.getParameter("status");
                    MemberService.getInstance().updateLicenseStatus(memberId, status);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/member/userLicenseSubmitAction.do")) {
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
                            
                            String deployDir = request.getServletContext().getRealPath("/resources/images/licenses");
                            String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\images\\licenses";
                            
                            LicenseAuditDto auditDto = new LicenseAuditDto();
                            auditDto.setUserId(loginUser.getMemberId());
                            auditDto.setLicenseType(licenseType);
                            auditDto.setLicenseImage("resources/images/licenses/" + imageFilename);
                            
                            // 파일 쓰기 및 DB 저장은 서비스에서 수행
                            MemberService.getInstance().submitLicense(auditDto, licenseNumber);
                            
                            // 실제 파일 디렉토리 처리
                            File uploadDir = new File(deployDir);
                            if (!uploadDir.exists()) {
                                uploadDir.mkdirs();
                            }
                            String deployFilePath = deployDir + File.separator + imageFilename;
                            filePart.write(deployFilePath);
                            
                            File srcUploadDir = new File(srcDir);
                            if (srcUploadDir.exists()) {
                                try {
                                    java.nio.file.Files.copy(
                                        java.nio.file.Paths.get(deployFilePath),
                                        java.nio.file.Paths.get(srcDir + File.separator + imageFilename),
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
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/member/adminLicenseAuditAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int auditId = Integer.parseInt(request.getParameter("auditId"));
                    String status = request.getParameter("status");
                    String rejectReason = request.getParameter("rejectReason");
                    
                    MemberService.getInstance().auditLicense(auditId, status, rejectReason, loginUser.getMemberId());
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/member/adminBlacklistAddAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int targetUserId = Integer.parseInt(request.getParameter("userId"));
                    String banType = request.getParameter("banType");
                    String reason = request.getParameter("reason");
                    String endDateStr = request.getParameter("endDate");
                    
                    Date endDate = null;
                    if (endDateStr != null && !endDateStr.trim().isEmpty() && "기간차단".equals(banType)) {
                        try {
                            endDate = Date.valueOf(endDateStr);
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
                    
                    MemberService.getInstance().addBlacklist(dto);
                    
                    try {
                        com.bikerental.dao.NotificationDao.send(targetUserId, "SMS", "🚫 회원님의 계정이 정책 위반으로 인해 서비스 이용 차단(" + banType + ") 조치되었습니다. (사유: " + reason + ")");
                    } catch(Exception ex) {
                        ex.printStackTrace();
                    }
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/member/adminBlacklistReleaseAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int blacklistId = Integer.parseInt(request.getParameter("blacklistId"));
                    int targetUserId = Integer.parseInt(request.getParameter("userId"));
                    
                    MemberService.getInstance().releaseBlacklist(blacklistId);
                    
                    try {
                        com.bikerental.dao.NotificationDao.send(targetUserId, "SMS", "🔓 회원님의 계정 차단 조치가 해제되었습니다. 정상적으로 서비스 이용이 가능합니다.");
                    } catch(Exception ex) {
                        ex.printStackTrace();
                    }
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/member/adminCouponIssue.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    String targetUser = request.getParameter("targetUser");
                    String couponName = request.getParameter("couponName");
                    int discountAmount = Integer.parseInt(request.getParameter("discountAmount"));
                    String expireDateStr = request.getParameter("expireDate");
                    
                    Date expireDate = Date.valueOf(expireDateStr);
                    MemberService.getInstance().issueCoupon(targetUser, couponName, discountAmount, expireDate);
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
