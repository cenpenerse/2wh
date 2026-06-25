<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bike.css">

    <section class="content-section">
        <div class="board-container max-width" style="padding-top: 30px;">
            <div class="board-header" style="margin-bottom: 45px; text-align: center;">
                <span style="color: var(--primary-color); font-weight: 700; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 2px;">Premium Accessories</span>
                <h2 style="font-family: 'Outfit', sans-serif; font-size: 2.5rem; font-weight: 800; color: #fff; margin-top: 10px; margin-bottom: 12px; letter-spacing: -0.5px;">대여 장비 안내</h2>
                <p style="color: var(--light-text-color); font-size: 1.05rem;">안전하고 즐거운 라이딩을 위해 마련된 바렌의 프리미엄 추가 장비 라인업입니다.</p>
                <div style="margin-top: 20px;">
                    <a href="${pageContext.request.contextPath}/bike/bikeList.do" class="btn" style="background: linear-gradient(135deg, var(--primary-color) 0%, #FF5E62 100%); border: none; padding: 10px 25px; font-weight: 600; text-transform: uppercase; box-shadow: 0 4px 15px rgba(229, 9, 20, 0.4);">장비 선택하고 바이크 예약하기 </a>
                </div>
            </div>

            <!-- 대여 장비 카드 그리드 -->
            <div class="gear-info-grid">
                <c:forEach var="opt" items="${gearList}">
                    <!-- 카테고리에 맞는 카드 ID 및 이미지 매핑 -->
                    <c:set var="cardId" value="" />
                    <c:set var="gearSpec" value="" />
                    <c:choose>
                        <c:when test="${fn:contains(opt.optionName, '헬멧')}">
                            <c:set var="cardId" value="helmet" />
                            <c:set var="gearSpec" value="안전 규격 인증 완료 | 김서림 방지 실드 제공 | 위생 세척 및 소독 완료" />
                        </c:when>
                        <c:when test="${fn:contains(opt.optionName, '인터콤')}">
                            <c:set var="cardId" value="intercom" />
                            <c:set var="gearSpec" value="블루투스 5.0 탑재 | 최대 1.2km 무선 통신 | 노이즈 캔슬링 마이크 | 하만카돈 스피커" />
                        </c:when>
                        <c:when test="${fn:contains(opt.optionName, '탑박스')}">
                            <c:set var="cardId" value="topbox" />
                            <c:set var="gearSpec" value="용량 45L / 65L 선택 가능 | 완전 방수 설계 | 알루미늄 하드쉘 보호 구조" />
                        </c:when>
                        <c:when test="${fn:contains(opt.optionName, '거치대')}">
                            <c:set var="cardId" value="holder" />
                            <c:set var="gearSpec" value="초강력 네오디뮴 자석 장착 | 고속 무선 충전 케이블 내장 | 이중 안전 잠금 고리" />
                        </c:when>
                        <c:when test="${fn:contains(opt.optionName, '보호대')}">
                            <c:set var="cardId" value="protector" />
                            <c:set var="gearSpec" value="CE 레벨 2 안전 패드 내장 | 통풍 메시 재질 | 벨크로 밴딩 조절 방식" />
                        </c:when>
                        <c:when test="${fn:contains(opt.optionName, '장갑')}">
                            <c:set var="cardId" value="gloves" />
                            <c:set var="gearSpec" value="천연 가죽 및 고강도 매쉬 | 카본 너클 관절 보호대 | 스마트폰 터치 원단 지원" />
                        </c:when>
                        <c:when test="${fn:contains(opt.optionName, '재킷')}">
                            <c:set var="cardId" value="jacket" />
                            <c:set var="gearSpec" value="CE 인증 어깨/팔꿈치 보호 패드 기본 장착 | 탈부착식 방풍 내피 | 고휘도 반사 스카치" />
                        </c:when>
                        <c:when test="${fn:contains(opt.optionName, '팬츠')}">
                            <c:set var="cardId" value="pants" />
                            <c:set var="gearSpec" value="CE 인증 무릎/골반 보호대 기본 장착 | 고강도 케블라 안감 보강 | 사방 스트레치 데님" />
                        </c:when>
                    </c:choose>
                    
                    <!-- 개별 장비 정보 카드 (오토바이 카드와 동일 사이즈 및 그리드 구조) -->
                    <div id="${cardId}" class="info-card" style="scroll-margin-top: 100px;">
                        <div class="image-box">
                            <img src="${pageContext.request.contextPath}/resources/images/gears/${opt.imageFilename}" alt="${opt.optionName}">
                            <span class="cc-badge" style="background: rgba(16, 185, 129, 0.15); color: var(--success-color); border: 1px solid rgba(16, 185, 129, 0.3); font-weight: 700;">
                                재고 ${opt.stockQuantity}개
                            </span>
                        </div>
                        <div class="info-body">
                            <div>
                                <span class="brand-tag">
                                    Premium Gear
                                </span>
                                <h3>
                                    ${opt.optionName}
                                </h3>
                                <p style="min-height: 80px; margin-bottom: 15px;">
                                    <c:choose>
                                        <c:when test="${fn:contains(opt.optionName, '헬멧')}">
                                            안전성이 철저하게 입증된 프리미엄 HJC 헬멧으로, 장거리 고속 투어 및 시티 라이딩 시 라이더의 머리를 보호합니다. 사용 전 완벽한 살균 및 소독 청결 처리를 보장합니다.
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
                                        <c:when test="${fn:contains(opt.optionName, '장갑')}">
                                            넘어짐 시 손을 보호하고 스로틀 및 그립 조작의 그립력을 대폭 향상해 주는 고기능성 메쉬 가죽 장갑입니다. 엄지와 검지에 전도성 패치가 있어 착용한 상태로 터치가 가능합니다.
                                        </c:when>
                                        <c:when test="${fn:contains(opt.optionName, '재킷')}">
                                            어깨, 팔꿈치 보호 패드 기본 내장 및 내마모성이 뛰어난 코듀라 원단으로 제작된 사계절용 라이딩 재킷입니다. 방풍/방수 기능과 통기 벤틸레이션 지퍼가 설계되어 있습니다.
                                        </c:when>
                                        <c:when test="${fn:contains(opt.optionName, '팬츠')}">
                                            골반 및 무릎 보호대가 기본 포함된 고기능성 라이딩 진입니다. 고강도 아라미드 케블라 보강재 라이닝으로 마찰 내마모성을 극대화하여 슬립 시 라이더 하체를 안전하게 보호합니다.
                                        </c:when>
                                        <c:otherwise>
                                            라이더의 안전과 편안한 주행 환경을 보장하기 위해 세심하게 선별되고 정밀하게 관리되는 프리미엄 라이딩 장비입니다.
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                            
                            <!-- 제원 안내 (대여료, 특징) -->
                            <div class="spec-table" style="border-top: 1px solid var(--border-color); padding-top: 15px; margin-top: auto;">
                                <div style="display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 0.85rem;">
                                    <span style="color: #888;">1일 대여료</span>
                                    <strong style="color: var(--primary-color); font-weight: 700;">₩<fmt:formatNumber value="${opt.dailyPrice}" pattern="#,###"/></strong>
                                </div>
                                <div style="display: flex; justify-content: space-between; font-size: 0.85rem;">
                                    <span style="color: #888;">기능/특징</span>
                                    <span style="color: #ddd; font-weight: 600; font-size: 0.75rem; text-align: right; max-width: 70%; word-break: keep-all;">${gearSpec}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </section>

<style>
    .gear-info-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
        gap: 24px;
    }
    
    .info-card {
        background: var(--card-bg);
        border: 1px solid var(--border-color);
        border-radius: 16px;
        overflow: hidden;
        transition: all 0.3s ease;
        display: flex;
        flex-direction: column;
    }
    
    .info-card:hover {
        border-color: var(--primary-color) !important;
        transform: translateY(-5px);
        box-shadow: 0 10px 25px rgba(229, 9, 20, 0.15);
    }
    
    .info-card .image-box {
        position: relative;
        height: 180px;
        background: var(--light-gray-bg);
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
    }
    
    .info-card .image-box img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.5s ease;
    }
    
    .info-card:hover .image-box img {
        transform: scale(1.05);
    }
    
    .info-card .cc-badge {
        position: absolute;
        top: 15px;
        right: 15px;
        background: rgba(0,0,0,0.75);
        border: 1px solid var(--primary-color);
        color: #fff;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 0.75rem;
        font-weight: 700;
        letter-spacing: 0.5px;
        z-index: 2;
    }
    
    .info-card .info-body {
        padding: 20px;
        flex-grow: 1;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
    }
    
    .info-card .brand-tag {
        color: var(--primary-color);
        font-weight: 700;
        font-size: 0.8rem;
        text-transform: uppercase;
        letter-spacing: 1.5px;
        display: block;
        margin-bottom: 5px;
    }
    
    .info-card h3 {
        font-family: 'Outfit', sans-serif;
        font-size: 1.3rem;
        font-weight: 700;
        color: #fff;
        margin-bottom: 8px;
        letter-spacing: -0.3px;
    }
    
    .info-card p {
        color: #888;
        font-size: 0.85rem;
        line-height: 1.5;
        margin-bottom: 15px;
        min-height: 48px;
    }
</style>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
