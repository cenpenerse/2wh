<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/auth.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/join.css">

<div class="auth-container">
    <div class="auth-card signup-card">
        <h2>회원가입</h2>
        <p class="auth-subtitle">Baren의 회원이 되어 자유로운 라이딩 라이프를 경험하세요.</p>
        
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger">${errorMessage}</div>
        </c:if>

        <form id="signup-form" action="${pageContext.request.contextPath}/joinAction.do" method="post" class="auth-form" onsubmit="return validateForm()">
            <!-- 회원정보 입력 -->
            <div class="form-group">
                <label for="email">이메일 주소</label>
                <input type="email" id="email" name="email" placeholder="example@email.com" required>
            </div>
            
            <div class="form-group">
                <label for="password">비밀번호</label>
                <input type="password" id="password" name="password_hash" placeholder="비밀번호 (8자 이상)" required minlength="8">
            </div>

            <div class="form-group">
                <label for="password-confirm">비밀번호 확인</label>
                <input type="password" id="password-confirm" placeholder="비밀번호를 다시 입력해 주세요" required>
                <span id="pwd-match-error">비밀번호가 일치하지 않습니다.</span>
            </div>

            <div class="form-group">
                <label for="nickname">닉네임</label>
                <input type="text" id="nickname" name="nickname" placeholder="닉네임을 입력하세요" required>
            </div>

            <div class="form-group">
                <label for="phone">연락처</label>
                <input type="text" id="phone" name="phone" placeholder="010-0000-0000" required>
            </div>

            <div class="form-group">
                <label for="birth_date">생년월일</label>
                <input type="date" id="birth_date" name="birth_date" required>
            </div>

            <div class="form-group">
                <label for="license_number">운전면허증 번호</label>
                <input type="text" id="license_number" name="license_number" placeholder="예: 11-12-345678-01" required>
            </div>

            <!-- 약관 동의 -->
            <div class="agreement-box">
                <div class="agreement-all">
                    <label for="agree-all">
                        <input type="checkbox" id="agree-all" onchange="toggleAllAgreements(this)"> 
                        <strong>전체 약관에 동의합니다.</strong>
                    </label>
                </div>
                <hr class="divider">
                <div class="agreement-item">
                    <label for="agree-terms">
                        <input type="checkbox" id="agree-terms" class="required-agree" required> 
                        Baren 이용약관 동의 (필수)
                    </label>
                    <a href="javascript:void(0);" onclick="openTermsModal('terms')">보기</a>
                </div>
                <div class="agreement-item">
                    <label for="agree-privacy">
                        <input type="checkbox" id="agree-privacy" class="required-agree" required> 
                        개인정보 수집 및 이용 동의 (필수)
                    </label>
                    <a href="javascript:void(0);" onclick="openTermsModal('privacy')">보기</a>
                </div>
            </div>

            <button type="submit" class="btn btn-auth">가입하기</button>
        </form>
        
        <div class="auth-footer">
            <span>이미 Baren 계정이 있으신가요?</span>
            <a href="${pageContext.request.contextPath}/login.do">로그인하기</a>
        </div>
    </div>
</div>

<!-- 약관 모달 -->
<div id="terms-modal" class="modal-overlay">
    <div class="modal-content">
        <span class="close-btn" onclick="closeTermsModal()">&times;</span>
        <h2 id="terms-title">이용약관</h2>
        <div id="terms-body" class="terms-content-box"></div>
        <div class="terms-btn-wrapper">
            <button type="button" class="btn terms-confirm-btn" onclick="closeTermsModal()">확인</button>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
<script src="${pageContext.request.contextPath}/resources/js/join.js"></script>

