<%-- webapp/my-orders.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="includes/connection.jsp" %>
<%
    if (session.getAttribute("custName") == null) {
        response.sendRedirect(cp + "/login.jsp"); return;
    }
    int custId = (Integer) session.getAttribute("custId");
%>
<% request.setAttribute("pageTitle","My Orders"); %>
<%@ include file="includes/header.jsp" %>

<section style="background:var(--cream2);padding:60px 0;min-height:80vh;">
  <div class="container">
    <h2 style="margin-bottom:26px;"><i class="fas fa-receipt" style="color:var(--copper);margin-right:8px;"></i>My Orders</h2>

    <%
      Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
      boolean any = false;
      try {
        conn = getConn();
        ps   = conn.prepareStatement(
          "SELECT o.id, o.total_amount, o.order_status, o.payment_method, " +
          "o.payment_status, o.created_at, COUNT(oi.id) AS item_count " +
          "FROM orders o LEFT JOIN order_items oi ON o.id=oi.order_id " +
          "WHERE o.customer_id=? GROUP BY o.id ORDER BY o.created_at DESC"
        );
        ps.setInt(1, custId);
        rs = ps.executeQuery();
        while (rs.next()) {
          any = true;
          int    oid    = rs.getInt("id");
          double total  = rs.getDouble("total_amount");
          String status = rs.getString("order_status");
          String pMethod= rs.getString("payment_method");
          String pStatus= rs.getString("payment_status");
          int    items  = rs.getInt("item_count");
          String created= rs.getString("created_at");
    %>
    <div class="card" style="margin-bottom:14px;">
      <div class="card-body" style="display:flex;align-items:center;flex-wrap:wrap;gap:14px;justify-content:space-between;padding:18px 22px;">
        <div>
          <strong style="font-family:'Playfair Display',serif;font-size:1rem;">Order #<%= oid %></strong>
          <p style="font-size:.8rem;color:var(--txt3);margin-top:3px;"><i class="fas fa-clock"></i> <%= created.substring(0,16) %></p>
        </div>
        <div style="display:flex;align-items:center;gap:18px;flex-wrap:wrap;">
          <span style="font-size:.88rem;color:var(--txt2);"><%= items %> item<%= items!=1?"s":"" %></span>
          <span style="font-weight:700;color:var(--copper);">₹<%= String.format("%.0f",total) %></span>
          <span class="badge badge-<%= status.toLowerCase() %>"><%= status %></span>
          <span class="badge badge-<%= pStatus.equals("PAID")?"yes":"no" %>"><%= pMethod %> · <%= pStatus %></span>
          <a href="<%= cp %>/order-detail.jsp?oid=<%= oid %>" class="btn btn-outline btn-sm">
            <i class="fas fa-eye"></i> View
          </a>
        </div>
      </div>
    </div>
    <%
        }
      } catch (Exception e) {
    %><div class="alert alert-danger">Error: <%= e.getMessage() %></div>
    <% } finally {
        if(rs!=null)try{rs.close();}catch(Exception e){}
        if(ps!=null)try{ps.close();}catch(Exception e){}
        if(conn!=null)try{conn.close();}catch(Exception e){}
      }
      if (!any) {
    %>
    <div style="text-align:center;padding:60px 20px;color:var(--txt3);">
      <div style="font-size:3rem;margin-bottom:12px;">📋</div>
      <h3>No orders yet</h3>
      <p style="margin-bottom:20px;">When you place an order it will appear here.</p>
      <a href="<%= cp %>/menu.jsp" class="btn btn-primary"><i class="fas fa-utensils"></i> Browse Menu</a>
    </div>
    <% } %>
  </div>
</section>

<%@ include file="includes/footer.jsp" %>
