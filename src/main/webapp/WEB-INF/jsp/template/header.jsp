<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<body>
<!-- 전체 컨테이너 -->
<header class="sidebar">
    <div class="sidebar-logo">
        <a href="/">📊 관리시스템</a>
    </div>

    <nav class="sidebar-nav">
        <ul>
            <li><a href="/user">회원관리</a></li>
            <li><a href="/schedule">일정현황</a></li>
            <li><a href="/schedule/add">일정추가</a></li>
            <li><a href="/fund">공금관리</a></li>
            <li><a href="/monthlystats">월별통계</a></li>
        </ul>
    </nav>
</header>
<!-- ✅ 모바일 햄버거 버튼 -->
<div class="mobile-header">
    <button class="menu-toggle">☰</button>
    <h1 class="mobile-title"></h1>
</div>

<script>
    $(function() {
        $('.menu-toggle').click(function() {
            $('.sidebar').toggleClass('open');
        });
    });
</script>
