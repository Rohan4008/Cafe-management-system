<%-- webapp/logout.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    session.removeAttribute("custId");
    session.removeAttribute("custName");
    response.sendRedirect(request.getContextPath() + "/index.jsp");
%>
