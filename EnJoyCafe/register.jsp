<%-- webapp/register.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="includes/connection.jsp" %>
<%
    if (session.getAttribute("custName") != null) {
        response.sendRedirect(cp + "/index.jsp"); return;
    }

    String err = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String fullName = request.getParameter("full_name") != null ? request.getParameter("full_name").trim() : "";
        String email    = request.getParameter("email")     != null ? request.getParameter("email").trim()     : "";
        String phone    = request.getParameter("phone")     != null ? request.getParameter("phone").trim()     : "";
        String pass     = request.getParameter("password")  != null ? request.getParameter("password").trim()  : "";
        String confirm  = request.getParameter("confirm")   != null ? request.getParameter("confirm").trim()   : "";

        if (fullName.isEmpty() || email.isEmpty() || pass.isEmpty()) {
            err = "Name, email and password are required.";
        } else if (!pass.equals(confirm)) {
            err = "Passwords do not match.";
        } else if (pass.length() < 6) {
            err = "Password must be at least 6 characters.";
        } else {
            Connection conn = null; PreparedStatement ps = null;
            try {
                conn = getConn();
                /* Check duplicate email */
                PreparedStatement chk = conn.prepareStatement("SELECT id FROM customers WHERE email=?");
                chk.setString(1, email);
                ResultSet chkRs = chk.executeQuery();
                if (chkRs.next()) {
                    err = "This email is already registered. Please log in.";
                    chkRs.close(); chk.close();
                } else {
                    chkRs.close(); chk.close();
                    ps = conn.prepareStatement(
                        "INSERT INTO customers (full_name,email,phone,password) VALUES (?,?,?,SHA2(?,256))");
                    ps.setString(1, fullName); ps.setString(2, email);
                    ps.setString(3, phone);    ps.setString(4, pass);
                    ps.executeUpdate();
                    response.sendRedirect(cp + "/login.jsp?reg=1");
                    return;
                }
            } catch (Exception ex) {
                err = "Error: " + ex.getMessage();
            } finally {
                if(ps!=null)try{ps.close();}catch(Exception e){}
                if(conn!=null)try{conn.close();}catch(Exception e){}
            }
        }
    }
%>
<% request.setAttribute("pageTitle","Register"); %>
<%@ include file="includes/header.jsp" %>

<section style="min-height:82vh;display:flex;align-items:center;background:var(--cream2);padding:60px 0;">
  <div class="container" style="max-width:500px;">
    <div class="card">
      <div class="card-body" style="padding:40px;">
        <div style="text-align:center;margin-bottom:26px;">
          <div style="font-size:2.4rem;">☕</div>
          <h2 style="margin-top:8px;">Create Account</h2>
          <p style="color:var(--txt3);font-size:.88rem;margin-top:4px;">Join the EnJoyCafe family</p>
        </div>
        <% if (err != null) { %>
        <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> <%= err %></div>
        <% } %>
        <form method="post">
          <div class="form-group">
            <label>Full Name *</label>
            <input type="text" name="full_name" class="form-control" placeholder="Your full name" required>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Email *</label>
              <input type="email" name="email" class="form-control" placeholder="you@example.com" required>
            </div>
            <div class="form-group">
              <label>Phone</label>
              <input type="tel" name="phone" class="form-control" placeholder="10-digit number">
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>Password * <span style="font-size:.75rem;color:var(--txt3);">(min 6 chars)</span></label>
              <input type="password" name="password" class="form-control" placeholder="Password" required>
            </div>
            <div class="form-group">
              <label>Confirm Password *</label>
              <input type="password" name="confirm" class="form-control" placeholder="Repeat password" required>
            </div>
          </div>
          <button type="submit" class="btn btn-primary w100 btn-lg" style="margin-top:6px;">
            <i class="fas fa-user-plus"></i> Create Account
          </button>
        </form>
        <p style="text-align:center;margin-top:18px;font-size:.88rem;color:var(--txt3);">
          Already have an account?
          <a href="<%= cp %>/login.jsp" style="color:var(--copper);font-weight:700;">Sign in</a>
        </p>
      </div>
    </div>
  </div>
</section>

<%@ include file="includes/footer.jsp" %>
