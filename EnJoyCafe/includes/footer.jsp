<%-- =========================================================
     includes/footer.jsp
     Customer-facing footer. Include at bottom of every customer page.
 ========================================================= --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- cp is already declared by includes/connection.jsp which is included before this --%>

<footer class="footer">
  <div class="container">
    <div class="footer-grid">

      <div class="footer-col">
        <h4>☕ EnJoyCafe</h4>
        <p>Where every sip tells a story. Crafting premium coffee experiences with passion since 2012.</p>
        <div class="social-row">
          <a href="#"><i class="fab fa-facebook-f"></i></a>
          <a href="#"><i class="fab fa-instagram"></i></a>
          <a href="#"><i class="fab fa-twitter"></i></a>
        </div>
      </div>

      <div class="footer-col">
        <h4>Quick Links</h4>
        <ul>
          <li><a href="<%= cp %>/index.jsp">Home</a></li>
          <li><a href="<%= cp %>/menu.jsp">Our Menu</a></li>
          <li><a href="<%= cp %>/about.jsp">About Us</a></li>
          <li><a href="<%= cp %>/contact.jsp">Contact</a></li>
          <li><a href="<%= cp %>/reviews.jsp">Reviews</a></li>
        </ul>
      </div>

      <div class="footer-col">
        <h4>Opening Hours</h4>
        <p>Mon – Fri<br><strong>7:00 AM – 10:00 PM</strong></p>
        <p style="margin-top:10px;">Sat – Sun<br><strong>8:00 AM – 11:00 PM</strong></p>
      </div>

      <div class="footer-col">
        <h4>Find Us</h4>
        <p><i class="fas fa-map-marker-alt"></i> 123, FC Road, Shivajinagar,<br>&nbsp;&nbsp;&nbsp;Pune – 411 004</p>
        <p><i class="fas fa-phone"></i> +91 98765 43210</p>
        <p><i class="fas fa-envelope"></i> hello@enjoycafe.com</p>
      </div>

    </div>
  </div>
  <div class="footer-bottom">
    <p>&copy; 2024 EnJoyCafe. All rights reserved. Crafted with <span style="color:#B87333">❤</span> in Pune.</p>
  </div>
</footer>

<!-- jQuery + Main JS -->
<script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
<script src="<%= cp %>/js/cart.js"></script>
<script src="<%= cp %>/js/main.js"></script>
</body>
</html>
