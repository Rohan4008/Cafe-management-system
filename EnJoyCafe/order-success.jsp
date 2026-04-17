<%-- webapp/order-success.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="includes/connection.jsp" %>
<%
    if (session.getAttribute("custName") == null) {
        response.sendRedirect(cp + "/login.jsp"); return;
    }
    String oidStr = request.getParameter("oid");
    if (oidStr == null) { response.sendRedirect(cp + "/my-orders.jsp"); return; }
    int oid     = Integer.parseInt(oidStr);
    int custId  = (Integer) session.getAttribute("custId");

    double total = 0; String pm = ""; String ps_ = ""; String addr = ""; String created = "";
    Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        conn = getConn();
        ps   = conn.prepareStatement("SELECT * FROM orders WHERE id=? AND customer_id=?");
        ps.setInt(1, oid); ps.setInt(2, custId);
        rs = ps.executeQuery();
        if (!rs.next()) { response.sendRedirect(cp + "/my-orders.jsp"); return; }
        total   = rs.getDouble("total_amount");
        pm      = rs.getString("payment_method");
        ps_     = rs.getString("payment_status");
        addr    = rs.getString("delivery_address");
        created = rs.getString("created_at");
    } finally {
        if(rs!=null)try{rs.close();}catch(Exception e){}
        if(ps!=null)try{ps.close();}catch(Exception e){}
        if(conn!=null)try{conn.close();}catch(Exception e){}
    }
%>
<% request.setAttribute("pageTitle","Order Confirmed"); %>
<%@ include file="includes/header.jsp" %>
<meta name="contextPath" content="<%= cp %>">

<section style="min-height:80vh;display:flex;align-items:center;background:var(--cream2);padding:60px 0;">
  <div class="container" style="max-width:540px;">
    <div class="card" style="text-align:center;">
      <div class="card-body" style="padding:46px 38px;">
        <div style="width:76px;height:76px;background:#D5F5E3;border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 18px;font-size:2rem;">✅</div>
        <h2 style="color:var(--success);margin-bottom:8px;">Order Confirmed!</h2>
        <p style="color:var(--txt3);margin-bottom:26px;">Thank you! We've received your order and are getting it ready.</p>

        <div style="background:var(--cream);border-radius:10px;padding:18px;text-align:left;margin-bottom:22px;">
          <% String[][] rows = {
              {"Order ID",    "#" + oid},
              {"Placed At",   created.substring(0,16)},
              {"Total",       "₹" + String.format("%.0f",total)},
              {"Payment",     pm + " – " + ps_},
              {"Deliver To",  addr}
          }; for (String[] r : rows) { %>
          <div style="display:flex;justify-content:space-between;padding:8px 0;border-bottom:1px solid var(--cream2);font-size:.88rem;">
            <span style="color:var(--txt3);"><%= r[0] %></span>
            <strong style="text-align:right;max-width:60%;"><%= r[1] %></strong>
          </div>
          <% } %>
        </div>

        <div style="display:flex;gap:12px;justify-content:center;flex-wrap:wrap;">
          <a href="<%= cp %>/my-orders.jsp" class="btn btn-outline"><i class="fas fa-list"></i> My Orders</a>
          <a href="<%= cp %>/menu.jsp"      class="btn btn-primary"><i class="fas fa-redo"></i> Order More</a>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- Clear localStorage cart after confirmed order -->
<script>
$(function(){ localStorage.removeItem('ec_cart'); updateBadge && updateBadge(); });
</script>

<%@ include file="includes/footer.jsp" %>
