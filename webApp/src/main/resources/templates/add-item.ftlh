<#import "layout/main.ftlh" as layout>
<@layout.main pageTitle="Add New Item">

<div class="container my-5">
    <div class="row justify-content-center">
        <div class="col-md-7">
            <div class="d-flex align-items-center mb-4 gap-2">
                <a href="/products" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-left"></i>
                </a>
                <h4 class="fw-bold mb-0">Add New Item</h4>
            </div>

            <#if error??>
            <div class="alert alert-danger py-2">${error}</div>
            </#if>

            <div class="card shadow-sm">
                <div class="card-body p-4">
                    <form method="post" action="/items/new" enctype="multipart/form-data">

                        <div class="row g-3">
                            <div class="col-12">
                                <label class="form-label fw-semibold">Name <span class="text-danger">*</span></label>
                                <input type="text" name="name" class="form-control" required placeholder="Item name"/>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Type</label>
                                <input type="text" name="type" class="form-control" placeholder="e.g. Electronics"/>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Category</label>
                                <select name="category" class="form-select">
                                    <option value="">None</option>
                                    <#list categories as c>
                                    <option value="${c}">${c}</option>
                                    </#list>
                                </select>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Price <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text">$</span>
                                    <input type="number" name="price" class="form-control" min="0"
                                           step="0.01" required placeholder="0.00"/>
                                </div>
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-semibold">Quantity <span class="text-danger">*</span></label>
                                <input type="number" name="quantity" class="form-control" min="0" required placeholder="0"/>
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-semibold">Unit <span class="text-danger">*</span></label>
                                <select name="unit" class="form-select" required>
                                    <option value="">Select...</option>
                                    <#list units as u>
                                    <option value="${u}">${u}</option>
                                    </#list>
                                </select>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-semibold">Serial Number</label>
                                <input type="text" name="serialNumber" class="form-control" placeholder="Optional"/>
                            </div>

                            <#if providers??>
                            <div class="col-12">
                                <label class="form-label fw-semibold">Provider</label>
                                <select name="provider.id" class="form-select">
                                    <option value="">None</option>
                                    <#list providers as p>
                                    <option value="${p.id}">${p.name}</option>
                                    </#list>
                                </select>
                            </div>
                            </#if>

                            <#-- 9.1: per-method pricing -->
                            <div class="col-12">
                                <label class="form-label fw-semibold">
                                    <i class="bi bi-tags me-1"></i>Prices by Shipping Method
                                </label>
                                <div class="border rounded p-3 bg-light">
                                    <div class="text-muted small mb-2">Set a specific price per delivery method. Leave blank to use the base price above.</div>
                                    <div id="priceRows"></div>
                                    <button type="button" class="btn btn-outline-secondary btn-sm mt-1"
                                            onclick="addPriceRow()">
                                        <i class="bi bi-plus-circle me-1"></i>Add Price
                                    </button>
                                </div>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-semibold">Photos</label>
                                <input type="file" name="photos" class="form-control"
                                       multiple accept="image/*"/>
                                <div class="form-text">You can select multiple images (JPG, PNG, WebP).</div>
                            </div>
                        </div>

                        <div class="d-flex gap-2 mt-4">
                            <button type="submit" class="btn btn-dark px-4">
                                <i class="bi bi-plus-circle me-1"></i>Add Item
                            </button>
                            <a href="/products" class="btn btn-outline-secondary px-4">Cancel</a>
                        </div>

                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
const shippingMethods = [<#list shippingMethods as sm>"${sm}"<#sep>, </#sep></#list>];
function addPriceRow() {
    const options = shippingMethods.map(m => `<option value="${'$'}{m}">${'$'}{m}</option>`).join('');
    const row = document.createElement('div');
    row.className = 'row g-2 mb-2 price-row';
    row.innerHTML = `
        <div class="col-md-3"><select name="priceMethod" class="form-select form-select-sm">${'$'}{options}</select></div>
        <div class="col-md-3"><div class="input-group input-group-sm"><span class="input-group-text">₪</span><input type="text" name="priceAmount" class="form-control" placeholder="Amount"/></div></div>
        <div class="col-md-5"><input type="text" name="priceDeliveryTime" class="form-control form-control-sm" placeholder="e.g. Express – 24h"/></div>
        <div class="col-md-1"><button type="button" class="btn btn-outline-danger btn-sm w-100" onclick="this.closest('.price-row').remove()"><i class="bi bi-trash"></i></button></div>
    `;
    document.getElementById('priceRows').appendChild(row);
}
</script>

</@layout.main>
