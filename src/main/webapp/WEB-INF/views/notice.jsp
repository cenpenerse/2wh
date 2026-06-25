<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/support.css">

<section class="content-section">
    <div class="form-container">
        <h2 style="font-family: 'Outfit', sans-serif; font-size: 2.2rem; font-weight: 800; color: #fff; margin-bottom: 30px; text-align: center;">공지사항</h2>
        
        <div class="form-section" id="notices">
            <table class="mypage-table">
                <thead>
                    <tr>
                        <th style="width: 15%;">번호</th>
                        <th>제목</th>
                        <th style="width: 20%;">작성일</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>2</td>
                        <td><a href="#" style="color: white; font-weight: 600;">개인정보처리방침 개정 안내</a></td>
                        <td>2026-05-20</td>
                    </tr>
                    <tr>
                        <td>1</td>
                        <td><a href="#" style="color: white; font-weight: 600;">Baren 서비스 정식 오픈!</a></td>
                        <td>2026-05-01</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</section>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />