<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/auth.css">

<div class="auth-container">
    <div class="auth-card">
        <h2>로그인</h2>
        <p class="auth-subtitle">Baren의 다양한 프리미엄 서비스를 이용해 보세요.</p>
        
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger">${errorMessage}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/loginAction.do" method="post" class="auth-form">
            <div class="form-group">
                <label for="email">이메일 주소</label>
                <input type="email" id="email" name="email" placeholder="이메일을 입력하세요" required>
            </div>
            <div class="form-group">
                <label for="password">비밀번호</label>
                <input type="password" id="password" name="password_hash" placeholder="비밀번호를 입력하세요" required>
            </div>
            <button type="submit" class="btn btn-auth">로그인</button>
        </form>
        
        <div class="auth-footer">
            <span>아직 Baren 계정이 없으신가요?</span>
            <a href="${pageContext.request.contextPath}/join.do">회원가입하기</a>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />