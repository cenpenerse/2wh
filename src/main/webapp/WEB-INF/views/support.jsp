<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

    <section class="content-section">
        <div class="form-container">
            <h2 style="font-family: 'Outfit', sans-serif; font-size: 2.2rem; font-weight: 800; color: #fff; margin-bottom: 30px; text-align: center;">고객센터 (Customer Support)</h2>

            <div class="form-section" id="contact">
                <h3 style="font-family: 'Outfit', sans-serif; font-size: 1.4rem; font-weight: 700; color: var(--primary-color); margin-bottom: 20px; border-bottom: 1px solid #222; padding-bottom: 10px;">1:1 문의하기</h3>
                
                <form action="${pageContext.request.contextPath}/inquiryAction.do" method="post">
                    <c:choose>
                        <c:when test="${not empty sessionScope.loginUser}">
                            <div class="form-group">
                                <label for="contact-name">이름 (회원 닉네임)</label>
                                <input type="text" id="contact-name" value="${sessionScope.loginUser.nickname}" disabled style="background:#222; color:#888;">
                            </div>
                            <div class="form-group">
                                <label for="contact-email">이메일 주소</label>
                                <input type="email" id="contact-email" value="${sessionScope.loginUser.email}" disabled style="background:#222; color:#888;">
                            </div>
                            <div class="form-group">
                                <label for="contact-title">문의 제목</label>
                                <input type="text" id="contact-title" name="title" required placeholder="문의 제목을 입력하세요">
                            </div>
                            <div class="form-group">
                                <label for="contact-message">문의 내용</label>
                                <textarea id="contact-message" name="content" rows="8" required placeholder="문의하실 내용을 자세하게 작성해주세요."></textarea>
                            </div>
                            <button type="submit" class="btn" style="width: 100%; padding: 14px; font-weight: bold; margin-top: 10px;">문의 접수</button>
                        </c:when>
                        <c:otherwise>
                            <div style="text-align:center; padding: 40px 0;">
                                <p style="color:#aaa; margin-bottom:15px; font-size: 1.05rem;">1:1 문의를 등록하시려면 로그인이 필요합니다.</p>
                                <a href="${pageContext.request.contextPath}/login.do" class="btn" style="display:inline-block; padding: 12px 30px; font-weight: bold;">로그인하러 가기</a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </form>
            </div>
        </div>
    </section>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />

