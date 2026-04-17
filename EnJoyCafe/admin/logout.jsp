<%-- webapp/admin/logout.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    session.removeAttribute("adminUser");
    session.removeAttribute("adminName");
    session.removeAttribute("adminId");
    response.sendRedirect(request.getContextPath() + "/admin/login.jsp");
%>
