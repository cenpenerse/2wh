// Baren Premium Bike Rental Common Scripts

// ==========================
// 모달 열기 및 닫기 유틸리티
// ==========================
function toggleModal(modalId, show) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.style.display = show ? "flex" : "none";
    }
}

function openLoginModal() {
    toggleModal("login-modal", true);
}

function closeLoginModal() {
    toggleModal("login-modal", false);
}

document.addEventListener("DOMContentLoaded", () => {

    // ==========================
    // 모달 닫기 이벤트 리스너 바인딩
    // ==========================
    function setupModalCloseListeners(modalId, closeFunction) {
        const modal = document.getElementById(modalId);
        if (!modal) return;

        // X 버튼 클릭 시 닫기
        const closeBtn = modal.querySelector(".close-btn");
        if (closeBtn) {
            closeBtn.addEventListener("click", closeFunction);
        }

        // 모달 배경 영역 클릭 시 닫기
        modal.addEventListener("click", (e) => {
            if (e.target === modal) {
                closeFunction();
            }
        });
    }

    setupModalCloseListeners("login-modal", closeLoginModal);
    
    // booking-modal의 닫기 콜백 바인딩 (존재할 경우)
    if (document.getElementById("booking-modal")) {
        setupModalCloseListeners("booking-modal", () => {
            document.getElementById("booking-modal").style.display = "none";
        });
    }
    
    // update-modal의 닫기 콜백 바인딩 (존재할 경우)
    if (document.getElementById("update-modal")) {
        setupModalCloseListeners("update-modal", () => {
            document.getElementById("update-modal").style.display = "none";
        });
    }

    // ==========================
    // 고객 문의 폼 처리 (서버 전송으로 이관됨)
    // ==========================

    // ==========================
    // FAQ 아코디언 동작
    // ==========================
    const faqItems = document.querySelectorAll(".faq-item");

    faqItems.forEach(item => {
        const question = item.querySelector(".faq-question");
        const answer = item.querySelector(".faq-answer");

        if (!question || !answer) return;

        question.addEventListener("click", () => {
            const isActive = question.classList.contains("active");

            // 다른 FAQ들 닫기
            faqItems.forEach(otherItem => {
                const q = otherItem.querySelector(".faq-question");
                const a = otherItem.querySelector(".faq-answer");
                if (q) q.classList.remove("active");
                if (a) a.style.display = "none";
            });

            // 클릭된 FAQ 상태 토글
            if (!isActive) {
                question.classList.add("active");
                answer.style.display = "block";
            }
        });
    });

});