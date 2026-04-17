<%-- =========================================================
     includes/admin_header.jsp
     Admin panel header + sidebar. Include at top of every admin page.
     Before including, set:
         <% request.setAttribute("pageTitle","Dashboard");
            request.setAttribute("pageId","dashboard"); %>
 ========================================================= --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    /* Admin auth check — redirect to login if not logged in */
    if (session.getAttribute("adminUser") == null) {
        response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
        return;
    }
    /* cp is already set by connection.jsp */
    String ptitle  = request.getAttribute("pageTitle") != null
                     ? (String) request.getAttribute("pageTitle") : "Admin";
    String pageId  = request.getAttribute("pageId") != null
                     ? (String) request.getAttribute("pageId") : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><%= ptitle %> | EnJoyCafe Admin</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;600;700&family=Nunito:wght@300;400;600;700&display=swap">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<link rel="stylesheet" href="<%= cp %>/css/style.css">
<link rel="stylesheet" href="<%= cp %>/css/admin.css">
</head>
<body>
<div class="admin-wrap">

  <!-- ══ SIDEBAR ══ -->
  <aside class="sidebar" id="sidebar">
    <div class="sidebar-brand">
      <h2>☕ EnJoyCafe</h2>
      <p>Admin Panel</p>
    </div>
    <nav class="sidebar-nav">
      <span class="nav-label">Overview</span>
      <a href="<%= cp %>/admin/dashboard.jsp"   class="<%= "dashboard".equals(pageId)  ? "active" : "" %>"><i class="fas fa-th-large"></i> Dashboard</a>

      <span class="nav-label">Catalogue</span>
      <a href="<%= cp %>/admin/products.jsp"    class="<%= "products".equals(pageId)   ? "active" : "" %>"><i class="fas fa-mug-hot"></i> Products</a>
      <a href="<%= cp %>/admin/categories.jsp"  class="<%= "categories".equals(pageId) ? "active" : "" %>"><i class="fas fa-tags"></i> Categories</a>

      <span class="nav-label">Operations</span>
      <a href="<%= cp %>/admin/orders.jsp"      class="<%= "orders".equals(pageId)     ? "active" : "" %>"><i class="fas fa-receipt"></i> Orders</a>

      <span class="nav-label">People</span>
      <a href="<%= cp %>/admin/staff.jsp"       class="<%= "staff".equals(pageId)      ? "active" : "" %>"><i class="fas fa-users"></i> Staff</a>
      <a href="<%= cp %>/admin/customers.jsp"   class="<%= "customers".equals(pageId)  ? "active" : "" %>"><i class="fas fa-user-friends"></i> Customers</a>

      <span class="nav-label">Content</span>
      <a href="<%= cp %>/admin/reviews.jsp"     class="<%= "reviews".equals(pageId)    ? "active" : "" %>"><i class="fas fa-star"></i> Reviews</a>

      <span class="nav-label">Settings</span>
      <a href="<%= cp %>/admin/settings.jsp"    class="<%= "settings".equals(pageId)   ? "active" : "" %>"><i class="fas fa-cog"></i> Settings</a>
    </nav>
    <div class="sidebar-foot">
      <a href="<%= cp %>/admin/logout.jsp"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>
  </aside>
  <!-- ══ END SIDEBAR ══ -->

  <!-- ══ MAIN AREA ══ -->
  <div class="admin-main">
    <div class="admin-topbar">
      <div class="topbar-left">
        <button class="sidebar-toggle" onclick="document.getElementById('sidebar').classList.toggle('open')">
          <i class="fas fa-bars"></i>
        </button>
        <h1><%= ptitle %></h1>
      </div>
      <div class="topbar-right">
        <div class="admin-avatar">A</div>
        <span>Administrator</span>
        <a href="<%= cp %>/index.jsp" target="_blank" title="View site"><i class="fas fa-external-link-alt"></i></a>
      </div>
    </div>
    <div class="admin-content">
