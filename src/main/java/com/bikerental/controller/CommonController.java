package com.bikerental.controller;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.bikerental.dto.BikeDto;
import com.bikerental.service.BikeService;

@WebServlet(urlPatterns = {"/index.do", "/guide.do", "/pricing.do", "/support.do", "/notice.do", "/setupData.do"})
public class CommonController extends HttpServlet {
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
        
        System.out.println("[CommonController] Requested Command: " + command);

        String viewPage = null;
        boolean isRedirect = false;

        try {
            if (command.equals("/index.do") || command.equals("/")) {
                // 대표 바이크 3개 메인 화면 로딩
                List<BikeDto> bikeList = BikeService.getInstance().getBikeList();
                List<Map<String, Object>> shopList = BikeService.getInstance().getShopListAll();
                
                request.setAttribute("bikeList", bikeList);
                request.setAttribute("shopList", shopList);
                viewPage = "/WEB-INF/views/index.jsp";
                
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
