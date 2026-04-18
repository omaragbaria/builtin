<#import "layout/main.ftlh" as layout>
<@layout.main pageTitle="Cart">

<div class="container my-5">
    <h2 class="fw-bold mb-4"><i class="bi bi-cart3 me-2"></i>Your Cart</h2>

    <#if cart?? && cart?has_content>
    <div class="row g-4">

        <!-- Cart items grouped by shipping time -->
        <div class="col-lg-8">

            <#list groupedCart?keys as shippingGroup>
            <div class="card shadow-sm mb-3">
                <div class="card-header bg-light d-flex align-items-center gap-2">
                    <#if shippingGroup == "Immediate">
                        <i class="bi bi-lightning-fill text-warning"></i>
                        <strong>Immediate Delivery</strong>
                        <span class="badge bg-warning text-dark ms-1">Within 24h</span>
                    <#elseif shippingGroup == "Fast">
                        <i class="bi bi-truck text-primary"></i>
                        <strong>Fast Delivery</strong>
                        <span class="badge bg-primary ms-1">2–5 business days</span>
                    <#else>
                        <i class="bi bi-box-seam text-secondary"></i>
                        <strong>Standard Delivery</strong>
                        <span class="badge bg-secondary ms-1">6–10 business days</span>
                    </#if>
                </div>
                <div class="card-body p-0">
                    <#list groupedCart[shippingGroup] as cartItem>
                    <div class="d-flex align-items-center gap-3 p-3 border-bottom">
                        <div class="bg-light rounded d-flex align-items-center justify-content-center" style="width:70px;height:70px;">
                            <i class="bi bi-box-seam fs-3 text-secondary"></i>
                        </div>
                        <div class="flex-grow-1">
                            <h6 class="mb-0 fw-bold">${cartItem.name}</h6>
                            <small class="text-muted"><i class="bi bi-shop me-1"></i>${cartItem.providerName!""}</small>
                            <div class="text-muted small">$${cartItem.price} / ${cartItem.unit!"unit"}</div>
                        </div>
                        <form action="/cart/update/${cartItem.itemId}" method="post" class="d-flex align-items-center gap-2">
                            <input type="number" name="quantity" value="${cartItem.quantity}" min="0"
                                   class="form-control form-control-sm" style="width:70px;"
                                   onchange="this.form.submit()"/>
                        </form>
                        <div class="fw-bold" style="min-width:70px;">$${cartItem.subtotal}</div>
                        <form action="/cart/remove/${cartItem.itemId}" method="post">
                            <button type="submit" class="btn btn-outline-danger btn-sm">
                                <i class="bi bi-trash"></i>
                            </button>
                        </form>
                    </div>
                    </#list>
                </div>
            </div>
            </#list>

        </div>

        <!-- Order summary + shipping selection -->
        <div class="col-lg-4">
            <div class="card shadow-sm">
                <div class="card-body">
                    <h5 class="fw-bold mb-3">Order Summary</h5>
                    <hr/>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="text-muted">Items (${cart?size})</span>
                        <span>$${total}</span>
                    </div>

                    <!-- Shipping method selection -->
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Shipping Method</label>

                        <div class="form-check border rounded p-2 mb-2 shipping-option" id="opt-immediate">
                            <input class="form-check-input" type="radio" name="shippingMethod"
                                   id="shipping-immediate" value="IMMEDIATE">
                            <label class="form-check-label w-100" for="shipping-immediate">
                                <i class="bi bi-lightning-fill text-warning me-1"></i>
                                <strong>Immediate</strong>
                                <div class="text-muted small">Within 24 hours</div>
                            </label>
                        </div>

                        <div class="form-check border rounded p-2 mb-2 shipping-option" id="opt-fast">
                            <input class="form-check-input" type="radio" name="shippingMethod"
                                   id="shipping-fast" value="FAST" checked>
                            <label class="form-check-label w-100" for="shipping-fast">
                                <i class="bi bi-truck text-primary me-1"></i>
                                <strong>Fast</strong>
                                <div class="text-muted small">2–5 business days</div>
                            </label>
                        </div>

                        <div class="form-check border rounded p-2 mb-2 shipping-option" id="opt-standard">
                            <input class="form-check-input" type="radio" name="shippingMethod"
                                   id="shipping-standard" value="STANDARD">
                            <label class="form-check-label w-100" for="shipping-standard">
                                <i class="bi bi-box-seam text-secondary me-1"></i>
                                <strong>Standard</strong>
                                <div class="text-muted small">6–10 business days</div>
                            </label>
                        </div>
                    </div>

                    <hr/>
                    <div class="d-flex justify-content-between fw-bold fs-5 mb-4">
                        <span>Total</span>
                        <span>$${total}</span>
                    </div>
                    <button class="btn btn-warning w-100 btn-lg fw-bold" onclick="placeOrder()">
                        <i class="bi bi-bag-check me-2"></i>Place Order
                    </button>
                    <a href="/products" class="btn btn-outline-secondary w-100 mt-2">
                        <i class="bi bi-arrow-left me-1"></i>Continue Shopping
                    </a>
                </div>
            </div>
        </div>

    </div>
    <#else>
    <div class="text-center py-5">
        <i class="bi bi-cart-x fs-1 text-muted"></i>
        <h4 class="mt-3 text-muted">Your cart is empty</h4>
        <a href="/products" class="btn btn-dark mt-3">
            <i class="bi bi-arrow-left me-1"></i>Start Shopping
        </a>
    </div>
    </#if>
</div>

<script>
document.querySelectorAll('input[name="shippingMethod"]').forEach(radio => {
    radio.addEventListener('change', function() {
        document.querySelectorAll('.shipping-option').forEach(el => el.classList.remove('border-primary', 'bg-light'));
        this.closest('.shipping-option').classList.add('border-primary', 'bg-light');
    });
});
// Highlight default selected
const checked = document.querySelector('input[name="shippingMethod"]:checked');
if (checked) checked.closest('.shipping-option').classList.add('border-primary', 'bg-light');

function placeOrder() {
    const method = document.querySelector('input[name="shippingMethod"]:checked');
    if (!method) { alert('Please select a shipping method.'); return; }
    window.location.href = '/cart/checkout?shippingMethod=' + method.value;
}
</script>

</@layout.main>
