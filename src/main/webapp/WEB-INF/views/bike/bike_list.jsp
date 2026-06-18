<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

    <section class="content-section">
        <div class="board-container max-width" style="padding-top: 30px;">
            <div class="board-header" style="margin-bottom: 45px; text-align: center;">
                <h2 style="font-family: 'Outfit', sans-serif; font-size: 2.5rem; font-weight: 800; color: #fff; margin-bottom: 12px; letter-spacing: -0.5px;">대여/예약 가능한 지점</h2>
                <p style="color: var(--light-text-color); font-size: 1.05rem;">원하시는 대여 지점을 선택하여 바이크 목록을 확인하세요.</p>
            </div>

            <!-- 지점 카드 리스트 -->
            <div class="bike-list-container list-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 30px;">
                <c:forEach var="shop" items="${shopList}">
                    <div class="bike-card" style="display: flex; flex-direction: column; justify-content: space-between; min-height: 420px; background: rgba(30, 30, 48, 0.4); border: 1px solid rgba(255,255,255,0.05); border-radius: 12px; overflow: hidden; transition: all 0.3s ease;">
                        <div class="bike-image-wrapper" style="height: 180px; position: relative; background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%); display: flex; align-items: center; justify-content: center; overflow: hidden;">
                            <div style="font-size: 4.5rem; filter: drop-shadow(0 6px 12px rgba(0,0,0,0.35)); transition: transform 0.3s ease;">
                                <c:choose>
                                    <c:when test="${shop.shopId == 1}">🏛️</c:when>
                                    <c:when test="${shop.shopId == 2}">🚄</c:when>
                                    <c:when test="${shop.shopId == 3}">🏞️</c:when>
                                    <c:when test="${shop.shopId == 4}">🎓</c:when>
                                    <c:when test="${shop.shopId == 5}">🎪</c:when>
                                    <c:when test="${shop.shopId == 6}">⛰️</c:when>
                                    <c:when test="${shop.shopId == 7}">🛍️</c:when>
                                    <c:when test="${shop.shopId == 8}">🚜</c:when>
                                    <c:when test="${shop.shopId == 9}">🏫</c:when>
                                    <c:otherwise>🏢</c:otherwise>
                                </c:choose>
                            </div>
                            <span class="badge" style="background: #10b981 !important; color: #fff !important; position: absolute; top: 15px; right: 15px; font-weight: 600; padding: 4px 10px; border-radius: 20px; font-size: 0.75rem;">영업 중</span>
                        </div>
                        <div class="bike-info" style="padding: 24px; flex-grow: 1; display: flex; flex-direction: column; justify-content: flex-start;">
                            <span class="bike-category" style="color: #60a5fa; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; margin-bottom: 6px; display: block; letter-spacing: 1px;">BareN Rental Shop</span>
                            <h3 style="font-size: 1.35rem; font-weight: 800; color: #fff; margin: 0 0 16px 0; font-family: 'Outfit', sans-serif;">${shop.shopName}</h3>
                            
                            <div style="font-size: 0.9rem; color: #cbd5e1; display: flex; flex-direction: column; gap: 10px;">
                                <div style="display: flex; align-items: flex-start; gap: 8px; line-height: 1.4;">
                                    <span style="color: #60a5fa; font-size: 1rem; width: 20px;">📍</span>
                                    <span>${shop.address}</span>
                                </div>
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <span style="color: #60a5fa; font-size: 1rem; width: 20px;">📞</span>
                                    <span>${shop.tel}</span>
                                </div>
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <span style="color: #60a5fa; font-size: 1rem; width: 20px;">⏰</span>
                                    <span>${shop.openTime} ~ ${shop.closeTime}</span>
                                </div>
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <span style="color: #60a5fa; font-size: 1rem; width: 20px;">👤</span>
                                    <span>지점장: ${shop.managerName}</span>
                                </div>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/bikeSelect.do?shopId=${shop.shopId}" class="card-btn" style="text-align: center; border-radius: 0 0 12px 12px; background: linear-gradient(90deg, #2563eb, #1d4ed8); font-weight: 700; padding: 14px 0; color: #fff; display: block; text-decoration: none; transition: background 0.3s;">지점 선택 및 바이크 예약</a>
                    </div>
                </c:forEach>
            </div>
        </div>
    </section>

<style>
    .bike-card:hover {
        transform: translateY(-8px);
        box-shadow: 0 12px 24px rgba(0, 0, 0, 0.3);
        border-color: rgba(96, 165, 250, 0.3) !important;
    }
    .bike-card:hover .bike-image-wrapper div {
        transform: scale(1.15);
    }
</style>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
