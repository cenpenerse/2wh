<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="board-container max-width">
    <div class="board-header">
        <h2>게시글 수정</h2>
        <p>기존에 등록한 게시글의 내용을 변경합니다.</p>
    </div>

    <div class="form-card-box">
        <form action="${pageContext.request.contextPath}/boardUpdateAction.do" method="post" enctype="multipart/form-data" class="board-write-form">
            <input type="hidden" name="postId" value="${post.postId}">
            
            <div class="form-group">
                <label for="title">글 제목</label>
                <input type="text" id="title" name="title" value="${post.title}" required maxlength="100">
            </div>

            <div class="form-group">
                <label for="content">본문 내용</label>
                <textarea id="content" name="content" rows="12" required>${post.content}</textarea>
            </div>

            <div class="form-group" style="margin-top: 20px;">
                <label for="attachedFile">파일 첨부 변경</label>
                <c:if test="${not empty post.filename}">
                    <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 8px; background: #222; padding: 8px 12px; border-radius: 6px; border: 1px solid #333;">
                        <span style="color: #60a5fa; font-size: 0.9rem;">📎 현재 첨부파일: <strong>${post.filename}</strong></span>
                        <label style="display: inline-flex; align-items: center; gap: 6px; font-size: 0.85rem; color: #ef4444; cursor: pointer; margin-left: auto;">
                            <input type="checkbox" name="deleteExistingFile" value="true"> 기존 파일 삭제
                        </label>
                    </div>
                </c:if>
                <input type="file" id="attachedFile" name="attachedFile" style="background: #222; color: #ccc; border: 1px solid #444; padding: 10px; border-radius: 6px; width: 100%;">
                <p style="font-size: 0.8rem; color: #888; margin-top: 6px;">📄 새로운 파일을 첨부하면 기존 파일은 자동으로 교체 및 삭제됩니다.</p>
            </div>

            <div class="form-actions-row" style="text-align: right; margin-top: 30px;">
                <a href="${pageContext.request.contextPath}/boardDetail.do?postId=${post.postId}" class="btn btn-secondary-outline" style="margin-right: 10px;">취소</a>
                <button type="submit" class="btn btn-action-main">수정 완료</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
