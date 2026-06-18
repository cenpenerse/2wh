<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

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
                <span id="pwd-match-error" style="color: #ff3838; font-size: 0.8rem; display: none; margin-top: 5px;">비밀번호가 일치하지 않습니다.</span>
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
<div id="terms-modal" class="modal-overlay" style="display:none;">
    <div class="modal-content" style="max-width: 600px;">
        <span class="close-btn" onclick="closeTermsModal()">&times;</span>
        <h2 id="terms-title" style="margin-bottom: 20px;">이용약관</h2>
        <div id="terms-body" class="terms-content-box" style="max-height: 300px; overflow-y: auto; text-align: left; background: #222; color: #ddd; padding: 15px; border-radius: 6px; white-space: pre-wrap; font-size: 0.9rem;"></div>
        <div style="text-align: center; margin-top: 20px;">
            <button type="button" class="btn" onclick="closeTermsModal()" style="width: 100px;">확인</button>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script>
    // 약관 모달 데이터
    const termsData = {
        terms: `제1조 (목적)
본 약관은 Baren 바이크 렌탈 서비스(이하 '회사')가 제공하는 바이크 대여 플랫폼 및 관련 제반 서비스의 이용조건과 절차, 회사와 회원 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (회원가입 및 자격)
1. 회원이 되고자 하는 자는 본 약관에 동의하고 가입 양식을 기재하여 가입을 완료합니다.
2. 타인의 정보를 도용하여 가입하거나 만 14세 미만의 가입은 임의 취소될 수 있습니다.

제3조 (서비스 이용 및 대여)
1. 회원은 예약 시간 및 장소를 지켜야 하며 반납 시간을 초과할 경우 추가 요금이 발생할 수 있습니다.
2. 대여 바이크의 훼손 및 라이더의 과실로 인한 고장은 회원 본인에게 책임이 있습니다.`,

        privacy: `1. 수집하는 개인정보 항목
- 필수: 이메일, 패스워드, 닉네임, 가입 일시
- 선택: 마이페이지 프로필 사진, 예약 히스토리

2. 수집 및 이용 목적
- 회원 식별 및 가입 관리
- 바이크 대여 예약 정보 저장 및 예약 승인 통보
- 고객 서비스 문의 응대

3. 보유 및 이용 기간
- 회원 탈퇴 시 수집된 정보는 즉시 파기됩니다.
- 단, 상법 등 법령의 규정에 따라 일정 기간 보존이 필요할 경우 예외로 합니다.`
    };

    function openTermsModal(type) {
        const modal = document.getElementById('terms-modal');
        const title = document.getElementById('terms-title');
        const body = document.getElementById('terms-body');
        
        if (type === 'terms') {
            title.innerText = "Baren 이용약관 동의 (필수)";
            body.innerText = termsData.terms;
        } else if (type === 'privacy') {
            title.innerText = "개인정보 수집 및 이용 동의 (필수)";
            body.innerText = termsData.privacy;
        }
        modal.style.display = 'flex';
    }

    function closeTermsModal() {
        document.getElementById('terms-modal').style.display = 'none';
    }

    function toggleAllAgreements(masterCheck) {
        const agrees = document.querySelectorAll('.required-agree');
        agrees.forEach(chk => {
            chk.checked = masterCheck.checked;
        });
    }

    function validateForm() {
        const pwd = document.getElementById('password').value;
        const pwdConfirm = document.getElementById('password-confirm').value;
        const matchError = document.getElementById('pwd-match-error');

        if (pwd !== pwdConfirm) {
            matchError.style.display = 'block';
            document.getElementById('password-confirm').focus();
            return false;
        } else {
            matchError.style.display = 'none';
        }

        const agreeTerms = document.getElementById('agree-terms').checked;
        const agreePrivacy = document.getElementById('agree-privacy').checked;
        if (!agreeTerms || !agreePrivacy) {
            alert("필수 약관에 모두 동의해 주셔야 가입이 가능합니다.");
            return false;
        }
        return true;
    }
</script>

