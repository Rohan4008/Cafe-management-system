<%-- webapp/contact.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="includes/connection.jsp" %>
<% request.setAttribute("pageTitle","Contact"); %>
<%@ include file="includes/header.jsp" %>

<div style="background:linear-gradient(135deg,var(--espresso),var(--brown));padding:56px 0;text-align:center;">
  <div class="container"><h1 style="color:#fff;">Contact & Location</h1><p style="color:rgba(255,255,255,.7);margin-top:8px;">Find us, call us, or drop a message</p></div>
</div>

<section class="section">
  <div class="container">
    <div class="grid-2" style="gap:40px;">

      <!-- Info + form -->
      <div>
        <h3 style="margin-bottom:22px;">Get in Touch</h3>
        <% String[][] infos = {
          {"fas fa-map-marker-alt","Address","123, FC Road, Shivajinagar,<br>Pune – 411 004, Maharashtra"},
          {"fas fa-phone","Phone","+91 98765 43210"},
          {"fas fa-envelope","Email","hello@enjoycafe.com"},
          {"fas fa-clock","Hours","Mon–Fri: 7AM–10PM  |  Sat–Sun: 8AM–11PM"}
        };
        for(String[] i:infos){ %>
        <div style="display:flex;gap:16px;margin-bottom:22px;align-items:flex-start;">
          <div style="width:42px;height:42px;background:rgba(184,115,51,.12);border-radius:10px;display:flex;align-items:center;justify-content:center;flex-shrink:0;color:var(--copper);"><i class="<%= i[0] %>"></i></div>
          <div><strong style="display:block;color:var(--espresso);margin-bottom:3px;"><%= i[1] %></strong><span style="color:var(--txt2);font-size:.88rem;"><%= i[2] %></span></div>
        </div>
        <% } %>

        <h3 style="margin:28px 0 18px;">Send a Message</h3>
        <div id="cMsg" class="alert alert-success hidden"><i class="fas fa-check-circle"></i> Message sent! We'll get back to you soon.</div>
        <form id="cForm">
          <div class="form-row">
            <div class="form-group"><label>Name</label><input type="text" class="form-control" id="cName" placeholder="Your name" required></div>
            <div class="form-group"><label>Email</label><input type="email" class="form-control" id="cEmail" placeholder="you@email.com" required></div>
          </div>
          <div class="form-group"><label>Subject</label><input type="text" class="form-control" id="cSubject" placeholder="What's it about?"></div>
          <div class="form-group"><label>Message</label><textarea class="form-control" id="cMessage" rows="4" placeholder="Your message…" required></textarea></div>
          <button type="submit" class="btn btn-primary"><i class="fas fa-paper-plane"></i> Send Message</button>
        </form>
      </div>

      <!-- Map -->
      <div>
        <h3 style="margin-bottom:18px;">Our Location</h3>
        <div style="border-radius:12px;overflow:hidden;border:2px solid var(--cream2);">
          <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3782.2855120043765!2d73.84259311538671!3d18.527810187399724!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3bc2c07f4e4e5e0b%3A0x9b8b8b8b8b8b8b8b!2sFC%20Road%2C%20Shivajinagar%2C%20Pune!5e0!3m2!1sen!2sin!4v1600000000000"
            width="100%" height="320" style="border:0;display:block;" allowfullscreen="" loading="lazy"></iframe>
        </div>
        <div style="background:var(--white);border-radius:12px;padding:18px;margin-top:16px;box-shadow:var(--sh-sm);">
          <h4 style="font-size:.95rem;margin-bottom:7px;"><i class="fas fa-directions" style="color:var(--copper);margin-right:8px;"></i>How to Find Us</h4>
          <p style="font-size:.85rem;">Near Shivajinagar Metro Station on FC Road. Look for the large coffee-cup signage above the entrance. Ample parking in nearby lanes.</p>
        </div>
      </div>
    </div>
  </div>
</section>

<script>
$('#cForm').on('submit',function(e){
  e.preventDefault();
  $('#cMsg').removeClass('hidden');
  this.reset();
  setTimeout(function(){ $('#cMsg').addClass('hidden'); }, 5000);
});
</script>

<%@ include file="includes/footer.jsp" %>
