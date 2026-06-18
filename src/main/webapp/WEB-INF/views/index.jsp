<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<!-- 메인 히어로 섹션 (화려한 검정&빨강 대비 비주얼) -->
<section class="hero-section" style="position: relative; height: 85vh; display: flex; align-items: center; justify-content: center; background: linear-gradient(rgba(0, 0, 0, 0.4), rgba(0, 0, 0, 0.95)), url('https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=1600&q=80') no-repeat center center/cover; text-align: center; padding: 0 20px; overflow: hidden;">
    <div class="hero-overlay" style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background: radial-gradient(circle, transparent 20%, #000 100%); z-index: 1;"></div>
    <div class="hero-content" style="position: relative; z-index: 2; max-width: 900px;">
        <span class="hero-badge" style="display: inline-block; background: #E50914; color: #fff; padding: 6px 16px; border-radius: 50px; font-weight: 700; font-size: 0.85rem; letter-spacing: 2px; margin-bottom: 25px; text-transform: uppercase; box-shadow: 0 0 15px rgba(229, 9, 20, 0.5);">Premium Motorcycle Rental</span>
        <h1 style="font-family: 'Outfit', sans-serif; font-size: 3.8rem; font-weight: 800; line-height: 1.15; color: #fff; margin-bottom: 20px; letter-spacing: -1px; text-shadow: 0 4px 10px rgba(0,0,0,0.5);">
            FEEL THE BAREN<br>
            <span style="background: linear-gradient(to right, #E50914, #FF5E62); -webkit-background-clip: text; -webkit-text-fill-color: transparent;">LIMITLESS RIDING</span>
        </h1>
        <p style="font-size: 1.25rem; color: #bbb; max-width: 700px; margin: 0 auto 40px; line-height: 1.6;">도심 스쿠팅부터 압도적인 스포츠 와인딩까지, 최상의 상태로 정비된 라이드와 함께 바람을 갈라보세요.</p>
        
        <!-- 동적 지점 검색 퀵 폼 -->
        <form id="search-form" action="${pageContext.request.contextPath}/bikeList.do" method="get" class="main-search-form" onsubmit="handleSearchSubmit(event)">
            <div class="search-select-wrapper">
                <span class="search-icon">📍</span>
                <select id="search-shop-id" name="shopId" class="main-search-select">
                    <option value="all">대여할 지점을 선택하세요 (전체)</option>
                    <c:forEach var="shop" items="${shopList}">
                        <option value="${shop.shopId}">${shop.shopName}</option>
                    </c:forEach>
                </select>
            </div>
            <button type="submit" class="main-search-btn">
                검색
            </button>
        </form>
        <script>
        function handleSearchSubmit(event) {
            var shopId = document.getElementById("search-shop-id").value;
            var form = document.getElementById("search-form");
            if (shopId && shopId !== "all") {
                form.action = "${pageContext.request.contextPath}/bikeSelect.do";
            } else {
                form.action = "${pageContext.request.contextPath}/bikeList.do";
            }
        }
        </script>
    </div>
</section>

<!-- 카테고리 퀵 내비게이션 (스쿠터 / 쿼터급 / 리터급) -->
<section style="background: #000; padding: 60px 20px; border-bottom: 1px solid #1a1a1a;">
    <div class="max-width" style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 25px;">
        <a href="${pageContext.request.contextPath}/bikeList.do?ccType=SCOOTER" class="category-link" style="display: block; background: #121212; border: 1px solid #222; padding: 30px; border-radius: 12px; text-align: center; color: #fff; transition: all 0.3s ease;">
            <div style="font-size: 2.5rem; margin-bottom: 15px;">🛵</div>
            <h3 style="font-size: 1.25rem; font-weight: 700; margin-bottom: 5px;">스쿠터 라인업</h3>
            <p style="font-size: 0.9rem; color: #888; margin: 0;">125cc 이하 | 일상 및 도심 주행용</p>
        </a>
        <a href="${pageContext.request.contextPath}/bikeList.do?ccType=QUARTER" class="category-link" style="display: block; background: #121212; border: 1px solid #222; padding: 30px; border-radius: 12px; text-align: center; color: #fff; transition: all 0.3s ease;">
            <div style="font-size: 2.5rem; margin-bottom: 15px;">🏍️</div>
            <h3 style="font-size: 1.25rem; font-weight: 700; margin-bottom: 5px;">쿼터급 라인업</h3>
            <p style="font-size: 0.9rem; color: #888; margin: 0;">125cc ~ 400cc | 스포티한 입문용</p>
        </a>
        <a href="${pageContext.request.contextPath}/bikeList.do?ccType=LITER" class="category-link" style="display: block; background: #121212; border: 1px solid #222; padding: 30px; border-radius: 12px; text-align: center; color: #fff; transition: all 0.3s ease;">
            <div style="font-size: 2.5rem; margin-bottom: 15px;">🚀</div>
            <h3 style="font-size: 1.25rem; font-weight: 700; margin-bottom: 5px;">미들/리터급 라인업</h3>
            <p style="font-size: 0.9rem; color: #888; margin: 0;">400cc 초과 | 대형 투어러 및 고성능</p>
        </a>
    </div>
</section>

<!-- 추천 바이크 리스트 섹션 (검정 배경에 화려한 스포츠 느낌) -->
<section class="section featured-bikes" style="background: #000; padding: 100px 20px;">
    <div class="max-width">
        <div style="text-align: center; margin-bottom: 60px;">
            <span style="color: #E50914; font-weight: 700; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 2px;">Hot Lineups</span>
            <h2 class="section-title" style="font-family: 'Outfit', sans-serif; font-size: 2.5rem; font-weight: 800; color: #fff; margin-top: 10px;">Baren 추천 머신</h2>
            <p class="section-subtitle" style="color: #888; font-size: 1.05rem;">지금 즉시 대여 가능한 인기 오토바이를 한눈에 만나보세요.</p>
        </div>
        
        <div class="bike-list-container list-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(350px, 1fr)); gap: 30px;">
            <c:choose>
                <c:when test="${not empty bikeList}">
                    <c:forEach var="bike" items="${bikeList}">
                        <div class="bike-card" style="background: #121212; border: 1px solid #222; border-radius: 16px; overflow: hidden; transition: all 0.3s ease; display: flex; flex-direction: column;">
                            <div class="bike-image-wrapper" style="position: relative; height: 230px; background: #1a1a1a; display: flex; align-items: center; justify-content: center; overflow: hidden;">
                                <span class="badge ${bike.status eq 'AVAILABLE' ? 'badge-avail' : (bike.status eq 'RENTED' ? 'badge-rented' : 'badge-maintenance')}" style="position: absolute; top: 15px; left: 15px; z-index: 2; padding: 6px 14px; border-radius: 20px; font-size: 0.75rem; font-weight: 700;">
                                    <c:choose>
                                        <c:when test="${bike.status eq 'AVAILABLE'}">대여 가능</c:when>
                                        <c:when test="${bike.status eq 'RENTED'}">대여 중</c:when>
                                        <c:otherwise>정비 중</c:otherwise>
                                    </c:choose>
                                </span>
                                <img src="${pageContext.request.contextPath}/${bike.bikeImageUrl}" alt="${bike.bikeName}" style="width: 100%; height: 100%; object-fit: cover; transition: transform 0.5s ease;">
                            </div>
                            <div class="bike-info" style="padding: 25px; flex-grow: 1;">
                                <span class="bike-category">${bike.brandName}</span>
                                <h3 style="font-family: 'Outfit', sans-serif; font-size: 1.4rem; font-weight: 700; color: #fff; margin-bottom: 12px; letter-spacing: -0.3px;">${bike.bikeName}</h3>
                                <p class="location" style="color: #888; font-size: 0.95rem; margin-bottom: 15px; display: flex; align-items: center; gap: 5px;">
                                    <span>📍</span> 대구 전 지점 대여 가능
                                </p>
                                <div class="price" style="margin-bottom: 15px;">
                                    <span style="font-size: 1.35rem; color: #fff; font-weight: 800; font-family: 'Outfit';">₩<fmt:formatNumber value="${bike.dailyPrice}" pattern="#,###"/></span> / 일
                                </div>
                                <div style="display: flex; flex-direction: column; gap: 8px; margin-top: 15px; border-top: 1px solid #222; padding-top: 15px;">
                                    <span style="font-size: 0.85rem; color: #bbb; display: flex; align-items: center; gap: 6px;">🛡️ 종합 책임 보험 가입 완료</span>
                                    <span style="font-size: 0.85rem; color: #bbb; display: flex; align-items: center; gap: 6px;">⛑️ 프리미엄 헬멧 무상 대여</span>
                                    <span style="font-size: 0.85rem; color: #bbb; display: flex; align-items: center; gap: 6px;">🛠️ 반납 즉시 정밀 정비 진단</span>
                                </div>
                            </div>
                            <a href="${pageContext.request.contextPath}/bikeDetail.do?bikeId=${bike.bikeId}" class="card-btn" style="display: block; background: #1a1a1a; color: #fff; text-align: center; padding: 18px; font-weight: 700; font-size: 0.95rem; border-top: 1px solid #222; transition: all 0.3s ease;">상세 사양 및 예약하기</a>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div style="grid-column: 1/-1; text-align: center; padding: 60px; color: #666;">
                        <div style="font-size: 3rem; margin-bottom: 15px;">🏍️</div>
                        <p>현재 준비 중인 추천 오토바이가 없습니다. 대여소를 필터링해 보십시오.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</section>

<!-- Baren 서비스 특장점 섹션 -->
<section style="background: #090909; border-top: 1px solid #1a1a1a; border-bottom: 1px solid #1a1a1a; padding: 100px 20px;">
    <div class="max-width">
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

<!-- 최종 CTA 예약 유도 섹션 (레드 그라데이션) -->
<section style="position: relative; text-align: center; padding: 120px 20px; background: linear-gradient(135deg, #E50914 0%, #FF5E62 100%); color: #fff;">
    <div style="max-width: 800px; margin: 0 auto;">
        <h2 style="font-family: 'Outfit', sans-serif; font-size: 2.8rem; font-weight: 800; margin-bottom: 20px; text-shadow: 0 4px 15px rgba(0,0,0,0.3);">지금, 바람을 가르며 달릴 시간입니다</h2>
        <p style="font-size: 1.2rem; color: rgba(255,255,255,0.9); margin-bottom: 40px; max-width: 600px; margin-left: auto; margin-right: auto;">최고의 머신들과 함께하는 자유로운 투어링 라이프. Baren이 라이더의 첫 시동을 동행합니다.</p>
        <div>
            <a href="${pageContext.request.contextPath}/bikeList.do" style="display: inline-block; background: #000; color: #fff; padding: 18px 45px; font-size: 1.1rem; font-weight: 700; border-radius: 50px; box-shadow: 0 10px 30px rgba(0,0,0,0.4); transition: all 0.3s ease; text-transform: uppercase;" onmouseover="this.style.transform='scale(1.05)'; this.style.backgroundColor='#111';" onmouseout="this.style.transform='scale(1)'; this.style.backgroundColor='#000';">바이크 예약하러 가기 ⚡</a>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<style>
    /* 메인 검색 폼 스타일링 */
    .main-search-form {
        display: flex;
        gap: 12px;
        max-width: 650px;
        margin: 0 auto;
        background: rgba(18, 18, 18, 0.85);
        padding: 10px;
        border-radius: 12px;
        border: 1px solid #333;
        box-shadow: 0 10px 40px rgba(0,0,0,0.5);
        transition: all 0.3s ease;
    }
    .main-search-form:focus-within {
        border-color: #E50914;
        box-shadow: 0 0 15px rgba(229, 9, 20, 0.3), 0 10px 40px rgba(0,0,0,0.6);
    }
    .search-select-wrapper {
        flex: 1;
        display: flex;
        align-items: center;
        padding-left: 15px;
    }
    .search-icon {
        font-size: 1.1rem;
        margin-right: 10px;
        color: #E50914;
    }
    .main-search-select {
        width: 100%;
        background: transparent;
        border: none;
        outline: none;
        color: #fff;
        font-size: 0.9rem; /* 폰트 사이즈 줄임 */
        cursor: pointer;
        font-weight: 500;
        padding-right: 25px;
        appearance: none;
        -webkit-appearance: none;
        -moz-appearance: none;
        background: url("data:image/svg+xml;utf8,<svg fill='%23E50914' height='24' viewBox='0 0 24 24' width='24' xmlns='http://www.w3.org/2000/svg'><path d='M7 10l5 5 5-5z'/><path d='M0 0h24v24H0z' fill='none'/></svg>") no-repeat;
        background-position: right 5px center;
    }
    .main-search-select option {
        background: #121212;
        color: #fff;
        font-size: 0.9rem; /* 폰트 사이즈 줄임 */
        padding: 10px;
    }
    .main-search-btn {
        background: #E50914;
        color: #fff;
        border: none;
        padding: 12px 35px;
        font-size: 0.95rem; /* 폰트 사이즈 줄임 */
        font-weight: 700;
        border-radius: 8px;
        cursor: pointer;
        transition: all 0.3s ease;
        display: inline-flex;
        align-items: center;
        justify-content: center;
    }
    .main-search-btn:hover {
        background: #B20710;
        transform: translateY(-1px);
    }

    /* 카테고리 카드 호버 스타일링 */
    .category-link:hover {
        border-color: #E50914 !important;
        transform: translateY(-5px);
        box-shadow: 0 10px 25px rgba(229, 9, 20, 0.15);
    }
    /* 카드 마우스 호버 시 버튼 컬러 반전 */
    .bike-card:hover {
        border-color: #E50914 !important;
        box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5) !important;
    }
    .bike-card:hover .card-btn {
        background: #E50914 !important;
    }
    .bike-card:hover .bike-image-wrapper img {
        transform: scale(1.05);
    }
    .badge-avail { background: #10b981 !important; color: #fff !important; }
    .badge-rented { background: #ef4444 !important; color: #fff !important; }
    .badge-maintenance { background: #f59e0b !important; color: #fff !important; }
</style>