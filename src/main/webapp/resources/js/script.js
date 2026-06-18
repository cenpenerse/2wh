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
    // 메인화면 백그라운드 히어로 슬라이더
    // ==========================
    const hero = document.querySelector(".hero");

    if (hero) {
        // 프리미엄 바이크 및 도로 주행 웅장한 이미지 리스트
        const images = [
            "https://images.unsplash.com/photo-1517649763962-0c623066013b?q=80&w=2070&auto=format&fit=crop", /* 로드 레이싱 */
            "https://images.unsplash.com/photo-1544192240-4a34edd010d2?q=80&w=2070&auto=format&fit=crop", /* MTB 산악 */
            "https://images.unsplash.com/photo-1485965120184-e220f721d03e?q=80&w=2070&auto=format&fit=crop", /* 도심 라이딩 */
            "https://images.unsplash.com/photo-1507036066871-b7e8032b3dea?q=80&w=2070&auto=format&fit=crop"  /* 로드 바이커 */
        ];

        let currentImageIndex = 0;
        const transitionTime = 1500; // CSS 페이드 효과 시간 (ms)

        // 이미지 프리로딩
        images.forEach(src => {
            const img = new Image();
            img.src = src;
        });

        // 초기 배경 설정
        hero.style.backgroundImage = `url('${images[currentImageIndex]}')`;

        setInterval(() => {
            const nextImageIndex = (currentImageIndex + 1) % images.length;

            // 다음 이미지를 가상 요소에 세팅
            hero.style.setProperty('--bg-image-next', `url('${images[nextImageIndex]}')`);
            
            // fade-in 클래스 부착하여 트랜지션 구동
            hero.classList.add('fade-in');

            // 트랜지션 만료 후 메인 백그라운드 교체 및 리셋
            setTimeout(() => {
                hero.style.backgroundImage = `url('${images[nextImageIndex]}')`;
                hero.classList.remove('fade-in');
                currentImageIndex = nextImageIndex;
            }, transitionTime);

        }, 5000); // 5초 주기 변경
    }

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