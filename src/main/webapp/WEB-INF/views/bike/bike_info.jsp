<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

    <section class="content-section">
        <div class="board-container max-width" style="padding-top: 30px;">
            <div class="board-header" style="margin-bottom: 45px; text-align: center;">
                <span style="color: var(--primary-color); font-weight: 700; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 2px;">Baren Fleet</span>
                <h2 style="font-family: 'Outfit', sans-serif; font-size: 2.5rem; font-weight: 800; color: #fff; margin-top: 10px; margin-bottom: 12px; letter-spacing: -0.5px;">바이크 라인업 안내</h2>
                <p style="color: var(--light-text-color); font-size: 1.05rem;">바렌이 제공하는 최고 사양의 프리미엄 바이크 종류 및 상세 제원입니다.</p>
                <div style="margin-top: 20px;">
                    <a href="${pageContext.request.contextPath}/bikeList.do" class="btn" style="background: linear-gradient(135deg, var(--primary-color) 0%, #FF5E62 100%); border: none; padding: 10px 25px; font-weight: 600; text-transform: uppercase; box-shadow: 0 4px 15px rgba(229, 9, 20, 0.4);">실시간 대여/예약 신청하러 가기 ⚡</a>
                </div>
            </div>

            <!-- 바이크 상세 정보 카드 리스트 (대여/예약 버튼 및 가격 정보 제외) -->
            <div class="bike-info-grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 30px;">
                <c:forEach var="bike" items="${bikeList}">
                    <div class="info-card" style="background: #121212; border: 1px solid #222; border-radius: 16px; overflow: hidden; transition: all 0.3s ease; display: flex; flex-direction: column;">
                        <div class="image-box" style="position: relative; height: 210px; background: #1a1a1a; display: flex; align-items: center; justify-content: center; overflow: hidden;">
                            <img src="${pageContext.request.contextPath}/${bike.bikeImageUrl}" alt="${bike.bikeName}" style="width: 100%; height: 100%; object-fit: cover; transition: transform 0.5s ease;">
                            <span class="cc-badge" style="position: absolute; top: 15px; right: 15px; background: rgba(0,0,0,0.75); border: 1px solid var(--primary-color); color: #fff; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 700; letter-spacing: 0.5px;">
                                ${bike.cc} cc
                            </span>
                        </div>
                        <div class="info-body" style="padding: 25px; flex-grow: 1; display: flex; flex-direction: column; justify-content: space-between;">
                            <div>
                                <span class="brand-tag" style="color: var(--primary-color); font-weight: 700; font-size: 0.8rem; text-transform: uppercase; letter-spacing: 1.5px; display: block; margin-bottom: 5px;">
                                    ${bike.brandName}
                                </span>
                                <h3 style="font-family: 'Outfit', sans-serif; font-size: 1.5rem; font-weight: 700; color: #fff; margin-bottom: 12px; letter-spacing: -0.3px;">
                                    ${bike.bikeName}
                                </h3>
                                <p style="color: #888; font-size: 0.9rem; line-height: 1.6; margin-bottom: 20px; min-height: 48px;">
                                    ${bike.description}
                                </p>
                            </div>
                            
                            <!-- 제원 안내 (배기량, 색상, 모델연식) -->
                            <div class="spec-table" style="border-top: 1px solid #222; padding-top: 15px;">
                                <div style="display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 0.85rem;">
                                    <span style="color: #666;">제조사</span>
                                    <span style="color: #ddd; font-weight: 600;">${bike.brandName}</span>
                                </div>
                                <div style="display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 0.85rem;">
                                    <span style="color: #666;">배기량</span>
                                    <span style="color: #ddd; font-weight: 600;">${bike.cc}cc</span>
                                </div>
                                <div style="display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 0.85rem;">
                                    <span style="color: #666;">모델 연식</span>
                                    <span style="color: #ddd; font-weight: 600;">${bike.year}년식</span>
                                </div>
                                <div style="display: flex; justify-content: space-between; font-size: 0.85rem;">
                                    <span style="color: #666;">시그니처 컬러</span>
                                    <span style="color: #ddd; font-weight: 600;">${bike.color}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </section>

<style>
    .info-card:hover {
        border-color: var(--primary-color) !important;
        transform: translateY(-5px);
        box-shadow: 0 10px 25px rgba(229, 9, 20, 0.15);
    }
    .info-card:hover .image-box img {
        transform: scale(1.05);
    }
</style>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
