<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>관리자 로그인</title>
    <style>
        body {
            font-family: 'Noto Sans KR', sans-serif;
            margin: 0;
            padding: 0;
            background: url('/img/main.webp') no-repeat center center / cover;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .login-container {
            background: rgba(255,255,255,0.95);
            padding: 50px 60px;
            border-radius: 12px;
            text-align: center;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }

        .login-container h2 {
            margin-bottom: 25px;
            color: #333;
        }

        .login-container input {
            width: 100%;
            padding: 10px 12px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 15px;
        }

        .login-container button {
            width: 100%;
            padding: 10px;
            border: none;
            background: #4a90e2;
            color: white;
            font-size: 16px;
            border-radius: 6px;
            cursor: pointer;
        }

        .login-container button:hover {
            background: #357ac8;
        }

        .error {
            color: #e74c3c;
            margin-top: 10px;
        }
    </style>
</head>
<body>
<div class="login-container">
    <h2>관리자 로그인</h2>
    <form method="post" action="/login">
        <input type="text" name="id" placeholder="아이디" required/>
        <input type="password" name="pwd" placeholder="비밀번호" required/>
        <button type="submit">로그인</button>
    </form>
    <c:if test="${not empty error}">
        <div class="error">${error}</div>
    </c:if>
</div>
</body>
</html>
