<%-- webapp/index.jsp  —  EnJoyCafe Homepage --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="includes/connection.jsp" %>
<% request.setAttribute("pageTitle","Home"); %>
<%@ include file="includes/header.jsp" %>
<!-- context path meta tag used by cart.js -->
<meta name="contextPath" content="<%= cp %>">

<!-- ══ HERO ══ -->
<section class="hero">
  <div class="container">
    <div class="hero-content">
      <span class="hero-tag">☕ Artisan Coffee · Pune</span>
      <h1>Where Every Sip<br><em>Tells a Story</em></h1>
      <p>Handcrafted coffee, fresh bites and a warm space that feels like home. Order online or walk in anytime.</p>
      <div class="hero-btns">
        <a href="<%= cp %>/menu.jsp" class="btn btn-primary btn-lg"><i class="fas fa-utensils"></i> Order Now</a>
        <a href="<%= cp %>/about.jsp" class="btn btn-lg" style="color:#fff;border:2px solid rgba(255,255,255,.45);border-radius:8px;">Our Story</a>
      </div>
    </div>
  </div>
  <div class="hero-decor">☕</div>
</section>

<!-- ══ FEATURE STRIP ══ -->
<div style="background:var(--espresso);">
  <div class="container">
    <div style="display:grid;grid-template-columns:repeat(4,1fr);text-align:center;">
      <%
        String[][] feats = {
          {"fas fa-coffee",    "Premium Beans",   "Single-origin, ethically sourced"},
          {"fas fa-bolt",      "Fast Service",    "Ready in under 10 minutes"},
          {"fas fa-star",      "5-Star Rated",    "Loved by 1000+ customers"},
          {"fas fa-motorcycle","Free Delivery",   "Orders above ₹499"}
        };
        for (String[] f : feats) {
      %>
      <div style="padding:26px 16px;border-right:1px solid rgba(255,255,255,.1);">
        <i class="<%= f[0] %>" style="font-size:1.7rem;color:var(--gold);display:block;margin-bottom:8px;"></i>
        <strong style="color:#fff;display:block;font-family:'Playfair Display',serif;"><%= f[1] %></strong>
        <span style="color:rgba(255,255,255,.5);font-size:.8rem;"><%= f[2] %></span>
      </div>
      <% } %>
    </div>
  </div>
</div>

<!-- ══ FEATURED PRODUCTS ══ -->
<section class="section">
  <div class="container">
    <div class="sec-title">
      <h2>Our Favourites</h2>
      <div class="divider"></div>
      <p>Hand-picked highlights — crowd pleasers and chef's specials.</p>
    </div>
    <div class="grid-4">
      <%
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
          conn = getConn();
          ps   = conn.prepareStatement(
            "SELECT p.*, c.name AS cat FROM products p " +
            "JOIN categories c ON p.category_id = c.id " +
            "WHERE p.is_featured=1 AND p.is_available=1 LIMIT 8"
          );
          rs = ps.executeQuery();
          boolean any = false;
          while (rs.next()) {
            any = true;
            int    pid   = rs.getInt("id");
            String pname = rs.getString("name");
            String pdesc = rs.getString("description");
            double price = rs.getDouble("price");
            String img   = rs.getString("image_url");
            String cat   = rs.getString("cat");
      %>
      <div class="prod-card">
        <div class="prod-img">
          <% if (img!=null && !img.trim().isEmpty()) { %>
          <img src="<%= cp %>/<%= img %>" alt="<%= pname %>">
          <% } else { %><span class="no-img">☕</span><% } %>
          <span class="prod-feat-badge">⭐ Featured</span>
        </div>
        <div class="prod-body">
          <span class="prod-cat"><%= cat %></span>
          <h4><%= pname %></h4>
          <p><%= pdesc!=null?(pdesc.length()>60?pdesc.substring(0,60)+"…":pdesc):"" %></p>
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
                <i class="fas fa-plus"></i>
              </button>
            </div>
          </div>
        </div>
      </div>
      <%
          }
          if (!any) {
      %><p class="text-center" style="grid-column:1/-1;padding:30px;color:var(--txt3);">No featured items yet.</p>
      <% }
        } catch (Exception e) {
      %><div class="alert alert-danger" style="grid-column:1/-1;">DB error: <%= e.getMessage() %></div>
      <% } finally {
          if(rs!=null)try{rs.close();}catch(Exception e){}
          if(ps!=null)try{ps.close();}catch(Exception e){}
          if(conn!=null)try{conn.close();}catch(Exception e){}
        }
      %>
    </div>
    <div class="text-center mt-4">
      <a href="<%= cp %>/menu.jsp" class="btn btn-outline btn-lg">View Full Menu <i class="fas fa-arrow-right"></i></a>
    </div>
  </div>
</section>

<!-- ══ ABOUT STRIP ══ -->
<section class="section" style="background:var(--cream2);">
  <div class="container">
    <div class="grid-2" style="align-items:center;gap:60px;">
      <div>
        <span style="color:var(--copper);font-weight:700;font-size:.82rem;text-transform:uppercase;letter-spacing:1px;">About EnJoyCafe</span>
        <h2 style="margin:10px 0 18px;">More Than Coffee,<br>It's an Experience</h2>
        <p style="margin-bottom:14px;">Founded in Pune's heart, EnJoyCafe has been the city's favourite corner for artisan brews, hearty sandwiches and sweet desserts since 2012.</p>
        <p>Our baristas train year-round with single-origin beans from Coorg and Chikmagalur. Pair your brew with a freshly made sandwich or our legendary Chocolate Brownie.</p>
        <a href="<%= cp %>/about.jsp" class="btn btn-primary mt-3">Learn More <i class="fas fa-arrow-right"></i></a>
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;">
        <% String[][] stats = {{"12+","Years","fas fa-calendar"},{"50+","Menu Items","fas fa-utensils"},{"1000+","Happy Guests","fas fa-heart"},{"4.9","Stars","fas fa-star"}}; for(String[] s:stats){ %>
        <div style="background:var(--white);border-radius:12px;padding:24px 18px;text-align:center;box-shadow:var(--sh-sm);">
          <i class="<%= s[2] %>" style="font-size:1.5rem;color:var(--copper);margin-bottom:10px;display:block;"></i>
          <strong style="font-family:'Playfair Display',serif;font-size:1.9rem;color:var(--espresso);display:block;"><%= s[0] %></strong>
          <span style="font-size:.8rem;color:var(--txt3);"><%= s[1] %></span>
        </div>
        <% } %>
      </div>
    </div>
  </div>
</section>

<!-- ══ REVIEWS PREVIEW ══ -->
<section class="section">
  <div class="container">
    <div class="sec-title"><h2>What Guests Say</h2><div class="divider"></div></div>
    <div class="grid-3">
      <%
        Connection conn2 = null; PreparedStatement ps2 = null; ResultSet rs2 = null;
        try {
          conn2 = getConn();
          ps2   = conn2.prepareStatement("SELECT * FROM reviews WHERE is_approved=1 ORDER BY created_at DESC LIMIT 3");
          rs2   = ps2.executeQuery();
          while (rs2.next()) {
            int r = rs2.getInt("rating");
            String nm = rs2.getString("name");
            String cm = rs2.getString("comment");
      %>
      <div class="review-card">
        <div class="stars"><%= stars(r) %></div>
        <p style="margin-top:10px;font-size:.9rem;">"<%= cm %>"</p>
        <div class="review-author">
          <div class="review-av"><%= nm.substring(0,1).toUpperCase() %></div>
          <strong style="font-size:.88rem;"><%= nm %></strong>
        </div>
      </div>
      <% } } catch(Exception e){} finally {
          if(rs2!=null)try{rs2.close();}catch(Exception e){}
          if(ps2!=null)try{ps2.close();}catch(Exception e){}
          if(conn2!=null)try{conn2.close();}catch(Exception e){}
        }
      %>
    </div>
    <div class="text-center mt-4">
      <a href="<%= cp %>/reviews.jsp" class="btn btn-outline">Read All Reviews <i class="fas fa-arrow-right"></i></a>
    </div>
  </div>
</section>

<!-- ══ CTA ══ -->
<section style="background:linear-gradient(135deg,var(--espresso),var(--brown));padding:70px 0;text-align:center;">
  <div class="container">
    <h2 style="color:#fff;margin-bottom:14px;">Ready to Order?</h2>
    <p style="color:rgba(255,255,255,.7);margin-bottom:28px;max-width:460px;margin-left:auto;margin-right:auto;">Browse our full menu and place your order online. Fresh, fast and delivered.</p>
    <a href="<%= cp %>/menu.jsp" class="btn btn-primary btn-lg"><i class="fas fa-shopping-bag"></i> Order Online</a>
  </div>
</section>

<%@ include file="includes/footer.jsp" %>
