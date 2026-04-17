<%-- webapp/order-detail.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="includes/connection.jsp" %>
<%
    if (session.getAttribute("custName") == null) {
        response.sendRedirect(cp + "/login.jsp"); return;
    }
    String oidStr = request.getParameter("oid");
    if (oidStr == null) { response.sendRedirect(cp + "/my-orders.jsp"); return; }
    int oid    = Integer.parseInt(oidStr);
    int custId = (Integer) session.getAttribute("custId");

    double total=0; String orderStatus="", payM="", payS="", addr="", rnotes="", created="";
    Connection conn=null; PreparedStatement ps=null; ResultSet rs=null;
    try {
        conn=getConn();
        ps=conn.prepareStatement("SELECT * FROM orders WHERE id=? AND customer_id=?");
        ps.setInt(1,oid); ps.setInt(2,custId); rs=ps.executeQuery();
        if (!rs.next()) { response.sendRedirect(cp+"/my-orders.jsp"); return; }
        total=rs.getDouble("total_amount"); orderStatus=rs.getString("order_status");
        payM=rs.getString("payment_method"); payS=rs.getString("payment_status");
        addr=rs.getString("delivery_address");
        rnotes=rs.getString("notes")!=null?rs.getString("notes"):"";
        created=rs.getString("created_at");
    } finally {
        if(rs!=null)try{rs.close();}catch(Exception e){}
        if(ps!=null)try{ps.close();}catch(Exception e){}
        if(conn!=null)try{conn.close();}catch(Exception e){}
    }
%>
<% request.setAttribute("pageTitle","Order #" + oid); %>
<%@ include file="includes/header.jsp" %>

<section style="background:var(--cream2);padding:60px 0;min-height:80vh;">
  <div class="container" style="max-width:800px;">
    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:24px;flex-wrap:wrap;gap:12px;">
      <h2><i class="fas fa-receipt" style="color:var(--copper);margin-right:8px;"></i>Order #<%= oid %></h2>
      <a href="<%= cp %>/my-orders.jsp" class="btn btn-outline btn-sm"><i class="fas fa-arrow-left"></i> Back</a>
    </div>

    <!-- Status Timeline -->
    <div class="card" style="margin-bottom:18px;">
      <div class="card-body">
        <h3 style="font-size:.95rem;margin-bottom:20px;"><i class="fas fa-truck" style="color:var(--copper);"></i> Order Status</h3>
        <%
          String[] steps  = {"PENDING","CONFIRMED","PREPARING","READY","DELIVERED"};
          String[] labels = {"Placed","Confirmed","Preparing","Ready","Delivered"};
          String[] icons  = {"fas fa-clock","fas fa-check","fas fa-fire","fas fa-bell","fas fa-check-circle"};
          int cur = -1;
          if (!"CANCELLED".equals(orderStatus)) {
              for (int i=0;i<steps.length;i++) if (steps[i].equals(orderStatus)) { cur=i; break; }
          }
        %>
        <% if ("CANCELLED".equals(orderStatus)) { %>
        <div class="alert alert-danger"><i class="fas fa-times-circle"></i> This order has been cancelled.</div>
        <% } else { %>
        <div class="timeline">
          <div class="timeline-fill" style="width:<%= cur<=0?"0":cur*25+"%" %>;"></div>
          <% for (int i=0;i<steps.length;i++) {
               String cls = i<cur?"done":i==cur?"active":"todo"; %>
          <div class="tl-step">
            <div class="tl-dot <%= cls %>"><i class="<%= icons[i] %>"></i></div>
            <span class="tl-lbl" style="color:<%= i<=cur?"var(--espresso)":"var(--txt3)" %>"><%= labels[i] %></span>
          </div>
          <% } %>
        </div>
        <% } %>
      </div>
    </div>

    <div style="display:grid;grid-template-columns:1fr 280px;gap:18px;align-items:start;">
      <!-- Items table -->
      <div class="card">
        <div class="card-body" style="padding:0;">
          <div style="padding:16px 20px;border-bottom:1px solid var(--cream2);">
            <h3 style="font-size:.95rem;">Items Ordered</h3>
          </div>
          <table>
            <thead><tr><th>Item</th><th style="text-align:center;">Qty</th><th>Price</th><th>Subtotal</th></tr></thead>
            <tbody>
            <%
              Connection c2=null; PreparedStatement p2=null; ResultSet r2=null;
              try {
                c2=getConn();
                p2=c2.prepareStatement(
                  "SELECT oi.*,p.name FROM order_items oi JOIN products p ON oi.product_id=p.id WHERE oi.order_id=?");
                p2.setInt(1,oid); r2=p2.executeQuery();
                while(r2.next()){
            %>
            <tr>
              <td><strong><%= r2.getString("name") %></strong></td>
              <td style="text-align:center;"><%= r2.getInt("quantity") %></td>
              <td>₹<%= String.format("%.0f",r2.getDouble("unit_price")) %></td>
              <td style="font-weight:700;color:var(--copper);">₹<%= String.format("%.0f",r2.getDouble("subtotal")) %></td>
            </tr>
            <% } } catch(Exception e){} finally {
                if(r2!=null)try{r2.close();}catch(Exception e){}
                if(p2!=null)try{p2.close();}catch(Exception e){}
                if(c2!=null)try{c2.close();}catch(Exception e){}
              }
            %>
            <tr style="background:var(--cream);">
              <td colspan="3" style="text-align:right;font-weight:700;padding-right:18px;">Grand Total</td>
              <td style="font-weight:700;color:var(--copper);font-size:1.05rem;">₹<%= String.format("%.0f",total) %></td>
            </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Info -->
      <div class="card">
        <div class="card-body">
          <h3 style="font-size:.95rem;margin-bottom:14px;">Order Info</h3>
          <div style="font-size:.85rem;display:flex;flex-direction:column;gap:10px;">
            <div><span style="color:var(--txt3);display:block;">Placed On</span><strong><%= created.substring(0,16) %></strong></div>
            <div><span style="color:var(--txt3);display:block;">Payment</span><strong><%= payM %></strong> <span class="badge badge-<%= payS.equals("PAID")?"yes":"no" %>" style="margin-left:4px;"><%= payS %></span></div>
            <div><span style="color:var(--txt3);display:block;">Status</span><span class="badge badge-<%= orderStatus.toLowerCase() %>"><%= orderStatus %></span></div>
            <hr style="border-color:var(--cream2);">
            <div><span style="color:var(--txt3);display:block;margin-bottom:3px;">Delivery Address</span><%= addr %></div>
            <% if (!rnotes.isEmpty()) { %><div><span style="color:var(--txt3);display:block;">Notes</span><%= rnotes %></div><% } %>
          </div>
          <a href="<%= cp %>/menu.jsp" class="btn btn-primary w100 btn-sm mt-2"><i class="fas fa-redo"></i> Order Again</a>
        </div>
      </div>
    </div>
  </div>
</section>

<%@ include file="includes/footer.jsp" %>
