<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<style>
    /* 마이페이지 탭 레이아웃 스타일 */
    .mypage-tabs {
        display: flex;
        gap: 8px;
        border-bottom: 2px solid #222;
        margin-bottom: 30px;
        flex-wrap: wrap;
        margin-top: 20px;
    }
    .tab-btn {
        background: transparent;
        border: none;
        color: #9CA3AF;
        padding: 12px 20px;
        font-size: 0.95rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
        border-bottom: 3px solid transparent;
        font-family: 'Outfit', sans-serif;
    }
    .tab-btn:hover {
        color: #fff;
    }
    .tab-btn.active {
        color: var(--primary-color);
        border-bottom-color: var(--primary-color);
    }
    .tab-content {
        display: none;
        animation: fadeIn 0.3s ease-in-out;
    }
    .tab-content.active {
        display: block;
    }
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(5px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    .crud-section-grid {
        display: grid;
        grid-template-columns: 1.2fr 0.8fr;
        gap: 30px;
        margin-top: 15px;
    }
    @media (max-width: 992px) {
        .crud-section-grid {
            grid-template-columns: 1fr;
        }
    }
    
    /* 1:1 문의 아코디언 스타일 */
    .accordion-inquiry {
        background: #121212;
        border: 1px solid #222;
        border-radius: 6px;
        margin-bottom: 12px;
        overflow: hidden;
    }
    .accordion-header {
        padding: 15px 20px;
        cursor: pointer;
        display: flex;
        justify-content: space-between;
        align-items: center;
        background: #181818;
        font-weight: 600;
        transition: background 0.2s ease;
    }
    .accordion-header:hover {
        background: #222;
    }
    .accordion-content {
        padding: 20px;
        border-top: 1px solid #222;
        background: #0d0d0d;
        display: none;
    }
    .inquiry-status {
        padding: 3px 8px;
        border-radius: 4px;
        font-size: 0.75rem;
        font-weight: bold;
    }
    .inquiry-pending {
        background: var(--primary-color);
        color: #fff;
    }
    .inquiry-answered {
        background: #10b981;
        color: #fff;
    }
    
    .panel-form {
        background: #121212;
        border: 1px solid #222;
        padding: 20px;
        border-radius: 8px;
        margin-bottom: 30px;
    }
</style>

<div class="mypage-container max-width">
    <!-- 1. 상단 마이페이지 헤더 정보 -->
    <div class="mypage-profile-card">
        <div class="user-avatar">👤</div>
        <div class="user-details">
            <span class="user-role-badge ${loginUser.memberStatus eq 'ADMIN' ? 'badge-admin' : 'badge-user'}">
                ${loginUser.memberStatus eq 'ADMIN' ? '관리자 계정' : '일반 회원'}
            </span>
            <h2>${loginUser.nickname} 님</h2>
            <p>${loginUser.email}</p>
            <c:if test="${loginUser.memberStatus ne 'ADMIN'}">
                <p style="font-size: 0.9rem; color: #aaa; margin-top: 6px;">
                    면허 번호: ${empty loginUser.licenseNumber ? '미등록' : loginUser.licenseNumber} 
                    <span style="display: inline-block; padding: 2px 8px; border-radius: 4px; font-weight: bold; font-size: 0.75rem; margin-left: 5px; color: #fff;
                        background: ${loginUser.licenseStatus eq 'APPROVED' ? '#10b981' : (loginUser.licenseStatus eq 'REJECTED' ? '#ef4444' : '#f59e0b')};">
                        <c:choose>
                            <c:when test="${loginUser.licenseStatus eq 'APPROVED'}">면허 승인 완료</c:when>
                            <c:when test="${loginUser.licenseStatus eq 'REJECTED'}">면허 승인 반려</c:when>
                            <c:otherwise>면허 승인 대기중</c:otherwise>
                        </c:choose>
                    </span>
                </p>
            </c:if>
        </div>
        <div class="profile-actions">
            <c:if test="${loginUser.memberStatus ne 'ADMIN'}">
                <button class="btn btn-danger-outline" onclick="confirmWithdrawal()">회원 탈퇴</button>
            </c:if>
        </div>
    </div>

    <div class="mypage-tabs">
        <c:choose>
            <c:when test="${loginUser.memberStatus eq 'ADMIN'}">
                <button class="tab-btn active" onclick="openTab(event, 'tab-admin-bookings')">📋 전체 예약 관리</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-members')">👥 가입 회원 목록</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-crud')">🛠️ 바이크/지점/브랜드 관리</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-inquiries')">💬 1:1 문의 답변 관리</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-coupons')">🎫 쿠폰 발급</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-penalties')">💸 패널티 및 벌금 관리</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-license')">🪪 면허 검증 심사</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-maintenance')">🔧 차량 정비 관리</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-fuel')">⛽ 반납/주유 기록</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-payment')">💳 결제 관리</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-notification')">🔔 알림 발송 이력</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-accident')">💥 사고 처리 관리</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-blacklist')">🚫 블랙리스트 관리</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-refund')">💸 환불 내역 관리</button>
            </c:when>
            <c:otherwise>
                <button class="tab-btn active" onclick="openTab(event, 'tab-user-bookings')">🏍️ 내 예약 내역</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-user-coupons')">🎫 쿠폰 보관함</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-user-license')">🪪 면허증 관리</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-user-inquiries')">💬 1:1 문의 내역</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-user-edit')">👤 내 정보 수정</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-user-payment')">💳 내 결제 이력</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-user-notification')">🔔 내 알림함</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-user-point')">🪙 내 포인트/등급</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-user-accident')">💥 사고 접수 내역</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-user-refund')">💸 내 환불 내역</button>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- 3. 각 탭 상세 콘텐츠 -->
    <div class="mypage-content-box" style="border:none; padding:0; background:transparent;">
        <c:choose>
            <c:when test="${loginUser.memberStatus eq 'ADMIN'}">
                <!-- ================= [관리자] 탭 1: 전체 예약 관리 ================= -->
                <div id="tab-admin-bookings" class="tab-content active">
                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">전체 사용자 대여 예약 관리</h3>
                        <div class="table-wrapper">
                            <table class="mypage-table">
                                <thead>
                                    <tr>
                                        <th>예약번호</th>
                                        <th>예약자 정보</th>
                                        <th>바이크 모델</th>
                                        <th>대여 기간</th>
                                        <th>총 금액</th>
                                        <th>결제 방식</th>
                                        <th>상태</th>
                                        <th>관리 동작</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty bookingList}">
                                            <c:forEach var="book" items="${bookingList}">
                                                <tr>
                                                    <td>
                                                        #${book.bookingId}<br>
                                                        <span class="sub-text" style="color: var(--primary-color); font-weight: bold;">
                                                            [${book.pickupShopName} &rarr; ${book.dropoffShopName}]
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <strong>${book.memberNickname}</strong><br>
                                                        <span class="sub-text">${book.memberEmail}</span>
                                                    </td>
                                                    <td>
                                                        <strong>${book.bikeName}</strong>
                                                        <c:if test="${not empty book.bookingOptions}">
                                                            <div style="font-size:0.8rem; color:#aaa; margin-top:4px; line-height:1.4;">
                                                                🛠️ 옵션: 
                                                                <c:forEach var="opt" items="${book.bookingOptions}" varStatus="status">
                                                                    ${opt.optionName} (${opt.quantity}개)${!status.last ? ', ' : ''}
                                                                </c:forEach>
                                                            </div>
                                                        </c:if>
                                                    </td>
                                                    <td>${book.startDate} ~ ${book.endDate} (${book.rentalDays}일)</td>
                                                    <td>₩<fmt:formatNumber value="${book.price}" pattern="#,###"/></td>
                                                    <td>${book.paymentMethod}</td>
                                                    <td>
                                                        <span class="status-badge status-${book.bookingStatus.toLowerCase()}">
                                                            <c:choose>
                                                                <c:when test="${book.bookingStatus eq 'PENDING'}">승인 대기</c:when>
                                                                <c:when test="${book.bookingStatus eq 'APPROVED'}">대여 승인</c:when>
                                                                <c:when test="${book.bookingStatus eq 'CANCELLED'}">예약 취소</c:when>
                                                                <c:otherwise>${book.bookingStatus}</c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <c:if test="${book.bookingStatus eq 'PENDING'}">
                                                            <a href="${pageContext.request.contextPath}/bookingStatusAction.do?bookingId=${book.bookingId}&status=APPROVED" class="btn-sm btn-approve" style="margin-right:5px;">승인</a>
                                                            <a href="${pageContext.request.contextPath}/bookingStatusAction.do?bookingId=${book.bookingId}&status=CANCELLED" class="btn-sm btn-reject">거절</a>
                                                        </c:if>
                                                        <c:if test="${book.bookingStatus ne 'PENDING'}">
                                                            <span class="done-text">-</span>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="8" class="no-data">등록된 대여 예약 내역이 존재하지 않습니다.</td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- ================= [관리자] 탭 2: 가입 회원 목록 ================= -->
                <div id="tab-admin-members" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">가입 회원 목록 조회</h3>
                        <div class="table-wrapper">
                            <table class="mypage-table">
                                <thead>
                                    <tr>
                                        <th>회원번호</th>
                                        <th>이메일 주소</th>
                                        <th>닉네임</th>
                                        <th>회원 권한</th>
                                        <th>면허 번호</th>
                                        <th>면허 상태</th>
                                        <th>가입 일시</th>
                                        <th>면허 관리</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="mem" items="${memberList}">
                                        <tr>
                                            <td>${mem.memberId}</td>
                                            <td>${mem.email}</td>
                                            <td><strong>${mem.nickname}</strong></td>
                                            <td>
                                                <span class="role-badge ${mem.memberStatus eq 'ADMIN' ? 'role-admin' : 'role-user'}" style="padding: 2px 6px; border-radius: 4px; font-size: 0.8rem; font-weight: bold; background: ${mem.memberStatus eq 'ADMIN' ? 'var(--primary-color)' : '#333'};">
                                                    ${mem.memberStatus}
                                                </span>
                                            </td>
                                            <td>${empty mem.licenseNumber ? '-' : mem.licenseNumber}</td>
                                            <td>
                                                <span class="status-badge" style="padding: 2px 6px; border-radius: 4px; font-size: 0.8rem; font-weight: bold; 
                                                    background: ${mem.licenseStatus eq 'APPROVED' ? '#10b981' : (mem.licenseStatus eq 'REJECTED' ? '#ef4444' : '#f59e0b')}; color: #fff;">
                                                    <c:choose>
                                                        <c:when test="${mem.licenseStatus eq 'APPROVED'}">승인 완료</c:when>
                                                        <c:when test="${mem.licenseStatus eq 'REJECTED'}">반려됨</c:when>
                                                        <c:otherwise>승인 대기</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </td>
                                            <td><fmt:formatDate value="${mem.createdAt}" pattern="yyyy-MM-dd HH:mm"/></td>
                                            <td>
                                                <c:if test="${mem.memberStatus ne 'ADMIN' and not empty mem.licenseNumber}">
                                                    <c:if test="${mem.licenseStatus ne 'APPROVED'}">
                                                        <a href="${pageContext.request.contextPath}/adminLicenseAction.do?memberId=${mem.memberId}&status=APPROVED" class="btn-sm btn-approve" style="margin-right:5px; padding: 4px 8px; border-radius: 4px; background: #10b981; color: #fff;">승인</a>
                                                    </c:if>
                                                    <c:if test="${mem.licenseStatus ne 'REJECTED'}">
                                                        <a href="${pageContext.request.contextPath}/adminLicenseAction.do?memberId=${mem.memberId}&status=REJECTED" class="btn-sm btn-reject" style="padding: 4px 8px; border-radius: 4px; background: #ef4444; color: #fff;">반려</a>
                                                    </c:if>
                                                </c:if>
                                                <c:if test="${mem.memberStatus eq 'ADMIN' or empty mem.licenseNumber}">
                                                    <span style="color: #666;">-</span>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- ================= [관리자] 탭 3: 바이크/지점/브랜드 통합 CRUD ================= -->
                <div id="tab-admin-crud" class="tab-content">
                    <!-- 3-1. 브랜드 관리 섹션 -->
                    <div class="panel-form" style="border:1px solid #222;">
                        <h4 style="color:var(--primary-color); border-bottom:1px solid #222; padding-bottom:10px; margin-bottom:15px; font-family:'Outfit'; font-size:1.2rem;">제조 브랜드 관리</h4>
                        <div class="crud-section-grid">
                            <div>
                                <h5 style="margin-bottom:10px;">브랜드 리스트</h5>
                                <div class="table-wrapper" style="max-height: 250px; overflow-y: auto;">
                                    <table class="mypage-table">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>브랜드명</th>
                                                <th>국가</th>
                                                <th>동작</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="brd" items="${adminBrandList}">
                                                <tr>
                                                    <td>${brd.brandId}</td>
                                                    <td><strong>${brd.brandName}</strong></td>
                                                    <td>${brd.country}</td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/adminBrandDeleteAction.do?brandId=${brd.brandId}" class="btn-sm btn-reject" onclick="return confirm('정말 삭제하시겠습니까? 관련 바이크들의 브랜드 정보가 초기화됩니다.');">삭제</a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div>
                                <h5 style="margin-bottom:10px;">신규 브랜드 추가</h5>
                                <form action="${pageContext.request.contextPath}/adminBrandAddAction.do" method="post">
                                    <div class="form-group" style="margin-bottom:10px;">
                                        <label style="font-size:0.85rem; color:#aaa;">브랜드명</label>
                                        <input type="text" name="brandName" required placeholder="예: Ducati, Honda" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                    </div>
                                    <div class="form-group" style="margin-bottom:10px;">
                                        <label style="font-size:0.85rem; color:#aaa;">생산 국가</label>
                                        <input type="text" name="country" required placeholder="예: 이탈리아, 일본" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                    </div>
                                    <div class="form-group" style="margin-bottom:10px;">
                                        <label style="font-size:0.85rem; color:#aaa;">설명</label>
                                        <textarea name="description" placeholder="간단한 설명 기재" style="width:100%; height:50px; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff; resize:none;"></textarea>
                                    </div>
                                    <button type="submit" class="btn btn-action-main" style="width:100%; padding:10px;">브랜드 등록</button>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- 3-2. 지점 관리 섹션 -->
                    <div class="panel-form" style="border:1px solid #222; margin-top:30px;">
                        <h4 style="color:var(--primary-color); border-bottom:1px solid #222; padding-bottom:10px; margin-bottom:15px; font-family:'Outfit'; font-size:1.2rem;">렌탈 지점 관리</h4>
                        <div class="crud-section-grid">
                            <div>
                                <h5 style="margin-bottom:10px;">지점 리스트</h5>
                                <div class="table-wrapper" style="max-height: 250px; overflow-y: auto;">
                                    <table class="mypage-table">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>이미지</th>
                                                <th>지점명</th>
                                                <th>연락처 / 주소</th>
                                                <th>동작</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="sh" items="${adminShopList}">
                                                <tr>
                                                    <td>${sh.shopId}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty sh.imageFilename}">
                                                                <div style="position: relative; width: 80px; height: 50px; overflow: hidden; border-radius: 4px; border: 1px solid #333; margin-bottom: 5px;">
                                                                    <img src="${pageContext.request.contextPath}/resources/images/shops/${sh.imageFilename}" style="width: 100%; height: 100%; object-fit: cover;">
                                                                </div>
                                                                <a href="${pageContext.request.contextPath}/adminShopImageDeleteAction.do?shopId=${sh.shopId}" class="btn-sm btn-reject" style="display: inline-block; padding: 2px 6px; font-size: 0.7rem; line-height: 1; text-decoration: none;" onclick="return confirm('지점 이미지를 삭제하시겠습니까?');">이미지 삭제</a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <form action="${pageContext.request.contextPath}/adminShopImageUploadAction.do" method="post" enctype="multipart/form-data" style="display: flex; flex-direction: column; gap: 4px;">
                                                                    <input type="hidden" name="shopId" value="${sh.shopId}">
                                                                    <input type="file" name="shopImage" accept="image/*" style="font-size: 0.7rem; width: 120px; color: #aaa;" required>
                                                                    <button type="submit" class="btn-sm btn-action-main" style="padding: 2px 6px; font-size: 0.7rem; background: #2563eb; width: fit-content; border: none; border-radius: 4px;">업로드</button>
                                                                </form>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td><strong>${sh.shopName}</strong></td>
                                                    <td>
                                                        <span class="sub-text">${sh.tel}</span><br>
                                                        <span class="sub-text" style="font-size:0.75rem;">${sh.address}</span>
                                                    </td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/adminShopDeleteAction.do?shopId=${sh.shopId}" class="btn-sm btn-reject" onclick="return confirm('정말 삭제하시겠습니까? 관련 바이크들의 지점 정보가 초기화됩니다.');">삭제</a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div>
                                <h5 style="margin-bottom:10px;">신규 지점 추가</h5>
                                <form action="${pageContext.request.contextPath}/adminShopAddAction.do" method="post" enctype="multipart/form-data">
                                    <div class="form-group" style="margin-bottom:10px;">
                                        <label style="font-size:0.85rem; color:#aaa;">지점명</label>
                                        <input type="text" name="shopName" required placeholder="예: 대구 중앙점" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                    </div>
                                    <div class="form-group" style="margin-bottom:10px;">
                                        <label style="font-size:0.85rem; color:#aaa;">매니저 / 연락처</label>
                                        <div style="display:flex; gap:10px;">
                                            <input type="text" name="managerName" required placeholder="홍길동" style="flex:1; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                            <input type="text" name="tel" required placeholder="053-123-4567" style="flex:1; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                        </div>
                                    </div>
                                    <div class="form-group" style="margin-bottom:10px;">
                                        <label style="font-size:0.85rem; color:#aaa;">지점 주소</label>
                                        <input type="text" name="address" required placeholder="대구광역시 중구 달구벌대로 123" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                    </div>
                                    <div class="form-group" style="margin-bottom:10px;">
                                        <label style="font-size:0.85rem; color:#aaa;">지점 이미지 첨부</label>
                                        <input type="file" name="shopImage" accept="image/*" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                    </div>
                                    <div style="display:flex; gap:10px; margin-bottom:10px;">
                                        <div style="flex:1;">
                                            <label style="font-size:0.85rem; color:#aaa;">오픈시간</label>
                                            <input type="text" name="openTime" value="09:00" placeholder="09:00" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                        </div>
                                        <div style="flex:1;">
                                            <label style="font-size:0.85rem; color:#aaa;">마감시간</label>
                                            <input type="text" name="closeTime" value="20:00" placeholder="20:00" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                        </div>
                                    </div>
                                    <button type="submit" class="btn btn-action-main" style="width:100%; padding:10px;">지점 등록</button>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- 3-3. 바이크 차량 관리 섹션 -->
                    <div class="panel-form" style="border:1px solid #222; margin-top:30px;">
                        <h4 style="color:var(--primary-color); border-bottom:1px solid #222; padding-bottom:10px; margin-bottom:15px; font-family:'Outfit'; font-size:1.2rem;">바이크(모터사이클) 차량 관리</h4>
                        <div class="crud-section-grid">
                            <div>
                                <h5 style="margin-bottom:10px;">바이크 리스트</h5>
                                <div class="table-wrapper" style="max-height: 400px; overflow-y: auto;">
                                    <table class="mypage-table">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>바이크 모델</th>
                                                <th>소속 지점 / 대여 요금</th>
                                                <th>동작</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="bk" items="${adminBikeList}">
                                                <tr>
                                                    <td>${bk.bikeId}</td>
                                                    <td>
                                                        <strong>${bk.bikeName}</strong><br>
                                                        <span class="sub-text">${bk.brandName} | ${bk.cc}cc | ${bk.year}년식</span>
                                                    </td>
                                                    <td>
                                                        <span class="sub-text">${bk.shopName}</span><br>
                                                        <strong>₩<fmt:formatNumber value="${bk.dailyPrice}" pattern="#,###"/></strong> / 일
                                                    </td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/adminBikeDeleteAction.do?bikeId=${bk.bikeId}" class="btn-sm btn-reject" onclick="return confirm('정말 삭제하시겠습니까?');">삭제</a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div>
                                <h5 style="margin-bottom:10px;">신규 바이크 등록</h5>
                                <form action="${pageContext.request.contextPath}/adminBikeAddAction.do" method="post">
                                    <div style="display:flex; gap:10px; margin-bottom:10px;">
                                        <div style="flex:1;">
                                            <label style="font-size:0.85rem; color:#aaa;">브랜드</label>
                                            <select name="brandId" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                                <c:forEach var="brd" items="${adminBrandList}">
                                                    <option value="${brd.brandId}">${brd.brandName}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div style="flex:1;">
                                            <label style="font-size:0.85rem; color:#aaa;">소속 지점</label>
                                            <select name="shopId" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                                <c:forEach var="sh" items="${adminShopList}">
                                                    <option value="${sh.shopId}">${sh.shopName}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="form-group" style="margin-bottom:10px;">
                                        <label style="font-size:0.85rem; color:#aaa;">모델명</label>
                                        <input type="text" name="modelName" required placeholder="예: CBR650R, SuperSport 950" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                    </div>
                                    <div style="display:flex; gap:10px; margin-bottom:10px;">
                                        <div style="flex:1;">
                                            <label style="font-size:0.85rem; color:#aaa;">배기량 (cc)</label>
                                            <input type="number" name="cc" required placeholder="650" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                        </div>
                                        <div style="flex:1;">
                                            <label style="font-size:0.85rem; color:#aaa;">연식 (Year)</label>
                                            <input type="number" name="year" required placeholder="2024" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                        </div>
                                    </div>
                                    <div style="display:flex; gap:10px; margin-bottom:10px;">
                                        <div style="flex:1;">
                                            <label style="font-size:0.85rem; color:#aaa;">컬러</label>
                                            <input type="text" name="color" required placeholder="Red" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                        </div>
                                        <div style="flex:1;">
                                            <label style="font-size:0.85rem; color:#aaa;">1일 렌탈료 (₩)</label>
                                            <input type="number" name="dailyPrice" required placeholder="80000" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                        </div>
                                    </div>
                                    <div class="form-group" style="margin-bottom:10px;">
                                        <label style="font-size:0.85rem; color:#aaa;">누적 주행거리 (km)</label>
                                        <input type="number" name="mileage" value="0" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                    </div>
                                    <div class="form-group" style="margin-bottom:10px;">
                                        <label style="font-size:0.85rem; color:#aaa;">대표 이미지 경로 (resources/ 하위)</label>
                                        <input type="text" name="imageUrl" value="resources/images/bikes/honda_cbr650r.png" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                    </div>
                                    <div class="form-group" style="margin-bottom:10px;">
                                        <label style="font-size:0.85rem; color:#aaa;">차량 설명</label>
                                        <textarea name="description" required placeholder="간단한 특징 설명 기재" style="width:100%; height:50px; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff; resize:none;"></textarea>
                                    </div>
                                    <button type="submit" class="btn btn-action-main" style="width:100%; padding:10px;">바이크 등록</button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ================= [관리자] 탭 4: 1:1 문의 답변 관리 ================= -->
                <div id="tab-admin-inquiries" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">1:1 문의 답변 등록 대시보드</h3>
                        <c:choose>
                            <c:when test="${not empty adminInquiryList}">
                                <c:forEach var="inq" items="${adminInquiryList}">
                                    <div class="accordion-inquiry">
                                        <div class="accordion-header" onclick="toggleAccordion(this)">
                                            <span>
                                                <span class="inquiry-status ${inq.status eq 'PENDING' ? 'inquiry-pending' : 'inquiry-answered'}">
                                                    ${inq.status eq 'PENDING' ? '답변 대기' : '답변 완료'}
                                                </span>
                                                &nbsp;&nbsp;<strong>${inq.title}</strong>
                                            </span>
                                            <span class="sub-text" style="font-size:0.8rem; color:#888;">
                                                회원: ${inq.userNickname} | 등록일: <fmt:formatDate value="${inq.createdAt}" pattern="yyyy-MM-dd"/>
                                            </span>
                                        </div>
                                        <div class="accordion-content">
                                            <div style="background:#1e1e1e; padding:15px; border-radius:6px; margin-bottom:20px; white-space:pre-wrap;">
                                                <strong>[문의 내용]</strong><br><br>${inq.content}
                                            </div>
                                            <c:choose>
                                                <c:when test="${inq.status eq 'PENDING'}">
                                                    <form action="${pageContext.request.contextPath}/adminInquiryAnswer.do" method="post">
                                                        <input type="hidden" name="inquiryId" value="${inq.inquiryId}">
                                                        <div class="form-group">
                                                            <label style="color:#aaa; font-size:0.9rem; display:block; margin-bottom:5px;">답변 내용 작성</label>
                                                            <textarea name="answerContent" required placeholder="답변을 입력하세요..." style="width:100%; height:120px; background:#2a2a2a; border:1px solid #444; border-radius:6px; color:#fff; padding:12px; resize:none;"></textarea>
                                                        </div>
                                                        <button type="submit" class="btn btn-action-main" style="margin-top:10px;">답변 등록</button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <div style="border-top:1px dashed #333; padding-top:15px; color:#10b981; white-space:pre-wrap;">
                                                        <strong>[등록된 답변]</strong> (${inq.answeredAt})<br><br>${inq.answerContent}
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="no-data">등록된 1:1 문의글이 존재하지 않습니다.</div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- ================= [관리자] 탭 5: 쿠폰 발급 ================= -->
                <div id="tab-admin-coupons" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">쿠폰 발행 및 전송</h3>
                        <p class="sub-text" style="margin-bottom:20px;">특정 회원 또는 가입한 전체 회원에게 할인쿠폰을 직접 발송합니다.</p>
                        <div style="max-width:550px; background:#0d0d0d; border:1px solid #222; padding:25px; border-radius:8px;">
                            <form action="${pageContext.request.contextPath}/adminCouponIssue.do" method="post">
                                <div class="form-group" style="margin-bottom:15px;">
                                    <label>발송 대상</label>
                                    <select name="targetUser" required style="width:100%; padding:12px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                        <option value="all">전체 가입 회원 일괄 발송</option>
                                        <c:forEach var="m" items="${memberList}">
                                            <c:if test="${m.memberStatus ne 'ADMIN'}">
                                                <option value="${m.memberId}">${m.nickname} (${m.email})</option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="form-group" style="margin-bottom:15px;">
                                    <label>쿠폰 이름</label>
                                    <input type="text" name="couponName" required placeholder="예: 주말 라이딩 2만원 할인쿠폰" style="width:100%; padding:12px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                </div>
                                <div class="form-group" style="margin-bottom:15px;">
                                    <label>할인 혜택 금액 (₩)</label>
                                    <input type="number" name="discountAmount" required min="1000" step="1000" placeholder="예: 20000" style="width:100%; padding:12px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                </div>
                                <div class="form-group" style="margin-bottom:20px;">
                                    <label>유효 만료일</label>
                                    <input type="date" name="expireDate" required style="width:100%; padding:12px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                </div>
                                <button type="submit" class="btn btn-action-main" style="width:100%; padding:12px; font-weight:bold;">쿠폰 발행 및 발송</button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- ================= [관리자] 탭 6: 패널티 및 벌금 관리 ================= -->
                <div id="tab-admin-penalties" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">전체 회원 패널티 부과 및 현황 관리</h3>
                        
                        <div class="crud-section-grid">
                            <!-- 패널티 현황 테이블 -->
                            <div>
                                <h4 style="margin-bottom: 10px; color:#fff;">부과된 패널티 현황</h4>
                                <div class="table-wrapper">
                                    <table class="mypage-table" style="font-size: 0.85rem;">
                                        <thead>
                                            <tr>
                                                <th>부과일자</th>
                                                <th>대상회원</th>
                                                <th>종류</th>
                                                <th>금액</th>
                                                <th>결제상태</th>
                                                <th>사유</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${not empty adminPenaltyList}">
                                                    <c:forEach var="pen" items="${adminPenaltyList}">
                                                        <tr>
                                                            <td><fmt:formatDate value="${pen.createdAt}" pattern="yyyy-MM-dd"/></td>
                                                            <td>
                                                                <strong>${pen.userName}</strong><br>
                                                                <span style="font-size:0.75rem; color:#888;">${pen.userEmail}</span>
                                                            </td>
                                                            <td><span style="padding: 2px 6px; background: #222; border-radius: 4px; font-weight: bold; color: #ff9800;">${pen.penaltyType}</span></td>
                                                            <td>₩<fmt:formatNumber value="${pen.amount}" pattern="#,###"/></td>
                                                            <td>
                                                                <span style="font-weight: bold; color: ${pen.isPaid eq 'Y' ? '#10b981' : '#ef4444'};">
                                                                    ${pen.isPaid eq 'Y' ? '납부완료' : '미납'}
                                                                </span>
                                                            </td>
                                                            <td>${pen.reason} (예약 #${pen.reservationId})</td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <tr>
                                                        <td colspan="6" style="text-align: center; padding: 20px; color: #888;">부과된 패널티 내역이 없습니다.</td>
                                                    </tr>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            
                            <!-- 신규 패널티 부과 폼 -->
                            <div>
                                <h4 style="margin-bottom: 10px; color:#fff;">신규 패널티 부과</h4>
                                <div style="background:#0d0d0d; border:1px solid #222; padding:20px; border-radius:8px;">
                                    <form action="${pageContext.request.contextPath}/adminAddPenaltyAction.do" method="post">
                                        <div class="form-group" style="margin-bottom: 12px;">
                                            <label style="font-size:0.85rem; color:#aaa;">대상 예약 선택</label>
                                            <select name="reservationId" id="penalty-res-selector" onchange="updatePenaltyUser()" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                                <option value="">--- 예약을 선택하세요 ---</option>
                                                <c:forEach var="book" items="${bookingList}">
                                                    <option value="${book.bookingId}" data-userid="${book.memberId}" data-username="${book.memberNickname}">${book.memberNickname} 님 - 예약 #${book.bookingId} (${book.bikeName})</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        
                                        <!-- Hidden 회원번호 자동 바인딩 -->
                                        <input type="hidden" name="userId" id="penalty-user-id">
                                        
                                        <div class="form-group" style="margin-bottom: 12px;">
                                            <label style="font-size:0.85rem; color:#aaa;">선택된 예약자명</label>
                                            <input type="text" id="penalty-user-name" disabled placeholder="예약을 선택하면 자동 입력됩니다" style="width:100%; padding:10px; border-radius:6px; background:#1e1e1e; border:1px solid #333; color:#666;">
                                        </div>
                                        
                                        <div class="form-group" style="margin-bottom: 12px;">
                                            <label style="font-size:0.85rem; color:#aaa;">패널티 종류</label>
                                            <select name="penaltyType" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                                <option value="반납 지연">반납 지연</option>
                                                <option value="차량 파손">차량 파손</option>
                                                <option value="과태료">과태료 (속도/신호위반 등)</option>
                                                <option value="주유량 미달">주유량 미달</option>
                                                <option value="기타">기타 추가 요금</option>
                                            </select>
                                        </div>
                                        
                                        <div class="form-group" style="margin-bottom: 12px;">
                                            <label style="font-size:0.85rem; color:#aaa;">부과 금액 (₩)</label>
                                            <input type="number" name="amount" required placeholder="예: 50000" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                        </div>
                                        
                                        <div class="form-group" style="margin-bottom: 15px;">
                                            <label style="font-size:0.85rem; color:#aaa;">상세 사유</label>
                                            <textarea name="reason" required placeholder="예: 신천대로 속도위반 20km 초과 과태료 청구" style="width:100%; height:60px; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff; resize:none;"></textarea>
                                        </div>
                                        
                                        <button type="submit" class="btn btn-action-main" style="width:100%; padding:10px; font-weight:bold;">패널티 청구하기</button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ================= [관리자] 탭 7: 면허 검증 심사 ================= -->
                <div id="tab-admin-license" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">🪪 면허 검증 심사 관리</h3>
                        <div class="table-wrapper">
                            <table class="mypage-table">
                                <thead>
                                    <tr>
                                        <th>심사번호</th>
                                        <th>신청인 정보</th>
                                        <th>면허 종류</th>
                                        <th>면허증 사진</th>
                                        <th>심사 상태</th>
                                        <th>반려 사유</th>
                                        <th>처리 일시 / 담당자</th>
                                        <th>심사 관리</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty adminLicenseAuditList}">
                                            <c:forEach var="audit" items="${adminLicenseAuditList}">
                                                <tr>
                                                    <td>#${audit.auditId}</td>
                                                    <td>
                                                        <strong>${audit.userNickname}</strong><br>
                                                        <span style="font-size:0.75rem; color:#888;">${audit.userEmail}</span>
                                                    </td>
                                                    <td><span style="padding: 2px 6px; background: #222; border-radius: 4px; font-weight: bold; color:#fff;">${audit.licenseType}</span></td>
                                                    <td>
                                                        <c:if test="${not empty audit.licenseImage}">
                                                            <a href="${pageContext.request.contextPath}/${audit.licenseImage}" target="_blank">
                                                                <img src="${pageContext.request.contextPath}/${audit.licenseImage}" alt="면허증" style="width: 80px; height: 50px; object-fit: cover; border-radius: 4px; border: 1px solid #444; cursor: pointer; transition: transform 0.2s;" onmouseover="this.style.transform='scale(1.1)'" onmouseout="this.style.transform='scale(1.0)'"/>
                                                            </a>
                                                        </c:if>
                                                        <c:if test="${empty audit.licenseImage}">-</c:if>
                                                    </td>
                                                    <td>
                                                        <span class="status-badge" style="padding: 2px 6px; border-radius: 4px; font-size: 0.8rem; font-weight: bold; 
                                                            background: ${audit.status eq 'APPROVED' ? '#10b981' : (audit.status eq 'REJECTED' ? '#ef4444' : '#f59e0b')}; color: #fff;">
                                                            <c:choose>
                                                                <c:when test="${audit.status eq 'APPROVED'}">승인 완료</c:when>
                                                                <c:when test="${audit.status eq 'REJECTED'}">반려됨</c:when>
                                                                <c:otherwise>대기 중</c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                    </td>
                                                    <td style="color:#aaa;">${empty audit.rejectReason ? '-' : audit.rejectReason}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty audit.auditDate}">
                                                                <span style="font-size:0.8rem;"><fmt:formatDate value="${audit.auditDate}" pattern="yyyy-MM-dd HH:mm"/></span><br>
                                                                <span style="font-size:0.75rem; color:#888;">담당: ${audit.adminNickname} (${audit.adminEmail})</span>
                                                            </c:when>
                                                            <c:otherwise>-</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:if test="${audit.status eq 'PENDING'}">
                                                            <button onclick="approveLicense(${audit.auditId})" class="btn-sm" style="padding: 4px 8px; border:none; border-radius: 4px; background: #10b981; color: #fff; font-weight:bold; cursor:pointer; margin-right:5px;">승인</button>
                                                            <button onclick="rejectLicense(${audit.auditId})" class="btn-sm" style="padding: 4px 8px; border:none; border-radius: 4px; background: #ef4444; color: #fff; font-weight:bold; cursor:pointer;">반려</button>
                                                        </c:if>
                                                        <c:if test="${audit.status ne 'PENDING'}">
                                                            <span style="color:#666;">처리 완료</span>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="8" style="text-align: center; padding: 20px; color: #888;">대기 중이거나 심사 완료된 면허증 심사 내역이 없습니다.</td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- ================= [관리자] 탭 8: 차량 정비 관리 ================= -->
                <div id="tab-admin-maintenance" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">🔧 차량 정비 이력 관리</h3>
                        
                        <div class="crud-section-grid">
                            <!-- 정비 이력 테이블 -->
                            <div>
                                <h4 style="margin-bottom: 10px; color:#fff;">정비 이력 내역</h4>
                                <div class="table-wrapper">
                                    <table class="mypage-table" style="font-size: 0.85rem;">
                                        <thead>
                                            <tr>
                                                <th>정비번호</th>
                                                <th>바이크 모델</th>
                                                <th>정비일자</th>
                                                <th>정비종류</th>
                                                <th>정비 내용</th>
                                                <th>정비비용</th>
                                                <th>정비소</th>
                                                <th>차기 점검일</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${not empty adminMaintenanceList}">
                                                    <c:forEach var="maint" items="${adminMaintenanceList}">
                                                        <tr>
                                                            <td>#${maint.maintenanceId}</td>
                                                            <td><strong>${maint.modelName}</strong></td>
                                                            <td>${maint.maintenanceDate}</td>
                                                            <td><span style="padding: 2px 6px; background: #222; border-radius: 4px; font-weight: bold; color: var(--primary-color);">${maint.maintenanceType}</span></td>
                                                            <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${maint.content}">${maint.content}</td>
                                                            <td>₩<fmt:formatNumber value="${maint.cost}" pattern="#,###"/></td>
                                                            <td>${maint.shopName}</td>
                                                            <td>${empty maint.nextCheckDate ? '-' : maint.nextCheckDate}</td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <tr>
                                                        <td colspan="8" style="text-align: center; padding: 20px; color: #888;">등록된 차량 정비 이력이 없습니다.</td>
                                                    </tr>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            
                            <!-- 신규 정비 등록 폼 -->
                            <div>
                                <h4 style="margin-bottom: 10px; color:#fff;">🔧 신규 정비 등록</h4>
                                <div style="background:#0d0d0d; border:1px solid #222; padding:20px; border-radius:8px;">
                                    <form action="${pageContext.request.contextPath}/adminMaintenanceAddAction.do" method="post">
                                        <div class="form-group" style="margin-bottom: 12px;">
                                            <label style="font-size:0.85rem; color:#aaa;">바이크 모델 선택</label>
                                            <select name="bikeId" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                                <option value="">--- 바이크를 선택하세요 ---</option>
                                                <c:forEach var="bike" items="${adminBikeList}">
                                                    <option value="${bike.bikeId}">${bike.bikeName} (차량 ID: ${bike.bikeId})</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        
                                        <div class="form-group" style="margin-bottom: 12px;">
                                            <label style="font-size:0.85rem; color:#aaa;">정비 일자</label>
                                            <input type="date" name="maintenanceDate" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;"/>
                                        </div>
                                        
                                        <div class="form-group" style="margin-bottom: 12px;">
                                            <label style="font-size:0.85rem; color:#aaa;">정비 종류</label>
                                            <select name="maintenanceType" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                                <option value="정기점검">정기점검</option>
                                                <option value="사고수리">사고수리</option>
                                                <option value="소모품교체">소모품교체</option>
                                                <option value="기타">기타</option>
                                            </select>
                                        </div>
                                        
                                        <div class="form-group" style="margin-bottom: 12px;">
                                            <label style="font-size:0.85rem; color:#aaa;">정비 비용 (₩)</label>
                                            <input type="number" name="cost" required placeholder="예: 35000" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;"/>
                                        </div>
                                        
                                        <div class="form-group" style="margin-bottom: 12px;">
                                            <label style="font-size:0.85rem; color:#aaa;">정비소명</label>
                                            <input type="text" name="shopName" required placeholder="예: 대구 바이크나라" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;"/>
                                        </div>
                                        
                                        <div class="form-group" style="margin-bottom: 12px;">
                                            <label style="font-size:0.85rem; color:#aaa;">차기 점검 예정일 (선택)</label>
                                            <input type="date" name="nextCheckDate" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;"/>
                                        </div>
                                        
                                        <div class="form-group" style="margin-bottom: 15px;">
                                            <label style="font-size:0.85rem; color:#aaa;">정비 상세 내용</label>
                                            <textarea name="content" required placeholder="예: 엔진오일 10W40 및 오일필터 신품 교환 진행" style="width:100%; height:60px; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff; resize:none;"></textarea>
                                        </div>
                                        
                                        <button type="submit" class="btn btn-action-main" style="width:100%; padding:10px; font-weight:bold;">정비 기록 등록</button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ================= [관리자] 탭 9: 반납/주유 기록 ================= -->
                <div id="tab-admin-fuel" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">⛽ 반납 및 주유/배터리 충전 기록</h3>
                        
                        <div class="crud-section-grid">
                            <!-- 반납 및 주유 로그 -->
                            <div>
                                <h4 style="margin-bottom: 10px; color:#fff;">반납 및 주유 로그</h4>
                                <div class="table-wrapper">
                                    <table class="mypage-table" style="font-size: 0.85rem;">
                                        <thead>
                                            <tr>
                                                <th>로그번호</th>
                                                <th>바이크 모델</th>
                                                <th>예약 번호</th>
                                                <th>반납자</th>
                                                <th>반납 주유량</th>
                                                <th>부과 패널티</th>
                                                <th>반납 기록일</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${not empty adminFuelLogList}">
                                                    <c:forEach var="fuel" items="${adminFuelLogList}">
                                                        <tr>
                                                            <td>#${fuel.fuelLogId}</td>
                                                            <td><strong>${fuel.modelName}</strong></td>
                                                            <td>#${fuel.reservationId}</td>
                                                            <td>
                                                                <strong>${fuel.userNickname}</strong><br>
                                                                <span style="font-size:0.75rem; color:#888;">${fuel.userEmail}</span>
                                                            </td>
                                                            <td>
                                                                <span style="font-weight:bold; color: ${fuel.fuelLevel eq 100 ? '#10b981' : '#f59e0b'};">
                                                                    ${fuel.fuelLevel}%
                                                                </span>
                                                            </td>
                                                            <td>
                                                                <c:if test="${fuel.penaltyAmount > 0}">
                                                                    <span style="color:#ef4444; font-weight:bold;">₩<fmt:formatNumber value="${fuel.penaltyAmount}" pattern="#,###"/></span>
                                                                </c:if>
                                                                <c:if test="${fuel.penaltyAmount eq 0}">
                                                                    <span style="color:#666;">없음</span>
                                                                </c:if>
                                                            </td>
                                                            <td><span style="font-size:0.8rem;"><fmt:formatDate value="${fuel.logDate}" pattern="yyyy-MM-dd HH:mm"/></span></td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <tr>
                                                        <td colspan="7" style="text-align: center; padding: 20px; color: #888;">반납 및 주유/충전 로그가 없습니다.</td>
                                                    </tr>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            
                            <!-- 차량 반납 처리 폼 -->
                            <div>
                                <h4 style="margin-bottom: 10px; color:#fff;">🏍️ 차량 반납 및 주유 검사</h4>
                                <div style="background:#0d0d0d; border:1px solid #222; padding:20px; border-radius:8px;">
                                    <form action="${pageContext.request.contextPath}/adminFuelLogAddAction.do" method="post">
                                        <div class="form-group" style="margin-bottom: 12px;">
                                            <label style="font-size:0.85rem; color:#aaa;">대여 중인 예약 선택</label>
                                            <select name="reservationId" id="fuel-res-selector" onchange="calculateFuelPenalty()" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                                <option value="">--- 대여 중인 예약을 선택하세요 ---</option>
                                                <c:forEach var="book" items="${bookingList}">
                                                    <c:if test="${book.bookingStatus eq 'APPROVED'}">
                                                        <option value="${book.bookingId}">${book.memberNickname} 님 - 예약 #${book.bookingId} (${book.bikeName})</option>
                                                    </c:if>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        
                                        <div class="form-group" style="margin-bottom: 12px;">
                                            <label style="font-size:0.85rem; color:#aaa;">반납 시 주유/배터리 잔량 (%)</label>
                                            <input type="number" name="fuelLevel" id="fuel-level-input" min="0" max="100" required placeholder="0 ~ 100 입력" oninput="calculateFuelPenalty()" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;"/>
                                        </div>
                                        
                                        <!-- 실시간 계산된 패널티 경고 표시 -->
                                        <div id="fuel-penalty-calc-box" style="margin-bottom:15px; padding:12px; border-radius:6px; background:#1a1a1a; border:1px solid #333; font-size:0.85rem; display:none;">
                                            <span style="color:#aaa;">부족 유량에 따른 벌금: </span>
                                            <strong id="fuel-penalty-display" style="color:#ef4444;">₩0</strong>
                                            <p style="font-size:0.75rem; color:#777; margin-top:4px;">* 100% 미만 주유 시 1%당 ₩1,000원의 패널티가 사용자에게 고지됩니다.</p>
                                        </div>
                                        
                                        <button type="submit" class="btn btn-action-main" style="width:100%; padding:10px; font-weight:bold; background: #e50914;">반납 및 주유 등록 완료</button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ================= [관리자] 탭 10: 결제 관리 ================= -->
                <div id="tab-admin-payment" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">💳 전체 회원 결제 내역 관리</h3>
                        <div class="table-wrapper">
                            <table class="mypage-table">
                                <thead>
                                    <tr>
                                        <th>결제번호</th>
                                        <th>예약번호</th>
                                        <th>결제자 정보</th>
                                        <th>결제 수단</th>
                                        <th>PG사 승인번호</th>
                                        <th>결제 금액</th>
                                        <th>결제 일시</th>
                                        <th>결제 상태</th>
                                        <th>취소/환불 금액</th>
                                        <th>결제 관리</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty adminPaymentList}">
                                            <c:forEach var="pay" items="${adminPaymentList}">
                                                <tr>
                                                    <td>#${pay.paymentId}</td>
                                                    <td>#${pay.reservationId}</td>
                                                    <td>
                                                        <strong>${pay.userNickname}</strong><br>
                                                        <span style="font-size:0.75rem; color:#888;">${pay.userEmail}</span>
                                                    </td>
                                                    <td><span style="padding:2px 6px; background:#222; border-radius:4px; font-weight:bold;">${pay.paymentMethod}</span></td>
                                                    <td><code style="color:#aaa;">${pay.pgApprovalNum}</code></td>
                                                    <td>₩<fmt:formatNumber value="${pay.amount}" pattern="#,###"/></td>
                                                    <td><span style="font-size:0.8rem;"><fmt:formatDate value="${pay.paidAt}" pattern="yyyy-MM-dd HH:mm"/></span></td>
                                                    <td>
                                                        <span class="status-badge" style="padding: 2px 6px; border-radius: 4px; font-size: 0.8rem; font-weight: bold; 
                                                            background: ${pay.paymentStatus eq '결제완료' ? '#10b981' : (pay.paymentStatus eq '부분취소' ? '#f59e0b' : '#ef4444')}; color: #fff;">
                                                            ${pay.paymentStatus}
                                                        </span>
                                                    </td>
                                                    <td style="color:${pay.refundAmount > 0 ? '#ef4444' : '#666'}; font-weight:bold;">
                                                        ₩<fmt:formatNumber value="${pay.refundAmount}" pattern="#,###"/>
                                                    </td>
                                                    <td>
                                                        <c:if test="${pay.paymentStatus ne '전체취소'}">
                                                            <button onclick="openRefundModal(${pay.paymentId}, ${pay.amount}, ${pay.refundAmount})" class="btn-sm" style="padding: 4px 8px; border:none; border-radius: 4px; background: #ef4444; color: #fff; font-weight:bold; cursor:pointer;">취소/환불</button>
                                                        </c:if>
                                                        <c:if test="${pay.paymentStatus eq '전체취소'}">
                                                            <span style="color:#666;">취소 완료</span>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="10" style="text-align: center; padding: 20px; color: #888;">조회된 회원 결제 이력이 없습니다.</td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- ================= [관리자] 탭 11: 알림 발송 이력 ================= -->
                <div id="tab-admin-notification" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">🔔 전체 회원 알림 발송 현황</h3>
                        
                        <div class="crud-section-grid">
                            <!-- 알림 이력 목록 -->
                            <div>
                                <h4 style="margin-bottom: 10px; color:#fff;">알림 발송 이력</h4>
                                <div class="table-wrapper">
                                    <table class="mypage-table" style="font-size: 0.85rem;">
                                        <thead>
                                            <tr>
                                                <th>알림번호</th>
                                                <th>수신자</th>
                                                <th>알림 타입</th>
                                                <th>알림 내용</th>
                                                <th>발송 일시</th>
                                                <th>수신 여부</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${not empty adminNotificationList}">
                                                    <c:forEach var="noti" items="${adminNotificationList}">
                                                        <tr>
                                                            <td>#${noti.notificationId}</td>
                                                            <td>
                                                                <strong>${noti.userNickname}</strong><br>
                                                                <span style="font-size:0.75rem; color:#888;">${noti.userEmail}</span>
                                                            </td>
                                                            <td><span style="padding:2px 6px; background:#222; border-radius:4px; font-weight:bold; color:var(--primary-color);">${noti.notificationType}</span></td>
                                                            <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${noti.content}">${noti.content}</td>
                                                            <td><span style="font-size:0.8rem;"><fmt:formatDate value="${noti.createdAt}" pattern="yyyy-MM-dd HH:mm"/></span></td>
                                                            <td>
                                                                <span style="font-weight:bold; color: ${noti.isReceived eq 'Y' ? '#10b981' : '#f59e0b'};">
                                                                    ${noti.isReceived eq 'Y' ? '수신완료' : '전송대기'}
                                                                </span>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:when>
                                                <c:otherwise>
                                                    <tr>
                                                        <td colspan="6" style="text-align: center; padding: 20px; color: #888;">조회된 알림 발송 이력이 없습니다.</td>
                                                    </tr>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            
                            <!-- 알림 직접 발송 폼 -->
                            <div>
                                <h4 style="margin-bottom: 10px; color:#fff;">🔔 개별 알림 직접 발송</h4>
                                <div style="background:#0d0d0d; border:1px solid #222; padding:20px; border-radius:8px;">
                                    <form action="${pageContext.request.contextPath}/adminNotificationAddAction.do" method="post">
                                        <div class="form-group" style="margin-bottom: 12px;">
                                            <label style="font-size:0.85rem; color:#aaa;">대상 회원 선택</label>
                                            <select name="userId" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                                <option value="">--- 알림을 보낼 회원을 선택하세요 ---</option>
                                                <c:forEach var="member" items="${memberList}">
                                                    <c:if test="${member.memberStatus ne 'ADMIN'}">
                                                        <option value="${member.memberId}">${member.nickname} (${member.email})</option>
                                                    </c:if>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        
                                        <div class="form-group" style="margin-bottom: 12px;">
                                            <label style="font-size:0.85rem; color:#aaa;">알림 타입</label>
                                            <select name="notificationType" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                                <option value="알림톡">알림톡 (KakaoTalk)</option>
                                                <option value="SMS">SMS 문자메시지</option>
                                                <option value="앱푸시">앱푸시 (App Push)</option>
                                            </select>
                                        </div>
                                        
                                        <div class="form-group" style="margin-bottom: 15px;">
                                            <label style="font-size:0.85rem; color:#aaa;">알림 내용</label>
                                            <textarea name="content" required placeholder="전송할 알림 메세지 내용을 입력하세요." style="width:100%; height:120px; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff; resize:none;"></textarea>
                                        </div>
                                        
                                        <button type="submit" class="btn btn-action-main" style="width:100%; padding:10px; font-weight:bold; background:#e50914;">알림 발송하기</button>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 💥 사고 처리 관리 탭 -->
                <div id="tab-admin-accident" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">💥 사고 접수 및 처리 관리</h3>
                        <div class="table-wrapper">
                            <table class="mypage-table">
                                <thead>
                                    <tr>
                                        <th>사고번호</th>
                                        <th>회원 정보</th>
                                        <th>예약번호</th>
                                        <th>사고일시</th>
                                        <th>사고장소</th>
                                        <th>현장사진</th>
                                        <th>보험접수번호</th>
                                        <th>과실비율</th>
                                        <th>처리상태</th>
                                        <th>상태 변경</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty adminAccidentList}">
                                            <c:forEach var="acc" items="${adminAccidentList}">
                                                <tr>
                                                    <td><strong>#${acc.reportId}</strong></td>
                                                    <td>
                                                        <strong>${acc.userNickname}</strong><br>
                                                        <span style="font-size:0.8rem; color:#888;">${acc.userEmail}</span>
                                                    </td>
                                                    <td>#${acc.reservationId}</td>
                                                    <td><fmt:formatDate value="${acc.accidentDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                                                    <td>${acc.accidentLocation}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty acc.photoPath}">
                                                                <a href="${pageContext.request.contextPath}/${acc.photoPath}" target="_blank" class="btn" style="padding:4px 8px; font-size:0.8rem; background:#333; border:1px solid #555; color:#fff;">👁️ 사진보기</a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="color:#666;">사진 없음</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty acc.insuranceClaimNum}">
                                                                <strong>${acc.insuranceClaimNum}</strong>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="color:#666;">미발급</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${acc.status eq '접수'}">
                                                                <span style="color:#666;">산정 전</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <strong>${acc.faultRatio}%</strong>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${acc.status eq '접수'}">
                                                                <span style="background:#444; color:#fff; padding:3px 8px; border-radius:12px; font-size:0.8rem; font-weight:bold;">접수</span>
                                                            </c:when>
                                                            <c:when test="${acc.status eq '손해사정중'}">
                                                                <span style="background:#e0a82e; color:#000; padding:3px 8px; border-radius:12px; font-size:0.8rem; font-weight:bold;">손해사정중</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="background:#28a745; color:#fff; padding:3px 8px; border-radius:12px; font-size:0.8rem; font-weight:bold;">종결</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <button onclick="openAccidentModal('${acc.reportId}', '${acc.status}', '${acc.insuranceClaimNum}', '${acc.faultRatio}')" class="btn" style="padding:5px 10px; font-size:0.8rem; background:#333; border:1px solid #555; color:#fff; cursor:pointer;">🛠️ 변경</button>
                                                    </td>
                                                </tr>
                                                <tr style="background:#151515;">
                                                    <td colspan="10" style="padding:10px 15px; border-top:none; text-align:left;">
                                                        <div style="font-size:0.85rem; color:#ccc; line-height:1.5;">
                                                            <strong>💬 사고경위:</strong> ${acc.accidentDescription}
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="10" style="text-align:center; padding:30px; color:#888;">접수된 사고 건이 없습니다.</td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- 🚫 블랙리스트 관리 탭 -->
                <div id="tab-admin-blacklist" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222; margin-bottom: 25px;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">🚫 악성 회원 블랙리스트 등록</h3>
                        <form action="${pageContext.request.contextPath}/adminBlacklistAddAction.do" method="post" style="display:flex; flex-direction:column; gap:15px;">
                            <div style="display:flex; gap:15px;">
                                <div style="flex:1;">
                                    <label style="display:block; margin-bottom:5px; color:#aaa; font-size:0.85rem;">회원 선택</label>
                                    <select name="userId" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                        <option value="">-- 차단할 회원 선택 --</option>
                                        <c:forEach var="m" items="${memberList}">
                                            <c:if test="${m.memberStatus eq 'USER'}">
                                                <option value="${m.memberId}">${m.nickname} (${m.email})</option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div style="flex:1;">
                                    <label style="display:block; margin-bottom:5px; color:#aaa; font-size:0.85rem;">차단 유형</label>
                                    <select name="banType" id="ban-type-selector" onchange="toggleBanDate()" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                        <option value="영구차단">영구차단</option>
                                        <option value="기간차단">기간차단</option>
                                    </select>
                                </div>
                                <div style="flex:1; display:none;" id="ban-date-group">
                                    <label style="display:block; margin-bottom:5px; color:#aaa; font-size:0.85rem;">차단 만료일</label>
                                    <input type="date" name="endDate" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                </div>
                            </div>
                            <div>
                                <label style="display:block; margin-bottom:5px; color:#aaa; font-size:0.85rem;">차단 사유</label>
                                <textarea name="reason" required placeholder="사유를 입력해 주세요 (예: 체납, 무면허 대여, 오토바이 파손 등)" style="width:100%; height:80px; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff; resize:none;"></textarea>
                            </div>
                            <button type="submit" class="btn" style="padding:12px; font-weight:bold; background:#e50914; color:#fff; border:none; border-radius:6px; cursor:pointer;">블랙리스트 차단 등록</button>
                        </form>
                    </div>

                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">📋 블랙리스트 차단 목록</h3>
                        <div class="table-wrapper">
                            <table class="mypage-table">
                                <thead>
                                    <tr>
                                        <th>차단번호</th>
                                        <th>회원 정보</th>
                                        <th>차단 유형</th>
                                        <th>차단 사유</th>
                                        <th>차단 시작일</th>
                                        <th>차단 만료일</th>
                                        <th>등록 관리자</th>
                                        <th>조치 해제</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty adminBlacklist}">
                                            <c:forEach var="bl" items="${adminBlacklist}">
                                                <tr>
                                                    <td><strong>#${bl.blacklistId}</strong></td>
                                                    <td>
                                                        <strong>${bl.userNickname}</strong><br>
                                                        <span style="font-size:0.8rem; color:#888;">${bl.userEmail}</span>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${bl.banType eq '영구차단'}">
                                                                <span style="color:#e50914; font-weight:bold;">영구차단</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="color:#e0a82e; font-weight:bold;">기간차단</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>${bl.reason}</td>
                                                    <td>${bl.startDate}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty bl.endDate}">
                                                                ${bl.endDate}
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="color:#666;">없음</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>${bl.adminNickname}</td>
                                                    <td>
                                                        <form action="${pageContext.request.contextPath}/adminBlacklistReleaseAction.do" method="post" onsubmit="return confirm('해당 회원의 차단 조치를 해제하시겠습니까?');" style="display:inline;">
                                                            <input type="hidden" name="blacklistId" value="${bl.blacklistId}">
                                                            <input type="hidden" name="userId" value="${bl.userId}">
                                                            <button type="submit" class="btn" style="padding:5px 10px; font-size:0.8rem; background:#333; color:#fff; border:1px solid #555; cursor:pointer;">🔓 해제</button>
                                                        </form>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="8" style="text-align:center; padding:30px; color:#888;">차단된 회원이 없습니다.</td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <!-- 💸 환불 내역 관리 탭 -->
                <div id="tab-admin-refund" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">💸 전체 회원 환불 내역 관리</h3>
                        <div class="table-wrapper">
                            <table class="mypage-table">
                                <thead>
                                    <tr>
                                        <th>환불번호</th>
                                        <th>결제번호</th>
                                        <th>예약번호</th>
                                        <th>회원 정보</th>
                                        <th>결제 금액</th>
                                        <th>적용 위약금율</th>
                                        <th>최종 환불금액</th>
                                        <th>환불 수단</th>
                                        <th>취소 요청일시</th>
                                        <th>처리 상태</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty adminRefundList}">
                                            <c:forEach var="ref" items="${adminRefundList}">
                                                <tr>
                                                    <td><strong>#${ref.refundId}</strong></td>
                                                    <td>#${ref.paymentId}</td>
                                                    <td>#${ref.reservationId}</td>
                                                    <td>
                                                        <strong>${ref.userNickname}</strong><br>
                                                        <span style="font-size:0.75rem; color:#888;">${ref.userEmail}</span>
                                                    </td>
                                                    <td>₩<fmt:formatNumber value="${ref.paymentAmount}" pattern="#,###"/></td>
                                                    <td style="color:#ef4444; font-weight:bold;">${ref.penaltyRate}%</td>
                                                    <td style="color:#10b981; font-weight:bold;">₩<fmt:formatNumber value="${ref.refundAmount}" pattern="#,###"/></td>
                                                    <td><span style="padding:2px 6px; background:#222; border-radius:4px; font-weight:bold;">${ref.refundMethod}</span></td>
                                                    <td><span style="font-size:0.8rem;"><fmt:formatDate value="${ref.cancelRequestDate}" pattern="yyyy-MM-dd HH:mm"/></span></td>
                                                    <td>
                                                        <span style="background:#10b981; color:#fff; padding:3px 8px; border-radius:12px; font-size:0.8rem; font-weight:bold;">${ref.status}</span>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="10" style="text-align:center; padding:30px; color:#888;">조회된 환불 내역이 없습니다.</td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </c:when>
            
            <c:otherwise>
                <!-- ================= 일반 사용자 화면 ================= -->
                
                <!-- ================= [사용자] 탭 1: 내 예약 내역 ================= -->
                <div id="tab-user-bookings" class="tab-content active">
                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">내 바이크 대여 예약 내역</h3>
                        
                        <!-- 패널티 경고 및 납부 섹션 -->
                        <c:if test="${not empty penaltyList}">
                            <c:set var="unpaidCount" value="0"/>
                            <c:forEach var="pen" items="${penaltyList}">
                                <c:if test="${pen.isPaid eq 'N'}">
                                    <c:set var="unpaidCount" value="${unpaidCount + 1}"/>
                                </c:if>
                            </c:forEach>
                            
                            <c:if test="${unpaidCount > 0}">
                                <div style="background: rgba(229, 9, 20, 0.1); border: 1px solid #E50914; padding: 20px; border-radius: 8px; margin-bottom: 25px;">
                                    <h4 style="color: #ff3838; margin-bottom: 8px; font-family: 'Outfit'; display: flex; align-items: center; gap: 8px;">
                                        ⚠️ 미납 패널티 및 벌금 고지 (${unpaidCount}건)
                                    </h4>
                                    <p style="font-size: 0.9rem; color: #ccc; margin-bottom: 15px;">
                                        오토바이 반납 지연, 차량 손상 또는 도로 교통 법규 위반(속도위반/신호위반 등)으로 인하여 패널티가 부과되었습니다. 아래 미납 건의 결제를 완료해 주세요.
                                    </p>
                                    <div style="display: flex; flex-direction: column; gap: 10px;">
                                        <c:forEach var="pen" items="${penaltyList}">
                                            <c:if test="${pen.isPaid eq 'N'}">
                                                <div style="display: flex; justify-content: space-between; align-items: center; background: #1a1a1a; padding: 12px 15px; border-radius: 6px; border: 1px solid #333;">
                                                    <div>
                                                        <strong style="color: #fff; font-size: 0.95rem;">${pen.penaltyType} - ₩<fmt:formatNumber value="${pen.amount}" pattern="#,###"/></strong>
                                                        <span style="font-size: 0.8rem; color: #888; margin-left: 10px;">(예약번호: #${pen.reservationId} | 대상 바이크: ${pen.bikeName})</span>
                                                        <p style="margin-top: 4px; font-size: 0.85rem; color: #aaa;">사유: ${pen.reason}</p>
                                                    </div>
                                                    <a href="${pageContext.request.contextPath}/payPenaltyAction.do?penaltyId=${pen.penaltyId}" class="btn" style="background: #E50914; color: #fff; padding: 6px 12px; font-size: 0.85rem; border-radius: 4px; text-decoration: none; font-weight: bold;">즉시 납부하기</a>
                                                </div>
                                            </c:if>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>
                        </c:if>
                        <div class="table-wrapper">
                            <table class="mypage-table">
                                <thead>
                                    <tr>
                                        <th>대여 정보</th>
                                        <th>바이크 모델</th>
                                        <th>대여 기간</th>
                                        <th>이용 일수</th>
                                        <th>총 결제 금액</th>
                                        <th>결제 방식</th>
                                        <th>상태</th>
                                        <th>취소 요청</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty bookingList}">
                                            <c:forEach var="book" items="${bookingList}">
                                                <tr>
                                                    <td>
                                                        #${book.bookingId}<br>
                                                        <span class="sub-text" style="color: var(--primary-color); font-weight: bold;">
                                                            [${book.pickupShopName} &rarr; ${book.dropoffShopName}]
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <div class="bike-cell">
                                                            <img src="${pageContext.request.contextPath}/${book.bikeImageUrl}" alt="${book.bikeName}" class="table-bike-img">
                                                            <div class="bike-cell-desc">
                                                                <strong>${book.bikeName}</strong><br>
                                                                <span class="sub-text">${book.bikeType}</span>
                                                                 <c:if test="${not empty book.insuranceName}">
                                                                     <div style="font-size:0.8rem; color:#e0a82e; margin-top:2px;">
                                                                         🛡️ 보험: <strong>${book.insuranceName}</strong> (+₩<fmt:formatNumber value="${book.insuranceFee * book.rentalDays}" pattern="#,###"/>)
                                                                     </div>
                                                                 </c:if>
                                                                <c:if test="${not empty book.bookingOptions}">
                                                                    <div style="font-size:0.8rem; color:#aaa; margin-top:4px; line-height:1.4;">
                                                                        🛠️ 옵션: 
                                                                        <c:forEach var="opt" items="${book.bookingOptions}" varStatus="status">
                                                                            ${opt.optionName} (${opt.quantity}개)${!status.last ? ', ' : ''}
                                                                        </c:forEach>
                                                                    </div>
                                                                </c:if>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td>${book.startDate} ~ ${book.endDate}</td>
                                                    <td>${book.rentalDays} 일</td>
                                                    <td>₩<fmt:formatNumber value="${book.price}" pattern="#,###"/></td>
                                                    <td>${book.paymentMethod}</td>
                                                    <td>
                                                        <span class="status-badge status-${book.bookingStatus.toLowerCase()}">
                                                            <c:choose>
                                                                <c:when test="${book.bookingStatus eq 'PENDING'}">승인 대기</c:when>
                                                                <c:when test="${book.bookingStatus eq 'APPROVED'}">대여 확정</c:when>
                                                                <c:when test="${book.bookingStatus eq 'CANCELLED'}">예약 취소</c:when>
                                                                <c:otherwise>${book.bookingStatus}</c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                    </td>
                                                    <td>
                                                        <c:if test="${book.bookingStatus eq 'PENDING' or book.bookingStatus eq 'APPROVED'}">
                                                            <a href="${pageContext.request.contextPath}/bookingCancelAction.do?bookingId=${book.bookingId}" class="btn-sm btn-reject" onclick="return confirm('정말로 예약을 취소하시겠습니까?');">대여취소</a>
                                                        </c:if>
                                                        <c:if test="${book.bookingStatus eq 'APPROVED'}">
                                                            <!-- 리뷰 작성 버튼 제공 -->
                                                            <button class="btn-sm btn-approve" style="margin-left: 5px;" onclick="openReviewModal('${book.bookingId}', '${book.bikeId}', '${book.bikeName}')">리뷰작성</button>
                                                        </c:if>
                                                        <c:if test="${book.bookingStatus eq 'CANCELLED'}">
                                                            <span class="done-text">-</span>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="8" class="no-data">아직 대여 신청 내역이 없습니다. <a href="${pageContext.request.contextPath}/bikeList.do" style="color: var(--primary-color);">바이크 예약하러 가기 &rarr;</a></td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                        
                        <!-- 패널티 납부 히스토리 -->
                        <c:if test="${not empty penaltyList}">
                            <div style="margin-top: 30px; border-top: 1px dashed #333; padding-top: 20px;">
                                <h4 style="font-family:'Outfit'; color:#ccc; margin-bottom:12px;">💸 패널티 납부 내역 히스토리</h4>
                                <div class="table-wrapper">
                                    <table class="mypage-table" style="font-size: 0.85rem;">
                                        <thead>
                                            <tr>
                                                <th>청구일자</th>
                                                <th>패널티 종류</th>
                                                <th>상세 사유</th>
                                                <th>금액</th>
                                                <th>결제상태</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="pen" items="${penaltyList}">
                                                <tr>
                                                    <td><fmt:formatDate value="${pen.createdAt}" pattern="yyyy-MM-dd"/></td>
                                                    <td><strong>${pen.penaltyType}</strong></td>
                                                    <td>${pen.reason} (예약 #${pen.reservationId})</td>
                                                    <td>₩<fmt:formatNumber value="${pen.amount}" pattern="#,###"/></td>
                                                    <td>
                                                        <span style="font-weight: bold; color: ${pen.isPaid eq 'Y' ? '#10b981' : '#ef4444'};">
                                                            ${pen.isPaid eq 'Y' ? '납부완료' : '미납'}
                                                        </span>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- ================= [사용자] 탭 2: 쿠폰 보관함 ================= -->
                <div id="tab-user-coupons" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:10px; font-family:'Outfit';">내 보유 쿠폰 보관함</h3>
                        <p class="sub-text" style="margin-bottom:25px;">바이크 예약 시 즉시 할인을 적용받을 수 있는 쿠폰입니다.</p>
                        <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap:20px;">
                            <c:choose>
                                <c:when test="${not empty couponList}">
                                    <c:forEach var="cp" items="${couponList}">
                                        <div class="coupon-card" style="background:linear-gradient(135deg, #181818, #0a0a0a); border:1px solid #E50914; border-radius:8px; padding:22px; position:relative; overflow:hidden;">
                                            <div style="font-size:0.75rem; color:#E50914; font-weight:bold; letter-spacing:1px; margin-bottom:5px;">BAREN OFF</div>
                                            <h4 style="font-size:1.15rem; margin-bottom:8px; font-family:'Outfit';">${cp.couponName}</h4>
                                            <div style="font-size:1.8rem; font-weight:800; color:#fff; margin-bottom:15px; font-family:'Outfit';">
                                                ₩<fmt:formatNumber value="${cp.discountAmount}" pattern="#,###"/>
                                            </div>
                                            <div style="font-size:0.75rem; color:#888;">
                                                발행일: <fmt:formatDate value="${cp.issueDate}" pattern="yyyy-MM-dd"/><br>
                                                만료일: <span style="color:#ef4444; font-weight:bold;"><fmt:formatDate value="${cp.expireDate}" pattern="yyyy-MM-dd"/></span>
                                            </div>
                                            <div style="position:absolute; right:-10px; bottom:-20px; font-size:6rem; opacity:0.04; font-weight:bold; pointer-events:none; color:#fff;">%</div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="no-data" style="grid-column:1/-1;">현재 사용 가능한 미사용 할인쿠폰이 없습니다.</div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- ================= [사용자] 탭 3: 1:1 문의 내역 ================= -->
                <div id="tab-user-inquiries" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222;">
                        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px; flex-wrap:wrap; gap:10px;">
                            <h3 style="font-family:'Outfit';">1:1 고객 문의 내역</h3>
                            <button class="btn btn-action-main" onclick="toggleInquiryForm()">새 문의 등록하기</button>
                        </div>
                        
                        <!-- 새 문의 작성 영역 (토글) -->
                        <div id="inquiry-form-box" style="display:none; background:#0d0d0d; border:1px solid #222; padding:20px; border-radius:8px; margin-bottom:30px;">
                            <h4 style="margin-bottom:15px; color:var(--primary-color); font-family:'Outfit';">새로운 1:1 문의글 작성</h4>
                            <form action="${pageContext.request.contextPath}/inquiryAction.do" method="post">
                                <div class="form-group" style="margin-bottom:12px;">
                                    <label style="font-size:0.85rem; color:#aaa;">문의 제목</label>
                                    <input type="text" name="title" required placeholder="문의 제목을 입력하세요." style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                </div>
                                <div class="form-group" style="margin-bottom:15px;">
                                    <label style="font-size:0.85rem; color:#aaa;">문의 내용</label>
                                    <textarea name="content" required placeholder="문의 사항을 상세히 남겨주시면 관리자가 빠른 시간 내 답변해 드립니다." style="width:100%; height:120px; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff; resize:none;"></textarea>
                                </div>
                                <button type="submit" class="btn btn-action-main">문의 등록</button>
                                <button type="button" class="btn btn-secondary-outline" onclick="toggleInquiryForm()" style="margin-left:10px;">취소</button>
                            </form>
                        </div>

                        <!-- 문의 목록 -->
                        <c:choose>
                            <c:when test="${not empty inquiryList}">
                                <c:forEach var="inq" items="${inquiryList}">
                                    <div class="accordion-inquiry">
                                        <div class="accordion-header" onclick="toggleAccordion(this)">
                                            <span>
                                                <span class="inquiry-status ${inq.status eq 'PENDING' ? 'inquiry-pending' : 'inquiry-answered'}">
                                                    ${inq.status eq 'PENDING' ? '답변 대기' : '답변 완료'}
                                                </span>
                                                &nbsp;&nbsp;<strong>${inq.title}</strong>
                                            </span>
                                            <span class="sub-text" style="font-size:0.8rem; color:#888;">
                                                등록일: <fmt:formatDate value="${inq.createdAt}" pattern="yyyy-MM-dd"/>
                                            </span>
                                        </div>
                                        <div class="accordion-content">
                                            <div style="background:#1e1e1e; padding:15px; border-radius:6px; margin-bottom:15px; white-space:pre-wrap;">
                                                <strong>[문의 내용]</strong><br><br>${inq.content}
                                            </div>
                                            <c:choose>
                                                <c:when test="${inq.status eq 'ANSWERED'}">
                                                    <div style="border-top:1px dashed #333; padding-top:15px; color:#10b981; white-space:pre-wrap;">
                                                        <strong>[관리자 답변]</strong> (${inq.answeredAt})<br><br>${inq.answerContent}
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div style="border-top:1px dashed #333; padding-top:15px; color:#888; font-style:italic;">
                                                        관리자가 문의 내용을 확인 중입니다. 잠시만 기다려 주세요.
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="no-data">등록된 1:1 고객 문의 내역이 없습니다.</div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- ================= [사용자] 탭: 면허증 관리 ================= -->
                <div id="tab-user-license" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222; max-width:800px;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">🪪 내 운전면허증 관리</h3>
                        
                        <!-- 현재 면허 상태 카드 -->
                        <div style="background:#0d0d0d; border:1px solid #222; padding:20px; border-radius:8px; margin-bottom:20px; display:flex; align-items:center; gap:20px;">
                            <div style="font-size:3rem;">🪪</div>
                            <div>
                                <h4 style="margin:0 0 5px 0; color:#fff;">면허 상태: 
                                    <span style="color: ${loginUser.licenseStatus eq 'APPROVED' ? '#10b981' : (loginUser.licenseStatus eq 'REJECTED' ? '#ef4444' : '#f59e0b')}; font-weight:bold;">
                                        <c:choose>
                                            <c:when test="${loginUser.licenseStatus eq 'APPROVED'}">인증 승인 완료</c:when>
                                            <c:when test="${loginUser.licenseStatus eq 'REJECTED'}">인증 반려됨</c:when>
                                            <c:otherwise>승인 대기 중</c:otherwise>
                                        </c:choose>
                                    </span>
                                </h4>
                                <p style="margin:0; font-size:0.9rem; color:#aaa;">등록된 면허증 번호: ${empty loginUser.licenseNumber ? '없음' : loginUser.licenseNumber}</p>
                            </div>
                        </div>

                        <!-- 반려 사유 및 안내 고지 -->
                        <c:if test="${loginUser.licenseStatus eq 'REJECTED'}">
                            <c:set var="latestRejectReason" value="면허 정보가 불명확하거나 누락되었습니다."/>
                            <c:forEach var="audit" items="${userLicenseAuditList}">
                                <c:if test="${audit.status eq 'REJECTED' and not empty audit.rejectReason}">
                                    <c:set var="latestRejectReason" value="${audit.rejectReason}"/>
                                </c:if>
                            </c:forEach>
                            <div style="background: rgba(229, 9, 20, 0.1); border: 1px solid #E50914; padding:15px; border-radius:6px; margin-bottom:20px; color:#ff3838; font-size:0.9rem;">
                                <strong>⚠️ 면허 반려 사유:</strong> ${latestRejectReason}<br/>
                                <span style="font-size:0.8rem; color:#ccc; margin-top:5px; display:block;">아래 폼을 이용하여 유효한 운전면허증 사진과 정보를 다시 제출해 주세요.</span>
                            </div>
                        </c:if>

                        <c:if test="${loginUser.licenseStatus eq 'PENDING'}">
                            <div style="background: rgba(245, 158, 11, 0.1); border: 1px solid #f59e0b; padding:15px; border-radius:6px; margin-bottom:20px; color:#f59e0b; font-size:0.9rem;">
                                <strong>⏳ 심사가 대기 중입니다.</strong><br/>
                                <span style="font-size:0.8rem; color:#ccc; margin-top:5px; display:block;">관리자가 업로드된 면허증을 확인하고 있습니다. 영업일 기준 보통 1~2시간 이내에 처리가 완료됩니다.</span>
                            </div>
                        </c:if>

                        <!-- 면허증 신청/재신청 폼 -->
                        <c:if test="${loginUser.licenseStatus ne 'APPROVED'}">
                            <h4 style="margin-bottom:10px; color:#fff;">면허 검증 신청하기</h4>
                            <div style="background:#0d0d0d; border:1px solid #222; padding:20px; border-radius:8px; margin-bottom:30px;">
                                <form action="${pageContext.request.contextPath}/userLicenseSubmitAction.do" method="post" enctype="multipart/form-data">
                                    <div class="form-group" style="margin-bottom:12px;">
                                        <label style="font-size:0.85rem; color:#aaa;">면허증 종류</label>
                                        <select name="licenseType" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                            <option value="2종소형">2종 소형 면허 (125cc 초과 기종 탑재 필수)</option>
                                            <option value="원동기">원동기 장치 자전거 면허 (125cc 이하 스쿠터 전용)</option>
                                            <option value="1종대형">1종 대형 면허</option>
                                            <option value="기타">기타 면허</option>
                                        </select>
                                    </div>

                                    <div class="form-group" style="margin-bottom:12px;">
                                        <label style="font-size:0.85rem; color:#aaa;">면허 번호</label>
                                        <input type="text" name="licenseNumber" required placeholder="예: 11-12-345678-01" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;"/>
                                    </div>

                                    <div class="form-group" style="margin-bottom:15px;">
                                        <label style="font-size:0.85rem; color:#aaa;">면허증 사진 첨부 (위조 여부 식별용)</label>
                                        <input type="file" name="licenseImage" accept="image/*" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;"/>
                                    </div>

                                    <button type="submit" class="btn btn-action-main" style="width:100%; padding:10px; font-weight:bold;">면허증 검증 심사 요청</button>
                                </form>
                            </div>
                        </c:if>

                        <!-- 심사 이력 목록 -->
                        <h4 style="margin-bottom:10px; color:#fff;">면허 심사 이력</h4>
                        <div class="table-wrapper">
                            <table class="mypage-table" style="font-size:0.85rem;">
                                <thead>
                                    <tr>
                                        <th>신청 ID</th>
                                        <th>면허 종류</th>
                                        <th>면허증 사진</th>
                                        <th>심사 상태</th>
                                        <th>반려 사유</th>
                                        <th>심사 일시 / 담당자</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty userLicenseAuditList}">
                                            <c:forEach var="audit" items="${userLicenseAuditList}">
                                                <tr>
                                                    <td>#${audit.auditId}</td>
                                                    <td>${audit.licenseType}</td>
                                                    <td>
                                                        <c:if test="${not empty audit.licenseImage}">
                                                            <a href="${pageContext.request.contextPath}/${audit.licenseImage}" target="_blank" style="color:var(--primary-color);">[이미지 보기]</a>
                                                        </c:if>
                                                        <c:if test="${empty audit.licenseImage}">-</c:if>
                                                    </td>
                                                    <td>
                                                        <span style="font-weight:bold; color: ${audit.status eq 'APPROVED' ? '#10b981' : (audit.status eq 'REJECTED' ? '#ef4444' : '#f59e0b')};">
                                                            <c:choose>
                                                                <c:when test="${audit.status eq 'APPROVED'}">승인 완료</c:when>
                                                                <c:when test="${audit.status eq 'REJECTED'}">반려됨</c:when>
                                                                <c:otherwise>대기 중</c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                    </td>
                                                    <td>${empty audit.rejectReason ? '-' : audit.rejectReason}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty audit.auditDate}">
                                                                <fmt:formatDate value="${audit.auditDate}" pattern="yyyy-MM-dd HH:mm"/><br/>
                                                                <span style="font-size:0.75rem; color:#777;">담당: ${audit.adminNickname}</span>
                                                            </c:when>
                                                            <c:otherwise>진행 중</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="6" style="text-align: center; padding: 20px; color: #888;">제출된 심사 신청 내역이 없습니다.</td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- ================= [사용자] 탭 4: 내 정보 수정 ================= -->
                <div id="tab-user-edit" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222; max-width:550px;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">회원 정보 수정</h3>
                        <form action="${pageContext.request.contextPath}/memberUpdateAction.do" method="post" onsubmit="return validateUpdateForm()">
                            <div class="form-group" style="margin-bottom:15px;">
                                <label>이메일 계정 (수정 불가)</label>
                                <input type="email" value="${loginUser.email}" disabled style="width:100%; padding:10px; border-radius:6px; background:#1c1c1c; border:1px solid #333; color:#666;">
                            </div>
                            
                            <div class="form-group" style="margin-bottom:15px;">
                                <label for="update-nickname">닉네임</label>
                                <input type="text" id="update-nickname" name="nickname" value="${loginUser.nickname}" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                            </div>

                            <div class="form-group" style="margin-bottom:15px;">
                                <label for="update-password">새 비밀번호</label>
                                <input type="password" id="update-password" name="password_hash" placeholder="새 비밀번호 입력 (8자 이상)" required minlength="8" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                            </div>

                            <div class="form-group" style="margin-bottom:20px;">
                                <label for="update-password-confirm">비밀번호 확인</label>
                                <input type="password" id="update-password-confirm" placeholder="새 비밀번호 재입력" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                                <span id="update-pwd-error" style="color: #ff3838; font-size: 0.8rem; display: none; margin-top: 5px;">비밀번호가 일치하지 않습니다.</span>
                            </div>

                            <button type="submit" class="btn btn-action-main" style="width:100%; padding:12px;">정보 수정 완료</button>
                        </form>
                    </div>
                </div>

                <!-- ================= [사용자] 탭 6: 내 결제 이력 ================= -->
                <div id="tab-user-payment" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">💳 내 결제 및 취소 내역</h3>
                        <div class="table-wrapper">
                            <table class="mypage-table">
                                <thead>
                                    <tr>
                                        <th>결제번호</th>
                                        <th>예약번호</th>
                                        <th>결제 수단</th>
                                        <th>PG사 승인번호</th>
                                        <th>결제 금액</th>
                                        <th>결제 일시</th>
                                        <th>결제 상태</th>
                                        <th>취소/환불 금액</th>
                                        <th>취소 신청</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty userPaymentList}">
                                            <c:forEach var="pay" items="${userPaymentList}">
                                                <tr>
                                                    <td>#${pay.paymentId}</td>
                                                    <td>#${pay.reservationId}</td>
                                                    <td><span style="padding:2px 6px; background:#222; border-radius:4px; font-weight:bold;">${pay.paymentMethod}</span></td>
                                                    <td><code style="color:#aaa;">${pay.pgApprovalNum}</code></td>
                                                    <td>₩<fmt:formatNumber value="${pay.amount}" pattern="#,###"/></td>
                                                    <td><span style="font-size:0.8rem;"><fmt:formatDate value="${pay.paidAt}" pattern="yyyy-MM-dd HH:mm"/></span></td>
                                                    <td>
                                                        <span class="status-badge" style="padding: 2px 6px; border-radius: 4px; font-size: 0.8rem; font-weight: bold; 
                                                            background: ${pay.paymentStatus eq '결제완료' ? '#10b981' : (pay.paymentStatus eq '부분취소' ? '#f59e0b' : '#ef4444')}; color: #fff;">
                                                            ${pay.paymentStatus}
                                                        </span>
                                                    </td>
                                                    <td style="color:${pay.refundAmount > 0 ? '#ef4444' : '#666'}; font-weight:bold;">
                                                        ₩<fmt:formatNumber value="${pay.refundAmount}" pattern="#,###"/>
                                                    </td>
                                                    <td>
                                                        <c:if test="${pay.paymentStatus eq '결제완료'}">
                                                            <form action="${pageContext.request.contextPath}/paymentCancelAction.do" method="post" onsubmit="return confirm('해당 결제를 정말 취소/환불하시겠습니까?');" style="display:inline;">
                                                                <input type="hidden" name="paymentId" value="${pay.paymentId}"/>
                                                                <input type="hidden" name="cancelType" value="FULL"/>
                                                                <input type="hidden" name="cancelAmount" value="${pay.amount}"/>
                                                                <button type="submit" class="btn-sm" style="padding: 4px 8px; border:none; border-radius: 4px; background: #ef4444; color: #fff; font-weight:bold; cursor:pointer;">결제취소</button>
                                                            </form>
                                                        </c:if>
                                                        <c:if test="${pay.paymentStatus ne '결제완료'}">
                                                            <span style="color:#666;">신청 불가</span>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="9" style="text-align: center; padding: 20px; color: #888;">결제 내역이 존재하지 않습니다.</td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- ================= [사용자] 탭 7: 내 알림함 ================= -->
                <div id="tab-user-notification" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">🔔 내 알림함</h3>
                        <div class="table-wrapper">
                            <table class="mypage-table">
                                <thead>
                                    <tr>
                                        <th>알림번호</th>
                                        <th>알림 타입</th>
                                        <th>알림 내용</th>
                                        <th>수신 일시</th>
                                        <th>읽음 표시</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty userNotificationList}">
                                            <c:forEach var="noti" items="${userNotificationList}">
                                                <tr style="opacity: ${noti.isReceived eq 'Y' ? '0.6' : '1.0'};">
                                                    <td>#${noti.notificationId}</td>
                                                    <td><span style="padding:2px 6px; background:#222; border-radius:4px; font-weight:bold; color:var(--primary-color);">${noti.notificationType}</span></td>
                                                    <td style="text-align:left; font-size: 0.9rem; padding-left: 15px;">${noti.content}</td>
                                                    <td><span style="font-size:0.8rem;"><fmt:formatDate value="${noti.createdAt}" pattern="yyyy-MM-dd HH:mm"/></span></td>
                                                    <td>
                                                        <c:if test="${noti.isReceived eq 'N'}">
                                                            <form action="${pageContext.request.contextPath}/userNotificationReadAction.do" method="post" style="display:inline;">
                                                                <input type="hidden" name="notificationId" value="${noti.notificationId}"/>
                                                                <button type="submit" class="btn-sm" style="padding: 4px 8px; border:none; border-radius: 4px; background: var(--primary-color); color: #fff; font-weight:bold; cursor:pointer;">읽음표시</button>
                                                            </form>
                                                        </c:if>
                                                        <c:if test="${noti.isReceived eq 'Y'}">
                                                            <span style="color:#666;">읽음</span>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="5" style="text-align: center; padding: 20px; color: #888;">수신된 알림 메세지가 없습니다.</td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- 🪙 내 포인트/등급 탭 -->
                <div id="tab-user-point" class="tab-content">
                    <div style="display:flex; gap:20px; margin-bottom:25px;">
                        <div class="panel-form" style="flex:1; border:1px solid #222; text-align:center; padding:30px;">
                            <h4 style="color:#aaa; margin-bottom:10px;">현재 회원 등급</h4>
                            <h2 style="font-family:'Outfit'; color:#e0a82e; font-size:2.5rem; margin-bottom:10px;">
                                <c:choose>
                                    <c:when test="${loginUser.userGrade eq 'VIP'}">👑 VIP 등급</c:when>
                                    <c:when test="${loginUser.userGrade eq 'GOLD'}">✨ GOLD 등급</c:when>
                                    <c:otherwise>🚲 SILVER 등급</c:otherwise>
                                </c:choose>
                            </h2>
                            <p style="color:#ccc; font-size:0.95rem;">
                                <c:choose>
                                    <c:when test="${loginUser.userGrade eq 'VIP'}">대여료 <strong>10% 즉시 할인</strong> & 결제 금액의 <strong>10% 포인트 적립</strong></c:when>
                                    <c:when test="${loginUser.userGrade eq 'GOLD'}">대여료 <strong>5% 즉시 할인</strong> & 결제 금액의 <strong>7% 포인트 적립</strong></c:when>
                                    <c:otherwise>결제 금액의 <strong>5% 포인트 적립</strong> (GOLD 등급 달성 시 5% 할인 혜택)</c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                        <div class="panel-form" style="flex:1; border:1px solid #222; text-align:center; padding:30px; display:flex; flex-direction:column; justify-content:center; align-items:center;">
                            <h4 style="color:#aaa; margin-bottom:10px;">보유 포인트</h4>
                            <h2 style="font-family:'Outfit'; color:var(--primary-color); font-size:2.5rem; margin-bottom:10px;">
                                <fmt:formatNumber value="${loginUser.point}" pattern="#,###"/> P
                            </h2>
                            <p style="color:#888; font-size:0.85rem;">대여 예약 시 현금처럼 제한 없이 사용 가능합니다.</p>
                        </div>
                    </div>

                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">🪙 포인트 적립 및 사용 이력</h3>
                        <div class="table-wrapper">
                            <table class="mypage-table">
                                <thead>
                                    <tr>
                                        <th>이력번호</th>
                                        <th>변동 포인트</th>
                                        <th>변동 사유</th>
                                        <th>남은 포인트</th>
                                        <th>변동 일시</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty userPointList}">
                                            <c:forEach var="ph" items="${userPointList}">
                                                <tr>
                                                    <td>#${ph.historyId}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${ph.amount > 0}">
                                                                <span style="color:#28a745; font-weight:bold;">+<fmt:formatNumber value="${ph.amount}" pattern="#,###"/> P</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="color:#e50914; font-weight:bold;"><fmt:formatNumber value="${ph.amount}" pattern="#,###"/> P</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td style="text-align:left; padding-left:15px;">${ph.reason}</td>
                                                    <td><strong><fmt:formatNumber value="${ph.accumulatedPoints}" pattern="#,###"/> P</strong></td>
                                                    <td><fmt:formatDate value="${ph.createdAt}" pattern="yyyy-MM-dd HH:mm"/></td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="5" style="text-align:center; padding:20px; color:#888;">포인트 이력이 없습니다.</td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- 💥 사고 접수 내역 탭 -->
                <div id="tab-user-accident" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222; margin-bottom:20px; display:flex; justify-content:space-between; align-items:center;">
                        <div>
                            <h3 style="font-family:'Outfit';">💥 내 사고 접수 및 처리 내역</h3>
                            <p style="color:#aaa; font-size:0.85rem; margin-top:5px;">대여 중 발생한 사고에 대한 현황 및 보험 처리 상태를 조회합니다.</p>
                        </div>
                        <button onclick="openAccidentReportModal()" class="btn" style="background:#e50914; color:#fff; font-weight:bold; padding:10px 20px; border:none; border-radius:6px; cursor:pointer;">🚨 사고 접수 신고하기</button>
                    </div>

                    <div class="panel-form" style="border:1px solid #222;">
                        <div class="table-wrapper">
                            <table class="mypage-table">
                                <thead>
                                    <tr>
                                        <th>접수번호</th>
                                        <th>예약번호</th>
                                        <th>사고일시</th>
                                        <th>사고장소</th>
                                        <th>현장사진</th>
                                        <th>보험접수번호</th>
                                        <th>과실비율</th>
                                        <th>처리상태</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty userAccidentList}">
                                            <c:forEach var="acc" items="${userAccidentList}">
                                                <tr>
                                                    <td><strong>#${acc.reportId}</strong></td>
                                                    <td>#${acc.reservationId}</td>
                                                    <td><fmt:formatDate value="${acc.accidentDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                                                    <td>${acc.accidentLocation}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty acc.photoPath}">
                                                                <a href="${pageContext.request.contextPath}/${acc.photoPath}" target="_blank" style="color:var(--primary-color); text-decoration:underline;">[사진보기]</a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="color:#666;">없음</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty acc.insuranceClaimNum}">
                                                                <strong>${acc.insuranceClaimNum}</strong>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="color:#888; font-size:0.85rem;">접수 검토 중</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${acc.status eq '접수'}">
                                                                <span style="color:#888; font-size:0.85rem;">확정 전</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <strong>${acc.faultRatio}%</strong>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${acc.status eq '접수'}">
                                                                <span style="background:#444; color:#fff; padding:3px 8px; border-radius:12px; font-size:0.8rem; font-weight:bold;">접수</span>
                                                            </c:when>
                                                            <c:when test="${acc.status eq '손해사정중'}">
                                                                <span style="background:#e0a82e; color:#000; padding:3px 8px; border-radius:12px; font-size:0.8rem; font-weight:bold;">손해사정중</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="background:#28a745; color:#fff; padding:3px 8px; border-radius:12px; font-size:0.8rem; font-weight:bold;">종결</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                                <tr style="background:#151515;">
                                                    <td colspan="8" style="padding:10px 15px; border-top:none; text-align:left;">
                                                        <div style="font-size:0.85rem; color:#ccc; line-height:1.5;">
                                                            <strong>💬 사고경위:</strong> ${acc.accidentDescription}
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="8" style="text-align:center; padding:20px; color:#888;">접수 내역이 없습니다.</td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <!-- 💸 내 환불 내역 탭 -->
                <div id="tab-user-refund" class="tab-content">
                    <div class="panel-form" style="border:1px solid #222;">
                        <h3 style="margin-bottom:15px; font-family:'Outfit';">💸 내 환불 내역</h3>
                        <div class="table-wrapper">
                            <table class="mypage-table">
                                <thead>
                                    <tr>
                                        <th>환불번호</th>
                                        <th>결제번호</th>
                                        <th>예약번호</th>
                                        <th>결제 금액</th>
                                        <th>적용 위약금율</th>
                                        <th>최종 환불금액</th>
                                        <th>환불 수단</th>
                                        <th>취소 요청일시</th>
                                        <th>처리 상태</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${not empty userRefundList}">
                                            <c:forEach var="ref" items="${userRefundList}">
                                                <tr>
                                                    <td><strong>#${ref.refundId}</strong></td>
                                                    <td>#${ref.paymentId}</td>
                                                    <td>#${ref.reservationId}</td>
                                                    <td>₩<fmt:formatNumber value="${ref.paymentAmount}" pattern="#,###"/></td>
                                                    <td style="color:#ef4444; font-weight:bold;">${ref.penaltyRate}%</td>
                                                    <td style="color:#10b981; font-weight:bold;">₩<fmt:formatNumber value="${ref.refundAmount}" pattern="#,###"/></td>
                                                    <td><span style="padding:2px 6px; background:#222; border-radius:4px; font-weight:bold;">${ref.refundMethod}</span></td>
                                                    <td><span style="font-size:0.8rem;"><fmt:formatDate value="${ref.cancelRequestDate}" pattern="yyyy-MM-dd HH:mm"/></span></td>
                                                    <td>
                                                        <span style="background:#10b981; color:#fff; padding:3px 8px; border-radius:12px; font-size:0.8rem; font-weight:bold;">${ref.status}</span>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <tr>
                                                <td colspan="9" style="text-align:center; padding:30px; color:#888;">환불 내역이 없습니다.</td>
                                            </tr>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<!-- 사용자 리뷰 작성 모달 -->
<div id="review-modal" class="modal-overlay" style="display:none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.85); z-index: 1000; align-items: center; justify-content: center;">
    <div class="modal-content" style="background:#121212; border:1px solid #333; padding:30px; border-radius:10px; max-width:500px; width:90%; color:#fff; position:relative;">
        <span class="close-btn" onclick="closeReviewModal()" style="position: absolute; top: 15px; right: 20px; font-size: 2rem; cursor: pointer; color: #aaa;">&times;</span>
        <h2 style="color: var(--primary-color); margin-bottom: 10px; font-family:'Outfit';">이용 후기 리뷰 작성</h2>
        <p style="color:#aaa; margin-bottom:20px;" id="review-bike-model-name"></p>
        
        <form action="${pageContext.request.contextPath}/reviewAction.do" method="post">
            <input type="hidden" name="bookingId" id="review-booking-id">
            <input type="hidden" name="reservationId" id="review-reservation-id"> <!-- bookingId와 동일하게 매핑 -->
            <input type="hidden" name="bikeId" id="review-bike-id">
            
            <div class="form-group" style="margin-bottom:15px;">
                <label>평점 선택</label>
                <select name="rating" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                    <option value="5">★★★★★ (5점 만점 - 아주 만족해요)</option>
                    <option value="4">★★★★☆ (4점 - 만족해요)</option>
                    <option value="3">★★★☆☆ (3점 - 보통이에요)</option>
                    <option value="2">★★☆☆☆ (2점 - 그냥 그래요)</option>
                    <option value="1">★☆☆☆☆ (1점 - 불만족해요)</option>
                </select>
            </div>
            
            <div class="form-group" style="margin-bottom:15px;">
                <label>리뷰 한줄평 제목</label>
                <input type="text" name="title" required placeholder="예: 승차감도 좋고 대여도 편했습니다!" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
            </div>
            
            <div class="form-group" style="margin-bottom:20px;">
                <label>상세 이용 소감</label>
                <textarea name="content" required placeholder="라이딩에 대한 솔직한 후기를 남겨주세요." style="width:100%; height:120px; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff; resize:none;"></textarea>
            </div>
            
            <button type="submit" class="btn btn-action-main" style="width:100%; padding:12px; font-weight:bold;">리뷰 등록하기</button>
        </form>
    </div>
</div>

<!-- 관리자 결제 취소/환불 모달 -->
<div id="refund-modal" class="modal-overlay" style="display:none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.85); z-index: 1000; align-items: center; justify-content: center;">
    <div class="modal-content" style="background:#121212; border:1px solid #333; padding:30px; border-radius:10px; max-width:500px; width:90%; color:#fff; position:relative;">
        <span class="close-btn" onclick="closeRefundModal()" style="position: absolute; top: 15px; right: 20px; font-size: 2rem; cursor: pointer; color: #aaa;">&times;</span>
        <h2 style="color: var(--primary-color); margin-bottom: 10px; font-family:'Outfit';">💳 결제 취소 및 환불 처리</h2>
        <p style="color:#aaa; margin-bottom:20px;">결제 건에 대해 부분 또는 전체 취소/환불 처리를 기록합니다.</p>
        
        <form action="${pageContext.request.contextPath}/paymentCancelAction.do" method="post" onsubmit="return validateRefundForm()">
            <input type="hidden" name="paymentId" id="refund-payment-id">
            
            <div class="form-group" style="margin-bottom:15px;">
                <label>취소 방식 선택</label>
                <select name="cancelType" id="refund-cancel-type" onchange="adjustRefundLimit()" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                    <option value="FULL">전체 취소 (예약도 자동 취소 처리됨)</option>
                    <option value="PARTIAL">부분 취소 (일부 금액만 차감 환불)</option>
                </select>
            </div>
            
            <div class="form-group" style="margin-bottom:15px;">
                <label>결제 원금</label>
                <input type="text" id="refund-amount-orig-display" disabled style="width:100%; padding:10px; border-radius:6px; background:#1c1c1c; border:1px solid #333; color:#888;"/>
            </div>

            <div class="form-group" style="margin-bottom:15px;">
                <label>기존 취소/환불 완료 누적액</label>
                <input type="text" id="refund-amount-prev-display" disabled style="width:100%; padding:10px; border-radius:6px; background:#1c1c1c; border:1px solid #333; color:#888;"/>
            </div>
            
            <div class="form-group" style="margin-bottom:20px;">
                <label>금회 취소/환불 처리 금액 (₩)</label>
                <input type="number" name="cancelAmount" id="refund-cancel-amount" required placeholder="취소할 금액 입력" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;"/>
                <p style="font-size:0.75rem; color:#888; margin-top:4px;" id="refund-limit-text"></p>
            </div>
            
            <button type="submit" class="btn btn-action-main" style="width:100%; padding:12px; font-weight:bold; background:#ef4444;">환불/취소 승인</button>
        </form>
    </div>
</div>

<!-- 사용자 사고 접수 모달 -->
<div id="user-accident-modal" class="modal-overlay" style="display:none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.85); z-index: 1000; align-items: center; justify-content: center;">
    <div class="modal-content" style="background:#121212; border:1px solid #333; padding:30px; border-radius:10px; max-width:500px; width:90%; color:#fff; position:relative;">
        <span class="close-btn" onclick="closeAccidentReportModal()" style="position: absolute; top: 15px; right: 20px; font-size: 2rem; cursor: pointer; color: #aaa;">&times;</span>
        <h2 style="color: var(--primary-color); margin-bottom: 10px; font-family:'Outfit';">🚨 사고 접수 및 대여 신고</h2>
        <p style="color:#aaa; margin-bottom:20px;">사고 발생 현황 및 피해 내용을 작성해 주세요.</p>
        
        <form action="${pageContext.request.contextPath}/userAccidentReportAction.do" method="post" enctype="multipart/form-data">
            <div class="form-group" style="margin-bottom: 15px;">
                <label style="display:block; margin-bottom:5px; color:#aaa; font-size:0.85rem;">사고 관련 예약 선택</label>
                <select name="reservationId" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                    <option value="">-- 사고 대상 예약 건 선택 --</option>
                    <c:forEach var="res" items="${bookingList}">
                        <option value="${res.bookingId}">예약 #${res.bookingId} (${res.bikeName} | 대여일: <fmt:formatDate value="${res.startDate}" pattern="yyyy-MM-dd"/>)</option>
                    </c:forEach>
                </select>
            </div>
            
            <div class="form-group" style="margin-bottom: 15px;">
                <label style="display:block; margin-bottom:5px; color:#aaa; font-size:0.85rem;">사고 발생 일시</label>
                <input type="datetime-local" name="accidentDate" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
            </div>

            <div class="form-group" style="margin-bottom: 15px;">
                <label style="display:block; margin-bottom:5px; color:#aaa; font-size:0.85rem;">사고 장소</label>
                <input type="text" name="accidentLocation" placeholder="예: 대구 중구 반월당네거리 인근" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
            </div>
            
            <div class="form-group" style="margin-bottom: 15px;">
                <label style="display:block; margin-bottom:5px; color:#aaa; font-size:0.85rem;">사고 경위</label>
                <textarea name="accidentDescription" placeholder="사고가 발생한 구체적인 정황과 바이크 손상 정도를 상세하게 기재해 주세요." required style="width:100%; height:100px; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff; resize:none;"></textarea>
            </div>

            <div class="form-group" style="margin-bottom: 20px;">
                <label style="display:block; margin-bottom:5px; color:#aaa; font-size:0.85rem;">현장 사진 첨부</label>
                <input type="file" name="photo" accept="image/*" style="width:100%; padding:8px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
            </div>
            
            <button type="submit" class="btn btn-action-main" style="width:100%; padding:12px; font-weight:bold; background:#e50914; color:#fff; border:none; border-radius:6px; cursor:pointer;">사고 접수 신청하기</button>
        </form>
    </div>
</div>

<!-- 관리자 사고 처리 변경 모달 -->
<div id="admin-accident-modal" class="modal-overlay" style="display:none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.85); z-index: 1000; align-items: center; justify-content: center;">
    <div class="modal-content" style="background:#121212; border:1px solid #333; padding:30px; border-radius:10px; max-width:500px; width:90%; color:#fff; position:relative;">
        <span class="close-btn" onclick="closeAccidentModal()" style="position: absolute; top: 15px; right: 20px; font-size: 2rem; cursor: pointer; color: #aaa;">&times;</span>
        <h2 style="color: var(--primary-color); margin-bottom: 10px; font-family:'Outfit';">🛠️ 사고 처리 및 보험 등록</h2>
        <p style="color:#aaa; margin-bottom:20px;" id="admin-accident-info-text">사고 건에 대한 손해사정 정보 및 상태를 업데이트합니다.</p>
        
        <form action="${pageContext.request.contextPath}/adminAccidentReportUpdateAction.do" method="post">
            <input type="hidden" name="reportId" id="admin-accident-report-id">
            
            <div class="form-group" style="margin-bottom: 15px;">
                <label style="display:block; margin-bottom:5px; color:#aaa; font-size:0.85rem;">처리 상태</label>
                <select name="status" id="admin-accident-status" required style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
                    <option value="접수">접수</option>
                    <option value="손해사정중">손해사정중</option>
                    <option value="종결">종결</option>
                </select>
            </div>
            
            <div class="form-group" style="margin-bottom: 15px;">
                <label style="display:block; margin-bottom:5px; color:#aaa; font-size:0.85rem;">보험 접수 번호</label>
                <input type="text" name="insuranceClaimNum" id="admin-accident-claim-num" placeholder="예: INS-2026-987654" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
            </div>

            <div class="form-group" style="margin-bottom: 20px;">
                <label style="display:block; margin-bottom:5px; color:#aaa; font-size:0.85rem;">고객 과실 비율 (%)</label>
                <input type="number" name="faultRatio" id="admin-accident-fault-ratio" min="0" max="100" value="0" style="width:100%; padding:10px; border-radius:6px; background:#2a2a2a; border:1px solid #444; color:#fff;">
            </div>
            
            <button type="submit" class="btn btn-action-main" style="width:100%; padding:12px; font-weight:bold; background:#e50914; color:#fff; border:none; border-radius:6px; cursor:pointer;">상태 변경 및 등록</button>
        </form>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

<script>
    // 탭 동작
    function openTab(evt, tabId) {
        let i, tabcontent, tablinks;
        tabcontent = document.getElementsByClassName("tab-content");
        for (i = 0; i < tabcontent.length; i++) {
            tabcontent[i].classList.remove("active");
        }
        tablinks = document.getElementsByClassName("tab-btn");
        for (i = 0; i < tablinks.length; i++) {
            tablinks[i].classList.remove("active");
        }
        document.getElementById(tabId).classList.add("active");
        evt.currentTarget.classList.add("active");
    }

    // 1:1 문의 아코디언 토글
    function toggleAccordion(headerElement) {
        const content = headerElement.nextElementSibling;
        if (content.style.display === "block") {
            content.style.display = "none";
        } else {
            content.style.display = "block";
        }
    }

    // 새 1:1 문의 작성 상자 토글
    function toggleInquiryForm() {
        const box = document.getElementById("inquiry-form-box");
        if (box.style.display === "none") {
            box.style.display = "block";
        } else {
            box.style.display = "none";
        }
    }

    // 리뷰 작성 모달 열기/닫기
    function openReviewModal(bookingId, bikeId, bikeName) {
        document.getElementById("review-booking-id").value = bookingId;
        document.getElementById("review-reservation-id").value = bookingId; // reservationId는 bookingId와 매핑
        document.getElementById("review-bike-id").value = bikeId;
        document.getElementById("review-bike-model-name").innerText = "모델명: " + bikeName;
        document.getElementById("review-modal").style.display = "flex";
    }
    
    function closeReviewModal() {
        document.getElementById("review-modal").style.display = "none";
    }

    // 탈퇴 확인
    function confirmWithdrawal() {
        if (confirm("정말로 탈퇴하시겠습니까?\n탈퇴 시 대여 내역을 포함한 모든 계정 정보가 즉시 삭제됩니다.")) {
            location.href = "${pageContext.request.contextPath}/memberDeleteAction.do";
        }
    }

    // 어드민 패널티 부과 시 대상자 정보 실시간 바인딩
    function updatePenaltyUser() {
        let sel = document.getElementById('penalty-res-selector');
        if (!sel) return;
        let opt = sel.options[sel.selectedIndex];
        if (opt && opt.value !== "") {
            let userId = opt.getAttribute('data-userid');
            let userName = opt.getAttribute('data-username');
            document.getElementById('penalty-user-id').value = userId;
            document.getElementById('penalty-user-name').value = userName;
        } else {
            document.getElementById('penalty-user-id').value = "";
            document.getElementById('penalty-user-name').value = "";
        }
    }

    // 정보 수정 비밀번호 일치 검사
    function validateUpdateForm() {
        const pwd = document.getElementById('update-password').value;
        const pwdConfirm = document.getElementById('update-password-confirm').value;
        const err = document.getElementById('update-pwd-error');

        if (pwd !== pwdConfirm) {
            err.style.display = 'block';
            document.getElementById('update-password-confirm').focus();
            return false;
        } else {
            err.style.display = 'none';
        }
        return true;
    }

    // 면허 심사 승인
    function approveLicense(auditId) {
        if (confirm("해당 면허 검증 신청을 승인하시겠습니까?\n승인 시 사용자의 면허 상태가 '승인 완료'로 즉시 변경됩니다.")) {
            location.href = "${pageContext.request.contextPath}/adminLicenseAuditAction.do?auditId=" + auditId + "&status=APPROVED";
        }
    }

    // 면허 심사 반려
    function rejectLicense(auditId) {
        let reason = prompt("반려 사유를 입력해 주세요:", "첨부된 면허증 사진이 흐릿하여 식별할 수 없습니다.");
        if (reason === null) return; // 취소 버튼
        if (reason.trim() === "") {
            alert("반려 사유는 필수 입력 사항입니다.");
            return;
        }
        location.href = "${pageContext.request.contextPath}/adminLicenseAuditAction.do?auditId=" + auditId + "&status=REJECTED&rejectReason=" + encodeURIComponent(reason);
    }

    // 반납 주유 패널티 실시간 계산
    function calculateFuelPenalty() {
        let levelInput = document.getElementById("fuel-level-input");
        let calcBox = document.getElementById("fuel-penalty-calc-box");
        let display = document.getElementById("fuel-penalty-display");
        
        if (!levelInput || !calcBox || !display) return;
        
        let val = levelInput.value;
        if (val === "" || isNaN(val)) {
            calcBox.style.display = "none";
            return;
        }
        
        let fuelLevel = parseInt(val);
        if (fuelLevel < 0 || fuelLevel > 100) {
            calcBox.style.display = "none";
            return;
        }
        
        if (fuelLevel < 100) {
            let penalty = (100 - fuelLevel) * 1000;
            display.innerText = "₩" + penalty.toLocaleString();
            calcBox.style.display = "block";
        } else {
            display.innerText = "₩0 (패널티 없음)";
            calcBox.style.display = "block";
        }
    }

    // 결제 취소 환불 모달 함수
    let maxRefundable = 0;
    function openRefundModal(paymentId, origAmount, prevRefund) {
        document.getElementById("refund-payment-id").value = paymentId;
        document.getElementById("refund-amount-orig-display").value = "₩" + origAmount.toLocaleString();
        document.getElementById("refund-amount-prev-display").value = "₩" + prevRefund.toLocaleString();
        
        maxRefundable = origAmount - prevRefund;
        document.getElementById("refund-cancel-amount").value = maxRefundable;
        document.getElementById("refund-limit-text").innerText = "* 환불 가능 한도: ₩" + maxRefundable.toLocaleString();
        
        document.getElementById("refund-cancel-type").value = "FULL";
        document.getElementById("refund-cancel-amount").readOnly = true;
        
        document.getElementById("refund-modal").style.display = "flex";
    }
    
    function adjustRefundLimit() {
        const type = document.getElementById("refund-cancel-type").value;
        const amtInput = document.getElementById("refund-cancel-amount");
        if (type === "FULL") {
            amtInput.value = maxRefundable;
            amtInput.readOnly = true;
        } else {
            amtInput.readOnly = false;
            amtInput.value = "";
            amtInput.focus();
        }
    }
    
    function closeRefundModal() {
        document.getElementById("refund-modal").style.display = "none";
    }
    
    function validateRefundForm() {
        const amt = parseInt(document.getElementById("refund-cancel-amount").value);
        if (isNaN(amt) || amt <= 0) {
            alert("환불 취소 금액은 0보다 큰 숫자로 입력해야 합니다.");
            return false;
        }
        if (amt > maxRefundable) {
            alert("취소 환불 요청 금액(₩" + amt.toLocaleString() + ")이 남은 환불 한도(₩" + maxRefundable.toLocaleString() + ")를 초과했습니다.");
            return false;
        }
        return confirm("정말로 취소/환불 처리를 완료하시겠습니까?");
    }

    // 사용자 사고 접수 모달 열기/닫기
    function openAccidentReportModal() {
        document.getElementById("user-accident-modal").style.display = "flex";
    }
    function closeAccidentReportModal() {
        document.getElementById("user-accident-modal").style.display = "none";
    }

    // 관리자 사고 처리 모달 열기/닫기
    function openAccidentModal(reportId, status, claimNum, faultRatio) {
        document.getElementById("admin-accident-report-id").value = reportId;
        document.getElementById("admin-accident-status").value = status;
        document.getElementById("admin-accident-claim-num").value = (claimNum === 'null' || claimNum === 'undefined') ? '' : claimNum;
        document.getElementById("admin-accident-fault-ratio").value = faultRatio || 0;
        document.getElementById("admin-accident-info-text").innerText = "사고 건 #" + reportId + "번의 처리 정보 및 보험 심사 결과를 입력합니다.";
        document.getElementById("admin-accident-modal").style.display = "flex";
    }
    function closeAccidentModal() {
        document.getElementById("admin-accident-modal").style.display = "none";
    }

    // 블랙리스트 차단 기간 설정에 따른 만료일 표시 여부 토글
    function toggleBanDate() {
        let type = document.getElementById("ban-type-selector").value;
        let dateGroup = document.getElementById("ban-date-group");
        if (type === "기간차단") {
            dateGroup.style.display = "block";
            dateGroup.querySelector('input[type="date"]').required = true;
        } else {
            dateGroup.style.display = "none";
            dateGroup.querySelector('input[type="date"]').required = false;
            dateGroup.querySelector('input[type="date"]').value = "";
        }
    }
</script>
