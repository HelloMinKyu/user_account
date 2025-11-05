<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:include page="/head"/>
<jsp:include page="/header"/>

<div class="member-page">

  <!-- ✅ 메인 컨테이너 -->
  <div class="member-container">

    <h2 class="page-title">회원관리</h2>

    <!-- ✅ 회원 리스트 테이블 -->
    <div class="member-list-section">
      <table class="member-table">
        <thead>
        <tr>
          <th>회원명</th>
          <th>성별</th>
          <th>지역</th>
          <th>회원등급</th>
          <th>생년월일</th>
          <th>가입일</th>
          <th>특이사항</th>
        </tr>
        </thead>
        <tbody>
        <tr>
          <td>홍길동</td>
          <td>남</td>
          <td>서울</td>
          <td>VIP</td>
          <td>1995-06-14</td>
          <td>2024-02-10</td>
          <td>정기후원 회원</td>
        </tr>
        </tbody>
      </table>
      <div class="pagination" style="text-align:center; margin-top:15px;"></div>
    </div>

    <!-- ✅ 회원 입력 섹션 -->
    <div class="member-form-section">

      <div class="member-form-grid">

        <!-- 회원정보 입력 -->
        <div class="member-inputs">
          <label>회원명</label>
          <input type="text" name="name" placeholder="회원명 입력">

          <label>성별</label>
          <select name="gender">
            <option value="">선택</option>
            <option value="남">남</option>
            <option value="여">여</option>
          </select>

          <label>지역</label>
          <select name="region">
            <option value="">선택</option>
            <option value="진주">진주</option>
            <option value="창원">창원</option>
            <option value="마산">마산</option>
            <option value="진해">진해</option>
            <option value="김해">김해</option>
            <option value="귀산">귀산</option>
            <option value="장유">장유</option>
            <option value="양산">양산</option>
            <option value="울산">울산</option>
          </select>

          <label>회원등급</label>
          <select name="grade">
            <option value="">선택</option>
            <option value="방장">방장</option>
            <option value="부반장">부반장</option>
            <option value="일반">일반</option>
            <option value="병아리">병아리</option>
            <option value="블랙리스트">블랙리스트</option>
          </select>

          <label>생년월일</label>
          <input type="date" name="birth">

          <label>가입일</label>
          <input type="date" name="join_date">

          <label>특이사항</label>
          <textarea name="note" rows="2" placeholder="특이사항 메모"></textarea>
        </div>

        <!-- 회원 사진 -->
        <div class="member-photo">
          <img src="/img/default_profile.png" alt="회원 사진 미리보기" id="photoPreview">

          <!-- 파일 업로드 꾸민 버튼 -->
          <label for="photoInput" class="file-label">사진 선택</label>
          <input type="file" name="photo" id="photoInput" accept="image/*">
        </div>

      </div>

      <!-- 저장 버튼 -->
      <div class="save-btn-wrap">
        <button class="save-btn">저장</button>
      </div>
    </div>
  </div>
</div>

<script>
  let currentMembers = [];
  let selectedSrno = null;
  let currentPage = 0;
  let totalPages = 0;
  const pageSize = 10; // ✅ 기본 10명씩 표시

  $(document).ready(function() {
    loadMembers(0); // ✅ 첫 페이지 로드

    // 회원 목록 조회 (페이지별)
    function loadMembers(page) {
      $.ajax({
        url: '/api/member/list?page=' + page + '&size=' + pageSize,
        type: 'GET',
        success: function(res) {
          const tbody = $('.member-table tbody');
          tbody.empty();

          // res 구조가 Page 형식 또는 Map 형식인지 판단
          const members = res.content ? res.content : res;
          currentMembers = members;

          // 페이지 정보 저장
          currentPage = res.currentPage || 0;
          totalPages = res.totalPages || 1;

          if (!members || members.length === 0) {
            tbody.append('<tr><td colspan="7">등록된 회원이 없습니다.</td></tr>');
            $('.pagination').empty();
            return;
          }

          members.forEach(m => {
            const tr = `
              <tr data-srno="\${m.srno}">
                <td>\${m.name || ''}</td>
                <td>\${m.gender || ''}</td>
                <td>\${m.region || ''}</td>
                <td>\${m.grade || ''}</td>
                <td>\${m.birth || ''}</td>
                <td>\${m.joinDate || ''}</td>
                <td>\${m.note || ''}</td>
              </tr>`;
            tbody.append(tr);
          });

          renderPagination(totalPages, currentPage);
        },
        error: function(xhr) {
          alert('회원 목록 조회 실패: ' + xhr.responseText);
        }
      });
    }

    // 페이지네이션 버튼 렌더링
    function renderPagination(totalPages, currentPage) {
      const pagination = $('.pagination');
      pagination.empty();

      if (totalPages <= 1) return;

      // 이전 버튼
      const prevDisabled = currentPage === 0 ? 'disabled' : '';
      pagination.append(`<button class="page-btn" data-page="\${currentPage - 1}" \${prevDisabled}>이전</button>`);

      // 페이지 번호 버튼
      for (let i = 0; i < totalPages; i++) {
        const activeClass = (i === currentPage) ? 'active' : '';
        pagination.append(`<button class="page-btn \${activeClass}" data-page="\${i}">\${i + 1}</button>`);
      }

      // 다음 버튼
      const nextDisabled = currentPage >= totalPages - 1 ? 'disabled' : '';
      pagination.append(`<button class="page-btn" data-page="\${currentPage + 1}" \${nextDisabled}>다음</button>`);
    }

    // 페이지 이동 버튼 클릭
    $(document).on('click', '.page-btn', function() {
      const page = parseInt($(this).data('page'));
      if (!isNaN(page) && page >= 0 && page < totalPages) {
        loadMembers(page);
        window.scrollTo({ top: 0, behavior: 'smooth' }); // 페이지 바뀔 때 맨 위로 이동
      }
    });

    // 테이블 행 클릭 시 값 세팅
    $(document).on('click', '.member-table tbody tr', function() {
      const srno = $(this).data('srno');
      const member = currentMembers.find(m => m.srno === srno);
      if (!member) return;

      selectedSrno = srno;

      $('input[name=name]').val(member.name || '');
      $('select[name=gender]').val(member.gender || '');
      $('select[name=region]').val(member.region || '');
      $('select[name=grade]').val(member.grade || '');
      $('input[name=birth]').val(member.birth || '');
      $('input[name=join_date]').val(member.joinDate || '');
      $('textarea[name=note]').val(member.note || '');

      if (member.photoPath) {
        const safePath = member.photoPath.replace(/\\/g, '/');
        const base64Path = btoa(unescape(encodeURIComponent(safePath)));
        $('#photoPreview').attr('src', '/api/member/photo?path=' + base64Path);
      } else {
        $('#photoPreview').attr('src', '/img/default_profile.png');
      }
    });

    // 저장 (등록/수정 공통)
    $('.save-btn').click(function() {
      const formData = new FormData();
      if (selectedSrno) formData.append('srno', selectedSrno); // 수정 모드일 경우
      formData.append('name', $('input[name=name]').val());
      formData.append('gender', $('select[name=gender]').val());
      formData.append('region', $('select[name=region]').val());
      formData.append('grade', $('select[name=grade]').val());
      formData.append('birth', $('input[name=birth]').val());
      formData.append('join_date', $('input[name=join_date]').val());
      formData.append('note', $('textarea[name=note]').val());
      formData.append('photo', $('#photoInput')[0].files[0]);

      $.ajax({
        url: '/api/member/save',
        type: 'POST',
        data: formData,
        processData: false,
        contentType: false,
        success: function(res) {
          alert(res);
          loadMembers(currentPage); // 현재 페이지 그대로 새로고침
          clearForm();
        },
        error: function(xhr) {
          alert('저장 실패: ' + xhr.responseText);
        }
      });
    });

    // 폼 초기화 함수
    function clearForm() {
      selectedSrno = null;
      $('input[name=name]').val('');
      $('select[name=gender]').val('');
      $('select[name=region]').val('');
      $('select[name=grade]').val('');
      $('input[name=birth]').val('');
      $('input[name=join_date]').val('');
      $('textarea[name=note]').val('');
      $('#photoPreview').attr('src', '/img/default_profile.png');
      $('#photoInput').val('');
    }

    // 첨부 미리보기
    $('#photoInput').on('change', function(e) {
      const file = e.target.files[0];
      if (file) {
        const reader = new FileReader();
        reader.onload = function(e) {
          $('#photoPreview').attr('src', e.target.result);
        };
        reader.readAsDataURL(file);
      }
    });
  });
</script>


</body>
</html>

