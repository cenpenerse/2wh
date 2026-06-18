<%@page import="javax.sql.DataSource"%>
<%@page import="java.sql.*"%>
<%@page import="javax.naming.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>커넥션풀</title>
</head>
<body>
<%
Connection conn=null;
try {
	Context ctx=new InitialContext();
	DataSource ds=(DataSource) ctx.lookup("java:comp/env/jdbc/myoracle");
    conn=ds.getConnection();
    out.print("DB연결 성공");
} catch(Exception e){
	out.print(e);
}
%>
</body>
</html>