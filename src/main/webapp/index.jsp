<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 사용자가 웹 루트로 직접 접근 시, FrontController 서블릿 경로인 /index.do로 안전하게 리다이렉트합니다.
    response.sendRedirect(request.getContextPath() + "/index.do");
%>
