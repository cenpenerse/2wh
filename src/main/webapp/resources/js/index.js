/* ==========================================================================
   BAREN - 메인 페이지 (index.jsp) 전용 자바스크립트
   ========================================================================== */

document.addEventListener("DOMContentLoaded", function() {
    // 1. Flatpickr (대여 기간 선택 달력) 초기화
    flatpickr("#hero-date-range", {
        mode: "range",
        locale: "ko",
        dateFormat: "Y-m-d",
        minDate: "today",
        defaultDate: ["today", new Date().setDate(new Date().getDate() + 1)],
        onChange: function(selectedDates, dateStr, instance) {
            // 날짜 범위 선택 시 필요한 콜백 처리 가능
        }
    });

    // 2. 카테고리 필터 버튼 동작
    const filterBtns = document.querySelectorAll(".filter-btn");
    const bikeCards = document.querySelectorAll(".premium-bike-card");

    filterBtns.forEach(btn => {
        btn.addEventListener("click", function() {
            // 모든 버튼에서 active 클래스 제거
            filterBtns.forEach(b => b.classList.remove("active"));
            // 클릭된 버튼에 active 클래스 추가
            this.classList.add("active");

            const filterValue = this.getAttribute("data-filter");

            bikeCards.forEach(card => {
                if (filterValue === "all" || card.getAttribute("data-category") === filterValue) {
                    card.style.display = "flex";
                    // 카드 전환 시 페이드인 애니메이션 효과 적용
                    card.style.opacity = "0";
                    setTimeout(() => {
                        card.style.transition = "opacity 0.4s ease";
                        card.style.opacity = "1";
                    }, 50);
                } else {
                    card.style.display = "none";
                }
            });
        });
    });
});
