<%-- webapp/about.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="includes/connection.jsp" %>
<% request.setAttribute("pageTitle","About Us"); %>
<%@ include file="includes/header.jsp" %>

<div style="background:linear-gradient(135deg,var(--espresso),var(--brown));padding:56px 0;text-align:center;">
  <div class="container"><h1 style="color:#fff;">Our Story</h1><p style="color:rgba(255,255,255,.7);margin-top:8px;">How EnJoyCafe became Pune's favourite coffee corner</p></div>
</div>

<section class="section">
  <div class="container">
    <div class="grid-2" style="align-items:center;gap:60px;">
      <div>
        <span style="color:var(--copper);font-weight:700;font-size:.82rem;text-transform:uppercase;letter-spacing:1px;">Est. 2012</span>
        <h2 style="margin:10px 0 18px;">From a Dream to Pune's Favourite Café</h2>
        <p style="margin-bottom:14px;">EnJoyCafe was born from a simple idea: everyone deserves a perfect cup of coffee in a warm, welcoming space. Our founder started with a small corner in Shivajinagar armed with a dream, a vintage espresso machine and an unshakeable belief in hospitality.</p>
        <p style="margin-bottom:14px;">Over 12 years we've grown into one of Pune's most beloved café destinations — but our heart remains the same. We source the finest single-origin beans from Coorg and Chikmagalur, train our baristas rigorously, and ensure every bite is prepared with love.</p>
        <p>Today, EnJoyCafe is more than a café. It's a community for students, professionals and coffee lovers who deserve a place to simply <em>enjoy</em>.</p>
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;">
        <% String[][] vals = {{"☕","Passion","Coffee is our love language"},{"🌱","Sustainable","Ethically sourced beans"},{"👨‍🍳","Crafted","Trained baristas & chefs"},{"💛","Community","12+ years of warmth"}}; for(String[] v:vals){ %>
        <div style="background:var(--cream2);border-radius:12px;padding:22px;text-align:center;">
          <div style="font-size:1.8rem;margin-bottom:8px;"><%= v[0] %></div>
          <strong style="color:var(--espresso);display:block;margin-bottom:4px;"><%= v[1] %></strong>
          <span style="font-size:.78rem;color:var(--txt3);"><%= v[2] %></span>
        </div>
        <% } %>
      </div>
    </div>
  </div>
</section>

<section class="section" style="background:var(--cream2);">
  <div class="container">
    <div class="sec-title"><h2>Meet the Team</h2><div class="divider"></div></div>
    <div class="grid-4">
      <% String[][] team = {{"Anand Kulkarni","Founder & CEO"},{"Ravi Kumar","Head Barista"},{"Priya Sharma","Operations Manager"},{"Sneha Patil","Kitchen Head"}}; for(String[] t:team){ %>
      <div class="card text-center">
        <div style="padding:26px 18px;">
          <div style="width:66px;height:66px;background:linear-gradient(135deg,var(--copper),var(--gold));border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 12px;font-size:1.5rem;color:#fff;font-family:'Playfair Display',serif;font-weight:700;"><%= t[0].substring(0,1) %></div>
          <h4 style="font-size:.95rem;margin-bottom:4px;"><%= t[0] %></h4>
          <p style="font-size:.8rem;color:var(--copper);font-weight:700;margin:0;"><%= t[1] %></p>
        </div>
      </div>
      <% } %>
    </div>
  </div>
</section>

<%@ include file="includes/footer.jsp" %>
