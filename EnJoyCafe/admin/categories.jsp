<%-- webapp/admin/categories.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../includes/connection.jsp" %>
<%
    String action=request.getParameter("action")!=null?request.getParameter("action"):"list";
    String msg=null; boolean isErr=false;

    if("delete".equals(action)){
        Connection c=null; PreparedStatement p=null;
        try{ c=getConn(); p=c.prepareStatement("DELETE FROM categories WHERE id=?"); p.setInt(1,Integer.parseInt(request.getParameter("id"))); p.executeUpdate(); msg="Category deleted."; }
        catch(Exception ex){ msg="Cannot delete: category may have products linked."; isErr=true; }
        finally{ if(p!=null)try{p.close();}catch(Exception e){} if(c!=null)try{c.close();}catch(Exception e){} }
        action="list";
    }
    if("POST".equalsIgnoreCase(request.getMethod())){
        String cname=request.getParameter("cname"); String cdesc=request.getParameter("cdesc");
        String eid=request.getParameter("eid"); String actv=request.getParameter("is_active");
        if(cname==null||cname.trim().isEmpty()){ msg="Name required."; isErr=true; }
        else {
            Connection c=null; PreparedStatement p=null;
            try{ c=getConn();
                if(eid!=null&&!eid.isEmpty()){ p=c.prepareStatement("UPDATE categories SET name=?,description=?,is_active=? WHERE id=?"); p.setString(1,cname.trim()); p.setString(2,cdesc); p.setInt(3,"1".equals(actv)?1:0); p.setInt(4,Integer.parseInt(eid)); msg="Category updated."; }
                else{ p=c.prepareStatement("INSERT INTO categories (name,description) VALUES (?,?)"); p.setString(1,cname.trim()); p.setString(2,cdesc); msg="Category added."; }
                p.executeUpdate(); action="list";
            }catch(Exception ex){ msg="Error: "+ex.getMessage(); isErr=true; }
            finally{ if(p!=null)try{p.close();}catch(Exception e){} if(c!=null)try{c.close();}catch(Exception e){} }
        }
    }
    String eNm="",eDesc=""; int eId=0,eActv=1;
    if("edit".equals(action)){
        Connection c=null; PreparedStatement p=null; ResultSet r=null;
        try{ c=getConn(); p=c.prepareStatement("SELECT * FROM categories WHERE id=?"); p.setInt(1,Integer.parseInt(request.getParameter("id"))); r=p.executeQuery();
            if(r.next()){ eId=r.getInt("id"); eNm=r.getString("name"); eDesc=r.getString("description")!=null?r.getString("description"):""; eActv=r.getInt("is_active"); }
        }catch(Exception ex){}finally{ if(r!=null)try{r.close();}catch(Exception e){} if(p!=null)try{p.close();}catch(Exception e){} if(c!=null)try{c.close();}catch(Exception e){} }
    }
%>
<% request.setAttribute("pageTitle","Categories"); request.setAttribute("pageId","categories"); %>
<%@ include file="../includes/admin_header.jsp" %>

<% if(msg!=null){ %><div class="alert alert-<%= isErr?"danger":"success" %>"><i class="fas fa-<%= isErr?"exclamation":"check" %>-circle"></i> <%= msg %></div><% } %>

<div style="display:grid;grid-template-columns:1fr 340px;gap:22px;align-items:start;">
  <!-- Table -->
  <div>
    <div class="page-hdr"><h2>All Categories</h2></div>
    <div class="tbl-wrap">
      <table>
        <thead><tr><th>#</th><th>Name</th><th>Description</th><th>Products</th><th>Status</th><th>Actions</th></tr></thead>
        <tbody>
        <%
          Connection lc=null; ResultSet lr=null;
          try{ lc=getConn();
            lr=lc.prepareStatement("SELECT c.*,(SELECT COUNT(*) FROM products p WHERE p.category_id=c.id) AS cnt FROM categories c ORDER BY c.name").executeQuery();
            while(lr.next()){ boolean av=lr.getInt("is_active")==1;
        %>
        <tr>
          <td><%= lr.getInt("id") %></td>
          <td><strong><%= lr.getString("name") %></strong></td>
          <td style="font-size:.82rem;color:var(--txt3);max-width:180px;"><%= lr.getString("description")!=null?lr.getString("description"):"" %></td>
          <td style="text-align:center;"><%= lr.getInt("cnt") %></td>
          <td><span class="badge badge-<%= av?"active":"inactive" %>"><%= av?"Active":"Inactive" %></span></td>
          <td>
            <a href="<%= cp %>/admin/categories.jsp?action=edit&id=<%= lr.getInt("id") %>" class="btn btn-outline btn-sm"><i class="fas fa-edit"></i></a>
            <a href="<%= cp %>/admin/categories.jsp?action=delete&id=<%= lr.getInt("id") %>" class="btn btn-danger btn-sm confirm-del" style="margin-left:5px;"><i class="fas fa-trash"></i></a>
          </td>
        </tr>
        <% } }catch(Exception e){}finally{ if(lr!=null)try{lr.close();}catch(Exception e2){} if(lc!=null)try{lc.close();}catch(Exception e2){} } %>
        </tbody>
      </table>
    </div>
  </div>
  <!-- Add/Edit Form -->
  <div class="a-card" style="position:sticky;top:88px;">
    <div class="a-card-head"><h3><%= "edit".equals(action)?"Edit Category":"Add Category" %></h3></div>
    <div class="a-card-body">
      <form method="post" action="<%= cp %>/admin/categories.jsp">
        <% if("edit".equals(action)){ %><input type="hidden" name="eid" value="<%= eId %>"><% } %>
        <div class="form-group"><label>Name *</label><input type="text" name="cname" class="form-control" value="<%= eNm %>" required></div>
        <div class="form-group"><label>Description</label><textarea name="cdesc" class="form-control" rows="2"><%= eDesc %></textarea></div>
        <% if("edit".equals(action)){ %>
        <div class="form-group"><label>Status</label>
          <select name="is_active" class="form-control">
            <option value="1" <%= eActv==1?"selected":"" %>>Active</option>
            <option value="0" <%= eActv==0?"selected":"" %>>Inactive</option>
          </select>
        </div>
        <% } %>
        <div class="d-flex gap-8">
          <button type="submit" class="btn btn-primary btn-sm"><i class="fas fa-save"></i> Save</button>
          <% if("edit".equals(action)){ %><a href="<%= cp %>/admin/categories.jsp" class="btn btn-outline btn-sm">Cancel</a><% } %>
        </div>
      </form>
    </div>
  </div>
</div>

<%@ include file="../includes/admin_footer.jsp" %>
