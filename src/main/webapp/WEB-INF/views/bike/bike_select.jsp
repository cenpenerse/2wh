<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

    <section class="content-section">
        <div class="board-container max-width" style="padding-top: 30px;">
            <div class="board-header" style="margin-bottom: 45px; text-align: center; position: relative;">
                <a href="${pageContext.request.contextPath}/bikeList.do" style="position: absolute; left: 0; top: 10px; color: #60a5fa; text-decoration: none; font-weight: 600; display: flex; align-items: center; gap: 6px; font-size: 0.95rem;">
                    <span>←</span> 다른 지점 선택
                </a>
                <h2 style="font-family: 'Outfit', sans-serif; font-size: 2.3rem; font-weight: 800; color: #fff; margin-bottom: 12px; letter-spacing: -0.5px;">
                    ${selectedShop.shopName} - 대여 가능한 바이크
                </h2>
                <p style="color: var(--light-text-color); font-size: 1rem;">
                    📍 ${selectedShop.address} &nbsp;|&nbsp; 📞 ${selectedShop.tel} &nbsp;|&nbsp; ⏰ 영업시간: ${selectedShop.openTime} ~ ${selectedShop.closeTime}
                </p>
            </div>
            
            <!-- 필터 검색 영역 -->
            <form action="${pageContext.request.contextPath}/bikeSelect.do" method="get" class="filter-form">
                <input type="hidden" name="shopId" value="${selectedShopId}">
                <div class="filter-group-row">
                    <div class="filter-item">
                        <label for="brandId">제조사</label>
                        <select name="brandId" id="brandId">
                            <option value="all" ${selectedBrandId eq 'all' or empty selectedBrandId ? 'selected' : ''}>전체 제조사</option>
                            <c:forEach var="brand" items="${brandList}">
                                <option value="${brand.brandId}" ${selectedBrandId eq brand.brandId ? 'selected' : ''}>${brand.brandName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="filter-item">
                        <label for="ccType">배기량 구분</label>
                        <select name="ccType" id="ccType">
                            <option value="all" ${selectedCcType eq 'all' or empty selectedCcType ? 'selected' : ''}>전체 배기량</option>
                            <option value="SCOOTER" ${selectedCcType eq 'SCOOTER' ? 'selected' : ''}>~ 125cc 이하 (스쿠터)</option>
                            <option value="QUARTER" ${selectedCcType eq 'QUARTER' ? 'selected' : ''}>125cc ~ 400cc (쿼터급)</option>
                            <option value="LITER" ${selectedCcType eq 'LITER' ? 'selected' : ''}>400cc 초과 (미들/리터급)</option>
                        </select>
                    </div>
                    <div class="filter-btn-item">
                        <button type="submit" class="btn btn-filter">필터 검색</button>
                    </div>
                </div>
            </form>

            <!-- 바이크 카드 리스트 -->
            <div class="bike-list-container list-grid">
                <c:choose>
                    <c:when test="${not empty bikeList}">
                        <c:forEach var="bike" items="${bikeList}">
                            <div class="bike-card">
                                <div class="bike-image-wrapper">
                                    <span class="badge ${bike.status eq 'AVAILABLE' ? 'badge-avail' : (bike.status eq 'RENTED' ? 'badge-rented' : 'badge-maintenance')}">
                                        <c:choose>
                                            <c:when test="${bike.status eq 'AVAILABLE'}">대여 가능</c:when>
                                            <c:when test="${bike.status eq 'RENTED'}">대여 중</c:when>
                                            <c:otherwise>정비 중</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <img src="${pageContext.request.contextPath}/${bike.bikeImageUrl}" alt="${bike.bikeName}">
                                </div>
                                <div class="bike-info">
                                    <span class="bike-category">${bike.brandName}</span>
                                    <h3>${bike.bikeName}</h3>
                                    <p class="location" style="margin-bottom: 12px;"><i class="icon-loc">📍</i> ${bike.shopName}</p>
                                    <div class="price">
                                        <span>₩<fmt:formatNumber value="${bike.dailyPrice}" pattern="#,###"/></span> / 일
                                    </div>
                                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 15px; border-top: 1px solid #222; padding-top: 12px;">
                                        <span style="font-size: 0.85rem; color: #aaa; display: flex; align-items: center; gap: 6px;">🛡️ 종합 책임 보험 가입 완료</span>
                                        <span style="font-size: 0.85rem; color: #aaa; display: flex; align-items: center; gap: 6px;">⛑️ 프리미엄 헬멧 무상 대여</span>
                                        <span style="font-size: 0.85rem; color: #aaa; display: flex; align-items: center; gap: 6px;">🛠️ 반납 즉시 정밀 정비 진단</span>
                                    </div>
                                    <div class="rating">
                                        <span class="stars">★</span> <strong>${bike.ratingAvg}</strong> (${bike.reviewCount} 리뷰)
                                    </div>
                                </div>
                                <a href="${pageContext.request.contextPath}/bikeDetail.do?bikeId=${bike.bikeId}&shopId=${selectedShopId}" class="card-btn">상세 정보 및 예약</a>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="no-results" style="grid-column: 1 / -1; padding: 60px 20px; text-align: center; background: rgba(30, 30, 48, 0.2); border: 1px solid rgba(255,255,255,0.05); border-radius: 12px; margin-top: 20px;">
                            <span class="no-results-icon" style="font-size: 4rem; display: block; margin-bottom: 15px;">🏍️</span>
                            <p style="color: #cbd5e1; font-size: 1.1rem; margin-bottom: 20px;">선택하신 조건에 해당하는 바이크가 존재하지 않습니다.</p>
                            <a href="${pageContext.request.contextPath}/bikeSelect.do?shopId=${selectedShopId}" class="btn" style="background: #2563eb; color: #fff; border-radius: 6px; padding: 10px 24px; font-weight: 600; text-decoration: none;">지점 전체 바이크 보기</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </section>

<style>
    .badge-avail { background: #10b981 !important; color: #fff !important; }
    .badge-rented { background: #ef4444 !important; color: #fff !important; }
    .badge-maintenance { background: #f59e0b !important; color: #fff !important; }
</style>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
