<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

    <section class="content-section">
        <div class="board-container max-width" style="padding-top: 30px;">
            <div class="board-header" style="margin-bottom: 45px; text-align: center;">
                <span style="color: var(--primary-color); font-weight: 700; font-size: 0.9rem; text-transform: uppercase; letter-spacing: 2px;">Baren Fleet</span>
                <h2 style="font-family: 'Outfit', sans-serif; font-size: 2.5rem; font-weight: 800; color: #fff; margin-top: 10px; margin-bottom: 12px; letter-spacing: -0.5px;">바이크 라인업 안내</h2>
                <p style="color: var(--light-text-color); font-size: 1.05rem;">바렌이 제공하는 최고 사양의 프리미엄 바이크 종류 및 상세 제원입니다.</p>
                <div style="margin-top: 20px;">
                    <a href="${pageContext.request.contextPath}/bikeList.do" class="btn" style="background: linear-gradient(135deg, var(--primary-color) 0%, #FF5E62 100%); border: none; padding: 10px 25px; font-weight: 600; text-transform: uppercase; box-shadow: 0 4px 15px rgba(229, 9, 20, 0.4);">실시간 대여/예약 신청하러 가기 </a>
                </div>
            </div>

            <!-- 필터 검색 영역 (3개 콤보 상자) -->
            <div class="filter-form" style="margin-bottom: 40px;">
                <div class="filter-group-row">
                    <div class="filter-item">
                        <label for="filter-genre">장르 구분</label>
                        <select id="filter-genre">
                            <option value="all">전체 장르</option>
                            <option value="scooter">스쿠터 </option>
                            <option value="sports">스포츠 </option>
                            <option value="cruiser">크루저 </option>
                            <option value="adventure">어드벤쳐 </option>
                            <option value="naked">네이키드 </option>
                            <option value="classic">클래식 </option>
                        </select>
                    </div>
                    <div class="filter-item">
                        <label for="filter-brand">제조사</label>
                        <select id="filter-brand">
                            <option value="all">전체 제조사</option>
                            <option value="Honda">혼다 (Honda)</option>
                            <option value="Yamaha">야마하 (Yamaha)</option>
                            <option value="BMW">BMW</option>
                            <option value="Harley-Davidson">할리데이비슨 (Harley-Davidson)</option>
                            <option value="Vespa">베스파 (Vespa)</option>
                            <option value="Ducati">두카티 (Ducati)</option>
                            <option value="Kawasaki">가와사키 (Kawasaki)</option>
                        </select>
                    </div>
                    <div class="filter-item">
                        <label for="filter-cc">배기량 구분</label>
                        <select id="filter-cc">
                            <option value="all">전체 배기량</option>
                            <option value="under125">125cc 이하</option>
                            <option value="125to400">126cc ~ 400cc (쿼터급)</option>
                            <option value="over400">400cc 초과 (미들/리터급)</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- 바이크 상세 정보 카드 리스트 -->
            <div class="bike-info-grid">
                <c:forEach var="bike" items="${bikeList}">
                    <!-- 바이크 타입 결정 로직 -->
                    <c:set var="bikeType" value="other" />
                    <c:choose>
                        <c:when test="${fn:contains(bike.bikeImageUrl, 'scooter') or fn:contains(fn:toLowerCase(bike.bikeName), 'pcx') or fn:contains(fn:toLowerCase(bike.bikeName), 'primavera') or fn:contains(fn:toLowerCase(bike.bikeName), 'tmax') or fn:contains(fn:toLowerCase(bike.bikeName), 'gts')}">
                            <c:set var="bikeType" value="scooter" />
                        </c:when>
                        <c:when test="${fn:contains(bike.bikeImageUrl, 'sports') or fn:contains(fn:toLowerCase(bike.bikeName), 'r3') or fn:contains(fn:toLowerCase(bike.bikeName), 'r1') or fn:contains(fn:toLowerCase(bike.bikeName), 'panigale') or fn:contains(fn:toLowerCase(bike.bikeName), 'ninja') or fn:contains(fn:toLowerCase(bike.bikeName), 'cbr')}">
                            <c:set var="bikeType" value="sports" />
                        </c:when>
                        <c:when test="${fn:contains(bike.bikeImageUrl, 'cruiser') or fn:contains(fn:toLowerCase(bike.bikeName), 'iron') or fn:contains(fn:toLowerCase(bike.bikeName), 'harley') or fn:contains(fn:toLowerCase(bike.bikeName), 'rebel') or fn:contains(fn:toLowerCase(bike.bikeName), 'goldwing') or fn:contains(fn:toLowerCase(bike.bikeName), 'fat boy')}">
                            <c:set var="bikeType" value="cruiser" />
                        </c:when>
                        <c:when test="${fn:contains(bike.bikeImageUrl, 'adventure') or fn:contains(fn:toLowerCase(bike.bikeName), 'gs') or fn:contains(bike.bikeImageUrl, 'touring')}">
                            <c:set var="bikeType" value="adventure" />
                        </c:when>
                        <c:when test="${fn:contains(bike.bikeImageUrl, 'naked') or fn:contains(fn:toLowerCase(bike.bikeName), 'ninet') or fn:contains(fn:toLowerCase(bike.bikeName), 'mt-') or fn:contains(fn:toLowerCase(bike.bikeName), 'monster') or fn:contains(fn:toLowerCase(bike.bikeName), 'roadster')}">
                            <c:set var="bikeType" value="naked" />
                        </c:when>
                        <c:when test="${fn:contains(bike.bikeImageUrl, 'classic') or fn:contains(fn:toLowerCase(bike.bikeName), 'cub')}">
                            <c:set var="bikeType" value="classic" />
                        </c:when>
                    </c:choose>

                    <div class="info-card" data-type="${bikeType}" data-brand="${bike.brandName}" data-cc="${bike.cc}">
                        <div class="image-box">
                            <img src="${pageContext.request.contextPath}/${bike.bikeImageUrl}" alt="${bike.bikeName}">
                            <span class="cc-badge">
                                ${bike.cc} cc
                            </span>
                        </div>
                        <div class="info-body">
                            <div>
                                <span class="brand-tag">
                                    ${bike.brandName}
                                </span>
                                <h3>
                                    ${bike.bikeName}
                                </h3>
                                <p>
                                    ${bike.description}
                                </p>
                            </div>
                            
                            <!-- 제원 안내 (배기량, 색상, 모델연식) -->
                            <div class="spec-table" style="border-top: 1px solid #222; padding-top: 15px;">
                                <div style="display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 0.85rem;">
                                    <span style="color: #666;">제조사</span>
                                    <span style="color: #ddd; font-weight: 600;">${bike.brandName}</span>
                                </div>
                                <div style="display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 0.85rem;">
                                    <span style="color: #666;">배기량</span>
                                    <span style="color: #ddd; font-weight: 600;">${bike.cc}cc</span>
                                </div>
                                <div style="display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 0.85rem;">
                                    <span style="color: #666;">모델 연식</span>
                                    <span style="color: #ddd; font-weight: 600;">${bike.year}년식</span>
                                </div>
                                <div style="display: flex; justify-content: space-between; font-size: 0.85rem;">
                                    <span style="color: #666;">시그니처 컬러</span>
                                    <span style="color: #ddd; font-weight: 600;">${bike.color}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </section>

<style>
    .filter-item select:focus {
        border-color: #e50914 !important;
    }

    .bike-info-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
        gap: 24px;
    }
    
    .info-card {
        background: #121212;
        border: 1px solid #222;
        border-radius: 16px;
        overflow: hidden;
        transition: all 0.3s ease;
        display: flex;
        flex-direction: column;
    }
    .info-card:hover {
        border-color: #e50914 !important;
        transform: translateY(-5px);
        box-shadow: 0 10px 25px rgba(229, 9, 20, 0.15);
    }
    .info-card .image-box {
        position: relative;
        height: 180px;
        background: #1C1E26;
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
    }
    .info-card .image-box img {
        width: 100%;
        height: 100%;
        object-fit: cover;
        transition: transform 0.5s ease;
    }
    .info-card:hover .image-box img {
        transform: scale(1.05);
    }
    .info-card .cc-badge {
        position: absolute;
        top: 15px;
        right: 15px;
        background: rgba(0,0,0,0.75);
        border: 1px solid var(--primary-color);
        color: #fff;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 0.75rem;
        font-weight: 700;
        letter-spacing: 0.5px;
    }
    .info-card .info-body {
        padding: 20px;
        flex-grow: 1;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
    }
    .info-card .brand-tag {
        color: var(--primary-color);
        font-weight: 700;
        font-size: 0.8rem;
        text-transform: uppercase;
        letter-spacing: 1.5px;
        display: block;
        margin-bottom: 5px;
    }
    .info-card h3 {
        font-family: 'Outfit', sans-serif;
        font-size: 1.3rem;
        font-weight: 700;
        color: #fff;
        margin-bottom: 8px;
        letter-spacing: -0.3px;
    }
    .info-card p {
        color: #888;
        font-size: 0.85rem;
        line-height: 1.5;
        margin-bottom: 15px;
        min-height: 48px;
    }
</style>

<script>
    function filterBikes() {
        const genreVal = document.getElementById('filter-genre').value;
        const brandVal = document.getElementById('filter-brand').value;
        const ccVal = document.getElementById('filter-cc').value;
        
        const cards = document.querySelectorAll('.info-card');
        
        cards.forEach(card => {
            const cardType = card.getAttribute('data-type');
            const cardBrand = card.getAttribute('data-brand');
            const cardCc = parseInt(card.getAttribute('data-cc'), 10);
            
            let matchGenre = (genreVal === 'all' || cardType === genreVal);
            let matchBrand = (brandVal === 'all' || cardBrand === brandVal);
            let matchCc = false;
            
            if (ccVal === 'all') {
                matchCc = true;
            } else if (ccVal === 'under125') {
                matchCc = (cardCc <= 125);
            } else if (ccVal === '125to400') {
                matchCc = (cardCc > 125 && cardCc <= 400);
            } else if (ccVal === 'over400') {
                matchCc = (cardCc > 400);
            }
            
            if (matchGenre && matchBrand && matchCc) {
                card.style.display = 'flex';
            } else {
                card.style.display = 'none';
            }
        });
    }

    document.getElementById('filter-genre').addEventListener('change', filterBikes);
    document.getElementById('filter-brand').addEventListener('change', filterBikes);
    document.getElementById('filter-cc').addEventListener('change', filterBikes);
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
