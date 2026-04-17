<%-- webapp/login.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="includes/connection.jsp" %>
<%
    /* Already logged in */
    if (session.getAttribute("custName") != null) {
        response.sendRedirect(cp + "/index.jsp"); return;
    }

    String err = null;
    String successMsg = request.getParameter("reg") != null ? "Registration successful! Please log in." : null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String email = request.getParameter("email")    != null ? request.getParameter("email").trim()    : "";
        String pass  = request.getParameter("password") != null ? request.getParameter("password").trim() : "";

        if (email.isEmpty() || pass.isEmpty()) {
            err = "Email and password are required.";
        } else {
            Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
            try {
                conn = getConn();
                ps   = conn.prepareStatement(
                    "SELECT id, full_name FROM customers WHERE email=? AND password=SHA2(?,256)");
                ps.setString(1, email); ps.setString(2, pass);
                rs = ps.executeQuery();
                if (rs.next()) {
                    session.setAttribute("custId",   rs.getInt("id"));
                    session.setAttribute("custName", rs.getString("full_name"));
                    String red = request.getParameter("redirect");
                    response.sendRedirect(red != null && !red.isEmpty() ? red : cp + "/index.jsp");
                    return;
                } else {
                    err = "Invalid email or password.";
                }
            } catch (Exception ex) {
                err = "Error: " + ex.getMessage();
            } finally {
                if(rs!=null)try{rs.close();}catch(Exception e){}
                if(ps!=null)try{ps.close();}catch(Exception e){}
                if(conn!=null)try{conn.close();}catch(Exception e){}
            }
        }
    }
%>
<% request.setAttribute("pageTitle","Login"); %>
<%@ include file="includes/header.jsp" %>

<section style="min-height:82vh;display:flex;align-items:center;background:var(--cream2);padding:60px 0;">
  <div class="container" style="max-width:440px;">
    <div class="card">
      <div class="card-body" style="padding:40px;">
        <div style="text-align:center;margin-bottom:26px;">
          <div style="font-size:2.4rem;">☕</div>
          <h2 style="margin-top:8px;">Welcome Back</h2>
          <p style="color:var(--txt3);font-size:.88rem;margin-top:4px;">Sign in to your EnJoyCafe account</p>
        </div>
        <% if (err != null) { %>
        <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> <%= err %></div>
        <% } %>
        <% if (successMsg != null) { %>
        <div class="alert alert-success"><i class="fas fa-check-circle"></i> <%= successMsg %></div>
        <% } %>
        <form method="post">
          <input type="hidden" name="redirect" value="<%= request.getParameter("redirect") != null ? request.getParameter("redirect") : "" %>">
          <div class="form-group">
            <label><i class="fas fa-envelope"></i> Email Address</label>
            <input type="email" name="email" class="form-control" placeholder="you@example.com" required>
          </div>
          <div class="form-group">
            <label><i class="fas fa-lock"></i> Password</label>
            <input type="password" name="password" class="form-control" placeholder="Your password" required>
          </div>
          <button type="submit" class="btn btn-primary w100 btn-lg" style="margin-top:6px;">
            <i class="fas fa-sign-in-alt"></i> Sign In
          </button>
        </form>
        <p style="text-align:center;margin-top:18px;font-size:.88rem;color:var(--txt3);">
          Don't have an account?
          <a href="<%= cp %>/register.jsp" style="color:var(--copper);font-weight:700;">Register here</a>
        </p>
      </div>
    </div>
  </div>
</section>

<%@ include file="includes/footer.jsp" %>
