<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

    <section class="content-section">
        <div class="form-container" style="max-width: 1000px;">
            <h2>이용 요금 안내</h2>
            <p style="text-align: center; margin-bottom: 2rem; color: var(--light-text-color);">Baren은 모든 라이더들의 즐거운 라이딩을 위해 합리적이고 투명한 요금제를 운영합니다.</p>
            
            <table class="mypage-table">
                <thead>
                    <tr>
                        <th>바이크 유형</th>
                        <th>상세 특징</th>
                        <th style="width: 25%; text-align: center;">이용 요금 (1일 기준)</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><strong>125cc 이하 스쿠터 (Scooter)</strong></td>
                        <td>도심 주행의 최강자이자 연비와 편의성을 극대화한 기종 (예: Honda PCX 125 등)</td>
                        <td style="text-align: center; color: var(--primary-color); font-weight: 700;">45,000 원</td>
                    </tr>
                    <tr>
                        <td><strong>125cc ~ 400cc 쿼터급 (Quarter)</strong></td>
                        <td>스포티한 엔진 배기음과 민첩한 코너 와인딩을 즐길 수 있는 입문 스포츠형 바이크 (예: Yamaha YZF-R3 등)</td>
                        <td style="text-align: center; color: var(--primary-color); font-weight: 700;">80,000 원</td>
                    </tr>
                    <tr>
                        <td><strong>400cc 초과 미들/리터급 (Liter)</strong></td>
                        <td>장거리 투어링 및 초고속 와인딩 성능을 완벽히 탑재한 대형 스포츠 바이크 (예: BMW Motorrad 등)</td>
                        <td style="text-align: center; color: var(--primary-color); font-weight: 700;">150,000 원</td>
                    </tr>
                    <tr>
                        <td><strong>안전 장구 세트</strong></td>
                        <td>프리미엄 공인 인증 헬멧, 보호 장대 및 전용 도난 방지 자물쇠</td>
                        <td style="text-align: center; color: var(--success-color); font-weight: 700;">무상 대여 (0원)</td>
                    </tr>
                </tbody>
            </table>
            
            <h3 id="premium-options" style="margin-top: 40px; margin-bottom: 15px; font-family: 'Outfit'; color: #fff;">🔌 프리미엄 추가 대여 장비</h3>
            <table class="mypage-table">
                <thead>
                    <tr>
                        <th>장비 이름</th>
                        <th>장비 특징</th>
                        <th style="width: 25%; text-align: center;">대여 요금 (1일 기준)</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><strong>⛑️ 홍진 HJC 오픈페이스 헬멧</strong></td>
                        <td>안전성이 입증된 국산 브랜드 HJC 정품 하프/오픈페이스 헬멧</td>
                        <td style="text-align: center; color: var(--primary-color); font-weight: 700;">5,000 원</td>
                    </tr>
                    <tr>
                        <td><strong>🛜 세나 50S 블루투스 인터콤</strong></td>
                        <td>주행 중 동료 라이더와의 무선 통신 및 고음질 음악 감상 가능</td>
                        <td style="text-align: center; color: var(--primary-color); font-weight: 700;">7,000 원</td>
                    </tr>
                    <tr>
                        <td><strong>📦 알루미늄 대용량 탑박스</strong></td>
                        <td>장거리 투어나 소지품 보관에 유용한 견고한 리어 박스</td>
                        <td style="text-align: center; color: var(--primary-color); font-weight: 700;">4,000 원</td>
                    </tr>
                    <tr>
                        <td><strong>📱 초고속 자석 스마트폰 거치대</strong></td>
                        <td>스마트폰 내비게이션 사용을 위한 고정력 우수한 거치대</td>
                        <td style="text-align: center; color: var(--primary-color); font-weight: 700;">2,000 원</td>
                    </tr>
                    <tr>
                        <td><strong>🛡️ 프리미엄 무릎 및 팔꿈치 보호대</strong></td>
                        <td>전도 시 라이더의 관절을 확실하게 보호하는 인증 패드 세트</td>
                        <td style="text-align: center; color: var(--primary-color); font-weight: 700;">3,000 원</td>
                    </tr>
                </tbody>
            </table>
            
            <div style="margin-top: 30px; font-size: 13px; color: var(--light-text-color); line-height: 1.6;">
                <p>※ 대여 일정을 초과하여 반납 시 시간당 별도 추가 요금이 부과될 수 있습니다.</p>
                <p>※ 바이크 대여 예약 취소는 대여 예정일 24시간 전까지 마이페이지에서 위약금 없이 취소할 수 있습니다.</p>
            </div>
        </div>
    </section>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
