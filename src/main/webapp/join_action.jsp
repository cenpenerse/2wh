<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 약관 동의 처리
    session.setAttribute("isAgreed", true);

    // 회원 유형(member/sitter)을 세션에 저장
    String userType = request.getParameter("type");
    if (userType != null) {
        session.setAttribute("userType", userType);
    }

    // 회원가입 폼으로 리다이렉트
    response.sendRedirect("join_form.jsp");
%>