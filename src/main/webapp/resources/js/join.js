/* ==========================================================================
   BAREN - 회원가입 페이지 (join.jsp) 전용 자바스크립트
   ========================================================================== */

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

// 약관 모달 열기
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

// 약관 모달 닫기
function closeTermsModal() {
    document.getElementById('terms-modal').style.display = 'none';
}

// 전체 약관 동의 체크박스 토글
function toggleAllAgreements(masterCheck) {
    const agrees = document.querySelectorAll('.required-agree');
    agrees.forEach(chk => {
        chk.checked = masterCheck.checked;
    });
}

// 폼 유효성 검사
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
