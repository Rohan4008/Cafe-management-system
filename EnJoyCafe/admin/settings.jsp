<%-- webapp/admin/settings.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../includes/connection.jsp" %>
<%
    request.setAttribute("pageTitle","Settings"); request.setAttribute("pageId","settings");
    int adminId = (Integer) session.getAttribute("adminId");
    String msg=null; boolean isErr=false;

    if("POST".equalsIgnoreCase(request.getMethod())){
        String formType=request.getParameter("formType");

        if("profile".equals(formType)){
            String fn=request.getParameter("full_name"); String em=request.getParameter("email");
            if(fn==null||fn.trim().isEmpty()){ msg="Name required."; isErr=true; }
            else {
                Connection c=null; PreparedStatement p=null;
                try{ c=getConn(); p=c.prepareStatement("UPDATE admin SET full_name=?,email=? WHERE id=?"); p.setString(1,fn.trim()); p.setString(2,em); p.setInt(3,adminId); p.executeUpdate(); msg="Profile updated."; session.setAttribute("adminName",fn.trim()); }
                catch(Exception ex){ msg="Error: "+ex.getMessage(); isErr=true; }
                finally{ if(p!=null)try{p.close();}catch(Exception e){} if(c!=null)try{c.close();}catch(Exception e){} }
            }
        }

        if("password".equals(formType)){
            String curPw=request.getParameter("cur_pass");
            String newPw=request.getParameter("new_pass");
            String conPw=request.getParameter("con_pass");
            if(curPw==null||newPw==null||curPw.isEmpty()||newPw.isEmpty()){ msg="All fields required."; isErr=true; }
            else if(!newPw.equals(conPw)){ msg="New passwords do not match."; isErr=true; }
            else if(newPw.length()<6){ msg="New password must be at least 6 characters."; isErr=true; }
            else {
                Connection c=null; PreparedStatement p=null; ResultSet r=null;
                try{
                    c=getConn();
                    p=c.prepareStatement("SELECT id FROM admin WHERE id=? AND password=SHA2(?,256)"); p.setInt(1,adminId); p.setString(2,curPw); r=p.executeQuery();
                    if(!r.next()){ msg="Current password is incorrect."; isErr=true; }
                    else{ r.close(); p.close();
                        p=c.prepareStatement("UPDATE admin SET password=SHA2(?,256) WHERE id=?"); p.setString(1,newPw); p.setInt(2,adminId); p.executeUpdate();
                        msg="Password changed successfully!";
                    }
                }catch(Exception ex){ msg="Error: "+ex.getMessage(); isErr=true; }
                finally{ if(r!=null)try{r.close();}catch(Exception e){} if(p!=null)try{p.close();}catch(Exception e){} if(c!=null)try{c.close();}catch(Exception e){} }
            }
        }
    }

    /* Load admin data */
    String aNm="",aEm="",aUser="";
    Connection dc=null; PreparedStatement dp=null; ResultSet dr=null;
    try{ dc=getConn(); dp=dc.prepareStatement("SELECT * FROM admin WHERE id=?"); dp.setInt(1,adminId); dr=dp.executeQuery();
        if(dr.next()){ aNm=dr.getString("full_name"); aEm=dr.getString("email")!=null?dr.getString("email"):""; aUser=dr.getString("username"); }
    }catch(Exception ex){}finally{ if(dr!=null)try{dr.close();}catch(Exception e){} if(dp!=null)try{dp.close();}catch(Exception e){} if(dc!=null)try{dc.close();}catch(Exception e){} }
%>
<%@ include file="../includes/admin_header.jsp" %>

<% if(msg!=null){ %><div class="alert alert-<%= isErr?"danger":"success" %>"><i class="fas fa-<%= isErr?"exclamation":"check" %>-circle"></i> <%= msg %></div><% } %>

<div style="display:grid;grid-template-columns:1fr 1fr;gap:22px;">

  <!-- Profile -->
  <div class="a-card">
    <div class="a-card-head"><h3><i class="fas fa-user" style="color:var(--copper);margin-right:6px;"></i>Admin Profile</h3></div>
    <div class="a-card-body">
      <form method="post">
        <input type="hidden" name="formType" value="profile">
        <div class="form-group"><label>Username <span style="font-size:.75rem;color:var(--txt3);">(cannot change)</span></label><input type="text" class="form-control" value="<%= aUser %>" disabled style="opacity:.6;"></div>
        <div class="form-group"><label>Full Name *</label><input type="text" name="full_name" class="form-control" value="<%= aNm %>" required></div>
        <div class="form-group"><label>Email</label><input type="email" name="email" class="form-control" value="<%= aEm %>"></div>
        <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Update Profile</button>
      </form>
    </div>
  </div>

  <!-- Password -->
  <div class="a-card">
    <div class="a-card-head"><h3><i class="fas fa-lock" style="color:var(--copper);margin-right:6px;"></i>Change Password</h3></div>
    <div class="a-card-body">
      <form method="post">
        <input type="hidden" name="formType" value="password">
        <div class="form-group"><label>Current Password *</label><input type="password" name="cur_pass" class="form-control" placeholder="Enter current password" required></div>
        <div class="form-group"><label>New Password * <span style="font-size:.75rem;color:var(--txt3);">(min 6 chars)</span></label><input type="password" name="new_pass" class="form-control" placeholder="New password" required></div>
        <div class="form-group"><label>Confirm New Password *</label><input type="password" name="con_pass" class="form-control" placeholder="Repeat new password" required></div>
        <button type="submit" class="btn btn-primary"><i class="fas fa-key"></i> Change Password</button>
      </form>
    </div>
  </div>

</div>

<%@ include file="../includes/admin_footer.jsp" %>
