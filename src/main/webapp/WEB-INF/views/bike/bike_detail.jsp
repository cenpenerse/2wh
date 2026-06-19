<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<c:if test="${not empty errorMessage}">
    <script>
        alert("${errorMessage}");
    </script>
</c:if>

<!-- Flatpickr (달력 라이브러리) CDN -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/dark.css">
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://npmcdn.com/flatpickr/dist/l10n/ko.js"></script>

<section class="content-section">
    <div class="profile-container max-width">
        <!-- 상단 요약 정보 카드 -->
        <div class="profile-header">
            <div class="profile-image">
                <img src="${pageContext.request.contextPath}/${bike.bikeImageUrl}" alt="${bike.bikeName}">
            </div>
            <div class="profile-summary">
                <span class="bike-category">${bike.brandName} | ${bike.cc}cc</span>
                <h1>${bike.bikeName}</h1>
                <p class="location">${bike.shopName}</p>
                <p class="price">
                    <strong>₩<fmt:formatNumber value="${bike.dailyPrice}" pattern="#,###"/></strong> / 일
                </p>
                <div class="rating">
                    <span class="stars">★</span> <strong>${bike.ratingAvg}</strong> (${bike.reviewCount} 리뷰)
                </div>
                
                <!-- 예약 버튼 분기 -->
                <c:choose>
                    <c:when test="${not empty sessionScope.loginUser}">
                        <c:choose>
                            <c:when test="${bike.status eq 'AVAILABLE'}">
                                <button class="btn btn-action-main" onclick="openBookingModal()">실시간 예약하기</button>
                            </c:when>
                            <c:when test="${bike.status eq 'RENTED'}">
                                <button class="btn btn-disabled" disabled style="background: #e50914; color: #fff; cursor: not-allowed; opacity: 0.6;">대여 불가 (대여 중)</button>
                            </c:when>
                            <c:otherwise>
                                <button class="btn btn-disabled" disabled style="background: #555; cursor: not-allowed;">대여 불가 (정비 중)</button>
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                    <c:otherwise>
                        <button class="btn btn-action-main" onclick="alert('대여 서비스를 이용하시려면 로그인이 필요합니다.'); location.href='${pageContext.request.contextPath}/login.do';">로그인 후 예약</button>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- 하단 메인 설명 및 스펙 -->
        <div class="profile-main">
            <div class="profile-left">
                <div class="profile-section">
                    <h2>바이크 상세 사양</h2>
                    <table class="spec-table" style="width: 100%; border-collapse: collapse; margin-bottom: 25px; color: #ddd;">
                        <tr style="border-bottom: 1px solid #333;">
                            <td style="padding: 12px 10px; font-weight: bold; width: 150px; color: #aaa;">제조사 / 생산국</td>
                            <td style="padding: 12px 10px; color: #fff;">${bike.brandName} (${bike.brandCountry})</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #333;">
                            <td style="padding: 12px 10px; font-weight: bold; color: #aaa;">모델명 / 연식</td>
                            <td style="padding: 12px 10px; color: #fff;">${bike.bikeName} (${bike.year}년식)</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #333;">
                            <td style="padding: 12px 10px; font-weight: bold; color: #aaa;">배기량 / 컬러</td>
                            <td style="padding: 12px 10px; color: #fff;">${bike.cc} cc / ${bike.color}</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #333;">
                            <td style="padding: 12px 10px; font-weight: bold; color: #aaa;">누적 주행거리</td>
                            <td style="padding: 12px 10px; color: #fff;"><fmt:formatNumber value="${bike.mileage}" pattern="#,###"/> km</td>
                        </tr>
                        <tr style="border-bottom: 1px solid #333;">
                            <td style="padding: 12px 10px; font-weight: bold; color: #aaa;">대여 가능 지점</td>
                            <td style="padding: 12px 10px; color: #fff;">대구 전 지점 대여 가능 (예약 시 지점 선택 가능)</td>
                        </tr>
                    </table>
                    
                    <h2>차량 상세 설명</h2>
                    <div class="bike-description-box" style="white-space: pre-wrap; line-height: 1.8; color: #bbb; background: #222; padding: 20px; border-radius: 8px;">${bike.description}</div>
                </div>
                
                <div class="profile-section">
                    <h2>이용 안전 가이드</h2>
                    <ul class="guide-list" style="line-height: 2.0; padding-left: 20px; color: #ccc;">
                        <li><strong>보호 장구 필수 착용</strong>: 대여 지점에서 인증 헬멧을 수령하여 반드시 착용해 주세요.</li>
                        <li><strong>운전면허 확인</strong>: 오토바이 배기량에 맞는 유효한 원동기장치자전거면허 또는 2종소형면허가 필요합니다.</li>
                        <li><strong>신호 및 속도 준수</strong>: 도로교통법을 철저히 준수하여 과속 및 신호위반을 삼가세요.</li>
                        <li><strong>대여 시간 엄수</strong>: 연장을 원할 경우 반납 시간 1시간 전 고객센터 또는 지점에 사전 연락이 필요합니다.</li>
                    </ul>
                </div>
            </div>
            
            <div class="profile-right">
                <div class="profile-section spec-card" style="background: #1e1e1e; border: 1px solid #333; padding: 20px; border-radius: 8px;">
                    <h3>Baren 서비스 보장</h3>
                    <div class="spec-item" style="margin: 15px 0; display: flex; justify-content: space-between;">
                        <span class="label" style="color: #aaa;">정비 점검</span>
                        <span class="val" style="color: #fff; font-weight: bold;">정비사 전담 안전 진단</span>
                    </div>
                    <div class="spec-item" style="margin: 15px 0; display: flex; justify-content: space-between;">
                        <span class="label" style="color: #aaa;">안전 장비</span>
                        <span class="val" style="color: #fff; font-weight: bold;">프리미엄 헬멧 제공</span>
                    </div>
                    <div class="spec-item" style="margin: 15px 0; display: flex; justify-content: space-between;">
                        <span class="label" style="color: #aaa;">비상 긴급케어</span>
                        <span class="val" style="color: #fff; font-weight: bold;">24시간 사고 출동 접수</span>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- 리뷰 목록 섹션 (reviews 테이블 연동) -->
        <div class="profile-main" style="margin-top: 50px; border-top: 1px solid #222; padding-top: 40px; display: block; width: 100%;">
            <h2 style="font-family: 'Outfit'; margin-bottom: 25px; display: flex; align-items: center; justify-content: space-between;">
                <span>실제 이용 고객 리뷰 (${bike.reviewCount}개)</span>
                <span style="font-size: 1.1rem; color: #aaa;">평점 평균: <span style="color: var(--accent-color);">★</span> ${bike.ratingAvg} / 5.0</span>
            </h2>
            
            <div style="display: flex; flex-direction: column; gap: 20px;">
                <c:choose>
                    <c:when test="${not empty reviewList}">
                        <c:forEach var="rev" items="${reviewList}">
                            <div style="background: #121212; border: 1px solid #222; padding: 25px; border-radius: 8px; position: relative;">
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px;">
                                    <div>
                                        <span style="color: var(--accent-color); font-size: 1.1rem;">
                                            <c:forEach begin="1" end="${rev.rating}">★</c:forEach><c:forEach begin="${rev.rating + 1}" end="5">☆</c:forEach>
                                        </span>
                                        <h4 style="margin-top: 5px; font-size: 1.15rem; color: #fff;">${rev.title}</h4>
                                    </div>
                                    <span style="font-size: 0.85rem; color: #777;">
                                        작성자: <strong>${rev.userNickname}</strong> | <fmt:formatDate value="${rev.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                                    </span>
                                </div>
                                <p style="color: #ccc; line-height: 1.6; white-space: pre-wrap;">${rev.content}</p>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div style="text-align: center; padding: 50px; background: #121212; border: 1px solid #222; border-radius: 8px; color: #888;">
                            아직 작성된 이용 후기 리뷰가 없습니다. 이 바이크의 첫 번째 리뷰어가 되어 보세요!
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</section>

<!-- 예약 신청 모달 -->
<style>
    /* Force booking modal to be wide (1000px) */
    #booking-modal .modal-content {
        max-width: 1000px !important;
        width: 95% !important;
    }

    /* Prevent checkbox and radio buttons from stretching inside form groups */
    #booking-form input[type="checkbox"], 
    #booking-form input[type="radio"] {
        width: 18px !important;
        height: 18px !important;
        padding: 0 !important;
        margin: 0 !important;
        flex-shrink: 0 !important;
        cursor: pointer;
    }
    
    @media (min-width: 768px) {
        .booking-grid {
            display: grid !important;
            grid-template-columns: 1fr 1fr !important;
            gap: 24px !important;
        }
    }
</style>

<div id="booking-modal" class="modal-overlay" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.8); z-index: 1000; align-items: center; justify-content: center;">
    <div class="modal-content" style="background: #1a1a1a; border: 1px solid #333; padding: 30px; border-radius: 12px; max-width: 1000px; width: 95%; max-height: 90vh; overflow-y: auto; color: #fff; position: relative;">
        <span class="close-btn" onclick="closeBookingModal()" style="position: absolute; top: 15px; right: 20px; font-size: 2rem; cursor: pointer; color: #aaa;">&times;</span>
        <h2 style="color: var(--primary-color); margin-bottom: 10px; font-family: 'Outfit';">바이크 대여 예약 신청</h2>
        <p class="modal-intro" style="color: #bbb; margin-bottom: 20px;"><strong>${bike.brandName} - ${bike.bikeName}</strong> 예약을 진행합니다.</p>
        
        <form id="booking-form" action="${pageContext.request.contextPath}/bookingAction.do" method="post" onsubmit="return validateBooking()">
            <input type="hidden" name="bikeId" value="${bike.bikeId}">
            <input type="hidden" id="daily-price" value="${bike.dailyPrice}">
            <input type="hidden" id="start-date" name="start_date" required>
            <input type="hidden" id="end-date" name="end_date" required>
            <input type="hidden" id="rental-days" name="rental_days" required>
            <input type="hidden" id="total-price" name="total_price" required>
            
            <div class="booking-grid" style="display: flex; flex-direction: column; gap: 20px; margin-bottom: 20px;">
                <!-- Left Column -->
                <div class="booking-col-left" style="display: flex; flex-direction: column; gap: 15px;">
                    <div class="form-group" style="margin-bottom: 0;">
                        <label style="display: block; margin-bottom: 5px; color: #ccc;">대여 기간 선택</label>
                        <input type="text" id="rental-date-range" placeholder="시작일과 종료일을 선택하세요" style="width: 100%; padding: 12px; border-radius: 6px; border: 1px solid #444; background: #2a2a2a; color: #fff;" required>
                    </div>

                    <!-- 인수 및 반납 지점 선택 -->
                    <div style="display: flex; gap: 10px;">
                        <div style="flex: 1;">
                            <label style="display: block; margin-bottom: 5px; color: #ccc;">인수 지점 선택</label>
                            <select name="pickupShopId" style="width: 100%; padding: 12px; border-radius: 6px; border: 1px solid #444; background: #2a2a2a; color: #fff;" required>
                                <c:forEach var="shop" items="${shopList}">
                                    <option value="${shop.shopId}" ${shop.shopId == selectedShopId or (empty selectedShopId and shop.shopId == bike.shopId) ? 'selected' : ''}>${shop.shopName}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div style="flex: 1;">
                            <label style="display: block; margin-bottom: 5px; color: #ccc;">반납 지점 선택</label>
                            <select name="dropoffShopId" style="width: 100%; padding: 12px; border-radius: 6px; border: 1px solid #444; background: #2a2a2a; color: #fff;" required>
                                <c:forEach var="shop" items="${shopList}">
                                    <option value="${shop.shopId}" ${shop.shopId == selectedShopId or (empty selectedShopId and shop.shopId == bike.shopId) ? 'selected' : ''}>${shop.shopName}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <!-- 할인 쿠폰 선택 -->
                    <div class="form-group" style="margin-bottom: 0;">
                        <label style="display: block; margin-bottom: 5px; color: #ccc;">적용 가능 쿠폰</label>
                        <select id="coupon-selector" name="couponId" style="width: 100%; padding: 12px; border-radius: 6px; border: 1px solid #444; background: #2a2a2a; color: #fff;" onchange="updateCalculations()">
                            <option value="none" data-discount="0">--- 적용할 쿠폰 선택 (할인 없음) ---</option>
                            <c:forEach var="cp" items="${couponList}">
                                <option value="${cp.couponId}" data-discount="${cp.discountAmount}">${cp.couponName} (-₩<fmt:formatNumber value="${cp.discountAmount}" pattern="#,###"/>)</option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- 포인트 사용 -->
                    <c:if test="${not empty sessionScope.loginUser}">
                        <div class="form-group" style="margin-bottom: 0;">
                            <label style="display: block; margin-bottom: 5px; color: #ccc;">포인트 사용 (보유: <fmt:formatNumber value="${sessionScope.loginUser.point}" pattern="#,###"/> P)</label>
                            <div style="display: flex; gap: 10px;">
                                <input type="number" id="use-points-input" name="usePoints" min="0" max="${sessionScope.loginUser.point}" value="0" style="flex: 1; padding: 12px; border-radius: 6px; border: 1px solid #444; background: #2a2a2a; color: #fff;" oninput="updateCalculations()">
                                <button type="button" onclick="useAllPoints()" style="padding: 0 15px; background: #333; border: 1px solid #444; border-radius: 6px; color: #fff; cursor: pointer;">전액 사용</button>
                            </div>
                        </div>
                    </c:if>

                    <!-- 결제 수단 선택 -->
                    <div class="form-group" style="margin-bottom: 0;">
                        <label style="display: block; margin-bottom: 8px; color: #ccc;">결제 수단</label>
                        <div class="payment-options-grid" style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 10px;">
                            <label class="pay-method-card">
                                <input type="radio" name="payment_method" value="CARD" checked>
                                <span class="pay-box">신용카드</span>
                            </label>
                            <label class="pay-method-card">
                                <input type="radio" name="payment_method" value="KAKAO">
                                <span class="pay-box">카카오페이</span>
                            </label>
                            <label class="pay-method-card">
                                <input type="radio" name="payment_method" value="NAVER">
                                <span class="pay-box">네이버페이</span>
                            </label>
                        </div>
                    </div>
                </div>

                <!-- Right Column -->
                <div class="booking-col-right" style="display: flex; flex-direction: column; gap: 15px;">
                    <!-- 추가 옵션 장비 선택 -->
                    <div class="form-group" style="margin-bottom: 0;">
                        <label style="display: block; margin-bottom: 8px; color: #ccc;">추가 옵션 장비 (다중 선택 가능)</label>
                        <div style="display: flex; flex-direction: column; gap: 8px; background: #222; padding: 12px; border-radius: 6px; max-height: 200px; overflow-y: auto;">
                            <c:forEach var="opt" items="${optionList}">
                                <div style="display: flex; align-items: center; justify-content: space-between; padding: 2px 0;">
                                    <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; color: #ddd; width: 100%;">
                                        <input type="checkbox" name="optionId" value="${opt.optionId}" data-price="${opt.dailyPrice}" onchange="updateCalculations()" style="width: 18px !important; height: 18px !important; padding: 0 !important; margin: 0 !important; accent-color: var(--primary-color); flex-shrink: 0; cursor: pointer;">
                                        <span style="font-size:0.9rem;">${opt.optionName} <span style="font-size:0.8rem; color:#aaa;">(+₩<fmt:formatNumber value="${opt.dailyPrice}" pattern="#,###"/>/일)</span></span>
                                    </label>
                                    <div style="display: flex; align-items: center; gap: 5px; flex-shrink: 0;">
                                        <span style="font-size:0.8rem; color:#888;">수량:</span>
                                        <input type="number" name="quantity_${opt.optionId}" value="1" min="1" max="5" onchange="updateCalculations()" style="width: 50px; padding: 4px; border-radius: 4px; border: 1px solid #444; background: #333; color: #fff; text-align: center;">
                                     </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- 보험 상품 선택 -->
                    <div class="form-group" style="margin-bottom: 0;">
                        <label style="display: block; margin-bottom: 8px; color: #ccc;">보험 상품 선택 (필수)</label>
                        <div style="display: flex; flex-direction: column; gap: 8px; background: #222; padding: 12px; border-radius: 6px;">
                            <c:forEach var="ins" items="${insuranceList}" varStatus="status">
                                <label style="display: flex; align-items: flex-start; gap: 10px; cursor: pointer; color: #ddd; padding: 6px 0; border-bottom: 1px solid #333;">
                                     <input type="radio" name="insuranceId" value="${ins.planId}" data-fee="${ins.dailyFee}" onchange="updateCalculations()" style="width: 18px !important; height: 18px !important; padding: 0 !important; margin: 0 !important; margin-top: 4px; cursor: pointer; accent-color: var(--primary-color); flex-shrink: 0;" ${status.first ? 'checked' : ''} required>
                                    <div style="flex: 1;">
                                        <div style="display: flex; justify-content: space-between; font-weight: bold; color: #fff;">
                                            <span>${ins.planName}</span>
                                            <span style="color: var(--primary-color);">+₩<fmt:formatNumber value="${ins.dailyFee}" pattern="#,###"/>/일</span>
                                        </div>
                                        <div style="font-size: 0.8rem; color: #aaa; margin-top: 4px;">
                                            면책금 한도: ₩<fmt:formatNumber value="${ins.deductibleLimit}" pattern="#,###"/> | 보상 한도액: ₩<fmt:formatNumber value="${ins.coverageLimit}" pattern="#,###"/>
                                        </div>
                                        <div style="font-size: 0.75rem; color: #888; margin-top: 2px;">
                                            ${ins.termsContent}
                                        </div>
                                    </div>
                                </label>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- 금액 확인 요약 -->
                    <div class="price-summary-box" style="background: #252525; padding: 15px; border-radius: 8px; margin-bottom: 0;">
                        <div class="summary-row" style="display: flex; justify-content: space-between; margin-bottom: 8px; color: #aaa;">
                            <span>일 대여 요금</span>
                            <span>₩<fmt:formatNumber value="${bike.dailyPrice}" pattern="#,###"/></span>
                        </div>
                        <div class="summary-row" style="display: flex; justify-content: space-between; margin-bottom: 8px; color: #aaa;">
                            <span>총 대여 기간</span>
                            <span id="display-days">0 일</span>
                        </div>
                        <div class="summary-row" id="summary-insurance-row" style="display: none; justify-content: space-between; margin-bottom: 8px; color: #aaa;">
                            <span>보험료 합계</span>
                            <span id="display-insurance-price">₩0</span>
                        </div>
                        <div class="summary-row" id="summary-grade-row" style="display: none; justify-content: space-between; margin-bottom: 8px; color: #e0a82e;">
                            <span>등급 할인 혜택 (${not empty sessionScope.loginUser ? sessionScope.loginUser.userGrade : ''})</span>
                            <span id="display-grade-discount">-₩0</span>
                        </div>
                        <div class="summary-row" id="summary-discount-row" style="display: none; justify-content: space-between; margin-bottom: 8px; color: #E50914;">
                            <span>쿠폰 할인 혜택</span>
                            <span id="display-discount-price">-₩0</span>
                        </div>
                        <div class="summary-row" id="summary-points-row" style="display: none; justify-content: space-between; margin-bottom: 8px; color: #5bc0de;">
                            <span>포인트 사용</span>
                            <span id="display-points-discount">-₩0</span>
                        </div>
                        <hr style="border: 0; border-top: 1px solid #444; margin: 10px 0;">
                        <div class="summary-row total-row" style="display: flex; justify-content: space-between; font-weight: bold; color: var(--primary-color); font-size: 1.2rem;">
                            <span>최종 결제 금액</span>
                            <span id="display-total-price">₩0</span>
                        </div>
                    </div>
                </div>
            </div>

            <button type="submit" class="btn btn-booking-submit" style="width: 100%; padding: 12px; background: var(--primary-color); border: none; border-radius: 6px; color: #fff; font-weight: bold; cursor: pointer;">결제 및 예약 신청</button>
        </form>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script>
    function openBookingModal() {
        document.getElementById('booking-modal').style.display = 'flex';
    }
    
    function closeBookingModal() {
        document.getElementById('booking-modal').style.display = 'none';
    }
    
    function validateBooking() {
        let startDate = document.getElementById('start-date').value;
        let endDate = document.getElementById('end-date').value;
        if (!startDate || !endDate) {
            alert("대여 기간을 정확하게 선택해 주세요.");
            return false;
        }
        return true;
    }

    document.addEventListener('DOMContentLoaded', function() {
        let dailyPrice = parseInt(document.getElementById('daily-price').value);
        let diffDaysGlobal = 0;
        let userGrade = "${not empty sessionScope.loginUser ? sessionScope.loginUser.userGrade : ''}";
        let maxUserPoints = parseInt("${not empty sessionScope.loginUser ? sessionScope.loginUser.point : 0}");

        window.updateCalculations = function() {
            if (diffDaysGlobal <= 0) return;
            
            // 1. 기본 대여 비용 계산
            let baseSubtotal = diffDaysGlobal * dailyPrice;
            
            // 2. 보험 비용 계산
            let insuranceSubtotal = 0;
            let checkedInsurance = document.querySelector('input[name="insuranceId"]:checked');
            if (checkedInsurance) {
                let insFee = parseInt(checkedInsurance.getAttribute('data-fee')) || 0;
                insuranceSubtotal = insFee * diffDaysGlobal;
            }
            
            // 3. 추가 옵션 장비 비용 합산
            let optionsSubtotal = 0;
            let checkedOptions = document.querySelectorAll('input[name="optionId"]:checked');
            checkedOptions.forEach(function(cb) {
                let optId = cb.value;
                let optPrice = parseInt(cb.getAttribute('data-price')) || 0;
                let qtyInput = document.querySelector('input[name="quantity_' + optId + '"]');
                let qty = qtyInput ? (parseInt(qtyInput.value) || 1) : 1;
                optionsSubtotal += (optPrice * qty) * diffDaysGlobal;
            });
            
            let subtotal = baseSubtotal + insuranceSubtotal + optionsSubtotal;
            
            // 4. 등급 할인 계산 (대여료 기준)
            let gradeDiscountRate = 0.0;
            if (userGrade === 'GOLD') gradeDiscountRate = 0.05;
            else if (userGrade === 'VIP') gradeDiscountRate = 0.10;
            let gradeDiscount = Math.floor(baseSubtotal * gradeDiscountRate);
            
            // 5. 쿠폰 할인 적용
            let couponSelector = document.getElementById('coupon-selector');
            let discount = 0;
            if (couponSelector) {
                let selectedOption = couponSelector.options[couponSelector.selectedIndex];
                discount = parseInt(selectedOption.getAttribute('data-discount')) || 0;
            }
            
            // 6. 포인트 할인 적용
            let usePointsInput = document.getElementById('use-points-input');
            let usePoints = 0;
            if (usePointsInput) {
                usePoints = parseInt(usePointsInput.value) || 0;
                if (usePoints < 0) usePoints = 0;
                if (usePoints > maxUserPoints) {
                    usePoints = maxUserPoints;
                    usePointsInput.value = usePoints;
                }
                
                let currentSub = subtotal - gradeDiscount - discount;
                if (currentSub < 0) currentSub = 0;
                if (usePoints > currentSub) {
                    usePoints = currentSub;
                    usePointsInput.value = usePoints;
                }
            }
            
            let totalPrice = subtotal - gradeDiscount - discount - usePoints;
            if (totalPrice < 0) totalPrice = 0;

            document.getElementById('total-price').value = totalPrice;
            document.getElementById('display-total-price').innerText = "₩" + totalPrice.toLocaleString();

            // UI 표시 업데이트
            let insRow = document.getElementById('summary-insurance-row');
            if (insRow) {
                if (insuranceSubtotal > 0) {
                    insRow.style.display = 'flex';
                    document.getElementById('display-insurance-price').innerText = "₩" + insuranceSubtotal.toLocaleString();
                } else {
                    insRow.style.display = 'none';
                }
            }
            
            let gradeRow = document.getElementById('summary-grade-row');
            if (gradeRow) {
                if (gradeDiscount > 0) {
                    gradeRow.style.display = 'flex';
                    document.getElementById('display-grade-discount').innerText = "-₩" + gradeDiscount.toLocaleString();
                } else {
                    gradeRow.style.display = 'none';
                }
            }

            let discountRow = document.getElementById('summary-discount-row');
            if (discountRow) {
                if (discount > 0) {
                    discountRow.style.display = 'flex';
                    document.getElementById('display-discount-price').innerText = "-₩" + discount.toLocaleString();
                } else {
                    discountRow.style.display = 'none';
                }
            }
            
            let pointsRow = document.getElementById('summary-points-row');
            if (pointsRow) {
                if (usePoints > 0) {
                    pointsRow.style.display = 'flex';
                    document.getElementById('display-points-discount').innerText = "-₩" + usePoints.toLocaleString();
                } else {
                    pointsRow.style.display = 'none';
                }
            }
        };

        window.useAllPoints = function() {
            if (diffDaysGlobal <= 0) {
                alert("대여 기간을 먼저 선택해 주세요.");
                return;
            }
            let baseSubtotal = diffDaysGlobal * dailyPrice;
            let insuranceSubtotal = 0;
            let checkedInsurance = document.querySelector('input[name="insuranceId"]:checked');
            if (checkedInsurance) {
                let insFee = parseInt(checkedInsurance.getAttribute('data-fee')) || 0;
                insuranceSubtotal = insFee * diffDaysGlobal;
            }
            let optionsSubtotal = 0;
            let checkedOptions = document.querySelectorAll('input[name="optionId"]:checked');
            checkedOptions.forEach(function(cb) {
                let optId = cb.value;
                let optPrice = parseInt(cb.getAttribute('data-price')) || 0;
                let qtyInput = document.querySelector('input[name="quantity_' + optId + '"]');
                let qty = qtyInput ? (parseInt(qtyInput.value) || 1) : 1;
                optionsSubtotal += (optPrice * qty) * diffDaysGlobal;
            });
            let subtotal = baseSubtotal + insuranceSubtotal + optionsSubtotal;
            let gradeDiscountRate = 0.0;
            if (userGrade === 'GOLD') gradeDiscountRate = 0.05;
            else if (userGrade === 'VIP') gradeDiscountRate = 0.10;
            let gradeDiscount = Math.floor(baseSubtotal * gradeDiscountRate);
            
            let couponSelector = document.getElementById('coupon-selector');
            let discount = 0;
            if (couponSelector) {
                let selectedOption = couponSelector.options[couponSelector.selectedIndex];
                discount = parseInt(selectedOption.getAttribute('data-discount')) || 0;
            }
            
            let currentSub = subtotal - gradeDiscount - discount;
            if (currentSub < 0) currentSub = 0;
            
            let usePointsInput = document.getElementById('use-points-input');
            if (usePointsInput) {
                let pointsToUse = Math.min(maxUserPoints, currentSub);
                usePointsInput.value = pointsToUse;
                updateCalculations();
            }
        };
        
        if (typeof flatpickr !== 'undefined') {
            flatpickr("#rental-date-range", {
                locale: "ko",
                mode: "range",
                dateFormat: "Y-m-d",
                minDate: "today",
                onClose: function(selectedDates, dateStr, instance) {
                    if (selectedDates.length === 2) {
                        let start = selectedDates[0];
                        let end = selectedDates[1];
                        
                        let diffTime = Math.abs(end - start);
                        let diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1;
                        
                        let startStr = instance.formatDate(start, "Y-m-d");
                        let endStr = instance.formatDate(end, "Y-m-d");
                        
                        document.getElementById('start-date').value = startStr;
                        document.getElementById('end-date').value = endStr;
                        document.getElementById('rental-days').value = diffDays;
                        
                        diffDaysGlobal = diffDays;
                        document.getElementById('display-days').innerText = diffDays + " 일";
                        
                        updateCalculations();
                    } else {
                        diffDaysGlobal = 0;
                        document.getElementById('start-date').value = "";
                        document.getElementById('end-date').value = "";
                        document.getElementById('rental-days').value = "";
                        document.getElementById('total-price').value = "";
                        document.getElementById('display-days').innerText = "0 일";
                        document.getElementById('display-total-price').innerText = "₩0";
                        
                        let discountRow = document.getElementById('summary-discount-row');
                        if (discountRow) discountRow.style.display = 'none';
                    }
                }
            });
        }
    });
</script>

<style>
    .pay-method-card {
        display: block; 
        cursor: pointer; 
        text-align: center; 
        border: 1px solid #444; 
        padding: 12px; 
        border-radius: 6px; 
        background: #2a2a2a;
        transition: all 0.2s ease;
    }
    .pay-method-card input[type="radio"] {
        display: none;
    }
    .pay-method-card:has(input[type="radio"]:checked) {
        border-color: var(--primary-color) !important;
        background: #333 !important;
        box-shadow: 0 0 0 1px var(--primary-color);
    }
    .flatpickr-calendar {
        background: #1a1a1a !important;
        border: 1px solid #333 !important;
        box-shadow: 0 4px 15px rgba(0,0,0,0.5) !important;
    }
    .flatpickr-calendar .flatpickr-month {
        color: #fff !important;
        fill: #fff !important;
    }
    .flatpickr-calendar .flatpickr-weekday {
        color: #aaa !important;
    }
    .flatpickr-day {
        color: #ddd !important;
    }
    .flatpickr-day.flatpickr-disabled, .flatpickr-day.flatpickr-disabled:hover {
        color: #555 !important;
    }
    .flatpickr-day.selected, .flatpickr-day.startRange, .flatpickr-day.endRange,
    .flatpickr-day.selected.inRange, .flatpickr-day.startRange.inRange, .flatpickr-day.endRange.inRange,
    .flatpickr-day.selected:focus, .flatpickr-day.startRange:focus, .flatpickr-day.endRange:focus,
    .flatpickr-day.selected:hover, .flatpickr-day.startRange:hover, .flatpickr-day.endRange:hover {
        background: var(--primary-color) !important;
        border-color: var(--primary-color) !important;
        color: #fff !important;
    }
    .flatpickr-day.inRange {
        background: rgba(229, 9, 20, 0.15) !important;
        box-shadow: none !important;
    }
</style>