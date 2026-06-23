/* ==========================================================================
   BAREN - 마이페이지 (mypage.jsp) 전용 자바스크립트
   ========================================================================== */

// 탭 동작
function openTab(evt, tabId) {
    let i, tabcontent, tablinks;
    tabcontent = document.getElementsByClassName("tab-content");
    for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].classList.remove("active");
    }
    tablinks = document.getElementsByClassName("tab-btn");
    for (i = 0; i < tablinks.length; i++) {
        tablinks[i].classList.remove("active");
    }
    document.getElementById(tabId).classList.add("active");
    evt.currentTarget.classList.add("active");
}

// 1:1 문의 아코디언 토글
function toggleAccordion(headerElement) {
    const content = headerElement.nextElementSibling;
    if (content.style.display === "block") {
        content.style.display = "none";
    } else {
        content.style.display = "block";
    }
}

// 새 1:1 문의 작성 상자 토글
function toggleInquiryForm() {
    const box = document.getElementById("inquiry-form-box");
    if (box.style.display === "none") {
        box.style.display = "block";
    } else {
        box.style.display = "none";
    }
}

// 리뷰 작성 모달 열기/닫기
function openReviewModal(bookingId, bikeId, bikeName) {
    document.getElementById("review-booking-id").value = bookingId;
    document.getElementById("review-reservation-id").value = bookingId; // reservationId는 bookingId와 매핑
    document.getElementById("review-bike-id").value = bikeId;
    document.getElementById("review-bike-model-name").innerText = "모델명: " + bikeName;
    document.getElementById("review-modal").style.display = "flex";
}

function closeReviewModal() {
    document.getElementById("review-modal").style.display = "none";
}

// 탈퇴 확인
function confirmWithdrawal() {
    if (confirm("정말로 탈퇴하시겠습니까?\n탈퇴 시 대여 내역을 포함한 모든 계정 정보가 즉시 삭제됩니다.")) {
        // JSP EL 식 ${pageContext.request.contextPath} 대신 전역 변수 contextPath를 사용합니다.
        location.href = contextPath + "/memberDeleteAction.do";
    }
}

// 어드민 패널티 부과 시 대상자 정보 실시간 바인딩
function updatePenaltyUser() {
    let sel = document.getElementById('penalty-res-selector');
    if (!sel) return;
    let opt = sel.options[sel.selectedIndex];
    if (opt && opt.value !== "") {
        let userId = opt.getAttribute('data-userid');
        let userName = opt.getAttribute('data-username');
        document.getElementById('penalty-user-id').value = userId;
        document.getElementById('penalty-user-name').value = userName;
    } else {
        document.getElementById('penalty-user-id').value = "";
        document.getElementById('penalty-user-name').value = "";
    }
}

// 정보 수정 비밀번호 일치 검사
function validateUpdateForm() {
    const pwd = document.getElementById('update-password').value;
    const pwdConfirm = document.getElementById('update-password-confirm').value;
    const err = document.getElementById('update-pwd-error');

    if (pwd !== pwdConfirm) {
        err.style.display = 'block';
        document.getElementById('update-password-confirm').focus();
        return false;
    } else {
        err.style.display = 'none';
    }
    return true;
}

// 면허 심사 승인
function approveLicense(auditId) {
    if (confirm("해당 면허 검증 신청을 승인하시겠습니까?\n승인 시 사용자의 면허 상태가 '승인 완료'로 즉시 변경됩니다.")) {
        // JSP EL 식 대신 전역 변수 contextPath를 사용합니다.
        location.href = contextPath + "/adminLicenseAuditAction.do?auditId=" + auditId + "&status=APPROVED";
    }
}

// 면허 심사 반려
function rejectLicense(auditId) {
    let reason = prompt("반려 사유를 입력해 주세요:", "첨부된 면허증 사진이 흐릿하여 식별할 수 없습니다.");
    if (reason === null) return; // 취소 버튼
    if (reason.trim() === "") {
        alert("반려 사유는 필수 입력 사항입니다.");
        return;
    }
    // JSP EL 식 대신 전역 변수 contextPath를 사용합니다.
    location.href = contextPath + "/adminLicenseAuditAction.do?auditId=" + auditId + "&status=REJECTED&rejectReason=" + encodeURIComponent(reason);
}

// 반납 주유 패널티 실시간 계산
function calculateFuelPenalty() {
    let levelInput = document.getElementById("fuel-level-input");
    let calcBox = document.getElementById("fuel-penalty-calc-box");
    let display = document.getElementById("fuel-penalty-display");
    
    if (!levelInput || !calcBox || !display) return;
    
    let val = levelInput.value;
    if (val === "" || isNaN(val)) {
        calcBox.style.display = "none";
        return;
    }
    
    let fuelLevel = parseInt(val);
    if (fuelLevel < 0 || fuelLevel > 100) {
        calcBox.style.display = "none";
        return;
    }
    
    if (fuelLevel < 100) {
        let penalty = (100 - fuelLevel) * 1000;
        display.innerText = "₩" + penalty.toLocaleString();
        calcBox.style.display = "block";
    } else {
        display.innerText = "₩0 (패널티 없음)";
        calcBox.style.display = "block";
    }
}

// 결제 취소 환불 모달 함수
let maxRefundable = 0;
function openRefundModal(paymentId, origAmount, prevRefund) {
    document.getElementById("refund-payment-id").value = paymentId;
    document.getElementById("refund-amount-orig-display").value = "₩" + origAmount.toLocaleString();
    document.getElementById("refund-amount-prev-display").value = "₩" + prevRefund.toLocaleString();
    
    maxRefundable = origAmount - prevRefund;
    document.getElementById("refund-cancel-amount").value = maxRefundable;
    document.getElementById("refund-limit-text").innerText = "* 환불 가능 한도: ₩" + maxRefundable.toLocaleString();
    
    document.getElementById("refund-cancel-type").value = "FULL";
    document.getElementById("refund-cancel-amount").readOnly = true;
    
    document.getElementById("refund-modal").style.display = "flex";
}

function adjustRefundLimit() {
    const type = document.getElementById("refund-cancel-type").value;
    const amtInput = document.getElementById("refund-cancel-amount");
    if (type === "FULL") {
        amtInput.value = maxRefundable;
        amtInput.readOnly = true;
    } else {
        amtInput.readOnly = false;
        amtInput.value = "";
        amtInput.focus();
    }
}

function closeRefundModal() {
    document.getElementById("refund-modal").style.display = "none";
}

function validateRefundForm() {
    const amt = parseInt(document.getElementById("refund-cancel-amount").value);
    if (isNaN(amt) || amt <= 0) {
        alert("환불 취소 금액은 0보다 큰 숫자로 입력해야 합니다.");
        return false;
    }
    if (amt > maxRefundable) {
        alert("취소 환불 요청 금액(₩" + amt.toLocaleString() + ")이 남은 환불 한도(₩" + maxRefundable.toLocaleString() + ")를 초과했습니다.");
        return false;
    }
    return confirm("정말로 취소/환불 처리를 완료하시겠습니까?");
}

// 사용자 사고 접수 모달 열기/닫기
function openAccidentReportModal() {
    document.getElementById("user-accident-modal").style.display = "flex";
}
function closeAccidentReportModal() {
    document.getElementById("user-accident-modal").style.display = "none";
}

// 관리자 사고 처리 모달 열기/닫기
function openAccidentModal(reportId, status, claimNum, faultRatio) {
    document.getElementById("admin-accident-report-id").value = reportId;
    document.getElementById("admin-accident-status").value = status;
    document.getElementById("admin-accident-claim-num").value = (claimNum === 'null' || claimNum === 'undefined') ? '' : claimNum;
    document.getElementById("admin-accident-fault-ratio").value = faultRatio || 0;
    document.getElementById("admin-accident-info-text").innerText = "사고 건 #" + reportId + "번의 처리 정보 및 보험 심사 결과를 입력합니다.";
    document.getElementById("admin-accident-modal").style.display = "flex";
}
function closeAccidentModal() {
    document.getElementById("admin-accident-modal").style.display = "none";
}

// 블랙리스트 차단 기간 설정에 따른 만료일 표시 여부 토글
function toggleBanDate() {
    let type = document.getElementById("ban-type-selector").value;
    let dateGroup = document.getElementById("ban-date-group");
    if (type === "기간차단") {
        dateGroup.style.display = "block";
        dateGroup.querySelector('input[type="date"]').required = true;
    } else {
        dateGroup.style.display = "none";
        dateGroup.querySelector('input[type="date"]').required = false;
        dateGroup.querySelector('input[type="date"]').value = "";
    }
}

// 대여장비 수정 모달 열기/닫기
function openEditGearModal(optionId, optionName, stockQuantity, dailyPrice, status) {
    document.getElementById("edit-gear-id").value = optionId;
    document.getElementById("edit-gear-name").value = optionName;
    document.getElementById("edit-gear-stock").value = stockQuantity;
    document.getElementById("edit-gear-price").value = dailyPrice;
    document.getElementById("edit-gear-status").value = status;
    document.getElementById("admin-edit-gear-modal").style.display = "flex";
}

function closeEditGearModal() {
    document.getElementById("admin-edit-gear-modal").style.display = "none";
}

// 페이지 로드 시 URL 파라미터에 지정된 탭이 있으면 활성화
window.addEventListener('DOMContentLoaded', (event) => {
    const urlParams = new URLSearchParams(window.location.search);
    const activeTab = urlParams.get('tab');
    if (activeTab) {
        // 모든 탭 비활성화
        let i, tabcontent, tablinks;
        tabcontent = document.getElementsByClassName("tab-content");
        for (i = 0; i < tabcontent.length; i++) {
            tabcontent[i].classList.remove("active");
        }
        tablinks = document.getElementsByClassName("tab-btn");
        for (i = 0; i < tablinks.length; i++) {
            tablinks[i].classList.remove("active");
        }
        
        // 지정된 탭 활성화
        const targetContent = document.getElementById(activeTab);
        if (targetContent) {
            targetContent.classList.add("active");
        }
        
        // 지정된 탭 버튼 활성화
        const targetButton = Array.from(tablinks).find(btn => {
            const onclickAttr = btn.getAttribute('onclick');
            return onclickAttr && onclickAttr.includes("'" + activeTab + "'");
        });
        if (targetButton) {
            targetButton.classList.add("active");
        }
    }
});
