<%-- webapp/admin/reviews.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../includes/connection.jsp" %>
<%
    String msg=null; boolean isErr=false;
    String act=request.getParameter("act"); String rid=request.getParameter("id");
    if(act!=null&&rid!=null){
        Connection c=null; PreparedStatement p=null;
        try{ c=getConn();
            if("approve".equals(act)){ p=c.prepareStatement("UPDATE reviews SET is_approved=1 WHERE id=?"); p.setInt(1,Integer.parseInt(rid)); p.executeUpdate(); msg="Review approved."; }
            else if("delete".equals(act)){ p=c.prepareStatement("DELETE FROM reviews WHERE id=?"); p.setInt(1,Integer.parseInt(rid)); p.executeUpdate(); msg="Review removed."; }
        }catch(Exception ex){ msg="Error: "+ex.getMessage(); isErr=true; }
        finally{ if(p!=null)try{p.close();}catch(Exception e){} if(c!=null)try{c.close();}catch(Exception e){} }
    }
%>
<% request.setAttribute("pageTitle","Reviews"); request.setAttribute("pageId","reviews"); %>
<%@ include file="../includes/admin_header.jsp" %>

<% if(msg!=null){ %><div class="alert alert-<%= isErr?"danger":"success" %>"><i class="fas fa-<%= isErr?"exclamation":"check" %>-circle"></i> <%= msg %></div><% } %>

<div class="page-hdr"><h2>Customer Reviews</h2></div>

<div style="display:grid;grid-template-columns:1fr 1fr;gap:22px;">
  <!-- Pending -->
  <div>
    <h3 style="font-size:.95rem;margin-bottom:14px;color:var(--warning);"><i class="fas fa-clock"></i> Pending Approval</h3>
    <%
      Connection lc=null; ResultSet lr=null;
      try{ lc=getConn(); lr=lc.prepareStatement("SELECT * FROM reviews WHERE is_approved=0 ORDER BY created_at DESC").executeQuery();
        boolean any=false;
        while(lr.next()){ any=true; int r=lr.getInt("rating"); String nm=lr.getString("name"); String cm=lr.getString("comment");
    %>
    <div style="background:var(--white);border-radius:var(--r);padding:18px;box-shadow:var(--sh-sm);border-left:4px solid var(--warning);margin-bottom:12px;">
      <div class="stars" style="font-size:.95rem;"><%= stars(r) %></div>
      <p style="font-size:.88rem;margin-top:8px;">"<%= cm %>"</p>
      <div style="display:flex;align-items:center;justify-content:space-between;margin-top:12px;">
        <strong style="font-size:.85rem;"><%= nm %></strong>
        <div style="display:flex;gap:8px;">
          <a href="<%= cp %>/admin/reviews.jsp?act=approve&id=<%= lr.getInt("id") %>" class="btn btn-success btn-sm"><i class="fas fa-check"></i> Approve</a>
          <a href="<%= cp %>/admin/reviews.jsp?act=delete&id=<%= lr.getInt("id") %>"  class="btn btn-danger  btn-sm confirm-del"><i class="fas fa-times"></i></a>
        </div>
      </div>
    </div>
    <% } if(!any){%><p style="color:var(--txt3);font-size:.88rem;padding:12px 0;">No pending reviews. ✅</p><%}
      }catch(Exception e){}finally{ if(lr!=null)try{lr.close();}catch(Exception e2){} if(lc!=null)try{lc.close();}catch(Exception e2){} }
    %>
  </div>

  <!-- Approved -->
  <div>
    <h3 style="font-size:.95rem;margin-bottom:14px;color:var(--success);"><i class="fas fa-check-circle"></i> Approved Reviews</h3>
    <%
      Connection ac=null; ResultSet ar=null;
      try{ ac=getConn(); ar=ac.prepareStatement("SELECT * FROM reviews WHERE is_approved=1 ORDER BY created_at DESC").executeQuery();
        boolean any=false;
        while(ar.next()){ any=true; int r=ar.getInt("rating"); String nm=ar.getString("name"); String cm=ar.getString("comment"); String dt=ar.getString("created_at").substring(0,10);
    %>
    <div style="background:var(--white);border-radius:var(--r);padding:16px;box-shadow:var(--sh-sm);border-left:4px solid var(--success);margin-bottom:12px;">
      <div class="stars" style="font-size:.9rem;"><%= stars(r) %></div>
      <p style="font-size:.85rem;margin-top:7px;">"<%= cm %>"</p>
      <div style="display:flex;align-items:center;justify-content:space-between;margin-top:10px;">
        <div><strong style="font-size:.82rem;"><%= nm %></strong> <span style="font-size:.75rem;color:var(--txt3);margin-left:6px;"><%= dt %></span></div>
        <a href="<%= cp %>/admin/reviews.jsp?act=delete&id=<%= ar.getInt("id") %>" class="btn btn-danger btn-sm confirm-del"><i class="fas fa-trash"></i></a>
      </div>
    </div>
    <% } if(!any){%><p style="color:var(--txt3);font-size:.88rem;padding:12px 0;">No approved reviews yet.</p><%}
      }catch(Exception e){}finally{ if(ar!=null)try{ar.close();}catch(Exception e2){} if(ac!=null)try{ac.close();}catch(Exception e2){} }
    %>
  </div>
</div>

<%@ include file="../includes/admin_footer.jsp" %>
