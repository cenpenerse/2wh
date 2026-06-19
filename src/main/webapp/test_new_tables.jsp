<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.naming.*, javax.sql.DataSource" %>
<!DOCTYPE html>
<html>
<head><title>DB Seeding Verification</title></head>
<body>
<h2>New Tables Seeding Verification</h2>

<h3>1. license_audit</h3>
<table border="1">
    <tr><th>ID</th><th>User ID</th><th>License Type</th><th>Image</th><th>Status</th><th>Reason</th><th>Date</th><th>Admin ID</th></tr>
<%
    try {
        Context ctx = new InitialContext();
        DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/myoracle");
        try (Connection conn = ds.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM license_audit ORDER BY audit_id ASC")) {
            while (rs.next()) {
                out.println("<tr>");
                out.println("<td>" + rs.getInt("audit_id") + "</td>");
                out.println("<td>" + rs.getInt("user_id") + "</td>");
                out.println("<td>" + rs.getString("license_type") + "</td>");
                out.println("<td>" + rs.getString("license_image") + "</td>");
                out.println("<td>" + rs.getString("status") + "</td>");
                out.println("<td>" + rs.getString("reject_reason") + "</td>");
                out.println("<td>" + rs.getTimestamp("audit_date") + "</td>");
                out.println("<td>" + rs.getInt("admin_id") + "</td>");
                out.println("</tr>");
            }
        }
    } catch(Exception e) { e.printStackTrace(new java.io.PrintWriter(out)); }
%>
</table>

<h3>2. bike_maintenance</h3>
<table border="1">
    <tr><th>ID</th><th>Bike ID</th><th>Date</th><th>Type</th><th>Content</th><th>Cost</th><th>Shop</th><th>Next Date</th></tr>
<%
    try {
        Context ctx = new InitialContext();
        DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/myoracle");
        try (Connection conn = ds.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM bike_maintenance ORDER BY maintenance_id ASC")) {
            while (rs.next()) {
                out.println("<tr>");
                out.println("<td>" + rs.getInt("maintenance_id") + "</td>");
                out.println("<td>" + rs.getInt("bike_id") + "</td>");
                out.println("<td>" + rs.getDate("maintenance_date") + "</td>");
                out.println("<td>" + rs.getString("maintenance_type") + "</td>");
                out.println("<td>" + rs.getString("content") + "</td>");
                out.println("<td>" + rs.getInt("cost") + "</td>");
                out.println("<td>" + rs.getString("shop_name") + "</td>");
                out.println("<td>" + rs.getDate("next_check_date") + "</td>");
                out.println("</tr>");
            }
        }
    } catch(Exception e) { e.printStackTrace(new java.io.PrintWriter(out)); }
%>
</table>

<h3>3. fuel_log</h3>
<table border="1">
    <tr><th>ID</th><th>Bike ID</th><th>Res ID</th><th>Level (%)</th><th>Penalty</th><th>Date</th></tr>
<%
    try {
        Context ctx = new InitialContext();
        DataSource ds = (DataSource) ctx.lookup("java:comp/env/jdbc/myoracle");
        try (Connection conn = ds.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT * FROM fuel_log ORDER BY fuel_log_id ASC")) {
            while (rs.next()) {
                out.println("<tr>");
                out.println("<td>" + rs.getInt("fuel_log_id") + "</td>");
                out.println("<td>" + rs.getInt("bike_id") + "</td>");
                out.println("<td>" + rs.getInt("reservation_id") + "</td>");
                out.println("<td>" + rs.getInt("fuel_level") + "</td>");
                out.println("<td>" + rs.getInt("penalty_amount") + "</td>");
                out.println("<td>" + rs.getTimestamp("log_date") + "</td>");
                out.println("</tr>");
            }
        }
    } catch(Exception e) { e.printStackTrace(new java.io.PrintWriter(out)); }
%>
</table>
</body>
</html>
