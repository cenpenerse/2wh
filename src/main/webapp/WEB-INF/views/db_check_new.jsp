<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>DB 데이터 확인 New</title>
</head>
<body>
    <h2>현재 DB에 등록된 게시글 목록</h2>
    <table border="1">
        <tr><th>글번호</th><th>회원번호</th><th>제목</th><th>유형(board_type)</th><th>상태</th><th>작성일</th></tr>
        <%
            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;
            try {
                Context ctx = new InitialContext();
                DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/myoracle");
                conn = ds.getConnection();
                stmt = conn.createStatement();
                rs = stmt.executeQuery("SELECT post_id, member_id, title, board_type, post_status, created_at FROM app_board_email_post ORDER BY post_id ASC");
                while(rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("post_id") %></td>
            <td><%= rs.getInt("member_id") %></td>
            <td><%= rs.getString("title") %></td>
            <td><%= rs.getString("board_type") %></td>
            <td><%= rs.getString("post_status") %></td>
            <td><%= rs.getTimestamp("created_at") %></td>
        </tr>
        <%
                }
            } catch(Exception e) {
                out.println("<tr><td colspan='6'>에러: " + e.getMessage() + "</td></tr>");
            } finally {
                if(rs != null) try { rs.close(); } catch(Exception e){}
                if(stmt != null) try { stmt.close(); } catch(Exception e){}
                if(conn != null) try { conn.close(); } catch(Exception e){}
            }
        %>
    </table>
</body>
</html>
