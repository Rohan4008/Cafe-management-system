<%-- webapp/admin/dashboard.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../includes/connection.jsp" %>
<%
    request.setAttribute("pageTitle","Dashboard");
    request.setAttribute("pageId","dashboard");
%>
<%@ include file="../includes/admin_header.jsp" %>

<%
    int totalOrders=0, pendingOrders=0, totalProducts=0, totalCustomers=0;
    double todayRevenue=0, totalRevenue=0;
    Connection conn=null; ResultSet rs=null;
    try {
        conn=getConn();
        rs=conn.prepareStatement("SELECT COUNT(*) FROM orders").executeQuery(); if(rs.next())totalOrders=rs.getInt(1); rs.close();
        rs=conn.prepareStatement("SELECT COUNT(*) FROM orders WHERE order_status IN ('PENDING','CONFIRMED','PREPARING')").executeQuery(); if(rs.next())pendingOrders=rs.getInt(1); rs.close();
        rs=conn.prepareStatement("SELECT COUNT(*) FROM products WHERE is_available=1").executeQuery(); if(rs.next())totalProducts=rs.getInt(1); rs.close();
        rs=conn.prepareStatement("SELECT COUNT(*) FROM customers").executeQuery(); if(rs.next())totalCustomers=rs.getInt(1); rs.close();
        rs=conn.prepareStatement("SELECT IFNULL(SUM(total_amount),0) FROM orders WHERE DATE(created_at)=CURDATE() AND order_status!='CANCELLED'").executeQuery(); if(rs.next())todayRevenue=rs.getDouble(1); rs.close();
        rs=conn.prepareStatement("SELECT IFNULL(SUM(total_amount),0) FROM orders WHERE order_status!='CANCELLED'").executeQuery(); if(rs.next())totalRevenue=rs.getDouble(1); rs.close();
    } catch(Exception e){}
    finally{ if(rs!=null)try{rs.close();}catch(Exception e){} if(conn!=null)try{conn.close();}catch(Exception e){} }
%>

<!-- Stat Cards -->
<div class="stat-grid">
  <div class="stat-card">
    <div class="stat-icon"><i class="fas fa-receipt"></i></div>
    <div class="stat-info"><h3><%= totalOrders %></h3><p>Total Orders</p></div>
  </div>
  <div class="stat-card" style="border-left-color:var(--success);">
    <div class="stat-icon"><i class="fas fa-rupee-sign"></i></div>
    <div class="stat-info"><h3>₹<%= String.format("%.0f",todayRevenue) %></h3><p>Today's Revenue</p></div>
  </div>
  <div class="stat-card" style="border-left-color:var(--info);">
    <div class="stat-icon"><i class="fas fa-user-friends"></i></div>
    <div class="stat-info"><h3><%= totalCustomers %></h3><p>Customers</p></div>
  </div>
  <div class="stat-card" style="border-left-color:#8E44AD;">
    <div class="stat-icon"><i class="fas fa-mug-hot"></i></div>
    <div class="stat-info"><h3><%= totalProducts %></h3><p>Active Products</p></div>
  </div>
</div>

<div style="display:grid;grid-template-columns:1fr 300px;gap:22px;align-items:start;">
  <!-- Recent Orders -->
  <div class="a-card">
    <div class="a-card-head">
      <h3>Recent Orders</h3>
      <a href="<%= cp %>/admin/orders.jsp" class="btn btn-outline btn-sm">View All</a>
    </div>
    <div class="tbl-wrap" style="border-radius:0;box-shadow:none;">
      <table>
        <thead><tr><th>#</th><th>Customer</th><th>Total</th><th>Status</th><th>Date</th></tr></thead>
        <tbody>
        <%
          Connection c2=null; ResultSet r2=null;
          try {
            c2=getConn();
            r2=c2.prepareStatement(
              "SELECT o.id,c.full_name,o.total_amount,o.order_status,o.created_at " +
              "FROM orders o JOIN customers c ON o.customer_id=c.id " +
              "ORDER BY o.created_at DESC LIMIT 8"
            ).executeQuery();
            boolean any=false;
            while(r2.next()){ any=true; String st=r2.getString("order_status");
        %>
        <tr>
          <td><strong>#<%= r2.getInt("id") %></strong></td>
          <td><%= r2.getString("full_name") %></td>
          <td style="font-weight:700;color:var(--copper);">₹<%= String.format("%.0f",r2.getDouble("total_amount")) %></td>
          <td><span class="badge badge-<%= st.toLowerCase() %>"><%= st %></span></td>
          <td style="font-size:.78rem;color:var(--txt3);"><%= r2.getString("created_at").substring(0,10) %></td>
        </tr>
        <% } if(!any){ %><tr><td colspan="5" style="text-align:center;padding:24px;color:var(--txt3);">No orders yet</td></tr><% }
          }catch(Exception e){}finally{ if(r2!=null)try{r2.close();}catch(Exception ex){} if(c2!=null)try{c2.close();}catch(Exception ex){} }
        %>
        </tbody>
      </table>
    </div>
  </div>

  <!-- Quick Panel -->
  <div style="display:flex;flex-direction:column;gap:18px;">
    <div class="a-card">
      <div class="a-card-body">
        <h3 style="font-size:.95rem;margin-bottom:14px;"><i class="fas fa-chart-bar" style="color:var(--copper);margin-right:6px;"></i>Quick Stats</h3>
        <% String[][] qs={{"Pending Orders",String.valueOf(pendingOrders),"var(--warning)"},{"Total Revenue","₹"+String.format("%.0f",totalRevenue),"var(--success)"}}; for(String[] q:qs){ %>
        <div style="display:flex;justify-content:space-between;padding:9px 0;border-bottom:1px solid var(--cream2);font-size:.88rem;">
          <span style="color:var(--txt3);"><%= q[0] %></span>
          <strong style="color:<%= q[2] %>;"><%= q[1] %></strong>
        </div>
        <% } %>
      </div>
    </div>
    <div class="a-card">
      <div class="a-card-body">
        <h3 style="font-size:.95rem;margin-bottom:14px;"><i class="fas fa-bolt" style="color:var(--copper);margin-right:6px;"></i>Quick Actions</h3>
        <div style="display:flex;flex-direction:column;gap:8px;">
          <a href="<%= cp %>/admin/products.jsp?action=add" class="btn btn-primary btn-sm"><i class="fas fa-plus"></i> Add Product</a>
          <a href="<%= cp %>/admin/staff.jsp?action=add"    class="btn btn-outline btn-sm"><i class="fas fa-user-plus"></i> Add Staff</a>
          <a href="<%= cp %>/admin/orders.jsp?filter=PENDING" class="btn btn-outline btn-sm"><i class="fas fa-receipt"></i> Pending Orders</a>
        </div>
      </div>
    </div>
  </div>
</div>

<%@ include file="../includes/admin_footer.jsp" %>
