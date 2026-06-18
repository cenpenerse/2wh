<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="board-container max-width">
    <!-- 1. 글 상세 정보 카드 -->
    <div class="post-detail-card">
        <div class="post-header-info">
            <span class="board-badge">${post.boardType}</span>
            <h2>${post.title}</h2>
            <div class="post-meta">
                <span>작성자: <strong>${post.memberNickname}</strong></span> |
                <span>작성일: <fmt:formatDate value="${post.createdAt}" pattern="yyyy-MM-dd HH:mm"/></span> |
                <span>조회수: ${post.viewCount}</span>
            </div>
        </div>
        
        <hr class="divider">
        
        <!-- 본문 내용 -->
        <div class="post-content-body" style="white-space: pre-wrap; min-height: 250px; line-height: 1.8; font-size: 1.05rem;">${post.content}</div>
        
        <!-- 첨부 파일 영역 -->
        <c:if test="${not empty post.filename}">
            <div class="post-attachment-box" style="margin-top: 30px; padding: 20px; background: rgba(255, 255, 255, 0.02); border: 1px solid rgba(255, 255, 255, 0.05); border-radius: 8px;">
                <h4 style="font-size: 0.95rem; color: #aaa; margin: 0 0 12px 0; display: flex; align-items: center; gap: 6px;">
                    📎 첨부파일
                </h4>
                
                <c:set var="fileNameLower" value="${post.filename.toLowerCase()}" />
                <c:set var="isImage" value="${false}" />
                <c:if test="${fileNameLower.endsWith('.jpg') || fileNameLower.endsWith('.jpeg') || fileNameLower.endsWith('.png') || fileNameLower.endsWith('.gif') || fileNameLower.endsWith('.webp')}">
                    <c:set var="isImage" value="${true}" />
                </c:if>
                
                <c:if test="${isImage}">
                    <div style="margin-bottom: 15px; border-radius: 6px; overflow: hidden; border: 1px solid #333; max-width: 600px; background: #121212;">
                        <img src="${pageContext.request.contextPath}/resources/upload/${post.filename}" style="width: 100%; height: auto; display: block;" alt="첨부 이미지">
                    </div>
                </c:if>
                
                <a href="${pageContext.request.contextPath}/resources/upload/${post.filename}" download="${post.filename}" style="display: inline-flex; align-items: center; gap: 8px; color: #60a5fa; text-decoration: none; font-weight: 600; font-size: 0.9rem; transition: color 0.2s;" onmouseover="this.style.color='#93c5fd'" onmouseout="this.style.color='#60a5fa'">
                    💾 ${post.filename} (다운로드)
                </a>
            </div>
        </c:if>
        
        <!-- 제어 버튼 (수정, 삭제, 목록) -->
        <div class="post-actions-row">
            <div class="left-actions">
                <a href="${pageContext.request.contextPath}/boardList.do?boardType=${post.boardType}" class="btn btn-secondary-outline">목록으로</a>
            </div>
            <div class="right-actions">
                <c:if test="${not empty loginUser && (loginUser.memberId eq post.memberId || loginUser.memberStatus eq 'ADMIN')}">
                    <a href="${pageContext.request.contextPath}/boardUpdate.do?postId=${post.postId}" class="btn btn-edit">수정</a>
                    <a href="${pageContext.request.contextPath}/boardDeleteAction.do?postId=${post.postId}&boardType=${post.boardType}" class="btn btn-danger" onclick="return confirm('정말로 이 글을 삭제하시겠습니까?');">삭제</a>
                </c:if>
            </div>
        </div>
    </div>

    <!-- 2. 댓글 영역 -->
    <div class="comment-section-card">
        <h3>댓글 (${commentList.size()})</h3>
        
        <!-- 댓글 목록 -->
        <div class="comment-list-wrapper">
            <c:choose>
                <c:when test="${not empty commentList}">
                    <c:forEach var="comment" items="${commentList}">
                        <div class="comment-item">
                            <div class="comment-header">
                                <span class="comment-author">👤 ${comment.memberNickname}</span>
                                <span class="comment-date"><fmt:formatDate value="${comment.createdAt}" pattern="yyyy-MM-dd HH:mm"/></span>
                            </div>
                            <div class="comment-body">
                                <p>${comment.content}</p>
                                <c:if test="${not empty loginUser && (loginUser.memberId eq comment.memberId || loginUser.memberStatus eq 'ADMIN')}">
                                    <a href="${pageContext.request.contextPath}/commentDeleteAction.do?commentId=${comment.commentId}&postId=${post.postId}" class="comment-delete-btn" onclick="return confirm('정말로 이 댓글을 삭제하시겠습니까?');">삭제</a>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <p class="no-comments">등록된 댓글이 없습니다. 첫 댓글을 작성해 보세요!</p>
                </c:otherwise>
            </c:choose>
        </div>

        <hr class="divider" style="margin: 25px 0 20px;">

        <!-- 댓글 작성 폼 -->
        <c:choose>
            <c:when test="${not empty loginUser}">
                <form action="${pageContext.request.contextPath}/commentWriteAction.do" method="post" class="comment-form">
                    <input type="hidden" name="postId" value="${post.postId}">
                    <div class="comment-input-group">
                        <textarea name="content" rows="3" placeholder="댓글을 입력해 주세요. 타인을 배려하는 예의 바른 소통을 부탁드립니다." required></textarea>
                        <button type="submit" class="btn btn-comment-submit">댓글 등록</button>
                    </div>
                </form>
            </c:when>
            <c:otherwise>
                <div class="comment-login-banner" style="text-align: center; padding: 20px; background: #222; border-radius: 6px;">
                    <p style="margin: 0 0 10px; color: #aaa;">댓글을 작성하려면 로그인이 필요합니다.</p>
                    <button class="btn btn-sm" onclick="openLoginModal()">로그인하기</button>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
