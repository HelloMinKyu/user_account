<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/head"/>
<jsp:include page="/header"/>

<div class="schedule-page">

  <div class="schedule-container">
    <h2 class="page-title">일정 추가</h2>

    <!-- 입력 폼 -->
    <div class="schedule-form">

      <label>일정 날짜</label>
      <input type="date" name="schedule_date" required>

      <label>벙주</label>
      <div class="input-with-btn">
        <input type="text" name="leader" placeholder="벙주 선택" readonly required>
        <button type="button" class="search-btn" data-type="leader">찾기</button>
      </div>

      <label>공금 참석자</label>
      <div class="input-with-btn">
        <textarea name="fund_members" rows="2" placeholder="선택된 참석자 표시" readonly></textarea>
        <button type="button" class="search-btn" data-type="fund">찾기</button>
      </div>

      <label>비공금 참석자</label>
      <div class="input-with-btn">
        <textarea name="nonfund_members" rows="2" placeholder="선택된 참석자 표시" readonly></textarea>
        <button type="button" class="search-btn" data-type="nonfund">찾기</button>
      </div>

      <!-- 저장 버튼 -->
      <div class="save-btn-wrap">
        <button class="save-btn">저장</button>
      </div>
    </div>
  </div>
</div>

<!-- 팝업 모달 -->
<div id="memberModal" class="modal-overlay" style="display:none;">
  <div class="modal-content">
    <h3 class="modal-title">회원 선택</h3>
    <table class="modal-table">
      <thead>
      <tr>
        <th>선택</th>
        <th>회원명</th>
        <th>성별</th>
        <th>지역</th>
        <th>등급</th>
      </tr>
      </thead>
      <tbody id="modalMemberList">
      <!-- JS로 회원 목록 렌더링 -->
      </tbody>
    </table>

    <div class="modal-actions">
      <button id="confirmSelect">확인</button>
      <button id="closeModal">닫기</button>
    </div>
    <div class="modal-pagination"></div>
  </div>
</div>

</body>
</html>
<script>
  $(function(){
    let currentType = null;   // leader / fund / nonfund
    let members = [];

    // 모달 페이징 상태
    let MODAL_PAGE_SIZE = 10;
    let modalPage = 0;
    let modalTotalPages = 0;

    // 다중선택 유지용 (이름 기준)
    const modalSelected = new Set();

    // ===============================
    // ✅ [1] 수정모드 감지 및 폼 세팅
    // ===============================
    const editData = localStorage.getItem('editSchedule');
    if (editData) {
      const s = JSON.parse(editData);
      $('input[name=schedule_date]').val(s.scheduleDate);
      $('input[name=leader]').val(s.leader);
      $('textarea[name=fund_members]').val(s.fundMembers);
      $('textarea[name=nonfund_members]').val(s.nonFundMembers);

      // 수정모드 UI
      $('.save-btn').text('수정 완료');
      if ($('#deleteBtn').length === 0) {
        $('.save-btn-wrap').append('<button id="deleteBtn" class="delete-btn">삭제</button>');
      }

      // 전역 수정 ID
      window.editId = s.id;
    }

    // ===============================
    // ✅ [2] 팝업 열기 / 닫기
    // ===============================
    $('.search-btn').on('click', function(){
      currentType = $(this).data('type');

      // 다중선택의 경우 기존 입력값 복원
      if(currentType === 'fund' || currentType === 'nonfund'){
        modalSelected.clear();
        const preset = (currentType === 'fund'
                        ? $('textarea[name=fund_members]').val()
                        : $('textarea[name=nonfund_members]').val()
        ).split(',').map(s => s.trim()).filter(Boolean);
        preset.forEach(name => modalSelected.add(name));
      }

      modalPage = 0;
      loadMembersPaged(modalPage);
      $('#memberModal').fadeIn(200);
    });

    $('#closeModal').on('click', function(){
      $('#memberModal').fadeOut(200);
    });

    // ===============================
    // ✅ [3] 회원 목록 페이징 로드
    // ===============================
    function loadMembersPaged(page){
      $.ajax({
        url: '/api/member/list?page=' + page + '&size=' + MODAL_PAGE_SIZE,
        type: 'GET',
        success: function(res){
          const list = res.content || res;
          modalPage = res.currentPage || page || 0;
          modalTotalPages = res.totalPages || 1;
          const tbody = $('#modalMemberList');
          tbody.empty();

          list.forEach(m=>{
            const value = m.name;
            const checked = (currentType == 'leader')
                    ? ''
                    : (modalSelected.has(value) ? 'checked' : '');
            tbody.append(`
              <tr>
                <td>
                  <input type="\${currentType=='leader' ? 'radio' : 'checkbox'}"
                         class="modal-select"
                         name="selectMember"
                         value="\${value}" \${checked}>
                </td>
                <td>\${m.name || ''}</td>
                <td>\${m.gender || ''}</td>
                <td>\${m.region || ''}</td>
                <td>\${m.grade || ''}</td>
              </tr>
            `);
          });

          renderModalPagination(modalTotalPages, modalPage);
        },
        error: function(xhr){
          alert('회원 목록을 불러오지 못했습니다.');
        }
      });
    }

    function renderModalPagination(totalPages, current){
      const $p = $('.modal-pagination');
      $p.empty();
      if(totalPages <= 1) return;

      const prevDisabled = current === 0 ? 'disabled' : '';
      $p.append(`<button class="modal-page-btn" data-page="\${current-1}" \${prevDisabled}>이전</button>`);

      const windowSize = 5;
      const start = Math.max(0, current - Math.floor(windowSize/2));
      const end = Math.min(totalPages, start + windowSize);
      const realStart = Math.max(0, end - windowSize);

      for(let i=realStart; i<end; i++){
        const active = (i === current) ? 'active' : '';
        $p.append(`<button class="modal-page-btn \${active}" data-page="\${i}">\${i+1}</button>`);
      }

      const nextDisabled = current >= totalPages-1 ? 'disabled' : '';
      $p.append(`<button class="modal-page-btn" data-page="\${current+1}" \${nextDisabled}>다음</button>`);
    }

    $(document).on('click', '.modal-page-btn', function(){
      const page = parseInt($(this).data('page'));
      if(isNaN(page)) return;
      if(page < 0 || page >= modalTotalPages) return;
      loadMembersPaged(page);
    });

    $(document).on('change', '.modal-select', function(){
      const val = $(this).val();
      if(currentType == 'leader') return;
      if(this.checked) modalSelected.add(val);
      else modalSelected.delete(val);
    });

    // ===============================
    // ✅ [4] 선택 확인
    // ===============================
    $('#confirmSelect').on('click', function(){
      if(currentType === 'leader'){
        const selected = $('input[name=selectMember]:checked').val();
        if(!selected){ alert('벙주를 선택해주세요.'); return; }
        $('input[name=leader]').val(selected);
      } else {
        const arr = Array.from(modalSelected);
        if(arr.length === 0){ alert('참석자를 선택해주세요.'); return; }
        if(currentType === 'fund'){
          $('textarea[name=fund_members]').val(arr.join(', '));
        } else if(currentType === 'nonfund'){
          $('textarea[name=nonfund_members]').val(arr.join(', '));
        }
      }
      $('#memberModal').fadeOut(200);
    });

    // ===============================
    // ✅ [5] 저장 (등록 or 수정)
    // ===============================
    $('.save-btn').on('click', function(){
      const schedule = {
        srno: window.editId || null,
        scheduleDate: $('input[name=schedule_date]').val(),
        leader: $('input[name=leader]').val(),
        fundMembers: $('textarea[name=fund_members]').val(),
        nonFundMembers: $('textarea[name=nonfund_members]').val()
      };
      if(!schedule.scheduleDate || !schedule.leader){
        alert('날짜와 벙주는 필수 입력입니다.');
        return;
      }

      const url = window.editId ? '/api/schedule/update' : '/api/schedule/save';
      $.ajax({
        url: url,
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(schedule),
        success: function(res){
          alert(res);
          localStorage.removeItem('editSchedule');
          window.location.href = '/schedule'; // 일정현황 페이지로 이동
        },
        error: function(xhr){
          alert('저장 실패: ' + xhr.responseText);
        }
      });
    });

    // ===============================
    // ✅ [6] 삭제 버튼
    // ===============================
    $(document).on('click', '#deleteBtn', function(){
      if (!window.editId) return;
      if (!confirm('정말 삭제하시겠습니까?')) return;

      $.ajax({
        url: '/api/schedule/delete/' + window.editId,
        type: 'DELETE',
        success: function(res){
          alert(res);
          localStorage.removeItem('editSchedule');
          window.location.href = '/schedule';
        },
        error: function(xhr){
          alert('삭제 실패: ' + xhr.responseText);
        }
      });
    });
  });
</script>
