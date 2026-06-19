<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="board-container max-width">
    <div class="board-header">
        <h2>게시글 작성</h2>
        <p>선택한 게시판에 새 글을 등록합니다.</p>
    </div>

    <div class="form-card-box">
        <form action="${pageContext.request.contextPath}/boardWriteAction.do" method="post" enctype="multipart/form-data" class="board-write-form">
            <input type="hidden" name="boardType" value="${boardType}">
            
            <div class="form-group">
                <label for="board-select-display">게시판 유형</label>
                <input type="text" id="board-select-display" value="${boardType eq 'NOTICE' ? '공지사항' : (boardType eq 'REVIEW' ? '이용후기' : '자유게시판')}" disabled style="background: #2a2a2a; color: #888;">
            </div>

            <div class="form-group">
                <label for="title">글 제목</label>
                <input type="text" id="title" name="title" placeholder="제목을 입력하세요" required maxlength="100">
            </div>

            <div class="form-group">
                <label for="content">본문 내용</label>
                <textarea id="content" name="content" rows="12" placeholder="내용을 작성하세요. 음해성 글이나 부적절한 광고는 게시 제한될 수 있습니다." required></textarea>
            </div>

            <div class="form-group" style="margin-top: 20px;">
                <label for="attachedFile">파일 첨부</label>
                <input type="file" id="attachedFile" name="attachedFile" style="background: #222; color: #ccc; border: 1px solid #444; padding: 10px; border-radius: 6px; width: 100%;">
                <p style="font-size: 0.8rem; color: #888; margin-top: 6px;">이미지(jpg, png 등) 또는 일반 문서 파일을 최대 10MB까지 첨부할 수 있습니다.</p>
            </div>

            <div class="form-actions-row" style="text-align: right; margin-top: 30px;">
                <a href="${pageContext.request.contextPath}/boardList.do?boardType=${boardType}" class="btn btn-secondary-outline" style="margin-right: 10px;">취소</a>
                <button type="submit" class="btn btn-action-main">등록하기</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
