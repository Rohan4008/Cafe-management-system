<%-- webapp/reviews.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="includes/connection.jsp" %>
<% request.setAttribute("pageTitle","Reviews"); %>

<%
  String rmsg = null; boolean rErr = false;
  if ("POST".equalsIgnoreCase(request.getMethod())) {
    String rname  = request.getParameter("rname");
    String ratingS= request.getParameter("rating");
    String rcomm  = request.getParameter("comment");
    if (rname==null||rname.trim().isEmpty()||ratingS==null||rcomm==null||rcomm.trim().isEmpty()) {
      rmsg = "Please fill all fields."; rErr = true;
    } else {
      int rating = 5;
      try { rating = Integer.parseInt(ratingS); } catch(Exception e){}
      if (rating<1||rating>5) { rmsg="Invalid rating."; rErr=true; }
      else {
        Integer custId = (Integer) session.getAttribute("custId");
        Connection conn = null; PreparedStatement ps = null;
        try {
          conn = getConn();
          ps   = conn.prepareStatement("INSERT INTO reviews (customer_id,name,rating,comment) VALUES (?,?,?,?)");
          if (custId != null) ps.setInt(1, custId); else ps.setNull(1, java.sql.Types.INTEGER);
          ps.setString(2, rname.trim());
          ps.setInt(3, rating);
          ps.setString(4, rcomm.trim());
          ps.executeUpdate();
          rmsg = "Thank you! Your review is awaiting approval.";
        } catch(Exception ex) { rmsg = "Error: " + ex.getMessage(); rErr = true; }
        finally { if(ps!=null)try{ps.close();}catch(Exception e){} if(conn!=null)try{conn.close();}catch(Exception e){} }
      }
    }
  }
%>

<%@ include file="includes/header.jsp" %>

<div style="background:linear-gradient(135deg,var(--espresso),var(--brown));padding:56px 0;text-align:center;">
  <div class="container"><h1 style="color:#fff;">Customer Reviews</h1><p style="color:rgba(255,255,255,.7);margin-top:8px;">What our guests are saying</p></div>
</div>

<section class="section">
  <div class="container">

    <!-- Average strip -->
    <%
      double avg = 0; int total = 0;
      Connection ca = null; PreparedStatement pa = null; ResultSet ra = null;
      try {
        ca = getConn();
        pa = ca.prepareStatement("SELECT AVG(rating) avg, COUNT(*) cnt FROM reviews WHERE is_approved=1");
        ra = pa.executeQuery();
        if (ra.next()) { avg = ra.getDouble("avg"); total = ra.getInt("cnt"); }
      } catch(Exception e){} finally {
        if(ra!=null)try{ra.close();}catch(Exception e){}
        if(pa!=null)try{pa.close();}catch(Exception e){}
        if(ca!=null)try{ca.close();}catch(Exception e){}
      }
    %>
    <div style="background:var(--espresso);border-radius:16px;padding:30px;margin-bottom:44px;display:flex;align-items:center;gap:36px;flex-wrap:wrap;justify-content:center;text-align:center;">
      <div>
        <div style="font-size:3.2rem;font-family:'Playfair Display',serif;color:var(--gold);font-weight:700;"><%= String.format("%.1f",avg) %></div>
        <div class="stars" style="font-size:1.3rem;"><%= stars((int)Math.round(avg)) %></div>
        <p style="color:rgba(255,255,255,.6);font-size:.82rem;margin-top:4px;"><%= total %> verified reviews</p>
      </div>
    </div>

    <!-- Reviews grid -->
    <div class="grid-3">
      <%
        Connection cr = null; PreparedStatement pr = null; ResultSet rr = null;
        try {
          cr = getConn();
          pr = cr.prepareStatement("SELECT * FROM reviews WHERE is_approved=1 ORDER BY created_at DESC");
          rr = pr.executeQuery();
          boolean any = false;
          while (rr.next()) {
            any = true;
            int r = rr.getInt("rating");
            String nm = rr.getString("name");
            String cm = rr.getString("comment");
            String dt = rr.getString("created_at").substring(0,10);
      %>
      <div class="review-card">
        <div class="stars"><%= stars(r) %></div>
        <p style="margin-top:10px;font-size:.9rem;">"<%= cm %>"</p>
        <div class="review-author">
          <div class="review-av"><%= nm.substring(0,1).toUpperCase() %></div>
          <div><strong style="display:block;font-size:.88rem;"><%= nm %></strong><span style="font-size:.75rem;color:var(--txt3);"><%= dt %></span></div>
        </div>
      </div>
      <%  } if(!any){%><p style="grid-column:1/-1;text-align:center;color:var(--txt3);">No reviews yet. Be the first!</p><%}
        }catch(Exception e){}finally{
          if(rr!=null)try{rr.close();}catch(Exception e){}
          if(pr!=null)try{pr.close();}catch(Exception e){}
          if(cr!=null)try{cr.close();}catch(Exception e){}
        }
      %>
    </div>

    <!-- Submit form -->
    <div style="max-width:540px;margin:50px auto 0;">
      <div class="card">
        <div class="card-body">
          <h3 style="text-align:center;margin-bottom:22px;">Share Your Experience</h3>
          <% if(rmsg!=null){ %><div class="alert alert-<%= rErr?"danger":"success" %>"><i class="fas fa-<%= rErr?"exclamation":"check" %>-circle"></i> <%= rmsg %></div><% } %>
          <form method="post">
            <div class="form-group">
              <label>Your Name</label>
              <input type="text" name="rname" class="form-control" placeholder="Your name"
                value="<%= session.getAttribute("custName")!=null?session.getAttribute("custName"):"" %>" required>
            </div>
            <div class="form-group">
              <label>Rating</label>
              <div class="star-input">
                <input type="radio" id="s5" name="rating" value="5"><label for="s5">★</label>
                <input type="radio" id="s4" name="rating" value="4"><label for="s4">★</label>
                <input type="radio" id="s3" name="rating" value="3" checked><label for="s3">★</label>
                <input type="radio" id="s2" name="rating" value="2"><label for="s2">★</label>
                <input type="radio" id="s1" name="rating" value="1"><label for="s1">★</label>
              </div>
            </div>
            <div class="form-group">
              <label>Your Review</label>
              <textarea name="comment" class="form-control" rows="4" placeholder="Tell us about your experience…" required></textarea>
            </div>
            <button type="submit" class="btn btn-primary w100"><i class="fas fa-star"></i> Submit Review</button>
          </form>
        </div>
      </div>
    </div>
  </div>
</section>

<%@ include file="includes/footer.jsp" %>
