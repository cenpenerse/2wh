<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="board-container max-width">
    <div class="board-header">
        <h2>게시글 수정</h2>
        <p>기존에 등록한 게시글의 내용을 변경합니다.</p>
    </div>

    <div class="form-card-box">
        <form action="${pageContext.request.contextPath}/boardUpdateAction.do" method="post" class="board-write-form">
            <input type="hidden" name="postId" value="${post.postId}">
            
            <div class="form-group">
                <label for="title">글 제목</label>
                <input type="text" id="title" name="title" value="${post.title}" required maxlength="100">
            </div>

            <div class="form-group">
                <label for="content">본문 내용</label>
                <textarea id="content" name="content" rows="12" required>${post.content}</textarea>
            </div>

            <div class="form-actions-row" style="text-align: right; margin-top: 30px;">
                <a href="${pageContext.request.contextPath}/boardDetail.do?postId=${post.postId}" class="btn btn-secondary-outline" style="margin-right: 10px;">취소</a>
                <button type="submit" class="btn btn-action-main">수정 완료</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
