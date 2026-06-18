<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bikerental.dao.MemberDao, com.bikerental.dto.MemberDto" %>

<%-- 1. 인코딩 설정 --%>
<% request.setCharacterEncoding("UTF-8"); %>

<%-- 2. useBean으로 폼 데이터를 받을 member 객체 생성 --%>
<jsp:useBean id="loginInfo" class="com.bikerental.dto.MemberDto" />

<%-- 3. 폼 파라미터(id, pass)를 member 객체의 속성(email, password_hash)에 매핑 --%>
<jsp:setProperty name="loginInfo" property="email" param="id" />
<jsp:setProperty name="loginInfo" property="passwordHash" param="pass" />

<%
    // 4. 입력값 유효성 검사
    String email = loginInfo.getEmail();
    String password = loginInfo.getPasswordHash();

    if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
        out.println("<script>alert('아이디와 비밀번호를 모두 입력해주세요.'); history.back();</script>");
        return;
    }

    // 5. DAO를 통해 회원 정보 확인
    MemberDao dao = MemberDao.getInstance();
    MemberDto loginMember = dao.getMemberByEmailAndPassword(email.trim(), password.trim());

    // 6. 로그인 결과 처리
    if (loginMember != null) {
        // 로그인 성공: 세션에 정보 저장
        session.setAttribute("loginUser", loginMember);
        response.sendRedirect("index.jsp");
    } else {
        // 로그인 실패: 에러 메시지 출력
        out.println("<script>alert('아이디 또는 비밀번호가 일치하지 않습니다.'); history.back();</script>");
    }
%>