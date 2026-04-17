<%-- webapp/admin/login.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../includes/connection.jsp" %>
<%
    if (session.getAttribute("adminUser") != null) {
        response.sendRedirect(cp + "/admin/dashboard.jsp"); return;
    }
    String err = null;
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String user = request.getParameter("username") != null ? request.getParameter("username").trim() : "";
        String pass = request.getParameter("password") != null ? request.getParameter("password").trim() : "";
        if (user.isEmpty() || pass.isEmpty()) {
            err = "Username and password are required.";
        } else {
            Connection conn=null; PreparedStatement ps=null; ResultSet rs=null;
            try {
                conn=getConn();
                ps=conn.prepareStatement("SELECT id,full_name FROM admin WHERE username=? AND password=SHA2(?,256)");
                ps.setString(1,user); ps.setString(2,pass); rs=ps.executeQuery();
                if (rs.next()) {
                    session.setAttribute("adminUser", user);
                    session.setAttribute("adminName", rs.getString("full_name"));
                    session.setAttribute("adminId",   rs.getInt("id"));
                    response.sendRedirect(cp + "/admin/dashboard.jsp"); return;
                } else { err = "Invalid username or password."; }
            } catch(Exception ex) { err = "DB error: " + ex.getMessage(); }
            finally {
                if(rs!=null)try{rs.close();}catch(Exception e){}
                if(ps!=null)try{ps.close();}catch(Exception e){}
                if(conn!=null)try{conn.close();}catch(Exception e){}
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Admin Login | EnJoyCafe</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700&family=Nunito:wght@400;600;700&display=swap">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="stylesheet" href="<%= cp %>/css/style.css">
</head>
<body style="background:linear-gradient(135deg,#2C1810,#5C3317);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px;">

<div style="width:100%;max-width:400px;">
  <div style="text-align:center;margin-bottom:26px;">
    <div style="font-size:2.6rem;">☕</div>
    <h2 style="color:#D4A843;font-family:'Playfair Display',serif;margin-top:6px;">EnJoyCafe</h2>
    <p style="color:rgba(255,255,255,.55);font-size:.84rem;">Admin Control Panel</p>
  </div>
  <div class="card">
    <div class="card-body" style="padding:36px;">
      <h3 style="text-align:center;margin-bottom:22px;font-size:1.1rem;">Sign In</h3>
      <% if (err!=null) { %>
      <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> <%= err %></div>
      <% } %>
      <form method="post">
        <div class="form-group">
          <label><i class="fas fa-user"></i> Username</label>
          <input type="text" name="username" class="form-control" placeholder="admin" required autocomplete="username">
        </div>
        <div class="form-group">
          <label><i class="fas fa-lock"></i> Password</label>
          <input type="password" name="password" class="form-control" placeholder="••••••••" required autocomplete="current-password">
        </div>
        <button type="submit" class="btn btn-primary w100 btn-lg" style="margin-top:6px;">
          <i class="fas fa-sign-in-alt"></i> Login
        </button>
      </form>
      <p style="text-align:center;margin-top:14px;font-size:.78rem;color:var(--txt3);">Default: admin / admin123</p>
    </div>
  </div>
  <div style="text-align:center;margin-top:14px;">
    <a href="<%= cp %>/index.jsp" style="color:rgba(255,255,255,.5);font-size:.82rem;">← Back to website</a>
  </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
</body>
</html>
