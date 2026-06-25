package com.bikerental.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class DBConnection {
    private static Properties props = new Properties();

    static {
        try (InputStream is = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (is != null) {
                props.load(is);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() {
        Connection conn = null;
        
        // 1. JNDI 커넥션 시도 (Tomcat 환경)
        String jndiName = props.getProperty("db.jndi", "java:comp/env/jdbc/myoracle");
        try {
            Context ctx = new InitialContext();
            DataSource ds = (DataSource) ctx.lookup(jndiName);
            if (ds != null) {
                conn = ds.getConnection();
                if (conn != null) {
                    System.out.println("[DBConnection] Successfully obtained Connection via JNDI DataSource (" + jndiName + ")");
                    return conn;
                }
            }
        } catch (Exception e) {
            // JNDI 검색 실패 시 상세 메시지를 로깅하고 JDBC 직접 연결 시도
            System.err.println("[DBConnection] JNDI Lookup/Connection failed (" + jndiName + "): " + e.getMessage() + ". Trying direct JDBC connection...");
        }

        // 2. Fallback: JDBC 직접 커넥션 시도 (로컬 개발/단독 실행 환경)
        try {
            String driver = props.getProperty("db.driver", "oracle.jdbc.driver.OracleDriver");
            String url = props.getProperty("db.url");
            String username = props.getProperty("db.username");
            String password = props.getProperty("db.password");
            
            Class.forName(driver);
            conn = DriverManager.getConnection(url, username, password);
            if (conn != null) {
                System.out.println("[DBConnection] Fallback: Successfully connected directly via JDBC URL (" + url + ")");
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("[DBConnection] Direct JDBC Connection fallback failed!");
        }
        
        return conn;
    }

    public static void close(Connection conn, java.sql.Statement stmt, java.sql.ResultSet rs) {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
}
