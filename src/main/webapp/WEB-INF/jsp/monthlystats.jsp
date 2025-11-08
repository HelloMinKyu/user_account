<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/head"/>
<jsp:include page="/header"/>

<div class="stats-page">
    <div class="month-header">
        <button id="prevMonth">◀</button>
        <h2 id="monthTitle"></h2>
        <button id="nextMonth">▶</button>
    </div>

    <div class="stats-table-wrapper">
        <table class="stats-table">
            <thead>
            <tr>
                <th rowspan="2">회원명</th>
                <th rowspan="2">성별</th>
                <th rowspan="2">지역</th>
                <th rowspan="2">벙주</th>
                <th rowspan="2">공금</th>
                <th rowspan="2">비공금</th>
                <% for (int i = 1; i <= 31; i++) { %>
                <th colspan="3"><%= i %></th>
                <% } %>
            </tr>
            <tr>
                <% for (int i = 1; i <= 31; i++) { %>
                <th>벙주</th>
                <th>공금</th>
                <th>비공금</th>
                <% } %>
            </tr>
            </thead>
            <tbody id="statsBody"></tbody>
        </table>
    </div>

    <!-- ✅ TOP 섹션 -->
    <div class="top3-section">
        <h3>🏆 이달의 TOP</h3>
        <div class="top3-container">
            <div class="top3-box" id="top-leader">
                <h4>💪 벙주</h4>
                <ul></ul>
            </div>
            <div class="top3-box" id="top-fund">
                <h4>💰 공금</h4>
                <ul></ul>
            </div>
            <div class="top3-box" id="top-nonfund">
                <h4>👥 비공금</h4>
                <ul></ul>
            </div>
        </div>
    </div>
</div>

</body>
</html>

<script>
    $(function(){
        let current = new Date();

        function loadStats(year, month){
            $('#monthTitle').text(`\${year}년 \${month + 1}월`);

            $.get('/api/schedule/user/month', { year, month: month + 1 }, function(res){
                const tbody = $('#statsBody').empty();

                res.forEach(r => {
                    const daily = {};
                    if (r.dailyLog) {
                        r.dailyLog.split(',').forEach(item => {
                            const [day, type] = item.split(':');
                            if (!day || !type) return;
                            if (!daily[day]) daily[day] = [];
                            daily[day].push(type);
                        });
                    }

                    let html = `
          <tr>
            <td>\${r.memberName}</td>
            <td>\${r.gender || ''}</td>
            <td>\${r.region || ''}</td>
            <td>\${r.leaderCount || 0}</td>
            <td>\${r.fundCount || 0}</td>
            <td>\${r.nonFundCount || 0}</td>
        `;

                    for (let i = 1; i <= 31; i++) {
                        const vals = daily[i] || [];
                        html += `
            <td class="cell-leader">\${vals.includes('벙주') ? '✔' : ''}</td>
            <td class="cell-fund">\${vals.includes('공금') ? '✔' : ''}</td>
            <td class="cell-nonfund">\${vals.includes('비공금') ? '✔' : ''}</td>
          `;
                    }

                    html += '</tr>';
                    tbody.append(html);
                });

                renderTopSection(res);
            });
        }

        function renderTopSection(data){
            const stats = data.map(r => ({
                memberName: r.memberName,
                leaderCount: r.leaderCount || 0,
                fundCount: r.fundCount || 0,
                nonFundCount: r.nonFundCount || 0
            }));

            const leaderTop = extractTopWithTies(stats, 'leaderCount');
            const fundTop   = extractTopWithTies(stats, 'fundCount');
            const nonTop    = extractTopWithTies(stats, 'nonFundCount');

            renderTopList('#top-leader ul', leaderTop);
            renderTopList('#top-fund ul', fundTop);
            renderTopList('#top-nonfund ul', nonTop);
        }

        // 공동 순위 계산
        function extractTopWithTies(list, key){
            const sorted = list
                .filter(x => (x[key] || 0) > 0)
                .sort((a, b) => b[key] - a[key]);
            if (sorted.length === 0) return [];

            const result = [];
            let prev = null, rank = 0, usedRanks = 0;
            for (const item of sorted){
                if (prev === null || item[key] < prev){
                    rank++;
                    usedRanks++;
                }
                if (usedRanks > 3) break;
                result.push({ rank, name: item.memberName, count: item[key] });
                prev = item[key];
            }
            return result;
        }

        function renderTopList(selector, topList){
            const ul = $(selector).empty();
            if (!topList || topList.length === 0){
                ul.append('<li>데이터 없음</li>');
                return;
            }

            // rank별로 묶기
            const grouped = {};
            topList.forEach(it => {
                if (!grouped[it.rank]) grouped[it.rank] = [];
                grouped[it.rank].push(it);
            });

            // 각 순위별로 한 줄씩 출력
            Object.keys(grouped).forEach(rank => {
                const names = grouped[rank].map(it => `\${it.name}(\${it.count})`).join(', ');
                ul.append(`<li> \${rank}위 - \${names}</li>`);
            });
        }


        $('#prevMonth').click(() => {
            current.setMonth(current.getMonth() - 1);
            loadStats(current.getFullYear(), current.getMonth());
        });
        $('#nextMonth').click(() => {
            current.setMonth(current.getMonth() + 1);
            loadStats(current.getFullYear(), current.getMonth());
        });

        loadStats(current.getFullYear(), current.getMonth());
    });
</script>
