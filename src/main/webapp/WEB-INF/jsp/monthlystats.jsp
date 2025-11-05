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

    <!-- 추가: 테이블을 감싸는 wrapper -->
    <div class="stats-table-wrapper">
        <table class="stats-table">
            <thead>
            <tr>
                <th>회원명</th>
                <th>성별</th>
                <th>지역</th>
                <th>벙주</th>
                <th>공금</th>
                <th>비공금</th>
                <% for(int i=1;i<=31;i++){ %>
                <th><%=i%></th>
                <% } %>
            </tr>
            </thead>
            <tbody id="statsBody"></tbody>
        </table>
    </div>
</div>



</body>
</html>

<script>
    $(function(){
        let current = new Date();

        function loadStats(year, month){
            $('#monthTitle').text(`\${year}년 \${month+1}월`);
            $.get('/api/schedule/user/month', {year, month: month+1}, function(res){
                const tbody = $('#statsBody').empty();

                res.forEach(r=>{
                    const daily = {};

                    // 하루에 여러 항목 있을 경우 배열로 저장
                    if(r.dailyLog){
                        r.dailyLog.split(',').forEach(item=>{
                            const [day, type] = item.split(':');
                            if (!day || !type) return;
                            if (!daily[day]) daily[day] = [];
                            daily[day].push(type); // 누적 저장
                        });
                    }

                    let html = `
                        <tr>
                          <td>\${r.memberName}</td>
                          <td>\${r.gender||''}</td>
                          <td>\${r.region||''}</td>
                          <td>\${r.leaderCount||0}</td>
                          <td>\${r.fundCount||0}</td>
                          <td>\${r.nonFundCount||0}</td>
                    `;

                    // 날짜별 출력
                    for (let i = 1; i <= 31; i++) {
                        if (daily[i]) {
                            // daily[i] = ['벙주', '공금', '비공금'] 처럼 여러개일 수 있음
                            const cls = {'벙주':'leader','공금':'fund','비공금':'nonfund'};
                            const content = `<div class="cell-badges">` + daily[i]
                                .map(v => `<span class="mark \${cls[v]||''}">\${v}</span>`)
                                .join('') + `</div>`;
                            html += `<td>\${content}</td>`;
                        } else {
                            html += `<td></td>`;
                        }
                    }

                    html += '</tr>';
                    tbody.append(html);
                });
            });
        }

        $('#prevMonth').click(()=>{ current.setMonth(current.getMonth()-1); loadStats(current.getFullYear(), current.getMonth()); });
        $('#nextMonth').click(()=>{ current.setMonth(current.getMonth()+1); loadStats(current.getFullYear(), current.getMonth()); });

        loadStats(current.getFullYear(), current.getMonth());
    });
</script>

