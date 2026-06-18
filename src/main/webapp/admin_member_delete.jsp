<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String loginId = (String) session.getAttribute("login_id");
    String loginType = (String) session.getAttribute("login_type");
    if (loginId == null || !"admin".equals(loginType)) {
        response.sendRedirect("index.jsp");
        return;
    }

    String id = request.getParameter("id");
    if (id != null && !id.isEmpty()) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            Class.forName("oracle.jdbc.OracleDriver");
            conn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "oracle");
            pstmt = conn.prepareStatement("DELETE FROM member_test WHERE id = ? AND user_type != 'admin'");
            pstmt.setString(1, id);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }
    response.sendRedirect("admin_member_list.jsp");
%>