<%-- webapp/admin/orders.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../includes/connection.jsp" %>
<%
    String msg=null; boolean isErr=false;

    /* ── Update status via POST ── */
    if("POST".equalsIgnoreCase(request.getMethod())){
        String oid=request.getParameter("oid"); String ns=request.getParameter("newStatus");
        if(oid!=null&&ns!=null){
            Connection c=null; PreparedStatement p=null;
            try{ c=getConn(); p=c.prepareStatement("UPDATE orders SET order_status=? WHERE id=?"); p.setString(1,ns); p.setInt(2,Integer.parseInt(oid)); p.executeUpdate(); msg="Order #"+oid+" → "+ns; }
            catch(Exception ex){ msg="Error: "+ex.getMessage(); isErr=true; }
            finally{ if(p!=null)try{p.close();}catch(Exception e){} if(c!=null)try{c.close();}catch(Exception e){} }
        }
    }

    String filter  = request.getParameter("filter") != null ? request.getParameter("filter") : "ALL";
    String viewId  = request.getParameter("vid");
%>
<% request.setAttribute("pageTitle","Orders"); request.setAttribute("pageId","orders"); %>
<%@ include file="../includes/admin_header.jsp" %>

<% if(msg!=null){ %><div class="alert alert-<%= isErr?"danger":"success" %>"><i class="fas fa-<%= isErr?"exclamation":"check" %>-circle"></i> <%= msg %></div><% } %>

<% if (viewId != null) {
    /* ══ ORDER DETAIL VIEW ══ */
    Connection dc=null; PreparedStatement dp=null; ResultSet dr=null;
    try{
        dc=getConn();
        dp=dc.prepareStatement("SELECT o.*,c.full_name,c.email,c.phone FROM orders o JOIN customers c ON o.customer_id=c.id WHERE o.id=?");
        dp.setInt(1,Integer.parseInt(viewId)); dr=dp.executeQuery();
        if(dr.next()){
            String cName=dr.getString("full_name"); String cEmail=dr.getString("email"); String cPhone=dr.getString("phone");
            double total=dr.getDouble("total_amount"); String status=dr.getString("order_status");
            String payM=dr.getString("payment_method"); String payS=dr.getString("payment_status");
            String addr=dr.getString("delivery_address"); String onotes=dr.getString("notes"); String created=dr.getString("created_at");
%>
<div class="page-hdr">
  <h2>Order #<%= viewId %></h2>
  <a href="<%= cp %>/admin/orders.jsp" class="btn btn-outline btn-sm"><i class="fas fa-arrow-left"></i> All Orders</a>
</div>
<div style="display:grid;grid-template-columns:1fr 300px;gap:22px;align-items:start;">
  <div>
    <!-- Items -->
    <div class="a-card" style="margin-bottom:18px;">
      <div class="a-card-head"><h3><i class="fas fa-shopping-bag" style="color:var(--copper);margin-right:6px;"></i>Items</h3></div>
      <div class="tbl-wrap" style="border-radius:0;box-shadow:none;">
        <table>
          <thead><tr><th>Product</th><th style="text-align:center;">Qty</th><th>Unit Price</th><th>Subtotal</th></tr></thead>
          <tbody>
          <%
            PreparedStatement ip=null; ResultSet ir=null;
            try{ ip=dc.prepareStatement("SELECT oi.*,p.name FROM order_items oi JOIN products p ON oi.product_id=p.id WHERE oi.order_id=?"); ip.setInt(1,Integer.parseInt(viewId)); ir=ip.executeQuery();
              while(ir.next()){
          %>
          <tr>
            <td><strong><%= ir.getString("name") %></strong></td>
            <td style="text-align:center;"><%= ir.getInt("quantity") %></td>
            <td>₹<%= String.format("%.0f",ir.getDouble("unit_price")) %></td>
            <td style="font-weight:700;color:var(--copper);">₹<%= String.format("%.0f",ir.getDouble("subtotal")) %></td>
          </tr>
          <% } }finally{ if(ir!=null)try{ir.close();}catch(Exception e){} if(ip!=null)try{ip.close();}catch(Exception e){} } %>
          <tr style="background:var(--cream);">
            <td colspan="3" style="text-align:right;font-weight:700;padding-right:18px;">Grand Total</td>
            <td style="font-weight:700;color:var(--copper);font-size:1.05rem;">₹<%= String.format("%.0f",total) %></td>
          </tr>
          </tbody>
        </table>
      </div>
    </div>
    <!-- Customer -->
    <div class="a-card">
      <div class="a-card-head"><h3><i class="fas fa-user" style="color:var(--copper);margin-right:6px;"></i>Customer</h3></div>
      <div class="a-card-body">
        <p><strong><%= cName %></strong></p>
        <p style="font-size:.86rem;color:var(--txt3);margin-top:4px;"><i class="fas fa-envelope" style="margin-right:6px;"></i><%= cEmail %></p>
        <p style="font-size:.86rem;color:var(--txt3);margin-top:4px;"><i class="fas fa-phone" style="margin-right:6px;"></i><%= cPhone!=null?cPhone:"—" %></p>
        <hr style="border-color:var(--cream2);margin:12px 0;">
        <p style="font-size:.86rem;"><strong>Delivery Address:</strong><br><%= addr %></p>
        <% if(onotes!=null&&!onotes.trim().isEmpty()){ %><p style="font-size:.86rem;margin-top:8px;"><strong>Notes:</strong> <%= onotes %></p><% } %>
      </div>
    </div>
  </div>
  <!-- Status update -->
  <div class="a-card" style="position:sticky;top:88px;">
    <div class="a-card-head"><h3><i class="fas fa-sync-alt" style="color:var(--copper);margin-right:6px;"></i>Update Status</h3></div>
    <div class="a-card-body">
      <p style="font-size:.82rem;color:var(--txt3);margin-bottom:4px;">Current Status</p>
      <span class="badge badge-<%= status.toLowerCase() %>" style="font-size:.88rem;padding:5px 14px;display:inline-block;margin-bottom:18px;"><%= status %></span>
      <form method="post" action="<%= cp %>/admin/orders.jsp?vid=<%= viewId %>">
        <input type="hidden" name="oid" value="<%= viewId %>">
        <div class="form-group"><label>Change To</label>
          <select name="newStatus" class="form-control">
            <% String[] sts={"PENDING","CONFIRMED","PREPARING","READY","DELIVERED","CANCELLED"};
               for(String s:sts){ %><option value="<%= s %>" <%= s.equals(status)?"selected":"" %>><%= s %></option><% } %>
          </select>
        </div>
        <button type="submit" class="btn btn-primary w100"><i class="fas fa-save"></i> Update</button>
      </form>
      <hr style="border-color:var(--cream2);margin:14px 0;">
      <p style="font-size:.8rem;color:var(--txt3);">Payment: <strong><%= payM %> – <%= payS %></strong></p>
      <p style="font-size:.8rem;color:var(--txt3);">Placed: <strong><%= created.substring(0,16) %></strong></p>
    </div>
  </div>
</div>
<% } }catch(Exception ex){ %><div class="alert alert-danger">Error: <%=ex.getMessage()%></div>
<% }finally{ if(dr!=null)try{dr.close();}catch(Exception e){} if(dp!=null)try{dp.close();}catch(Exception e){} if(dc!=null)try{dc.close();}catch(Exception e){} }

} else {
  /* ══ ORDER LIST VIEW ══ */
%>
<div class="page-hdr">
  <h2>All Orders</h2>
  <div style="display:flex;gap:8px;flex-wrap:wrap;">
    <% String[] fs={"ALL","PENDING","CONFIRMED","PREPARING","READY","DELIVERED","CANCELLED"};
       for(String f:fs){ %>
    <a href="<%= cp %>/admin/orders.jsp?filter=<%= f %>" class="btn btn-sm <%= f.equals(filter)?"btn-primary":"btn-outline" %>"><%= f %></a>
    <% } %>
  </div>
</div>
<div class="tbl-wrap">
  <table>
    <thead><tr><th>#</th><th>Customer</th><th>Items</th><th>Total</th><th>Payment</th><th>Status</th><th>Date</th><th>Action</th></tr></thead>
    <tbody>
    <%
      Connection lc=null; ResultSet lr=null;
      try{
        lc=getConn();
        String sql="SELECT o.*,c.full_name,(SELECT COUNT(*) FROM order_items oi WHERE oi.order_id=o.id) AS icnt FROM orders o JOIN customers c ON o.customer_id=c.id";
        if(!"ALL".equals(filter)) sql+=" WHERE o.order_status='"+filter+"'";
        sql+=" ORDER BY o.created_at DESC";
        lr=lc.prepareStatement(sql).executeQuery();
        boolean any=false;
        while(lr.next()){ any=true; String st=lr.getString("order_status");
    %>
    <tr>
      <td><strong>#<%= lr.getInt("id") %></strong></td>
      <td><%= lr.getString("full_name") %></td>
      <td style="text-align:center;"><%= lr.getInt("icnt") %></td>
      <td style="font-weight:700;color:var(--copper);">₹<%= String.format("%.0f",lr.getDouble("total_amount")) %></td>
      <td style="font-size:.82rem;"><%= lr.getString("payment_method") %></td>
      <td><span class="badge badge-<%= st.toLowerCase() %>"><%= st %></span></td>
      <td style="font-size:.78rem;color:var(--txt3);"><%= lr.getString("created_at").substring(0,10) %></td>
      <td><a href="<%= cp %>/admin/orders.jsp?vid=<%= lr.getInt("id") %>" class="btn btn-outline btn-sm"><i class="fas fa-eye"></i> View</a></td>
    </tr>
    <% } if(!any){%><tr><td colspan="8" style="text-align:center;padding:24px;color:var(--txt3);">No orders found.</td></tr><%}
      }catch(Exception ex){%><tr><td colspan="8"><div class="alert alert-danger">Error: <%=ex.getMessage()%></div></td></tr>
    <%}finally{ if(lr!=null)try{lr.close();}catch(Exception e){} if(lc!=null)try{lc.close();}catch(Exception e){} }%>
    </tbody>
  </table>
</div>
<% } %>
<%@ include file="../includes/admin_footer.jsp" %>
