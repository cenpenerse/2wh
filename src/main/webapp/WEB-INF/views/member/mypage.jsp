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

    <!-- 2. 탭 메뉴 영역 -->
    <div class="mypage-tabs">
        <c:choose>
            <c:when test="${loginUser.memberStatus eq 'ADMIN'}">
                <button class="tab-btn active" onclick="openTab(event, 'tab-admin-bookings')">📋 전체 예약 관리</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-members')">👥 가입 회원 목록</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-crud')">🛠️ 바이크/지점/브랜드 관리</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-inquiries')">💬 1:1 문의 답변 관리</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-coupons')">🎫 쿠폰 발급</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-admin-penalties')">💸 패널티 및 벌금 관리</button>
            </c:when>
            <c:otherwise>
                <button class="tab-btn active" onclick="openTab(event, 'tab-user-bookings')">🏍️ 내 예약 내역</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-user-coupons')">🎫 쿠폰 보관함</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-user-inquiries')">💬 1:1 문의 내역</button>
                <button class="tab-btn" onclick="openTab(event, 'tab-user-edit')">👤 내 정보 수정</button>
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
                                                <th>지점명</th>
                                                <th>연락처 / 주소</th>
                                                <th>동작</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="sh" items="${adminShopList}">
                                                <tr>
                                                    <td>${sh.shopId}</td>
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
                                <form action="${pageContext.request.contextPath}/adminShopAddAction.do" method="post">
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
                                                        <c:if test="${book.bookingStatus eq 'PENDING'}">
                                                            <a href="${pageContext.request.contextPath}/bookingCancelAction.do?bookingId=${book.bookingId}" class="btn-sm btn-reject" onclick="return confirm('정말로 예약을 취소하시겠습니까?');">대여취소</a>
                                                        </c:if>
                                                        <c:if test="${book.bookingStatus eq 'APPROVED'}">
                                                            <!-- 리뷰 작성 버튼 제공 -->
                                                            <button class="btn-sm btn-approve" onclick="openReviewModal('${book.bookingId}', '${book.bikeId}', '${book.bikeName}')">리뷰작성</button>
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
</script>
