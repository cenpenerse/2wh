<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

    <section class="content-section">
        <div class="board-container max-width" style="padding-top: 30px;">
            <div class="board-header" style="margin-bottom: 45px; text-align: center;">
                <span style="color: var(--primary-color); font-weight: 700; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 2px;">Premium Accessories</span>
                <h2 style="font-family: 'Outfit', sans-serif; font-size: 2.5rem; font-weight: 800; color: #fff; margin-top: 10px; margin-bottom: 12px; letter-spacing: -0.5px;">대여 장비 안내</h2>
                <p style="color: var(--light-text-color); font-size: 1.05rem;">안전하고 즐거운 라이딩을 위해 마련된 바렌의 프리미엄 추가 장비 라인업입니다.</p>
                <div style="margin-top: 20px;">
                    <a href="${pageContext.request.contextPath}/bikeList.do" class="btn" style="background: linear-gradient(135deg, var(--primary-color) 0%, #FF5E62 100%); border: none; padding: 10px 25px; font-weight: 600; text-transform: uppercase; box-shadow: 0 4px 15px rgba(229, 9, 20, 0.4);">장비 선택하고 바이크 예약하기 ⚡</a>
                </div>
            </div>

            <!-- 대여 장비 카드 그리드 -->
            <div class="gear-info-grid" style="display: flex; flex-direction: column; gap: 40px; max-width: 900px; margin: 0 auto;">
                <c:forEach var="opt" items="${gearList}">
                    <!-- 카테고리에 맞는 카드 ID 및 이미지 매핑 -->
                    <c:set var="cardId" value="" />
                    <c:set var="imageUrl" value="" />
                    <c:set var="gearSpec" value="" />
                    <c:choose>
                        <c:when test="${fn:contains(opt.optionName, '헬멧')}">
                            <c:set var="cardId" value="helmet" />
                            <c:set var="imageUrl" value="https://images.unsplash.com/photo-1599819811279-d5ad9cccf838?auto=format&fit=crop&w=800&q=80" />
                            <c:set var="gearSpec" value="안전 규격 인증 완료 | 김서림 방지 실드 제공 | 위생 세척 및 소독 완료" />
                        </c:when>
                        <c:when test="${fn:contains(opt.optionName, '인터콤')}">
                            <c:set var="cardId" value="intercom" />
                            <c:set var="imageUrl" value="https://images.unsplash.com/photo-1608248597481-496100c80836?auto=format&fit=crop&w=800&q=80" />
                            <c:set var="gearSpec" value="블루투스 5.0 탑재 | 최대 1.2km 무선 통신 | 노이즈 캔슬링 마이크 | 하만카돈 스피커" />
                        </c:when>
                        <c:when test="${fn:contains(opt.optionName, '탑박스')}">
                            <c:set var="cardId" value="topbox" />
                            <c:set var="imageUrl" value="https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?auto=format&fit=crop&w=800&q=80" />
                            <c:set var="gearSpec" value="용량 45L / 65L 선택 가능 | 완전 방수 설계 | 알루미늄 하드쉘 보호 구조" />
                        </c:when>
                        <c:when test="${fn:contains(opt.optionName, '거치대')}">
                            <c:set var="cardId" value="holder" />
                            <c:set var="imageUrl" value="https://images.unsplash.com/photo-1586105251261-72a756497a11?auto=format&fit=crop&w=800&q=80" />
                            <c:set var="gearSpec" value="초강력 네오디뮴 자석 장착 | 고속 무선 충전 케이블 내장 | 이중 안전 잠금 고리" />
                        </c:when>
                        <c:when test="${fn:contains(opt.optionName, '보호대')}">
                            <c:set var="cardId" value="protector" />
                            <c:set var="imageUrl" value="https://images.unsplash.com/photo-1541625602330-2277a4c46182?auto=format&fit=crop&w=800&q=80" />
                            <c:set var="gearSpec" value="CE 레벨 2 안전 패드 내장 | 통풍 메시 재질 | 벨크로 밴딩 조절 방식" />
                        </c:when>
                    </c:choose>
                    
                    <!-- 개별 장비 정보 카드 -->
                    <div id="${cardId}" class="gear-card" style="background: #121212; border: 1px solid #222; border-radius: 16px; display: flex; flex-direction: row; gap: 0; overflow: hidden; transition: all 0.3s ease; scroll-margin-top: 100px;">
                        <div class="gear-img-wrapper" style="width: 35%; min-height: 250px; background: #1a1a1a; display: flex; align-items: center; justify-content: center; overflow: hidden; position: relative;">
                            <img src="${imageUrl}" alt="${opt.optionName}" style="width: 100%; height: 100%; object-fit: cover; transition: transform 0.5s ease;">
                            <div style="position: absolute; top: 15px; left: 15px; background: rgba(0,0,0,0.8); border: 1px solid var(--primary-color); padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; color:#fff; font-weight: 600;">
                                Daily Item
                            </div>
                        </div>
                        <div class="gear-info-body" style="width: 65%; padding: 30px; display: flex; flex-direction: column; justify-content: space-between;">
                            <div>
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 15px;">
                                    <h3 style="font-size: 1.45rem; font-weight: 700; color: #fff; margin: 0;">
                                        ${opt.optionName}
                                    </h3>
                                    <div style="text-align: right;">
                                        <span style="font-size: 0.8rem; color: #888; display: block; text-transform: uppercase;">1일 대여료</span>
                                        <strong style="font-size: 1.35rem; color: var(--primary-color); font-family: 'Outfit';">
                                            ₩<fmt:formatNumber value="${opt.dailyPrice}" pattern="#,###"/>
                                        </strong>
                                    </div>
                                </div>
                                
                                <p style="color: #bbb; font-size: 0.95rem; line-height: 1.6; margin-bottom: 20px; min-height: 48px;">
                                    <c:choose>
                                        <c:when test="${fn:contains(opt.optionName, '헬멧')}">
                                            안전성이 철저하게 입증된 프리미엄 HJC 헬멧으로, 장거리 고속 투어 및 시티 라이딩 시 라이더의 머리를 보호합니다. 사용 전 완벽한 자외선 살균 및 소독 청결 처리를 보장합니다.
                                        </c:when>
                                        <c:when test="${fn:contains(opt.optionName, '인터콤')}">
                                            라이딩 중 스마트폰 내비게이션의 음성 안내와 음악 감상을 무손실 오디오로 즐기거나, 동반 라이더와 실시간 음성 통신(메시 통신)이 가능한 고성능 무선 인터콤 장비입니다.
                                        </c:when>
                                        <c:when test="${fn:contains(opt.optionName, '탑박스')}">
                                            카메라 장비나 헬멧, 소지품을 넉넉하고 안전하게 보관할 수 있는 튼튼한 하드쉘 탑박스입니다. 열쇠로 이중 잠금이 가능하며 비가 와도 끄떡없는 방수 씰이 내장되어 있습니다.
                                        </c:when>
                                        <c:when test="${fn:contains(opt.optionName, '거치대')}">
                                            주행 중 스마트폰이 이탈되지 않도록 강하게 고정해 주는 충격 감쇄용 고급 스마트폰 자석 거치대입니다. 고속 주행 시에도 무선 충전을 통해 안정적으로 내비게이션을 볼 수 있습니다.
                                        </c:when>
                                        <c:when test="${fn:contains(opt.optionName, '보호대')}">
                                            기어 조작이나 예기치 못한 전도 상황에서 무릎과 팔꿈치 뼈, 피부를 최적으로 감싸 보호해 주는 라이더 필수 보호 장비 세트입니다. 통기성이 뛰어나 답답하지 않습니다.
                                        </c:when>
                                    </c:choose>
                                </p>
                            </div>
                            
                            <!-- 제원/특징 요약 한 줄 -->
                            <div style="border-top: 1px solid #222; padding-top: 18px; display: flex; justify-content: space-between; align-items: center; font-size: 0.85rem;">
                                <span style="color: #666; font-style: italic;">Spec: ${gearSpec}</span>
                                <span style="color: #10b981; font-weight: 600;">재고 보유량: ${opt.stockQuantity}개</span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </section>

<style>
    .gear-card:hover {
        border-color: var(--primary-color) !important;
        transform: translateY(-3px);
        box-shadow: 0 10px 30px rgba(229, 9, 20, 0.12);
    }
    .gear-card:hover .gear-img-wrapper img {
        transform: scale(1.05);
    }
    
    @media (max-width: 768px) {
        .gear-card {
            flex-direction: column !important;
        }
        .gear-img-wrapper, .gear-info-body {
            width: 100% !important;
        }
    }
</style>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
