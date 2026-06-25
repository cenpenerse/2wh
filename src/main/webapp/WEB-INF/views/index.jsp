<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/index.css">

<!-- Flatpickr (달력 라이브러리) CDN -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/dark.css">
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://npmcdn.com/flatpickr/dist/l10n/ko.js"></script>

<!-- 메인 히어로 섹션 -->
<section class="hero-section">
    <div class="hero-overlay"></div>
    <div class="hero-content">
        <h2>어디로든 떠나세요,</h2>
        <h1>지금 바로 내 손안의 차고</h1>
        <p>대구 도심부터 대구 근교까지, 가장 빠르고 스타일리시한 모빌리티 솔루션, 쉽고 빠르게 오토바이를 렌탈하세요.</p>
        
        <!-- 검색바 영역 -->
        <form action="${pageContext.request.contextPath}/bike/bikeSelect.do" method="get" class="hero-search-bar">
            <!-- 대여 위치 -->
            <div class="search-col-loc">
                <span class="search-icon-marker"></span>
                <div class="search-field-group">
                    <label>대여 위치</label>
                    <select name="shopId">
                        <c:forEach var="shop" items="${shopList}">
                            <option value="${shop.shopId}">${shop.shopName}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <!-- 구분선 -->
            <div class="search-divider"></div>

            <!-- 대여 시간 -->
            <div class="search-col-time">
                <span class="search-icon-calendar"></span>
                <div class="search-field-group">
                    <label>대여 시간</label>
                    <input type="text" id="hero-date-range" placeholder="대여 기간 선택">
                </div>
            </div>

            <!-- 검색 버튼 -->
            <button type="submit" class="search-btn">
                <span></span> 차량 검색
            </button>
        </form>
    </div>
</section>

<!-- 당신을 위한 프리미엄 라인업 섹션 -->
<section class="premium-fleet-section">
    <div class="max-width">
        <div class="section-header-center">
            <span class="sub-title">Premium Fleet Selection</span>
            <h2>당신을 위한 프리미엄 라인업</h2>
            <p>원하시는 스타일의 바이크를 선택하여 특별한 라이딩을 시작해 보세요.</p>
        </div>

        <!-- 카테고리 필터 버튼 -->
        <div class="filter-buttons-container">
            <button class="filter-btn active" data-filter="all">전체 보기</button>
            <button class="filter-btn" data-filter="scooter">스쿠터</button>
            <button class="filter-btn" data-filter="sports">스포츠</button>
            <button class="filter-btn" data-filter="cruiser">크루저</button>
            <button class="filter-btn" data-filter="adventure">어드벤처</button>
        </div>

        <!-- 바이크 카드 그리드 -->
        <div class="bikes-grid">
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
                <div class="premium-bike-card" data-category="${cat}">
                    <div class="bike-img-wrapper">
                        <img src="${pageContext.request.contextPath}/${bike.bikeImageUrl}" alt="${bike.bikeName}">
                        <span class="brand-tag">${bike.brandName}</span>
                        <c:choose>
                            <c:when test="${bike.status eq 'AVAILABLE'}">
                                <span class="badge-avail">AVAILABLE</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge-rented">RENTED</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    
                    <div class="bike-info">
                        <div>
                            <div class="bike-info-header">
                                <h3>${bike.bikeName}</h3>
                                <span class="bike-cc">${bike.cc}cc</span>
                            </div>
                            <p class="bike-desc">
                                ${bike.description}
                            </p>
                        </div>

                        <div>
                            <div class="bike-price-info">
                                <span class="price-label">1일 대여 기준</span>
                                <span class="price-amount">
                                    ₩<fmt:formatNumber value="${bike.dailyPrice}" pattern="#,###"/> <span class="price-unit">/ 일</span>
                                </span>
                            </div>

                            <a href="${pageContext.request.contextPath}/bike/bikeDetail.do?bikeId=${bike.bikeId}" class="card-action-btn">
                                상세 정보 및 예약하기 </a>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</section>

<!-- Baren 서비스 특장점 섹션 -->
<section class="features-section">
    <div class="max-width">
        <div class="section-header-center">
            <span class="sub-title">Why Choose Us</span>
            <h2>완벽을 향한 Baren만의 서비스</h2>
        </div>
        
        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon"></div>
                <h3>현업 미캐닉 전문 정비</h3>
                <p>매 반납 즉시 조향, 구동계, 전자 계통 등 20개 핵심 안전 진단 항목을 전용 장비로 확인하여 최고의 주행 질감을 보장합니다.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon"></div>
                <h3>프리미엄 보호 장구 포함</h3>
                <p>안전 검사를 획득한 풀페이스/오픈페이스 헬멧 및 신체 보호 반사 밴드를 고객의 생명을 위해 추가 과금 없이 무상 렌탈합니다.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon"></div>
                <h3>24시 긴급 출동 케어</h3>
                <p>라이딩 중 돌발 상황이나 펑크, 고장 등 긴급 사태가 벌어지면 당사 긴급 픽업 팀이 현장으로 24시간 즉시 출동하여 대처합니다.</p>
            </div>
        </div>
    </div>
</section>

<!-- 최종 CTA 예약 유도 섹션 -->
<section class="cta-section">
    <div class="cta-container">
        <h2>지금, 바람을 가르며 달릴 시간입니다</h2>
        <p>최고의 머신들과 함께하는 자유로운 투어링 라이프. Baren이 라이더의 첫 시동을 동행합니다.</p>
        <div>
            <a href="${pageContext.request.contextPath}/bike/bikeList.do" class="cta-btn">바이크 예약하러 가기 </a>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
<script src="${pageContext.request.contextPath}/resources/js/index.js"></script>