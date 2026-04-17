<%-- webapp/admin/staff.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../includes/connection.jsp" %>
<%
    String action=request.getParameter("action")!=null?request.getParameter("action"):"list";
    String msg=null; boolean isErr=false;

    if("delete".equals(action)){
        Connection c=null; PreparedStatement p=null;
        try{ c=getConn(); p=c.prepareStatement("DELETE FROM staff WHERE id=?"); p.setInt(1,Integer.parseInt(request.getParameter("id"))); p.executeUpdate(); msg="Staff member removed."; }
        catch(Exception ex){ msg="Error: "+ex.getMessage(); isErr=true; }
        finally{ if(p!=null)try{p.close();}catch(Exception e){} if(c!=null)try{c.close();}catch(Exception e){} }
        action="list";
    }

    if("POST".equalsIgnoreCase(request.getMethod())){
        String nm_=request.getParameter("full_name"); String role_=request.getParameter("role");
        String phone_=request.getParameter("phone"); String email_=request.getParameter("email");
        String join_=request.getParameter("joining_date"); String shift_=request.getParameter("shift");
        String photo_=request.getParameter("photo_url"); String eid=request.getParameter("eid");
        String actv_=request.getParameter("is_active");

        if(nm_==null||nm_.trim().isEmpty()||role_==null||role_.trim().isEmpty()){ msg="Name and role required."; isErr=true; action=eid!=null?"edit":"add"; }
        else {
            Connection c=null; PreparedStatement p=null;
            try{ c=getConn();
                if(eid!=null&&!eid.isEmpty()){
                    p=c.prepareStatement("UPDATE staff SET full_name=?,role=?,phone=?,email=?,joining_date=?,shift=?,photo_url=?,is_active=? WHERE id=?");
                    p.setString(1,nm_.trim()); p.setString(2,role_.trim()); p.setString(3,phone_); p.setString(4,email_);
                    p.setString(5,join_); p.setString(6,shift_); p.setString(7,photo_); p.setInt(8,"1".equals(actv_)?1:0); p.setInt(9,Integer.parseInt(eid));
                    msg="Staff updated.";
                } else {
                    p=c.prepareStatement("INSERT INTO staff (full_name,role,phone,email,joining_date,shift,photo_url) VALUES (?,?,?,?,?,?,?)");
                    p.setString(1,nm_.trim()); p.setString(2,role_.trim()); p.setString(3,phone_); p.setString(4,email_);
                    p.setString(5,join_); p.setString(6,shift_); p.setString(7,photo_);
                    msg="Staff member added.";
                }
                p.executeUpdate(); action="list";
            }catch(Exception ex){ msg="Error: "+ex.getMessage(); isErr=true; action="list"; }
            finally{ if(p!=null)try{p.close();}catch(Exception e){} if(c!=null)try{c.close();}catch(Exception e){} }
        }
    }

    String eNm="",eRole="",ePhone="",eEmail="",eJoin="",eShift="",ePhoto=""; int eId=0,eActv=1;
    if("edit".equals(action)){
        Connection c=null; PreparedStatement p=null; ResultSet r=null;
        try{ c=getConn(); p=c.prepareStatement("SELECT * FROM staff WHERE id=?"); p.setInt(1,Integer.parseInt(request.getParameter("id"))); r=p.executeQuery();
            if(r.next()){ eId=r.getInt("id"); eNm=r.getString("full_name"); eRole=r.getString("role"); ePhone=r.getString("phone")!=null?r.getString("phone"):""; eEmail=r.getString("email")!=null?r.getString("email"):""; eJoin=r.getString("joining_date")!=null?r.getString("joining_date"):""; eShift=r.getString("shift")!=null?r.getString("shift"):""; ePhoto=r.getString("photo_url")!=null?r.getString("photo_url"):""; eActv=r.getInt("is_active"); }
        }catch(Exception ex){}finally{ if(r!=null)try{r.close();}catch(Exception e){} if(p!=null)try{p.close();}catch(Exception e){} if(c!=null)try{c.close();}catch(Exception e){} }
    }
%>
<% request.setAttribute("pageTitle","Staff"); request.setAttribute("pageId","staff"); %>
<%@ include file="../includes/admin_header.jsp" %>

<% if(msg!=null){ %><div class="alert alert-<%= isErr?"danger":"success" %>"><i class="fas fa-<%= isErr?"exclamation":"check" %>-circle"></i> <%= msg %></div><% } %>

<% if("add".equals(action)||"edit".equals(action)){ boolean isEdit="edit".equals(action); %>
<div class="a-card" style="max-width:680px;">
  <div class="a-card-head">
    <h3><%= isEdit?"Edit Staff Member":"Add Staff Member" %></h3>
    <a href="<%= cp %>/admin/staff.jsp" class="btn btn-outline btn-sm"><i class="fas fa-arrow-left"></i> Back</a>
  </div>
  <div class="a-card-body">
    <form method="post" action="<%= cp %>/admin/staff.jsp">
      <% if(isEdit){ %><input type="hidden" name="eid" value="<%= eId %>"><% } %>
      <div class="form-row">
        <div class="form-group"><label>Full Name *</label><input type="text" name="full_name" class="form-control" value="<%= eNm %>" required></div>
        <div class="form-group"><label>Role / Designation *</label><input type="text" name="role" class="form-control" value="<%= eRole %>" placeholder="e.g. Barista, Cashier" required></div>
      </div>
      <div class="form-row">
        <div class="form-group"><label>Phone</label><input type="tel" name="phone" class="form-control" value="<%= ePhone %>" placeholder="10-digit number"></div>
        <div class="form-group"><label>Email</label><input type="email" name="email" class="form-control" value="<%= eEmail %>" placeholder="staff@enjoycafe.com"></div>
      </div>
      <div class="form-row">
        <div class="form-group"><label>Joining Date</label><input type="date" name="joining_date" class="form-control" value="<%= eJoin %>"></div>
        <div class="form-group"><label>Shift</label>
          <select name="shift" class="form-control">
            <option value="">-- Select --</option>
            <% String[] shifts={"Morning","Afternoon","Evening","Full Day","Night"}; for(String s:shifts){ %><option value="<%= s %>" <%= s.equals(eShift)?"selected":"" %>><%= s %></option><% } %>
          </select>
        </div>
      </div>
      <div class="form-row">
        <div class="form-group"><label>Photo URL</label><input type="text" name="photo_url" class="form-control" value="<%= ePhoto %>" placeholder="images/staff/name.jpg"></div>
        <% if(isEdit){ %>
        <div class="form-group"><label>Status</label>
          <select name="is_active" class="form-control">
            <option value="1" <%= eActv==1?"selected":"" %>>Active</option>
            <option value="0" <%= eActv==0?"selected":"" %>>Inactive</option>
          </select>
        </div>
        <% } %>
      </div>
      <div class="d-flex gap-12 mt-2">
        <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> <%= isEdit?"Update":"Add Staff" %></button>
        <a href="<%= cp %>/admin/staff.jsp" class="btn btn-outline">Cancel</a>
      </div>
    </form>
  </div>
</div>

<% } else { %>
<div class="page-hdr">
  <h2>Staff Directory</h2>
  <a href="<%= cp %>/admin/staff.jsp?action=add" class="btn btn-primary"><i class="fas fa-user-plus"></i> Add Staff</a>
</div>
<input type="text" class="form-control tbl-search" data-tbl="#staffGrid" style="max-width:280px;margin-bottom:18px;" placeholder="🔍 Search staff…">

<div class="grid-4" id="staffGrid">
  <%
    Connection lc=null; ResultSet lr=null;
    try{ lc=getConn(); lr=lc.prepareStatement("SELECT * FROM staff ORDER BY full_name").executeQuery();
      boolean any=false;
      while(lr.next()){ any=true;
        String sNm=lr.getString("full_name"); String sRole=lr.getString("role");
        String sPhone=lr.getString("phone")!=null?lr.getString("phone"):"—";
        String sEmail=lr.getString("email")!=null?lr.getString("email"):"—";
        String sJoin=lr.getString("joining_date")!=null?lr.getString("joining_date").substring(0,10):"—";
        String sShift=lr.getString("shift")!=null?lr.getString("shift"):"—";
        String sPhoto=lr.getString("photo_url"); boolean sAct=lr.getInt("is_active")==1;
  %>
  <div class="card">
    <div style="padding:22px 18px;text-align:center;">
      <% if(sPhoto!=null&&!sPhoto.trim().isEmpty()){ %>
      <img src="<%= cp %>/<%= sPhoto %>" alt="<%= sNm %>" style="width:68px;height:68px;border-radius:50%;object-fit:cover;margin:0 auto 12px;">
      <% } else { %>
      <div style="width:68px;height:68px;background:linear-gradient(135deg,var(--copper),var(--gold));border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 12px;font-size:1.6rem;color:#fff;font-family:'Playfair Display',serif;font-weight:700;"><%= sNm.substring(0,1) %></div>
      <% } %>
      <h4 style="font-size:.95rem;margin-bottom:4px;"><%= sNm %></h4>
      <p style="font-size:.78rem;color:var(--copper);font-weight:700;margin-bottom:8px;"><%= sRole %></p>
      <span class="badge badge-<%= sAct?"active":"inactive" %>"><%= sAct?"Active":"Inactive" %></span>
    </div>
    <div style="padding:0 18px 14px;font-size:.8rem;color:var(--txt3);">
      <p><i class="fas fa-phone" style="width:14px;color:var(--copper);margin-right:6px;"></i><%= sPhone %></p>
      <p style="margin-top:4px;"><i class="fas fa-envelope" style="width:14px;color:var(--copper);margin-right:6px;"></i><%= sEmail %></p>
      <p style="margin-top:4px;"><i class="fas fa-calendar" style="width:14px;color:var(--copper);margin-right:6px;"></i>Joined: <%= sJoin %></p>
      <p style="margin-top:4px;"><i class="fas fa-clock" style="width:14px;color:var(--copper);margin-right:6px;"></i>Shift: <%= sShift %></p>
    </div>
    <div class="card-foot" style="display:flex;gap:8px;">
      <a href="<%= cp %>/admin/staff.jsp?action=edit&id=<%= lr.getInt("id") %>" class="btn btn-outline btn-sm" style="flex:1;justify-content:center;"><i class="fas fa-edit"></i> Edit</a>
      <a href="<%= cp %>/admin/staff.jsp?action=delete&id=<%= lr.getInt("id") %>" class="btn btn-danger btn-sm confirm-del"><i class="fas fa-trash"></i></a>
    </div>
  </div>
  <% } if(!any){%><p style="grid-column:1/-1;text-align:center;padding:36px;color:var(--txt3);">No staff records. <a href="<%= cp %>/admin/staff.jsp?action=add" style="color:var(--copper);">Add one!</a></p><%}
    }catch(Exception e){}finally{ if(lr!=null)try{lr.close();}catch(Exception e2){} if(lc!=null)try{lc.close();}catch(Exception e2){} }
  %>
</div>
<% } %>
<%@ include file="../includes/admin_footer.jsp" %>
