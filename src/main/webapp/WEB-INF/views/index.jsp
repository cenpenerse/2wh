<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<!-- Flatpickr (달력 라이브러리) CDN -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/dark.css">
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://npmcdn.com/flatpickr/dist/l10n/ko.js"></script>

<!-- 메인 히어로 섹션 -->
<section class="hero-section" style="position: relative; height: 90vh; display: flex; align-items: center; justify-content: center; background: linear-gradient(rgba(0, 0, 0, 0.35), rgba(0, 0, 0, 0.9)), url('${pageContext.request.contextPath}/resources/images/hero_bg.png') no-repeat center center/cover; text-align: center; padding: 0 20px; overflow: hidden;">
    <div class="hero-overlay" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: radial-gradient(circle, transparent 10%, #000 100%); z-index: 1;"></div>
    <div class="hero-content" style="position: relative; z-index: 2; max-width: 900px; width: 100%; display: flex; flex-direction: column; align-items: center;">
        <h2 style="font-family: 'Outfit', sans-serif; font-size: 2.5rem; font-weight: 700; color: #fff; margin: 0 0 10px 0; letter-spacing: -0.5px; text-shadow: 0 4px 10px rgba(0,0,0,0.8);">어디로든 떠나세요,</h2>
        <h1 style="font-family: 'Outfit', sans-serif; font-size: 4.4rem; font-weight: 900; color: #E50914; margin: 0 0 25px 0; letter-spacing: -1px; text-shadow: 0 4px 15px rgba(0,0,0,0.8);">지금 바로 내 손안의 차고</h1>
        <p style="font-size: 1.15rem; color: #bbb; max-width: 750px; margin: 0 auto 50px; line-height: 1.7; text-shadow: 0 2px 5px rgba(0,0,0,0.8);">대구 도심부터 대구 근교까지, 가장 빠르고 스타일리시한 모빌리티 솔루션, 쉽고 빠르게 오토바이를 렌탈하세요.</p>
        
        <!-- 검색바 영역 -->
        <form action="${pageContext.request.contextPath}/bikeSelect.do" method="get" class="hero-search-bar" style="display: flex; align-items: center; background: rgba(22, 22, 22, 0.85); border: 1px solid #333; border-radius: 100px; padding: 8px 8px 8px 30px; max-width: 780px; width: 100%; box-shadow: 0 15px 35px rgba(0,0,0,0.6); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px);">
            <!-- 대여 위치 -->
            <div style="display: flex; align-items: center; gap: 12px; flex: 1; text-align: left;">
                <span style="color: #E50914; font-size: 1.35rem;">📍</span>
                <div style="display: flex; flex-direction: column; flex: 1;">
                    <label style="font-size: 0.75rem; color: #888; font-weight: 700; margin-bottom: 2px;">대여 위치</label>
                    <select name="shopId" style="background: transparent; border: none; outline: none; color: #fff; font-size: 0.95rem; font-weight: 700; width: 100%; cursor: pointer; padding-right: 15px; appearance: none; -webkit-appearance: none; -moz-appearance: none; background: url('data:image/svg+xml;utf8,<svg fill=%23ffffff height=18 viewBox=\'0 0 24 24\' width=18 xmlns=\'http://www.w3.org/2000/svg\'><path d=\'M7 10l5 5 5-5z\'/><path d=\'M0 0h24v24H0z\' fill=\'none\'/></svg>') no-repeat; background-position: right 0 center;">
                        <c:forEach var="shop" items="${shopList}">
                            <option value="${shop.shopId}" style="background: #151515; color: #fff;">${shop.shopName}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <!-- 구분선 -->
            <div style="border-left: 1px solid #333; height: 35px; margin: 0 25px;"></div>

            <!-- 대여 시간 -->
            <div style="display: flex; align-items: center; gap: 12px; flex: 1.2; text-align: left;">
                <span style="color: #E50914; font-size: 1.3rem;">📅</span>
                <div style="display: flex; flex-direction: column; flex: 1;">
                    <label style="font-size: 0.75rem; color: #888; font-weight: 700; margin-bottom: 2px;">대여 시간</label>
                    <input type="text" id="hero-date-range" placeholder="대여 기간 선택" style="background: transparent; border: none; outline: none; color: #fff; font-size: 0.95rem; font-weight: 700; width: 100%; cursor: pointer;">
                </div>
            </div>

            <!-- 검색 버튼 -->
            <button type="submit" style="background: #E50914; color: #fff; border: none; padding: 15px 35px; border-radius: 50px; font-weight: 800; font-size: 1rem; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: all 0.3s ease; box-shadow: 0 4px 15px rgba(229, 9, 20, 0.4);" onmouseover="this.style.backgroundColor='#B20710'; this.style.transform='scale(1.02)';" onmouseout="this.style.backgroundColor='#E50914'; this.style.transform='scale(1)';">
                <span>🔍</span> 차량 검색
            </button>
        </form>
    </div>
</section>

<!-- 당신을 위한 프리미엄 라인업 섹션 -->
<section style="background: #0a0a0a; padding: 100px 20px; border-bottom: 1px solid #1a1a1a;">
    <div class="max-width" style="max-width: 1200px; margin: 0 auto;">
        <div style="text-align: center; margin-bottom: 60px;">
            <span style="color: #E50914; font-weight: 700; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 2px;">Premium Fleet Selection</span>
            <h2 style="font-family: 'Outfit', sans-serif; font-size: 2.6rem; font-weight: 800; color: #fff; margin-top: 10px;">당신을 위한 프리미엄 라인업</h2>
            <p style="color: #888; margin-top: 10px; font-size: 1.05rem;">원하시는 스타일의 바이크를 선택하여 특별한 라이딩을 시작해 보세요.</p>
        </div>

        <!-- 카테고리 필터 버튼 -->
        <div class="filter-buttons-container" style="display: flex; justify-content: center; gap: 15px; margin-bottom: 50px; flex-wrap: wrap;">
            <button class="filter-btn active" data-filter="all">전체 보기</button>
            <button class="filter-btn" data-filter="scooter">스쿠터</button>
            <button class="filter-btn" data-filter="sports">스포츠</button>
            <button class="filter-btn" data-filter="cruiser">크루저</button>
            <button class="filter-btn" data-filter="adventure">어드벤처</button>
        </div>

        <!-- 바이크 카드 그리드 -->
        <div class="bikes-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap: 30px;">
            <c:forEach var="bike" items="${bikeList}">
                <!-- 카테고리 판별 -->
                <c:set var="cat" value="etc" />
                <c:choose>
                    <c:when test="${bike.bikeName == 'PCX 125' || bike.bikeName == 'Primavera 125' || bike.bikeName == 'Super Cub 110'}">
                        <c:set var="cat" value="scooter" />
                    </c:when>
                    <c:when test="${bike.bikeName == 'YZF-R3' || bike.bikeName == 'Panigale V4' || bike.bikeName == 'YZF-R1'}">
                        <c:set var="cat" value="sports" />
                    </c:when>
                    <c:when test="${bike.bikeName == 'Iron 883' || bike.bikeName == 'R nineT'}">
                        <c:set var="cat" value="cruiser" />
                    </c:when>
                    <c:when test="${bike.bikeName == 'R 1250 GS'}">
                        <c:set var="cat" value="adventure" />
                    </c:when>
                </c:choose>

                <!-- 바이크 카드 구조 -->
                <div class="premium-bike-card" data-category="${cat}" style="background: #121212; border: 1px solid #222; border-radius: 16px; overflow: hidden; transition: all 0.3s ease; display: flex; flex-direction: column;">
                    <div class="bike-img-wrapper" style="position: relative; height: 210px; background: #181818; display: flex; align-items: center; justify-content: center; overflow: hidden; padding: 0; border-bottom: 1px solid #1c1c1c;">
                        <img src="${pageContext.request.contextPath}/${bike.bikeImageUrl}" alt="${bike.bikeName}" style="width: 100%; height: 100%; object-fit: cover; transition: transform 0.5s ease;">
                        <span style="position: absolute; top: 15px; left: 15px; background: rgba(0,0,0,0.7); color: #fff; padding: 4px 12px; border-radius: 50px; font-size: 0.8rem; font-weight: 600; border: 1px solid rgba(255,255,255,0.15);">${bike.brandName}</span>
                        <c:choose>
                            <c:when test="${bike.status eq 'AVAILABLE'}">
                                <span class="badge-avail" style="position: absolute; top: 15px; right: 15px; padding: 4px 12px; border-radius: 50px; font-size: 0.8rem; font-weight: 600;">AVAILABLE</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge-rented" style="position: absolute; top: 15px; right: 15px; padding: 4px 12px; border-radius: 50px; font-size: 0.8rem; font-weight: 600;">RENTED</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    
                    <div class="bike-info" style="padding: 25px; display: flex; flex-direction: column; flex-grow: 1; justify-content: space-between;">
                        <div>
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                                <h3 style="color: #fff; font-size: 1.35rem; font-weight: 700; margin: 0; font-family: 'Outfit', sans-serif;">${bike.bikeName}</h3>
                                <span style="color: #E50914; font-weight: 700; font-size: 0.95rem;">${bike.cc}cc</span>
                            </div>
                            <p style="color: #888; font-size: 0.9rem; line-height: 1.5; margin: 0 0 20px 0; height: 45px; overflow: hidden; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;">
                                ${bike.description}
                            </p>
                        </div>

                        <div>
                            <div style="border-top: 1px solid #1c1c1c; padding-top: 20px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
                                <span style="color: #aaa; font-size: 0.9rem;">1일 대여 기준</span>
                                <span style="color: #fff; font-size: 1.3rem; font-weight: 800;">
                                    ₩<fmt:formatNumber value="${bike.dailyPrice}" pattern="#,###"/> <span style="font-size: 0.85rem; color: #888; font-weight: normal;">/ 일</span>
                                </span>
                            </div>

                            <a href="${pageContext.request.contextPath}/bikeDetail.do?bikeId=${bike.bikeId}" class="card-action-btn" style="display: block; text-align: center; background: transparent; color: #fff; border: 1px solid #E50914; padding: 12px 0; border-radius: 8px; font-weight: 700; text-decoration: none; transition: all 0.3s ease;">
                                상세 정보 및 예약하기 ⚡
                            </a>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

<!-- Baren 서비스 특장점 섹션 -->
<section style="background: #090909; border-bottom: 1px solid #1a1a1a; padding: 100px 20px;">
    <div class="max-width" style="max-width: 1200px; margin: 0 auto;">
        <div style="text-align: center; margin-bottom: 60px;">
            <span style="color: #E50914; font-weight: 700; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 2px;">Why Choose Us</span>
            <h2 style="font-family: 'Outfit', sans-serif; font-size: 2.5rem; font-weight: 800; color: #fff; margin-top: 10px;">완벽을 향한 Baren만의 서비스</h2>
        </div>
        
        <div class="features-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px;">
            <div class="feature-card" style="background: #121212; border: 1px solid #222; padding: 40px; border-radius: 16px; transition: transform 0.3s;" onmouseover="this.style.transform='translateY(-5px)'" onmouseout="this.style.transform='none'">
                <div style="font-size: 2.8rem; margin-bottom: 20px;">🛡️</div>
                <h3 style="font-size: 1.25rem; font-weight: 700; color: #fff; margin-bottom: 12px;">현업 미캐닉 전문 정비</h3>
                <p style="color: #888; font-size: 0.95rem; line-height: 1.6; margin: 0;">매 반납 즉시 조향, 구동계, 전자 계통 등 20개 핵심 안전 진단 항목을 전용 장비로 확인하여 최고의 주행 질감을 보장합니다.</p>
            </div>
            <div class="feature-card" style="background: #121212; border: 1px solid #222; padding: 40px; border-radius: 16px; transition: transform 0.3s;" onmouseover="this.style.transform='translateY(-5px)'" onmouseout="this.style.transform='none'">
                <div style="font-size: 2.8rem; margin-bottom: 20px;">⛑️</div>
                <h3 style="font-size: 1.25rem; font-weight: 700; color: #fff; margin-bottom: 12px;">프리미엄 보호 장구 포함</h3>
                <p style="color: #888; font-size: 0.95rem; line-height: 1.6; margin: 0;">안전 검사를 획득한 풀페이스/오픈페이스 헬멧 및 신체 보호 반사 밴드를 고객의 생명을 위해 추가 과금 없이 무상 렌탈합니다.</p>
            </div>
            <div class="feature-card" style="background: #121212; border: 1px solid #222; padding: 40px; border-radius: 16px; transition: transform 0.3s;" onmouseover="this.style.transform='translateY(-5px)'" onmouseout="this.style.transform='none'">
                <div style="font-size: 2.8rem; margin-bottom: 20px;">📞</div>
                <h3 style="font-size: 1.25rem; font-weight: 700; color: #fff; margin-bottom: 12px;">24시 긴급 출동 케어</h3>
                <p style="color: #888; font-size: 0.95rem; line-height: 1.6; margin: 0;">라이딩 중 돌발 상황이나 펑크, 고장 등 긴급 사태가 벌어지면 당사 긴급 픽업 팀이 현장으로 24시간 즉시 출동하여 대처합니다.</p>
            </div>
        </div>
    </div>
</section>

<!-- 최종 CTA 예약 유도 섹션 -->
<section style="position: relative; text-align: center; padding: 120px 20px; background: linear-gradient(135deg, #E50914 0%, #FF5E62 100%); color: #fff;">
    <div style="max-width: 800px; margin: 0 auto;">
        <h2 style="font-family: 'Outfit', sans-serif; font-size: 2.8rem; font-weight: 800; margin-bottom: 20px; text-shadow: 0 4px 15px rgba(0,0,0,0.3);">지금, 바람을 가르며 달릴 시간입니다</h2>
        <p style="font-size: 1.2rem; color: rgba(255,255,255,0.9); margin-bottom: 40px; max-width: 600px; margin-left: auto; margin-right: auto;">최고의 머신들과 함께하는 자유로운 투어링 라이프. Baren이 라이더의 첫 시동을 동행합니다.</p>
        <div>
            <a href="${pageContext.request.contextPath}/bikeList.do" style="display: inline-block; background: #000; color: #fff; padding: 18px 45px; font-size: 1.1rem; font-weight: 700; border-radius: 50px; box-shadow: 0 10px 30px rgba(0,0,0,0.4); transition: all 0.3s ease; text-transform: uppercase; text-decoration: none;" onmouseover="this.style.transform='scale(1.05)'; this.style.backgroundColor='#111';" onmouseout="this.style.transform='scale(1)'; this.style.backgroundColor='#000';">바이크 예약하러 가기 ⚡</a>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<style>
    /* 카테고리 필터 버튼 스타일링 */
    .filter-btn {
        background: #151515;
        color: #888;
        border: 1px solid #222;
        padding: 10px 24px;
        font-size: 0.95rem;
        font-weight: 600;
        border-radius: 50px;
        cursor: pointer;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        font-family: 'Outfit', sans-serif;
    }
    .filter-btn:hover {
        color: #fff;
        border-color: #E50914;
        background: #1a1a1a;
        box-shadow: 0 4px 15px rgba(229, 9, 20, 0.15);
    }
    .filter-btn.active {
        background: #E50914;
        color: #fff;
        border-color: #E50914;
        box-shadow: 0 4px 15px rgba(229, 9, 20, 0.3);
    }

    /* 프리미엄 카드 호버 애니메이션 */
    .premium-bike-card:hover {
        transform: translateY(-8px);
        border-color: #E50914 !important;
        box-shadow: 0 12px 30px rgba(229, 9, 20, 0.2) !important;
    }
    .premium-bike-card:hover .bike-img-wrapper img {
        transform: scale(1.06);
    }
    .premium-bike-card:hover .card-action-btn {
        background: #E50914 !important;
        border-color: #E50914 !important;
        box-shadow: 0 4px 12px rgba(229, 9, 20, 0.3);
    }

    .badge-avail { background: #10b981 !important; color: #fff !important; }
    .badge-rented { background: #ef4444 !important; color: #fff !important; }

    .hero-search-bar select option {
        background: #151515 !important;
        color: #fff !important;
    }
</style>

<script>
document.addEventListener("DOMContentLoaded", function() {
    // Flatpickr 초기화
    flatpickr("#hero-date-range", {
        mode: "range",
        locale: "ko",
        dateFormat: "Y-m-d",
        minDate: "today",
        defaultDate: ["today", new Date().setDate(new Date().getDate() + 1)],
        onChange: function(selectedDates, dateStr, instance) {
            // 날짜 범위 선택 시 필요한 로직 추가 가능
        }
    });

    const filterBtns = document.querySelectorAll(".filter-btn");
    const bikeCards = document.querySelectorAll(".premium-bike-card");

    filterBtns.forEach(btn => {
        btn.addEventListener("click", function() {
            // Remove active class from all buttons
            filterBtns.forEach(b => b.classList.remove("active"));
            // Add active class to clicked button
            this.classList.add("active");

            const filterValue = this.getAttribute("data-filter");

            bikeCards.forEach(card => {
                if (filterValue === "all" || card.getAttribute("data-category") === filterValue) {
                    card.style.display = "flex";
                    // Add entry animation
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
</script>