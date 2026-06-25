package com.bikerental.controller;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.bikerental.dto.MemberDto;
import com.bikerental.dto.BikeDto;
import com.bikerental.dto.BikeMaintenanceDto;
import com.bikerental.service.BikeService;

@WebServlet("/bike/*")
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 10,     // 10MB
    maxRequestSize = 1024 * 1024 * 20,   // 20MB
    fileSizeThreshold = 0
)
public class BikeController extends HttpServlet {
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
        
        System.out.println("[BikeController] Requested Command: " + command);

        String viewPage = null;
        boolean isRedirect = false;

        try {
            if (command.equals("/bike/bikeInfo.do")) {
                List<BikeDto> bikeList = BikeService.getInstance().getBikeList();
                request.setAttribute("bikeList", bikeList);
                viewPage = "/WEB-INF/views/bike/bike_info.jsp";
                
            } else if (command.equals("/bike/gearInfo.do")) {
                List<com.bikerental.dto.OptionItemDto> gearList = BikeService.getInstance().getGearList();
                request.setAttribute("gearList", gearList);
                viewPage = "/WEB-INF/views/bike/gear_info.jsp";
                
            } else if (command.equals("/bike/bikeList.do")) {
                List<Map<String, Object>> shopList = BikeService.getInstance().getShopListAll();
                request.setAttribute("shopList", shopList);
                viewPage = "/WEB-INF/views/bike/bike_list.jsp";
                
            } else if (command.equals("/bike/bikeSelect.do")) {
                String shopId = request.getParameter("shopId");
                if (shopId == null || shopId.trim().isEmpty()) {
                    isRedirect = true;
                    viewPage = contextPath + "/bike/bikeList.do";
                } else {
                    String brandId = request.getParameter("brandId");
                    String ccType = request.getParameter("ccType");
                    
                    Map<String, Object> selectData = BikeService.getInstance().getBikeSelectData(shopId, brandId, ccType);
                    for (String key : selectData.keySet()) {
                        request.setAttribute(key, selectData.get(key));
                    }
                    request.setAttribute("selectedShopId", shopId);
                    request.setAttribute("selectedBrandId", brandId);
                    request.setAttribute("selectedCcType", ccType);
                    
                    viewPage = "/WEB-INF/views/bike/bike_select.jsp";
                }
                
            } else if (command.equals("/bike/bikeDetail.do")) {
                int bikeId = Integer.parseInt(request.getParameter("bikeId"));
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                Integer memberId = (loginUser != null) ? loginUser.getMemberId() : null;
                
                Map<String, Object> detailData = BikeService.getInstance().getBikeDetailData(bikeId, memberId);
                for (String key : detailData.keySet()) {
                    request.setAttribute(key, detailData.get(key));
                }
                
                String selectedShopId = request.getParameter("shopId");
                request.setAttribute("selectedShopId", selectedShopId);
                
                viewPage = "/WEB-INF/views/bike/bike_detail.jsp";
                
            } else if (command.equals("/bike/adminBikeAddAction.do")) {
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
                    
                    BikeService.getInstance().addBike(dto, imageUrl);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/bike/adminBikeDeleteAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int bikeId = Integer.parseInt(request.getParameter("bikeId"));
                    BikeService.getInstance().deleteBike(bikeId);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/bike/adminOptionAddAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    String optionName = request.getParameter("optionName");
                    int stockQuantity = Integer.parseInt(request.getParameter("stockQuantity"));
                    int dailyPrice = Integer.parseInt(request.getParameter("dailyPrice"));
                    String status = request.getParameter("status");
                    
                    jakarta.servlet.http.Part filePart = request.getPart("gearImage");
                    String deployDir = request.getServletContext().getRealPath("/resources/images/gears");
                    String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\images\\gears";
                    
                    BikeService.getInstance().addOption(optionName, stockQuantity, dailyPrice, status, filePart, deployDir, srcDir);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do?tab=tab-admin-gears";
                
            } else if (command.equals("/bike/adminOptionUpdateAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int optionId = Integer.parseInt(request.getParameter("optionId"));
                    String optionName = request.getParameter("optionName");
                    int stockQuantity = Integer.parseInt(request.getParameter("stockQuantity"));
                    int dailyPrice = Integer.parseInt(request.getParameter("dailyPrice"));
                    String status = request.getParameter("status");
                    
                    jakarta.servlet.http.Part filePart = request.getPart("gearImage");
                    String deployDir = request.getServletContext().getRealPath("/resources/images/gears");
                    String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\images\\gears";
                    
                    BikeService.getInstance().updateOption(optionId, optionName, stockQuantity, dailyPrice, status, filePart, deployDir, srcDir);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do?tab=tab-admin-gears";
                
            } else if (command.equals("/bike/adminOptionDeleteAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int optionId = Integer.parseInt(request.getParameter("optionId"));
                    BikeService.getInstance().deleteOption(optionId);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do?tab=tab-admin-gears";
                
            } else if (command.equals("/bike/adminBrandAddAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    String brandName = request.getParameter("brandName");
                    String country = request.getParameter("country");
                    String description = request.getParameter("description");
                    BikeService.getInstance().addBrand(brandName, country, description);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/bike/adminBrandDeleteAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int brandId = Integer.parseInt(request.getParameter("brandId"));
                    BikeService.getInstance().deleteBrand(brandId);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/bike/adminShopAddAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    String shopName = request.getParameter("shopName");
                    String managerName = request.getParameter("managerName");
                    String tel = request.getParameter("tel");
                    String address = request.getParameter("address");
                    String openTime = request.getParameter("openTime");
                    String closeTime = request.getParameter("closeTime");
                    
                    jakarta.servlet.http.Part filePart = request.getPart("shopImage");
                    String deployDir = request.getServletContext().getRealPath("/resources/images/shops");
                    String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\images\\shops";
                    
                    BikeService.getInstance().addShop(shopName, managerName, tel, address, openTime, closeTime, filePart, deployDir, srcDir);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/bike/adminShopImageUploadAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int shopId = Integer.parseInt(request.getParameter("shopId"));
                    jakarta.servlet.http.Part filePart = request.getPart("shopImage");
                    String deployDir = request.getServletContext().getRealPath("/resources/images/shops");
                    String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\images\\shops";
                    
                    BikeService.getInstance().uploadShopImage(shopId, filePart, deployDir, srcDir);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/bike/adminShopImageDeleteAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int shopId = Integer.parseInt(request.getParameter("shopId"));
                    String deployDir = request.getServletContext().getRealPath("/resources/images/shops");
                    String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\images\\shops";
                    
                    BikeService.getInstance().deleteShopImage(shopId, deployDir, srcDir);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/bike/adminShopDeleteAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int shopId = Integer.parseInt(request.getParameter("shopId"));
                    String deployDir = request.getServletContext().getRealPath("/resources/images/shops");
                    String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\images\\shops";
                    
                    BikeService.getInstance().deleteShop(shopId, deployDir, srcDir);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/bike/adminMaintenanceAddAction.do")) {
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
                    
                    BikeService.getInstance().addMaintenance(dto);
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
