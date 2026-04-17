<%-- webapp/admin/customers.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../includes/connection.jsp" %>
<% request.setAttribute("pageTitle","Customers"); request.setAttribute("pageId","customers"); %>
<%@ include file="../includes/admin_header.jsp" %>

<div class="page-hdr">
  <h2>Registered Customers</h2>
  <input type="text" class="form-control tbl-search" data-tbl="#custTbl" style="max-width:260px;" placeholder="🔍 Search customers…">
</div>

<div class="tbl-wrap">
  <table id="custTbl">
    <thead><tr><th>#</th><th>Name</th><th>Email</th><th>Phone</th><th>Total Orders</th><th>Joined</th></tr></thead>
    <tbody>
    <%
      Connection lc=null; ResultSet lr=null;
      try{ lc=getConn();
        lr=lc.prepareStatement(
          "SELECT c.*,(SELECT COUNT(*) FROM orders o WHERE o.customer_id=c.id) AS oc " +
          "FROM customers c ORDER BY c.created_at DESC"
        ).executeQuery();
        boolean any=false;
        while(lr.next()){ any=true;
    %>
    <tr>
      <td><%= lr.getInt("id") %></td>
      <td><strong><%= lr.getString("full_name") %></strong></td>
      <td><%= lr.getString("email") %></td>
      <td><%= lr.getString("phone")!=null?lr.getString("phone"):"—" %></td>
      <td style="text-align:center;font-weight:700;color:var(--copper);"><%= lr.getInt("oc") %></td>
      <td style="font-size:.8rem;color:var(--txt3);"><%= lr.getString("created_at").substring(0,10) %></td>
    </tr>
    <% } if(!any){%><tr><td colspan="6" style="text-align:center;padding:24px;color:var(--txt3);">No customers registered yet.</td></tr><%}
      }catch(Exception e){%><tr><td colspan="6"><div class="alert alert-danger">Error: <%=e.getMessage()%></div></td></tr>
    <%}finally{ if(lr!=null)try{lr.close();}catch(Exception e){} if(lc!=null)try{lc.close();}catch(Exception e){} }%>
    </tbody>
  </table>
</div>

<%@ include file="../includes/admin_footer.jsp" %>
