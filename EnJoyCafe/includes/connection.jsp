<%-- =========================================================
     includes/connection.jsp
     Single file for DB connection — include in every JSP that
     needs the database.

     Usage:  <%@ include file="includes/connection.jsp" %>
             (adjust path prefix based on file depth)

     After including, use:  Connection conn = getConn();
     Always close conn in finally block.
 ========================================================= --%>
<%@ page import="java.sql.*" %>
<%!
    /* ── CHANGE THESE TO MATCH YOUR MYSQL SETUP ── */
    static final String DB_URL  = "jdbc:mysql://localhost:3306/enjoycafe"
                                + "?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    static final String DB_USER = "root";
    static final String DB_PASS = "root";          /* ← your MySQL root password */

    public Connection getConn() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }

    /* ── Stars helper: Java 1.8 compatible (String.repeat needs Java 11+) ── */
    public static String stars(int rating) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < rating; i++) sb.append("&#9733;");   /* ★ filled */
        for (int i = rating; i < 5;  i++) sb.append("&#9734;");  /* ☆ empty  */
        return sb.toString();
    }
%>
<% String cp = request.getContextPath(); %>
