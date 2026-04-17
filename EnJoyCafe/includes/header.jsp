<%-- =========================================================
     includes/header.jsp
     Customer-facing header. Include at top of every customer page.

     Before including, optionally set:
         <% request.setAttribute("pageTitle","Menu"); %>
 ========================================================= --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    /* cp is already set by connection.jsp */
    String ptitle  = request.getAttribute("pageTitle") != null
                     ? request.getAttribute("pageTitle") + " | EnJoyCafe"
                     : "EnJoyCafe – Where Every Sip Tells a Story";
    /* Current customer from session */
    String custName = (String) session.getAttribute("custName");
    boolean loggedIn = (custName != null);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><%= ptitle %></title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&family=Nunito:wght@300;400;600;700&display=swap">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="stylesheet" href="<%= cp %>/css/style.css">
</head>
<body>

<!-- ══ NAVBAR ══ -->
<nav class="navbar">
  <div class="nav-inner">
    <a href="<%= cp %>/index.jsp" class="nav-brand">☕ Enjoy<span>Cafe</span></a>
    <button class="nav-toggle" onclick="document.querySelector('.nav-links').classList.toggle('open')">
      <i class="fas fa-bars"></i>
    </button>
    <ul class="nav-links">
      <li><a href="<%= cp %>/index.jsp">Home</a></li>
      <li><a href="<%= cp %>/menu.jsp">Menu</a></li>
      <li><a href="<%= cp %>/about.jsp">About</a></li>
      <li><a href="<%= cp %>/contact.jsp">Contact</a></li>
      <li><a href="<%= cp %>/reviews.jsp">Reviews</a></li>
      <% if (loggedIn) { %>
      <li><a href="<%= cp %>/my-orders.jsp"><i class="fas fa-receipt"></i> My Orders</a></li>
      <li><a href="<%= cp %>/logout.jsp" style="color:#F87171;"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
      <% } else { %>
      <li><a href="<%= cp %>/login.jsp"><i class="fas fa-user"></i> Login</a></li>
      <% } %>
      <li>
        <a href="#" class="cart-icon-btn" onclick="openCart();return false;">
          <i class="fas fa-shopping-bag"></i> Cart
          <span class="cart-badge" id="cartBadge" style="display:none">0</span>
        </a>
      </li>
    </ul>
  </div>
</nav>

<!-- ══ CART SIDEBAR ══ -->
<div class="cart-overlay" id="cartOverlay" onclick="closeCart()"></div>
<div class="cart-sidebar" id="cartSidebar">
  <div class="cart-head">
    <h3><i class="fas fa-shopping-bag"></i> Your Cart</h3>
    <button onclick="closeCart()"><i class="fas fa-times"></i></button>
  </div>
  <div class="cart-items" id="cartItems"></div>
  <div class="cart-foot">
    <div class="cart-total-row">
      <span>Total</span><strong id="cartTotal">₹0</strong>
    </div>
    <button class="btn btn-primary w100" onclick="goCheckout()">
      <i class="fas fa-arrow-right"></i> Proceed to Checkout
    </button>
  </div>
</div>
<!-- ══ END CART ══ -->
