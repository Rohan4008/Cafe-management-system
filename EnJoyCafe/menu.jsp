<%-- webapp/menu.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="includes/connection.jsp" %>
<% request.setAttribute("pageTitle","Menu"); %>
<%@ include file="includes/header.jsp" %>
<meta name="contextPath" content="<%= cp %>">

<div style="background:linear-gradient(135deg,var(--espresso),var(--brown));padding:56px 0;text-align:center;">
  <div class="container"><h1 style="color:#fff;">Our Menu</h1><p style="color:rgba(255,255,255,.7);margin-top:8px;">Explore everything EnJoyCafe has to offer.</p></div>
</div>

<section class="section">
  <div class="container">

    <!-- Category tabs -->
    <div class="cat-tabs" id="catTabs">
      <button class="cat-tab active" data-cat="all">All</button>
      <%
        Connection cc = null; PreparedStatement cp2 = null; ResultSet cr = null;
        try {
          cc = getConn();
          cp2 = cc.prepareStatement("SELECT id,name FROM categories WHERE is_active=1 ORDER BY id");
          cr = cp2.executeQuery();
          while (cr.next()) {
      %>
      <button class="cat-tab" data-cat="cat-<%= cr.getInt("id") %>"><%= cr.getString("name") %></button>
      <% } } catch(Exception e){} finally {
          if(cr!=null)try{cr.close();}catch(Exception ex){}
          if(cp2!=null)try{cp2.close();}catch(Exception ex){}
          if(cc!=null)try{cc.close();}catch(Exception ex){}
        }
      %>
    </div>

    <!-- Search -->
    <div style="max-width:380px;margin:0 auto 28px;">
      <input type="text" id="menuSearch" class="form-control" placeholder="🔍 Search items…">
    </div>

    <!-- Products -->
    <div id="menuWrap">
      <%
        Connection pc = null; PreparedStatement pp = null; ResultSet pr = null;
        int lastCat = -1; boolean first = true;
        try {
          pc = getConn();
          pp = pc.prepareStatement(
            "SELECT p.*,c.name AS cname,c.id AS cid FROM products p " +
            "JOIN categories c ON p.category_id=c.id " +
            "WHERE p.is_available=1 ORDER BY c.id,p.name"
          );
          pr = pp.executeQuery();
          while (pr.next()) {
            int    cid   = pr.getInt("cid");
            String cname = pr.getString("cname");
            int    pid   = pr.getInt("id");
            String pname = pr.getString("name");
            String pdesc = pr.getString("description");
            double price = pr.getDouble("price");
            String img   = pr.getString("image_url");
            boolean feat = pr.getInt("is_featured")==1;

            if (cid != lastCat) {
              if (!first) out.print("</div>");
              first = false; lastCat = cid;
              out.print("<h3 style='margin:32px 0 14px;border-bottom:2px solid var(--cream2);padding-bottom:10px;'>" + cname + "</h3>");
              out.print("<div class='grid-4 cat-section' data-cat='cat-" + cid + "'>");
            }
      %>
      <div class="prod-card menu-item" data-cat="cat-<%= cid %>" data-name="<%= pname.toLowerCase() %>">
        <div class="prod-img">
          <% if(img!=null&&!img.trim().isEmpty()){%><img src="<%= cp %>/<%= img %>" alt="<%= pname %>"><% }else{ %><span class="no-img">☕</span><% } %>
          <% if(feat){%><span class="prod-feat-badge">⭐ Best</span><% } %>
        </div>
        <div class="prod-body">
          <h4><%= pname %></h4>
          <p><%= pdesc!=null?(pdesc.length()>65?pdesc.substring(0,65)+"…":pdesc):"" %></p>
          <div class="prod-actions">
            <span class="prod-price">₹<%= String.format("%.0f",price) %></span>
            <div class="d-flex align-center gap-8">
              <div class="qty-ctrl">
                <button class="qty-dec">−</button>
                <span class="qty-val">1</span>
                <button class="qty-inc">+</button>
              </div>
              <button class="btn btn-primary btn-sm btn-add"
                data-id="<%= pid %>" data-name="<%= pname %>" data-price="<%= price %>">
                <i class="fas fa-cart-plus"></i>
              </button>
            </div>
          </div>
        </div>
      </div>
      <% } if(!first) out.print("</div>");
        } catch(Exception e){
      %><div class="alert alert-danger">Error: <%= e.getMessage() %></div>
      <% } finally {
          if(pr!=null)try{pr.close();}catch(Exception e){}
          if(pp!=null)try{pp.close();}catch(Exception e){}
          if(pc!=null)try{pc.close();}catch(Exception e){}
        }
      %>
    </div>
  </div>
</section>

<script>
$(function(){
  // Category filter
  $('#catTabs .cat-tab').on('click',function(){
    $('#catTabs .cat-tab').removeClass('active');
    $(this).addClass('active');
    filter();
  });
  $('#menuSearch').on('input', filter);

  function filter(){
    var cat = $('#catTabs .cat-tab.active').data('cat');
    var q   = $('#menuSearch').val().toLowerCase().trim();
    $('.menu-item').each(function(){
      var catOk  = cat==='all' || $(this).data('cat')===cat;
      var nameOk = !q || ($(this).data('name')||'').indexOf(q)>-1;
      $(this).toggle(catOk && nameOk);
    });
    // hide section headers with no visible items
    $('.cat-section').each(function(){
      var vis = $(this).find('.menu-item:visible').length > 0;
      $(this).toggle(vis);
      $(this).prev('h3').toggle(vis);
    });
  }
});
</script>

<%@ include file="includes/footer.jsp" %>
