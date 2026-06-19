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
                        <div class="bike-image-wrapper" style="height: 180px; position: relative; display: flex; align-items: center; justify-content: center; overflow: hidden; background: #121212;">
                            <c:choose>
                                <c:when test="${not empty shop.imageFilename}">
                                    <img src="${pageContext.request.contextPath}/resources/images/shops/${shop.imageFilename}" alt="${shop.shopName}" style="width: 100%; height: 100%; object-fit: cover; transition: transform 0.5s ease;">
                                </c:when>
                                <c:otherwise>
                                    <img src="${pageContext.request.contextPath}/resources/images/shops/shop_1.png" alt="${shop.shopName}" style="width: 100%; height: 100%; object-fit: cover; transition: transform 0.5s ease;">
                                </c:otherwise>
                            </c:choose>
                            <div style="position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: linear-gradient(to bottom, rgba(0,0,0,0.1), rgba(0,0,0,0.4));"></div>
                            <span class="badge" style="background: #10b981 !important; color: #fff !important; position: absolute; top: 15px; right: 15px; font-weight: 600; padding: 4px 10px; border-radius: 20px; font-size: 0.75rem;">영업 중</span>
                        </div>
                        <div class="bike-info" style="padding: 24px; flex-grow: 1; display: flex; flex-direction: column; justify-content: flex-start;">
                            <span class="bike-category" style="color: #60a5fa; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; margin-bottom: 6px; display: block; letter-spacing: 1px;">BareN Rental Shop</span>
                            <h3 style="font-size: 1.35rem; font-weight: 800; color: #fff; margin: 0 0 16px 0; font-family: 'Outfit', sans-serif;">${shop.shopName}</h3>
                            
                            <div style="font-size: 0.9rem; color: #cbd5e1; display: flex; flex-direction: column; gap: 10px;">
                                <div style="display: flex; align-items: flex-start; gap: 8px; line-height: 1.4;">
                                    <span style="color: #fff; display: inline-flex; align-items: center; width: 20px; padding-top: 2px;">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                                    </span>
                                    <span>${shop.address}</span>
                                </div>
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <span style="color: #fff; display: inline-flex; align-items: center; width: 20px;">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path></svg>
                                    </span>
                                    <span>${shop.tel}</span>
                                </div>
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <span style="color: #fff; display: inline-flex; align-items: center; width: 20px;">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                                    </span>
                                    <span>${shop.openTime} ~ ${shop.closeTime}</span>
                                </div>
                                <div style="display: flex; align-items: center; gap: 8px;">
                                    <span style="color: #fff; display: inline-flex; align-items: center; width: 20px;">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                                    </span>
                                    <span>지점장: ${shop.managerName}</span>
                                </div>
                            </div>
                        </div>
                        <a href="${pageContext.request.contextPath}/bikeSelect.do?shopId=${shop.shopId}" class="card-btn" style="text-align: center; border-radius: 0 0 12px 12px; background: linear-gradient(90deg, #e50914, #b20710); font-weight: 700; padding: 14px 0; color: #fff; display: block; text-decoration: none; transition: all 0.3s ease;">지점 선택 및 바이크 예약</a>
                    </div>
                </c:forEach>
            </div>
        </div>
    </section>

<style>
    .bike-card:hover {
        transform: translateY(-8px);
        box-shadow: 0 12px 24px rgba(0, 0, 0, 0.3);
        border-color: rgba(229, 9, 20, 0.4) !important;
    }
    .bike-card:hover .bike-image-wrapper img {
        transform: scale(1.1);
    }
    .bike-card:hover .card-btn {
        background: linear-gradient(90deg, #ff1f29, #e50914) !important;
    }
</style>
<jsp:include page="/WEB-INF/views/common/footer.jsp" />
