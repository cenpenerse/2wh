<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="loginUser" value="${sessionScope.loginUser}" />
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Baren - 프리미엄 바이크 렌탈 서비스</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css?v=3.0">
    <!-- Google Fonts Inter, Outfit -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@400;600;800&display=swap" rel="stylesheet">
</head>
<body>
    <nav class="navbar">
        <div class="max-width">
            <div class="logo"><a href="${pageContext.request.contextPath}/index.do">BAREN<span>.</span></a></div>
            
            <ul class="menu">
                <li><a href="${pageContext.request.contextPath}/index.do">Home</a></li>
                <li><a href="${pageContext.request.contextPath}/bikeInfo.do">바이크 종류</a></li>
                <li><a href="${pageContext.request.contextPath}/bikeList.do">대여/예약</a></li>
                <li class="dropdown">
                    <a href="${pageContext.request.contextPath}/gearInfo.do">대여 장비</a>
                    <ul class="dropdown-menu">
                        <li><a href="${pageContext.request.contextPath}/gearInfo.do#helmet">헬멧</a></li>
                        <li><a href="${pageContext.request.contextPath}/gearInfo.do#intercom">인터콤</a></li>
                        <li><a href="${pageContext.request.contextPath}/gearInfo.do#topbox">탑박스</a></li>
                        <li><a href="${pageContext.request.contextPath}/gearInfo.do#holder">거치대</a></li>
                        <li><a href="${pageContext.request.contextPath}/gearInfo.do#protector">보호대</a></li>
                    </ul>
                </li>
                <li><a href="${pageContext.request.contextPath}/pricing.do">요금 안내</a></li>
                <li class="dropdown">
                    <a href="${pageContext.request.contextPath}/boardList.do?boardType=FREE">게시판</a>
                    <ul class="dropdown-menu">
                        <li><a href="${pageContext.request.contextPath}/boardList.do?boardType=REVIEW">이용후기 게시판</a></li>
                        <li><a href="${pageContext.request.contextPath}/boardList.do?boardType=FREE">자유게시판</a></li>
                    </ul>
                </li>
                <li class="dropdown">
                    <a href="${pageContext.request.contextPath}/support.do">고객센터</a>
                    <ul class="dropdown-menu">
                        <li><a href="${pageContext.request.contextPath}/support.do#contact">1:1 문의하기</a></li>
                        <li><a href="${pageContext.request.contextPath}/notice.do">공지사항</a></li>
                        <li><a href="${pageContext.request.contextPath}/guide.do">자주 묻는 질문</a></li>
                    </ul>
                </li>
            </ul>
            
            <div class="user-links">
                <c:choose>
                    <c:when test="${not empty loginUser}">
                        <span class="user-welcome"><strong>${loginUser.nickname}</strong>님 환영합니다</span>
                        <c:if test="${loginUser.memberStatus eq 'ADMIN'}">
                            | <a href="${pageContext.request.contextPath}/mypage.do" class="admin-link">관리자 모드</a>
                        </c:if>
                        <c:if test="${loginUser.memberStatus ne 'ADMIN'}">
                            | <a href="${pageContext.request.contextPath}/mypage.do">마이페이지</a>
                        </c:if>
                        | <a href="${pageContext.request.contextPath}/logout.do">로그아웃</a>
                    </c:when>
                    <c:otherwise>
                        <a href="javascript:openLoginModal();" class="login-link">로그인</a>
                        <div class="dropdown" style="display:inline-block;">
                            <a href="${pageContext.request.contextPath}/join.do" class="signup-link-btn">회원가입</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </nav>
    <main>

