<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.bikerental.dao.BoardDao, java.util.List, java.util.ArrayList, com.bikerental.dto.BoardDto, com.bikerental.util.Pagination" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
    // 1. 파라미터 받기
    request.setCharacterEncoding("UTF-8");
    String searchField = request.getParameter("searchField");
    String searchKeyword = request.getParameter("searchKeyword");
    String pageNumStr = request.getParameter("pageNum");

    // 검색 필드가 없을 경우 기본값을 '제목'으로 설정하여 오류를 방지합니다.
    if (searchField == null) {
        searchField = "title";
    }

    // 현재 페이지 번호 설정
    int pageNum = 1;
    if (pageNumStr != null && !pageNumStr.trim().isEmpty()) {
        try {
            pageNum = Integer.parseInt(pageNumStr.trim());
        } catch (NumberFormatException e) {
            // pageNum은 1로 유지
        }
    }

    // 2. DAO 및 페이징 처리
    BoardDao dao = BoardDao.getInstance();

    // 전체 게시글 수 조회
    int totalCount = dao.getPostCount("FREE");

    // Pagination 객체 생성 및 설정
    Pagination pagination = new Pagination(totalCount, pageNum);

    // 현재 페이지에 해당하는 게시글 목록 조회
    List<BoardDto> postList = dao.getPostList("FREE", pagination.getStartRow(), pagination.getEndRow());

    pageContext.setAttribute("postList", postList);
    pageContext.setAttribute("p", pagination);
%>

<jsp:include page="WEB-INF/views/common/header.jsp" />
<section class="content-section">
    <div class="board-container">
        <h2>자유게시판</h2>
        <table class="review-table">
            <thead>
                <tr>
                    <th style="width:10%;">번호</th>
                    <th>제목</th>
                    <th style="width:15%;">작성자</th>
                    <th style="width:15%;">작성일</th>
                    <th style="width:10%;">조회수</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${empty postList}">
                        <tr>
                            <td colspan="5">등록된 게시글이 없습니다.</td>
                        </tr>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="post" items="${postList}" varStatus="status">
                            <tr>
                                <td>${p.totalItems - ((p.currentPage - 1) * p.pageSize) - status.index}</td>
                                <td style="text-align:left;">
                                    <a href="${pageContext.request.contextPath}/boardDetail.do?postId=${post.postId}"><c:out value="${post.title}" /></a>
                                </td>
                                <td><c:out value="${post.memberNickname != null ? post.memberNickname : '익명'}" /></td>
                                <td><fmt:formatDate value="${post.createdAt}" pattern="yyyy-MM-dd" /></td>
                                <td>${post.viewCount}</td>
                            </tr>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
        <div class="pagination-container">
            <ul class="pagination">
                <c:if test="${p.totalItems > 0}">
                    <%-- 처음 --%>
                    <li><a href="free_board_list.jsp?pageNum=1&searchField=${param.searchField}&searchKeyword=${param.searchKeyword}">처음</a></li>
                    
                    <%-- 이전 (블록) --%>
                    <li><a href="free_board_list.jsp?pageNum=${p.startPage > p.blockSize ? p.startPage - 1 : 1}&searchField=${param.searchField}&searchKeyword=${param.searchKeyword}">이전</a></li>

                    <%-- 페이지 번호 --%>
                    <c:forEach var="i" begin="${p.startPage}" end="${p.endPage}">
                        <c:choose>
                            <c:when test="${i == p.currentPage}">
                                <li class="active"><a>${i}</a></li>
                            </c:when>
                            <c:otherwise>
                                <li><a href="free_board_list.jsp?pageNum=${i}&searchField=${param.searchField}&searchKeyword=${param.searchKeyword}">${i}</a></li>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>

                    <%-- 다음 (블록) --%>
                    <li><a href="free_board_list.jsp?pageNum=${p.endPage < p.totalPages ? p.endPage + 1 : p.totalPages}&searchField=${param.searchField}&searchKeyword=${param.searchKeyword}">다음</a></li>

                    <%-- 끝 --%>
                    <li><a href="free_board_list.jsp?pageNum=${p.totalPages}&searchField=${param.searchField}&searchKeyword=${param.searchKeyword}">끝</a></li>
                </c:if>
            </ul>
        </div>
        <div class="search-form-container">
            <form action="free_board_list.jsp" method="get" class="search-form">
                <select name="searchField">
                    <option value="title" ${param.searchField == 'title' ? 'selected' : ''}>제목</option>
                    <option value="author" ${param.searchField == 'author' ? 'selected' : ''}>작성자</option>
                </select>
                <input type="text" name="searchKeyword" placeholder="검색어를 입력하세요" value="${param.searchKeyword}">
                <button type="submit" class="btn">검색</button>
            </form>
        </div>
        <div class="board-footer">
            <button class="btn" onclick="location.href='${pageContext.request.contextPath}/board/board_writeform.jsp?board_type=free'">글 작성</button>
        </div>
    </div>
</section>
<style>
    .search-form-container { margin-top: 30px; display: flex; justify-content: center; }
    .search-form { display: flex; gap: 10px; align-items: center; }
    .search-form select, .search-form input { padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; }
    .search-form input { width: 300px; }
    .search-form select:focus, .search-form input:focus { outline: none; border-color: var(--primary-color, #4CAF50); box-shadow: 0 0 0 2px rgba(76, 175, 80, 0.15); }
    .search-form .btn { padding: 10px 20px; }
    .pagination-container { display: flex; justify-content: center; margin-top: 30px; margin-bottom: 30px; }
    .pagination { list-style: none; display: flex; gap: 5px; padding: 0; }
    .pagination li a { display: block; padding: 8px 12px; border: 1px solid #ddd; border-radius: 4px; color: #333; text-decoration: none; transition: background-color 0.2s; }
    .pagination li a:hover { background-color: #f0f0f0; }
    .pagination li.active a { background-color: var(--primary-color, #4CAF50); color: white; border-color: var(--primary-color, #4CAF50); cursor: default; }
    .pagination li.active a:hover { background-color: var(--primary-color, #4CAF50); }
</style>
<jsp:include page="WEB-INF/views/common/footer.jsp" />
