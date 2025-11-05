<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/head"/>
<jsp:include page="/header"/>

<div class="schedule-status-page">
    <div class="calendar-header">
        <button id="prevMonth">◀</button>
        <h2 id="calendarTitle"></h2>
        <button id="nextMonth">▶</button>
    </div>

    <!-- 요일 헤더 -->
    <div class="calendar-weekdays">
        <div>일</div><div>월</div><div>화</div><div>수</div><div>목</div><div>금</div><div>토</div>
    </div>

    <!-- 달력 본체 -->
    <div class="calendar-grid" id="calendarGrid"></div>

</div>

<div id="fundDetail" style="display:none; margin-top:15px;">
    <table class="fund-table">
        <thead>
        <tr>
            <th>일자</th>
            <th>출금</th>
            <th>입금</th>
            <th>완료</th>
        </tr>
        </thead>
        <tbody id="fundTableBody">
        <tr>
            <td id="fundDate">-</td>
            <td><input type="number" id="withdraw" value="0"></td>
            <td><input type="number" id="deposit" value="0"></td>
            <td class="fund-btn-cell">
                <div class="btn-wrap">
                    <button id="fundSaveBtn">확인</button>
                </div>
            </td>
        </tr>
        </tbody>
    </table>
</div>


</body>
</html>


<script>
    $(function(){
        let current = new Date();
        let fundList = [];

        function loadCalendar(year, month){
            $('#calendarTitle').text(`\${year}년 \${month+1}월`);
            const firstDay = new Date(year, month, 1);
            const lastDate = new Date(year, month+1, 0).getDate();
            const startDay = firstDay.getDay();
            $('#calendarGrid').empty();

            const todayStr = new Date().toISOString().slice(0,10);

            // 전체 데이터 불러오기
            $.get('/api/fund/all', function(res){
                fundList = res.sort((a,b) => new Date(a.fundDate) - new Date(b.fundDate)); // 날짜순 정렬

                for(let i=0;i<startDay;i++) $('#calendarGrid').append('<div></div>');

                for(let d=1; d<=lastDate; d++){
                    const dateStr = `\${year}-\${String(month+1).padStart(2,'0')}-\${String(d).padStart(2,'0')}`;
                    const data = fundList.find(f => f.fundDate === dateStr);

                    //  1) 해당 날짜까지의 누적 합계 계산
                    const pastFunds = fundList.filter(f => new Date(f.fundDate) <= new Date(dateStr));
                    const totalWithdraw = pastFunds.reduce((sum, f) => sum + (f.withdrawAmount || 0), 0);
                    const totalDeposit = pastFunds.reduce((sum, f) => sum + (f.depositAmount || 0), 0);
                    const totalBalance = totalDeposit - totalWithdraw;

                    //  2) 오늘 날짜 표시
                    const isToday = (dateStr === todayStr);
                    const todayClass = isToday ? 'today-cell' : '';

                    //  3) 해당 날짜에 데이터 있을 때만 표시
                    let summaryHtml = '';
                    if (data) {
                        summaryHtml = `
              <div class="summary">
                출금: \${data.withdrawAmount}<br>
                입금: \${data.depositAmount}<br>
                잔액: \${totalBalance}
              </div>
            `;
                    }

                    $('#calendarGrid').append(`
            <div class="day-cell \${todayClass}" data-date="\${dateStr}">
              <div class="day-num">\${d}</div>
              \${summaryHtml}
            </div>
          `);
                }
            });
        }

        // 날짜 클릭 시
        $(document).on('click', '.day-cell', function(){
            const date = $(this).data('date');
            $('#fundDate').text(date).css('color', '#333');
            $('#fundDetail').show();

            $('.day-cell').removeClass('selected-date');
            $(this).addClass('selected-date');

            // ✅ 클릭한 날짜에 해당하는 데이터 불러오기
            const fund = fundList.find(f => f.fundDate === date);
            if (fund) {
                $('#withdraw').val(fund.withdrawAmount || 0);
                $('#deposit').val(fund.depositAmount || 0);
            } else {
                $('#withdraw').val(0);
                $('#deposit').val(0);
            }

            // ✅ 테이블이 헤더에 가려지지 않도록 여유
            const offset = $('#fundDetail').offset().top - 150;
            $('html, body').animate({ scrollTop: offset }, 300);
        });



        // 저장
        $('#fundSaveBtn').click(function(){
            const fund = {
                fundDate: $('#fundDate').text(),
                withdrawAmount: parseInt($('#withdraw').val()||0),
                depositAmount: parseInt($('#deposit').val()||0)
            };
            $.ajax({
                url:'/api/fund/save',
                type:'POST',
                contentType:'application/json',
                data:JSON.stringify(fund),
                success:function(){
                    alert('저장완료');
                    loadCalendar(current.getFullYear(), current.getMonth());
                }
            });
        });

        $('#prevMonth').click(()=>{ current.setMonth(current.getMonth()-1); loadCalendar(current.getFullYear(), current.getMonth()); });
        $('#nextMonth').click(()=>{ current.setMonth(current.getMonth()+1); loadCalendar(current.getFullYear(), current.getMonth()); });

        loadCalendar(current.getFullYear(), current.getMonth());
    });
</script>
