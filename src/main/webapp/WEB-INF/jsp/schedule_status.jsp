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

  <!-- 일정 상세 -->
  <div class="schedule-detail">
    <h3 id="detailTitle">📅 선택된 날짜: <span>-</span></h3>
    <div id="scheduleList"></div>
  </div>
</div>
</body>
</html>

<script>
  let schedules = [];

  $(function(){
    let current = new Date();

    function loadCalendar(year, month){
      $('#calendarTitle').text(year + '년 ' + (month + 1) + '월');

      const firstDay = new Date(year, month, 1);
      const lastDate = new Date(year, month + 1, 0).getDate();
      const startDay = firstDay.getDay();

      $('#calendarGrid').empty();

      // 앞쪽 공백
      for(let i = 0; i < startDay; i++){
        $('#calendarGrid').append('<div></div>');
      }

      // ✅ 서버에서 일정 데이터 불러오기
      $.get('/api/schedule/month', {year:year, month:month+1}, function(res){
        schedules = res;
        for(let d = 1; d <= lastDate; d++){
          const dateStr = year + '-' + String(month+1).padStart(2, '0') + '-' + String(d).padStart(2, '0');
          const today = new Date();

          const dayData = schedules.filter(s => s.scheduleDate === dateStr);
          let fundCount = 0, nonCount = 0;

          if(dayData.length > 0){
            const item = dayData[0];
            fundCount = item.fundMembers ? item.fundMembers.split(',').length : 0;
            nonCount = item.nonFundMembers ? item.nonFundMembers.split(',').length : 0;
          }

          const summaryHtml =
                  (fundCount + nonCount > 0)
                          ? `
                      <div class="summary">
                        <div>공금 \${fundCount}명</div>
                        <div>비공금 \${nonCount}명</div>
                      </div>
                    `
                          : '';

          const cell = $('<div class="day-cell" data-date="' + dateStr + '">' +
                  '<div class="day-num">' + d + '</div>' +
                  summaryHtml + '</div>');

          if (isToday(today, year, month, d)) cell.addClass('today');
          $('#calendarGrid').append(cell);
        }
      }).fail(() => alert('일정 정보를 불러오지 못했습니다.'));
    }

    function isToday(today, y, m, d){
      return today.getFullYear() === y && today.getMonth() === m && today.getDate() === d;
    }

    $(document).on('click', '.day-cell', function(){
      const date = $(this).data('date');
      $('#detailTitle span').text(date);

      const list = schedules.filter(s => s.scheduleDate === date);
      const area = $('#scheduleList');
      area.empty();

      if(list.length === 0){
        area.append('<p>등록된 일정이 없습니다.</p>');
        return;
      }

      let tableHtml = `
    <table class="schedule-table">
      <thead>
        <tr>
          <th>공금/비공금</th>
          <th>벙주</th>
          <th>참석자</th>
          <th>인원</th>
          <th>수정</th>
        </tr>
      </thead>
      <tbody>
  `;

      list.forEach(s => {
        const fundArr = s.fundMembers ? s.fundMembers.split(',') : [];
        const nonArr = s.nonFundMembers ? s.nonFundMembers.split(',') : [];

        // 공금 행
        tableHtml += `
      <tr class="fund-row">
        <td>공금</td>
        <td>\${s.leader || '-'}</td>
        <td>\${fundArr.join(', ') || '-'}</td>
        <td>\${fundArr.length}명</td>
        <td><button class="edit-btn" data-id="\${s.id || s.srno}"  data-type="fund">수정</button></td>
      </tr>
    `;

        // 비공금 행
        tableHtml += `
      <tr class="nonfund-row">
        <td>비공금</td>
        <td>\${s.leader || '-'}</td>
        <td>\${nonArr.join(', ') || '-'}</td>
        <td>\${nonArr.length}명</td>
        <td><button class="edit-btn" data-id="\${s.id || s.srno}"  data-type="nonfund">수정</button></td>
      </tr>
    `;
      });

      tableHtml += `</tbody></table>`;
      area.append(tableHtml);
    });

    // ✅ 월 이동
    $('#prevMonth').click(function(){
      current.setMonth(current.getMonth() - 1);
      loadCalendar(current.getFullYear(), current.getMonth());
    });
    $('#nextMonth').click(function(){
      current.setMonth(current.getMonth() + 1);
      loadCalendar(current.getFullYear(), current.getMonth());
    });

    //  초기 달력 로드
    loadCalendar(current.getFullYear(), current.getMonth());
  });

  //  수정 버튼 클릭
  $(document).on('click', '.edit-btn', function() {
    const id = $(this).data('id');     // 일정 ID
    const type = $(this).data('type'); // fund / nonfund 구분

    // 선택된 일정 전체 데이터 찾기
    const selected = schedules.find(s => s.srno == id || s.scheduleId == id);

    if (!selected) {
      alert('해당 일정을 찾을 수 없습니다.');
      return;
    }

    //  로컬스토리지에 데이터 저장 (다음 페이지로 전달)
    localStorage.setItem('editSchedule', JSON.stringify({
      id: id,
      scheduleDate: selected.scheduleDate,
      leader: selected.leader,
      fundMembers: selected.fundMembers,
      nonFundMembers: selected.nonFundMembers,
      type: type
    }));

    // 일정추가 페이지로 이동
    window.location.href = '/schedule/add'; // 일정추가.jsp 경로에 맞게 수정
  });
</script>
