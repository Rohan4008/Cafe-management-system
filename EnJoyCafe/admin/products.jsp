<%-- webapp/admin/products.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../includes/connection.jsp" %>
<%
    String action = request.getParameter("action") != null ? request.getParameter("action") : "list";
    String msg = null; boolean isErr = false;

    /* ── DELETE ── */
    if ("delete".equals(action)) {
        String id = request.getParameter("id");
        Connection c=null; PreparedStatement p=null;
        try { c=getConn(); p=c.prepareStatement("DELETE FROM products WHERE id=?"); p.setInt(1,Integer.parseInt(id)); p.executeUpdate(); msg="Product deleted."; }
        catch(Exception ex){ msg="Cannot delete: product may be linked to orders."; isErr=true; }
        finally{ if(p!=null)try{p.close();}catch(Exception e){} if(c!=null)try{c.close();}catch(Exception e){} }
        action="list";
    }

    /* ── SAVE (add / edit) ── */
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String fa   = request.getParameter("fa");
        String name_= request.getParameter("name");
        String desc_= request.getParameter("description");
        String price_=request.getParameter("price");
        String cat_ = request.getParameter("category_id");
        String img_ = request.getParameter("image_url");
        String avail_=request.getParameter("is_available");
        String feat_ =request.getParameter("is_featured");
        String eid  = request.getParameter("eid");

        if (name_==null||name_.trim().isEmpty()||price_==null||cat_==null) {
            msg="Name, price and category are required."; isErr=true; action="add".equals(fa)?"add":"edit";
        } else {
            Connection c=null; PreparedStatement p=null;
            try {
                c=getConn();
                if (eid!=null&&!eid.isEmpty()) {
                    p=c.prepareStatement("UPDATE products SET name=?,description=?,price=?,category_id=?,image_url=?,is_available=?,is_featured=? WHERE id=?");
                    p.setString(1,name_.trim()); p.setString(2,desc_); p.setDouble(3,Double.parseDouble(price_));
                    p.setInt(4,Integer.parseInt(cat_)); p.setString(5,img_);
                    p.setInt(6,"1".equals(avail_)?1:0); p.setInt(7,"1".equals(feat_)?1:0); p.setInt(8,Integer.parseInt(eid));
                    msg="Product updated.";
                } else {
                    p=c.prepareStatement("INSERT INTO products (name,description,price,category_id,image_url,is_available,is_featured) VALUES (?,?,?,?,?,?,?)");
                    p.setString(1,name_.trim()); p.setString(2,desc_); p.setDouble(3,Double.parseDouble(price_));
                    p.setInt(4,Integer.parseInt(cat_)); p.setString(5,img_);
                    p.setInt(6,"1".equals(avail_)?1:0); p.setInt(7,"1".equals(feat_)?1:0);
                    msg="Product added.";
                }
                p.executeUpdate(); action="list";
            } catch(Exception ex){ msg="Error: "+ex.getMessage(); isErr=true; action="list"; }
            finally{ if(p!=null)try{p.close();}catch(Exception e){} if(c!=null)try{c.close();}catch(Exception e){} }
        }
    }

    /* ── Load product for edit ── */
    String eNm="",eDesc="",ePrice="",eImg=""; int eCatId=0,eAvail=1,eFeat=0,eId=0;
    if ("edit".equals(action)) {
        String id=request.getParameter("id");
        Connection c=null; PreparedStatement p=null; ResultSet r=null;
        try{ c=getConn(); p=c.prepareStatement("SELECT * FROM products WHERE id=?"); p.setInt(1,Integer.parseInt(id)); r=p.executeQuery();
            if(r.next()){ eId=r.getInt("id"); eNm=r.getString("name"); eDesc=r.getString("description")!=null?r.getString("description"):""; ePrice=""+r.getDouble("price"); eCatId=r.getInt("category_id"); eImg=r.getString("image_url")!=null?r.getString("image_url"):""; eAvail=r.getInt("is_available"); eFeat=r.getInt("is_featured"); }
        }catch(Exception ex){}finally{ if(r!=null)try{r.close();}catch(Exception e){} if(p!=null)try{p.close();}catch(Exception e){} if(c!=null)try{c.close();}catch(Exception e){} }
    }
%>
<%  request.setAttribute("pageTitle","Products"); request.setAttribute("pageId","products"); %>
<%@ include file="../includes/admin_header.jsp" %>

<% if(msg!=null){ %><div class="alert alert-<%= isErr?"danger":"success" %>"><i class="fas fa-<%= isErr?"exclamation":"check" %>-circle"></i> <%= msg %></div><% } %>

<% if ("add".equals(action)||"edit".equals(action)) {
    boolean isEdit="edit".equals(action);
    /* Build category options */
    StringBuilder catOpts = new StringBuilder("<option value=''>-- Select Category --</option>");
    Connection cc=null; PreparedStatement cp_=null; ResultSet cr=null;
    try{ cc=getConn(); cp_=cc.prepareStatement("SELECT id,name FROM categories WHERE is_active=1 ORDER BY name"); cr=cp_.executeQuery();
        while(cr.next()){ int cid=cr.getInt("id"); catOpts.append("<option value='").append(cid).append("'").append(cid==eCatId?" selected":"").append(">").append(cr.getString("name")).append("</option>"); }
    }catch(Exception e){}finally{ if(cr!=null)try{cr.close();}catch(Exception e){} if(cp_!=null)try{cp_.close();}catch(Exception e){} if(cc!=null)try{cc.close();}catch(Exception e){} }
%>
<div class="a-card" style="max-width:680px;">
  <div class="a-card-head">
    <h3><%= isEdit?"Edit Product":"Add New Product" %></h3>
    <a href="<%= cp %>/admin/products.jsp" class="btn btn-outline btn-sm"><i class="fas fa-arrow-left"></i> Back</a>
  </div>
  <div class="a-card-body">
    <form method="post" action="<%= cp %>/admin/products.jsp">
      <input type="hidden" name="fa"  value="<%= isEdit?"edit":"add" %>">
      <% if(isEdit){ %><input type="hidden" name="eid" value="<%= eId %>"><% } %>
      <div class="form-row">
        <div class="form-group"><label>Product Name *</label><input type="text" name="name" class="form-control" value="<%= eNm %>" required></div>
        <div class="form-group"><label>Category *</label><select name="category_id" class="form-control" required><%= catOpts %></select></div>
      </div>
      <div class="form-group"><label>Description</label><textarea name="description" class="form-control" rows="3"><%= eDesc %></textarea></div>
      <div class="form-row">
        <div class="form-group"><label>Price (₹) *</label><input type="number" name="price" class="form-control" step="0.01" min="0" value="<%= ePrice %>" required></div>
        <div class="form-group"><label>Image URL <span style="font-size:.75rem;color:var(--txt3);">(relative or full URL)</span></label><input type="text" name="image_url" class="form-control" value="<%= eImg %>" placeholder="images/products/latte.jpg"></div>
      </div>
      <div class="form-row">
        <div class="form-group"><label>Available?</label>
          <select name="is_available" class="form-control">
            <option value="1" <%= eAvail==1?"selected":"" %>>Yes – Available</option>
            <option value="0" <%= eAvail==0?"selected":"" %>>No – Unavailable</option>
          </select>
        </div>
        <div class="form-group"><label>Featured on Homepage?</label>
          <select name="is_featured" class="form-control">
            <option value="0" <%= eFeat==0?"selected":"" %>>No</option>
            <option value="1" <%= eFeat==1?"selected":"" %>>Yes</option>
          </select>
        </div>
      </div>
      <div class="d-flex gap-12 mt-2">
        <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> <%= isEdit?"Update":"Add Product" %></button>
        <a href="<%= cp %>/admin/products.jsp" class="btn btn-outline">Cancel</a>
      </div>
    </form>
  </div>
</div>
<% } else { %>

<div class="page-hdr">
  <h2>All Products</h2>
  <a href="<%= cp %>/admin/products.jsp?action=add" class="btn btn-primary"><i class="fas fa-plus"></i> Add Product</a>
</div>

<div style="display:flex;gap:12px;margin-bottom:18px;flex-wrap:wrap;">
  <input type="text" class="form-control tbl-search" data-tbl="#prodTbl" style="max-width:260px;" placeholder="🔍 Search products…">
  <select id="catFilter" class="form-control" style="max-width:200px;">
    <option value="">All Categories</option>
    <%
      Connection fc=null; PreparedStatement fp=null; ResultSet fr=null;
      try{ fc=getConn(); fp=fc.prepareStatement("SELECT id,name FROM categories WHERE is_active=1 ORDER BY name"); fr=fp.executeQuery();
        while(fr.next()){%><option value="<%= fr.getInt("id") %>"><%= fr.getString("name") %></option><%}
      }catch(Exception e){}finally{ if(fr!=null)try{fr.close();}catch(Exception e){} if(fp!=null)try{fp.close();}catch(Exception e){} if(fc!=null)try{fc.close();}catch(Exception e){} }
    %>
  </select>
</div>

<div class="tbl-wrap">
  <table id="prodTbl">
    <thead><tr><th>#</th><th>Name</th><th>Category</th><th>Price</th><th>Available</th><th>Featured</th><th>Actions</th></tr></thead>
    <tbody>
    <%
      Connection lc=null; PreparedStatement lp=null; ResultSet lr=null;
      try{
        lc=getConn();
        lr=lc.prepareStatement("SELECT p.*,c.name AS cat,c.id AS cid FROM products p JOIN categories c ON p.category_id=c.id ORDER BY c.name,p.name").executeQuery();
        boolean any=false;
        while(lr.next()){ any=true; boolean av=lr.getInt("is_available")==1; boolean ft=lr.getInt("is_featured")==1;
    %>
    <tr data-cat="<%= lr.getInt("cid") %>">
      <td><%= lr.getInt("id") %></td>
      <td><strong><%= lr.getString("name") %></strong></td>
      <td><%= lr.getString("cat") %></td>
      <td style="font-weight:700;color:var(--copper);">₹<%= String.format("%.0f",lr.getDouble("price")) %></td>
      <td><span class="badge badge-<%= av?"yes":"no" %>"><%= av?"Yes":"No" %></span></td>
      <td><span class="badge badge-<%= ft?"yes":"no" %>"><%= ft?"Yes":"No" %></span></td>
      <td>
        <a href="<%= cp %>/admin/products.jsp?action=edit&id=<%= lr.getInt("id") %>" class="btn btn-outline btn-sm"><i class="fas fa-edit"></i></a>
        <a href="<%= cp %>/admin/products.jsp?action=delete&id=<%= lr.getInt("id") %>" class="btn btn-danger btn-sm confirm-del" style="margin-left:5px;"><i class="fas fa-trash"></i></a>
      </td>
    </tr>
    <% } if(!any){%><tr><td colspan="7" style="text-align:center;padding:24px;color:var(--txt3);">No products found.</td></tr><%}
      }catch(Exception ex){%><tr><td colspan="7"><div class="alert alert-danger">Error: <%=ex.getMessage()%></div></td></tr>
    <%}finally{if(lr!=null)try{lr.close();}catch(Exception e){} if(lc!=null)try{lc.close();}catch(Exception e){}}%>
    </tbody>
  </table>
</div>
<script>
$('#catFilter').on('change',function(){
  var cat=$(this).val();
  $('#prodTbl tbody tr').each(function(){
    $(this).toggle(!cat || String($(this).data('cat'))===cat);
  });
});
</script>
<% } %>
<%@ include file="../includes/admin_footer.jsp" %>
