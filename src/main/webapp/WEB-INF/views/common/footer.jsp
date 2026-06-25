<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
    </main>

    <!-- 로그인 모달 영역 -->
    <div id="login-modal" class="modal-overlay">
        <div class="modal-content">
            <span class="close-btn" onclick="closeLoginModal()">&times;</span>
            <h2>로그인</h2>
            <form action="${pageContext.request.contextPath}/member/loginAction.do" method="post">
                <div class="form-group">
                    <label for="login-email">이메일</label>
                    <input type="email" id="login-email" name="email" placeholder="이메일 주소를 입력하세요" required>
                </div>
                <div class="form-group">
                    <label for="login-password">비밀번호</label>
                    <input type="password" id="login-password" name="password_hash" placeholder="비밀번호를 입력하세요" required>
                </div>
                <button type="submit" class="btn">로그인</button>
                <div class="signup-link" style="text-align: center; margin-top: 20px;">
                    아직 계정이 없으신가요?
                    <a href="${pageContext.request.contextPath}/member/join.do" style="color: var(--primary-color); text-decoration: none; font-weight: 600;">회원가입</a>
                </div>
            </form>
        </div>
    </div>

    <!-- 플로팅 알림 및 이동 버튼 -->
    <div class="floating-buttons">
        <a href="${pageContext.request.contextPath}/pricing.do" class="float-btn pricing">이용요금 안내</a>
        <a href="${pageContext.request.contextPath}/support.do#contact" class="float-btn">1:1 문의하기</a>
    </div>

    <footer>
        <div class="footer-container">
            <div class="footer-col about">
                <div class="logo">BAREN<span>.</span></div>
                <p>도심 라이딩부터 오프로드 어드벤처까지, 최상의 라이딩 경험을 선물하는 프리미엄 바이크 렌탈 서비스 Baren입니다.</p>
            </div>
            <div class="footer-col">
                <h4>서비스</h4>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/bike/bikeInfo.do">바이크 종류</a></li>
                    <li><a href="${pageContext.request.contextPath}/bike/gearInfo.do">대여 장비</a></li>
                    <li><a href="${pageContext.request.contextPath}/bike/bikeList.do">대여/예약</a></li>
                    <li><a href="${pageContext.request.contextPath}/board/boardList.do?boardType=FREE">게시판</a></li>
                    <li><a href="${pageContext.request.contextPath}/pricing.do">이용요금</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h4>고객센터</h4>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/notice.do">공지사항</a></li>
                    <li><a href="${pageContext.request.contextPath}/guide.do">자주 묻는 질문</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h4>회사소개</h4>
                <ul>
                    <li><a href="#">About Baren</a></li>
                    <li><a href="#">이용약관</a></li>
                    <li><a href="#">개인정보처리방침</a></li>
                </ul>
            </div>
        </div>
        <div class="footer-bottom">
            <span>&copy; 2026 BAREN Corp. All rights reserved. | Powered by Antigravity</span>
        </div>
    </footer>
    <script src="${pageContext.request.contextPath}/resources/js/script.js?v=3.0"></script>
</body>
</html>

