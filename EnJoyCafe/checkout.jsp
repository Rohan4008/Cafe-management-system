<%-- webapp/checkout.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="includes/connection.jsp" %>
<%
    if (session.getAttribute("custName") == null) {
        response.sendRedirect(cp + "/login.jsp?redirect=" + cp + "/checkout.jsp"); return;
    }
    /* Show any error passed via session from place-order.jsp */
    String orderErr = (String) session.getAttribute("orderErr");
    if (orderErr != null) session.removeAttribute("orderErr");
%>
<% request.setAttribute("pageTitle","Checkout"); %>
<%@ include file="includes/header.jsp" %>
<meta name="contextPath" content="<%= cp %>">

<section style="background:var(--cream2);padding:60px 0;min-height:80vh;">
  <div class="container" style="max-width:920px;">
    <h2 style="margin-bottom:26px;"><i class="fas fa-receipt" style="color:var(--copper);margin-right:8px;"></i>Checkout</h2>

    <% if (orderErr != null) { %>
    <div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> <%= orderErr %></div>
    <% } %>

    <div style="display:grid;grid-template-columns:1fr 360px;gap:24px;align-items:start;">

      <!-- Left column -->
      <div>
        <!-- Delivery -->
        <div class="card" style="margin-bottom:18px;">
          <div class="card-body">
            <h3 style="font-size:1rem;margin-bottom:18px;"><i class="fas fa-map-marker-alt" style="color:var(--copper);"></i> Delivery Address</h3>
            <div class="form-group">
              <label>Full Address *</label>
              <textarea id="delivAddr" class="form-control" rows="3" placeholder="Flat, Building, Street, Area, City…" required></textarea>
            </div>
            <div class="form-group" style="margin-bottom:0;">
              <label>Special Instructions</label>
              <input type="text" id="orderNotes" class="form-control" placeholder="e.g. Leave at gate, extra napkins…">
            </div>
          </div>
        </div>

        <!-- Payment -->
        <div class="card">
          <div class="card-body">
            <h3 style="font-size:1rem;margin-bottom:18px;"><i class="fas fa-credit-card" style="color:var(--copper);"></i> Payment Method</h3>
            <div style="display:flex;flex-direction:column;gap:10px;">
              <label class="pay-opt selected" id="optCard">
                <input type="radio" name="payMethod" value="CARD" checked style="display:none;">
                <span class="pay-icon">💳</span>
                <div><strong>Pay by Card</strong><br><span style="font-size:.8rem;color:var(--txt3);">Demo card payment (test mode)</span></div>
              </label>
              <label class="pay-opt" id="optCOD">
                <input type="radio" name="payMethod" value="COD" style="display:none;">
                <span class="pay-icon">💵</span>
                <div><strong>Cash on Delivery</strong><br><span style="font-size:.8rem;color:var(--txt3);">Pay when your order arrives</span></div>
              </label>
            </div>

            <!-- Dummy card fields -->
            <div id="cardFields" style="margin-top:18px;padding:18px;background:var(--cream);border-radius:10px;">
              <div class="form-row">
                <div class="form-group">
                  <label>Card Number</label>
                  <input type="text" id="cardNum" class="form-control" placeholder="4242 4242 4242 4242" maxlength="19">
                </div>
                <div class="form-group">
                  <label>Cardholder Name</label>
                  <input type="text" id="cardName" class="form-control" placeholder="Name on card">
                </div>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label>Expiry (MM/YY)</label>
                  <input type="text" id="cardExpiry" class="form-control" placeholder="MM/YY" maxlength="5">
                </div>
                <div class="form-group">
                  <label>CVV</label>
                  <input type="text" id="cardCvv" class="form-control" placeholder="123" maxlength="3">
                </div>
              </div>
              <div class="alert alert-info" style="font-size:.8rem;margin:0;padding:10px 14px;">
                <i class="fas fa-info-circle"></i> Demo mode — no real transaction occurs.
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Right: Order Summary -->
      <div>
        <div class="card" style="position:sticky;top:88px;">
          <div class="card-body">
            <h3 style="font-size:1rem;margin-bottom:18px;"><i class="fas fa-shopping-bag" style="color:var(--copper);"></i> Order Summary</h3>
            <div id="summaryItems"></div>
            <hr style="border-color:var(--cream2);margin:12px 0;">
            <div style="display:flex;justify-content:space-between;font-size:.88rem;color:var(--txt3);margin-bottom:6px;">
              <span>Subtotal</span><span id="sumSubtotal">₹0</span>
            </div>
            <div style="display:flex;justify-content:space-between;font-size:.88rem;color:var(--txt3);margin-bottom:6px;">
              <span>Delivery Fee</span><span id="sumDelivery">₹40</span>
            </div>
            <hr style="border-color:var(--cream2);margin:10px 0;">
            <div style="display:flex;justify-content:space-between;font-weight:700;font-size:1.1rem;">
              <span>Total</span><span id="sumTotal" style="color:var(--copper);">₹0</span>
            </div>
            <button id="placeBtn" class="btn btn-primary w100 btn-lg" style="margin-top:18px;">
              <i class="fas fa-check-circle"></i> Place Order
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- Hidden form to POST cart data to server -->
<form id="orderForm" method="post" action="<%= cp %>/place-order.jsp" style="display:none;">
  <input type="hidden" name="cartJson"   id="fCartJson">
  <input type="hidden" name="address"    id="fAddress">
  <input type="hidden" name="notes"      id="fNotes">
  <input type="hidden" name="payMethod"  id="fPayMethod">
</form>

<script>
$(function(){
    loadCart();
    if (!cart || cart.length === 0) {
        window.location.href = '<%= cp %>/menu.jsp'; return;
    }

    /* Render order summary */
    var DELIV = 40;
    var subtotal = 0;
    var html = '';
    $.each(cart, function(i, item){
        subtotal += item.price * item.qty;
        html += '<div style="display:flex;justify-content:space-between;font-size:.88rem;margin-bottom:7px;">'
              + '<span>' + $('<div>').text(item.name).html() + ' × ' + item.qty + '</span>'
              + '<span style="font-weight:700;">₹' + (item.price*item.qty).toFixed(0) + '</span></div>';
    });
    $('#summaryItems').html(html);
    $('#sumSubtotal').text('₹' + subtotal.toFixed(0));
    var grand = subtotal + DELIV;
    if (subtotal >= 499) { grand = subtotal; $('#sumDelivery').text('FREE 🎉').css('color','var(--success)'); }
    $('#sumTotal').text('₹' + grand.toFixed(0));

    /* Payment toggle */
    $('[name=payMethod]').on('change', function(){
        $('.pay-opt').removeClass('selected');
        $(this).closest('.pay-opt').addClass('selected');
        $(this).val() === 'CARD' ? $('#cardFields').slideDown(300) : $('#cardFields').slideUp(300);
    });
    $('#optCard, #optCOD').on('click', function(){
        $(this).find('input[type=radio]').prop('checked',true).trigger('change');
    });

    /* Place order */
    $('#placeBtn').on('click', function(){
        var addr = $('#delivAddr').val().trim();
        var pm   = $('[name=payMethod]:checked').val();
        if (!addr) { alert('Please enter a delivery address.'); $('#delivAddr').focus(); return; }
        if (pm === 'CARD') {
            var cn = $('#cardNum').val().replace(/\s/g,'');
            if (cn.length !== 16 || !$('#cardName').val().trim() || !$('#cardExpiry').val() || !$('#cardCvv').val()) {
                alert('Please fill all card details correctly.'); return;
            }
        }
        $('#fCartJson').val(JSON.stringify(cart));
        $('#fAddress').val(addr);
        $('#fNotes').val($('#orderNotes').val());
        $('#fPayMethod').val(pm);
        $(this).prop('disabled',true).html('<i class="fas fa-spinner fa-spin"></i> Placing…');
        $('#orderForm')[0].submit();
    });
});
</script>

<%@ include file="includes/footer.jsp" %>
