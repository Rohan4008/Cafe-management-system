/* ================================================================
   cart.js  —  EnJoyCafe shopping cart
   Stored in localStorage key: ec_cart
   ================================================================ */

var cart = [];

function loadCart() {
  try { cart = JSON.parse(localStorage.getItem('ec_cart')) || []; }
  catch(e) { cart = []; }
}

function saveCart() {
  localStorage.setItem('ec_cart', JSON.stringify(cart));
}

function cartTotal() {
  return cart.reduce(function(s,i){ return s + i.price * i.qty; }, 0);
}

function cartCount() {
  return cart.reduce(function(s,i){ return s + i.qty; }, 0);
}

function updateBadge() {
  var n = cartCount();
  var $b = $('#cartBadge');
  $b.text(n).toggle(n > 0);
}

function renderCart() {
  var $el = $('#cartItems');
  if (cart.length === 0) {
    $el.html('<div class="cart-empty"><i class="fas fa-shopping-bag"></i><p>Your cart is empty</p></div>');
    $('#cartTotal').text('₹0');
    return;
  }
  var html = '';
  $.each(cart, function(idx, item) {
    html += '<div class="cart-item" data-idx="' + idx + '">'
      + '<div class="cart-item-info">'
      + '<h5>' + $('<div>').text(item.name).html() + '</h5>'
      + '<p>₹' + item.price.toFixed(0) + ' × ' + item.qty
      + ' = ₹' + (item.price * item.qty).toFixed(0) + '</p>'
      + '</div>'
      + '<div class="qty-ctrl">'
      + '<button class="cqd">−</button>'
      + '<span>' + item.qty + '</span>'
      + '<button class="cqi">+</button>'
      + '</div>'
      + '<button class="cart-item-remove cqr" title="Remove">'
      + '<i class="fas fa-times"></i></button>'
      + '</div>';
  });
  $el.html(html);
  $('#cartTotal').text('₹' + cartTotal().toFixed(0));
}

function openCart() {
  renderCart();
  $('#cartOverlay,#cartSidebar').addClass('open');
}

function closeCart() {
  $('#cartOverlay,#cartSidebar').removeClass('open');
}

function addToCart(id, name, price, qty) {
  qty = qty || 1;
  var existing = null;
  $.each(cart, function(i, item) { if (item.id === id) { existing = item; return false; } });
  if (existing) { existing.qty += qty; }
  else { cart.push({ id: id, name: name, price: parseFloat(price), qty: qty }); }
  saveCart();
  renderCart();
  updateBadge();
  openCart();
}

function goCheckout() {
  if (cart.length === 0) { alert('Your cart is empty!'); return; }
  var cp = $('meta[name=contextPath]').attr('content') || '';
  window.location.href = cp + '/checkout.jsp';
}

function clearCart() {
  cart = [];
  saveCart();
  updateBadge();
}

/* ── Cart item qty / remove controls ── */
$(document).on('click', '.cqd', function() {
  var idx = $(this).closest('.cart-item').data('idx');
  if (cart[idx].qty > 1) cart[idx].qty--;
  else cart.splice(idx, 1);
  saveCart(); renderCart(); updateBadge();
});
$(document).on('click', '.cqi', function() {
  var idx = $(this).closest('.cart-item').data('idx');
  cart[idx].qty++;
  saveCart(); renderCart(); updateBadge();
});
$(document).on('click', '.cqr', function() {
  var idx = $(this).closest('.cart-item').data('idx');
  cart.splice(idx, 1);
  saveCart(); renderCart(); updateBadge();
});

/* ── Product page qty buttons ── */
$(document).on('click', '.qty-dec', function() {
  var $s = $(this).siblings('.qty-val');
  var v = parseInt($s.text()); if (v > 1) $s.text(v - 1);
});
$(document).on('click', '.qty-inc', function() {
  var $s = $(this).siblings('.qty-val');
  $s.text(parseInt($s.text()) + 1);
});

/* ── Add to cart button ── */
$(document).on('click', '.btn-add', function() {
  var $btn = $(this);
  var id    = parseInt($btn.data('id'));
  var name  = $btn.data('name');
  var price = parseFloat($btn.data('price'));
  var $qv   = $btn.closest('.prod-actions').find('.qty-val');
  var qty   = $qv.length ? parseInt($qv.text()) : 1;
  addToCart(id, name, price, qty);
  if ($qv.length) $qv.text('1');
});

/* Init */
$(function() {
  loadCart();
  updateBadge();
});
