<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/WEB-INF/views/common/header.jsp" />

    <section class="content-section">
        <div class="form-container" style="max-width: 1200px;">
            <h2>이용 요금 안내</h2>
            <p style="text-align: center; margin-bottom: 2.5rem; color: var(--light-text-color);">Baren은 모든 라이더들의 즐거운 라이딩을 위해 합리적이고 투명한 요금제를 운영합니다.</p>
            
            <div style="display: flex; flex-direction: column; gap: 35px;">
                <!-- 첫 번째 박스: 바이크 이용 요금 안내 -->
                <div style="background: var(--light-gray-bg); border: 1px solid var(--border-color); padding: 30px; border-radius: 12px;">
                    <h3 style="margin-bottom: 20px; font-family: 'Outfit'; color: #fff; display: flex; align-items: center; gap: 8px;">바이크 대여 요금</h3>
                    <table class="mypage-table" style="margin-bottom: 0;">
                        <thead>
                            <tr>
                                <th>바이크 유형</th>
                                <th>상세 특징</th>
                                <th style="width: 30%; text-align: center;">이용 요금 (1일)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><strong>125cc 이하 스쿠터</strong></td>
                                <td style="font-size: 0.85rem; color: #ccc;">도심 주행 최강자, 뛰어난 연비 (예: PCX 125 등)</td>
                                <td style="text-align: center; color: var(--primary-color); font-weight: 700;">45,000 원</td>
                            </tr>
                            <tr>
                                <td><strong>125cc ~ 400cc 쿼터급</strong></td>
                                <td style="font-size: 0.85rem; color: #ccc;">스포티한 가속, 민첩한 코너링 (예: YZF-R3 등)</td>
                                <td style="text-align: center; color: var(--primary-color); font-weight: 700;">80,000 원</td>
                            </tr>
                            <tr>
                                <td><strong>400cc 초과 미들/리터급</strong></td>
                                <td style="font-size: 0.85rem; color: #ccc;">장거리 투어러, 강력한 파워 (예: R nineT 등)</td>
                                <td style="text-align: center; color: var(--primary-color); font-weight: 700;">150,000 원</td>
                            </tr>
                            <tr>
                                <td><strong>안전 장구 세트</strong></td>
                                <td style="font-size: 0.85rem; color: #ccc;">공인 인증 헬멧, 보호대, 도난방지락</td>
                                <td style="text-align: center; color: var(--success-color); font-weight: 700;">무상 대여 (0원)</td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <!-- 두 번째 박스: 프리미엄 추가 대여 장비 -->
                <div style="background: var(--light-gray-bg); border: 1px solid var(--border-color); padding: 30px; border-radius: 12px;">
                    <h3 id="premium-options" style="margin-bottom: 20px; font-family: 'Outfit'; color: #fff; display: flex; align-items: center; gap: 8px;">프리미엄 추가 대여 장비</h3>
                    <table class="mypage-table" style="margin-bottom: 0;">
                        <thead>
                            <tr>
                                <th>장비 이름</th>
                                <th>장비 특징</th>
                                <th style="width: 30%; text-align: center;">대여 요금 (1일)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td><strong>HJC 오픈페이스 헬멧</strong></td>
                                <td style="font-size: 0.85rem; color: #ccc;">안전성이 검증된 국산 HJC 정품 오픈페이스</td>
                                <td style="text-align: center; color: var(--primary-color); font-weight: 700;">5,000 원</td>
                            </tr>
                            <tr>
                                <td><strong>세나 50S 블루투스</strong></td>
                                <td style="font-size: 0.85rem; color: #ccc;">동료 라이더와의 무선 통신 및 고음질 오디오</td>
                                <td style="text-align: center; color: var(--primary-color); font-weight: 700;">7,000 원</td>
                            </tr>
                            <tr>
                                <td><strong>알루미늄 탑박스</strong></td>
                                <td style="font-size: 0.85rem; color: #ccc;">장거리 보관이 용이한 견고한 리어 박스</td>
                                <td style="text-align: center; color: var(--primary-color); font-weight: 700;">4,000 원</td>
                            </tr>
                            <tr>
                                <td><strong>자석 스마트폰 거치대</strong></td>
                                <td style="font-size: 0.85rem; color: #ccc;">내비게이션용 고정력 우수한 거치대</td>
                                <td style="text-align: center; color: var(--primary-color); font-weight: 700;">2,000 원</td>
                            </tr>
                            <tr>
                                <td><strong>무릎 및 팔꿈치 보호대</strong></td>
                                <td style="font-size: 0.85rem; color: #ccc;">라이더 관절을 보호하는 인증 패드 세트</td>
                                <td style="text-align: center; color: var(--primary-color); font-weight: 700;">3,000 원</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div style="margin-top: 35px; font-size: 13px; color: var(--light-text-color); line-height: 1.6; border-top: 1px solid rgba(255,255,255,0.05); padding-top: 20px;">
                <p>※ 대여 일정을 초과하여 반납 시 시간당 별도 추가 요금이 부과될 수 있습니다.</p>
                <p>※ 바이크 대여 예약 취소는 대여 예정일 24시간 전까지 마이페이지에서 위약금 없이 취소할 수 있습니다.</p>
            </div>
        </div>
    </section>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
