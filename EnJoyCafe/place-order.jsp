<%-- webapp/place-order.jsp  —  processes checkout POST --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="includes/connection.jsp" %>
<%
    if (session.getAttribute("custName") == null) {
        response.sendRedirect(cp + "/login.jsp"); return;
    }
    if (!"POST".equalsIgnoreCase(request.getMethod())) {
        response.sendRedirect(cp + "/menu.jsp"); return;
    }

    int    custId    = (Integer) session.getAttribute("custId");
    String cartJson  = request.getParameter("cartJson");
    String address   = request.getParameter("address");
    String notes     = request.getParameter("notes");
    String payMethod = "COD".equals(request.getParameter("payMethod")) ? "COD" : "CARD";
    String payStatus = "CARD".equals(payMethod) ? "PAID" : "PENDING";

    String err = null;
    int    newOrderId = 0;

    if (cartJson == null || cartJson.trim().isEmpty() || address == null || address.trim().isEmpty()) {
        err = "Invalid order data.";
    } else {
        /* ── Manual JSON array parse ──
           Format: [{"id":1,"name":"Espresso","price":80.0,"qty":2}, ...]
        */
        List<int[]>    pidQty  = new ArrayList<>();   // {productId, qty}
        List<Double>   prices  = new ArrayList<>();

        try {
            String j = cartJson.trim();
            if (j.startsWith("[")) j = j.substring(1);
            if (j.endsWith("]"))   j = j.substring(0, j.length()-1);
            String[] items = j.split("\\},\\s*\\{");
            for (String item : items) {
                item = item.replace("{","").replace("}","");
                Map<String,String> f = new HashMap<>();
                for (String pair : item.split(",")) {
                    String[] kv = pair.split(":",2);
                    if (kv.length==2) f.put(kv[0].trim().replace("\"",""), kv[1].trim().replace("\"",""));
                }
                int pid = 0; int qty = 1;
                try { pid = Integer.parseInt(f.getOrDefault("id","0")); } catch(Exception e){}
                try { qty = Integer.parseInt(f.getOrDefault("qty","1")); } catch(Exception e){}
                if (pid > 0 && qty > 0) pidQty.add(new int[]{pid, qty});
            }
        } catch (Exception ex) { err = "Could not read cart: " + ex.getMessage(); }

        if (err == null && pidQty.isEmpty()) err = "Cart is empty.";

        if (err == null) {
            Connection conn = null;
            try {
                conn = getConn();
                conn.setAutoCommit(false);

                /* Verify products & fetch prices from DB (never trust client prices) */
                double subtotal = 0;
                for (int[] pq : pidQty) {
                    PreparedStatement psp = conn.prepareStatement(
                        "SELECT price FROM products WHERE id=? AND is_available=1");
                    psp.setInt(1, pq[0]);
                    ResultSet rsp = psp.executeQuery();
                    if (!rsp.next()) {
                        conn.rollback();
                        err = "Product #" + pq[0] + " is no longer available.";
                        rsp.close(); psp.close(); break;
                    }
                    double pr = rsp.getDouble("price");
                    prices.add(pr);
                    subtotal += pr * pq[1];
                    rsp.close(); psp.close();
                }

                if (err == null) {
                    double delivFee = subtotal >= 499 ? 0.0 : 40.0;
                    double total    = subtotal + delivFee;

                    /* Insert order */
                    PreparedStatement io = conn.prepareStatement(
                        "INSERT INTO orders (customer_id,total_amount,payment_method,payment_status,delivery_address,notes) VALUES (?,?,?,?,?,?)",
                        Statement.RETURN_GENERATED_KEYS);
                    io.setInt(1, custId);      io.setDouble(2, total);
                    io.setString(3, payMethod);io.setString(4, payStatus);
                    io.setString(5, address.trim());
                    io.setString(6, notes!=null?notes.trim():"");
                    io.executeUpdate();
                    ResultSet gk = io.getGeneratedKeys(); gk.next();
                    newOrderId = gk.getInt(1);
                    gk.close(); io.close();

                    /* Insert order items */
                    for (int i = 0; i < pidQty.size(); i++) {
                        double upr = prices.get(i);
                        PreparedStatement oi = conn.prepareStatement(
                            "INSERT INTO order_items (order_id,product_id,quantity,unit_price,subtotal) VALUES (?,?,?,?,?)");
                        oi.setInt(1,newOrderId); oi.setInt(2,pidQty.get(i)[0]);
                        oi.setInt(3,pidQty.get(i)[1]); oi.setDouble(4,upr);
                        oi.setDouble(5, upr * pidQty.get(i)[1]);
                        oi.executeUpdate(); oi.close();
                    }
                    conn.commit();
                }
            } catch (Exception ex) {
                if (conn!=null) try{conn.rollback();}catch(Exception e2){}
                err = "Order failed: " + ex.getMessage();
            } finally {
                if (conn!=null) try{conn.setAutoCommit(true);conn.close();}catch(Exception e){}
            }
        }
    }

    if (err != null) {
        session.setAttribute("orderErr", err);
        response.sendRedirect(cp + "/checkout.jsp"); return;
    }
    response.sendRedirect(cp + "/order-success.jsp?oid=" + newOrderId);
%>
