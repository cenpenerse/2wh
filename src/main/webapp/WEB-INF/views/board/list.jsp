<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/board.css">

<div class="board-container max-width">
    <!-- 게시판 헤더 제목 -->
    <div class="board-header">
        <c:choose>
            <c:when test="${boardType eq 'NOTICE'}">
                <h2>공지사항</h2>
                <p>Baren의 최신 소식과 안내 사항을 전달합니다.</p>
            </c:when>
            <c:when test="${boardType eq 'REVIEW'}">
                <h2>이용후기</h2>
                <p>Baren 회원들이 직접 작성한 생생한 라이딩 이용후기입니다.</p>
            </c:when>
            <c:otherwise>
                <h2>자유게시판</h2>
                <p>라이딩 코스 공유, 바이크 팁 등 자유로운 이야기를 나누는 소통 공간입니다.</p>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- 게시글 테이블 -->
    <div class="table-wrapper">
        <table class="mypage-table board-table">
            <thead>
                <tr>
                    <th style="width: 80px;">번호</th>
                    <th>제목</th>
                    <th style="width: 150px;">작성자</th>
                    <th style="width: 120px;">작성일</th>
                    <th style="width: 80px;">조회수</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty postList}">
                        <c:forEach var="post" items="${postList}">
                            <tr>
                                <td>${post.postId}</td>
                                <td class="title-cell" style="text-align: left;">
                                    <a href="${pageContext.request.contextPath}/boardDetail.do?postId=${post.postId}">
                                        ${post.title}
                                    </a>
                                    <c:if test="${not empty post.filename}">
                                        <span style="color: #60a5fa; font-size: 0.95rem; margin-left: 6px;" title="첨부파일 있음"></span>
                                    </c:if>
                                </td>
                                <td><strong>${post.memberNickname}</strong></td>
                                <td><fmt:formatDate value="${post.createdAt}" pattern="yyyy-MM-dd"/></td>
                                <td>${post.viewCount}</td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="5" class="no-data">등록된 게시글이 존재하지 않습니다.</td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>

    <!-- 게시판 제어 (글쓰기 버튼 및 페이징) -->
    <div class="board-footer-controls">
        <!-- 페이징 영역 -->
        <div class="pagination-bar">
            <c:if test="${paging.startPage > paging.blockSize}">
                <a href="${pageContext.request.contextPath}/boardList.do?boardType=${boardType}&page=${paging.startPage - 1}" class="page-link page-prev">&lt; 이전</a>
            </c:if>
            
            <c:forEach var="i" begin="${paging.startPage}" end="${paging.endPage}">
                <a href="${pageContext.request.contextPath}/boardList.do?boardType=${boardType}&page=${i}" class="page-link ${paging.currentPage eq i ? 'active' : ''}">${i}</a>
            </c:forEach>
            
            <c:if test="${paging.endPage < paging.totalPages}">
                <a href="${pageContext.request.contextPath}/boardList.do?boardType=${boardType}&page=${paging.endPage + 1}" class="page-link page-next">다음 &gt;</a>
            </c:if>
        </div>

        <!-- 글쓰기 권한 제어 -->
        <div class="write-btn-wrapper">
            <c:choose>
                <c:when test="${boardType eq 'NOTICE'}">
                    <!-- 공지사항은 관리자만 작성 가능 -->
                    <c:if test="${loginUser.memberStatus eq 'ADMIN'}">
                        <a href="${pageContext.request.contextPath}/boardWrite.do?boardType=${boardType}" class="btn">공지사항 작성</a>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <!-- 일반 게시판은 회원 전체 작성 가능 -->
                    <c:if test="${not empty loginUser}">
                        <a href="${pageContext.request.contextPath}/boardWrite.do?boardType=${boardType}" class="btn">글쓰기</a>
                    </c:if>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
