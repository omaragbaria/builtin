<#import "layout/main.ftlh" as layout>
<@layout.main pageTitle="Materials Calculator">

<div class="container my-5">
    <div class="row justify-content-center">
        <div class="col-lg-10">

            <!-- Header -->
            <div class="text-center mb-4">
                <i class="bi bi-building fs-1 text-warning"></i>
                <h2 class="fw-bold mt-2">Construction Materials Calculator</h2>
                <p class="text-muted">Enter your structure dimensions and get an instant materials estimate.</p>
            </div>

            <!-- Input form -->
            <div class="card shadow-sm mb-4">
                <div class="card-body p-4">
                    <form method="post" action="/calculator" id="calcForm">

                        <!-- Structure type -->
                        <div class="mb-4">
                            <label class="form-label fw-semibold">Structure Type</label>
                            <div class="d-flex gap-3">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="structureType"
                                           id="roofSlab" value="ROOF_SLAB"
                                           onchange="toggleFields()"
                                           ${(!request?? || request.structureType == "ROOF_SLAB")?then("checked", "")}>
                                    <label class="form-check-label fw-semibold" for="roofSlab">
                                        <i class="bi bi-house-door me-1 text-warning"></i>Roof / Floor Slab
                                    </label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="structureType"
                                           id="wall" value="WALL"
                                           onchange="toggleFields()"
                                           ${(request?? && request.structureType == "WALL")?then("checked", "")}>
                                    <label class="form-check-label fw-semibold" for="wall">
                                        <i class="bi bi-bricks me-1 text-warning"></i>Wall
                                    </label>
                                </div>
                            </div>
                        </div>

                        <!-- Dimensions -->
                        <div class="row g-3">
                            <div class="col-md-3">
                                <label class="form-label fw-semibold">Length (m)</label>
                                <input type="number" name="length" step="0.1" min="0.1"
                                       class="form-control"
                                       value="${request??then(request.length?string['0.##'], '')}"
                                       placeholder="e.g. 8" required/>
                            </div>

                            <!-- Width — shown for roof slab -->
                            <div class="col-md-3" id="widthField">
                                <label class="form-label fw-semibold">Width (m)</label>
                                <input type="number" name="width" step="0.1" min="0.1"
                                       class="form-control"
                                       value="${request??then(request.width?string['0.##'], '')}"
                                       placeholder="e.g. 6"/>
                            </div>

                            <!-- Height — shown for wall -->
                            <div class="col-md-3" id="heightField" style="display:none;">
                                <label class="form-label fw-semibold">Height (m)</label>
                                <input type="number" name="height" step="0.1" min="0.1"
                                       class="form-control"
                                       value="${request??then(request.height?string['0.##'], '')}"
                                       placeholder="e.g. 3"/>
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-semibold">Thickness (m)</label>
                                <input type="number" name="thickness" step="0.01" min="0.05"
                                       class="form-control"
                                       value="${request??then(request.thickness?string['0.##'], '0.2')}"
                                       placeholder="e.g. 0.20" required/>
                                <div class="form-text">Slab: 0.15–0.25 m | Wall: 0.20 m</div>
                            </div>
                        </div>

                        <div class="mt-4">
                            <button type="submit" class="btn btn-warning fw-bold px-4">
                                <i class="bi bi-calculator me-2"></i>Calculate Materials
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <#if response??>

            <!-- Structure summary -->
            <div class="alert alert-secondary d-flex align-items-center gap-2 mb-4">
                <i class="bi bi-info-circle-fill text-warning fs-5"></i>
                <span class="fw-semibold">${response.structureSummary}</span>
            </div>

            <!-- Materials list -->
            <#list response.materials as line>
            <div class="card shadow-sm mb-3">
                <div class="card-header bg-light d-flex justify-content-between align-items-center">
                    <span class="fw-bold">
                        <i class="bi bi-hammer me-2"></i>${line.materialType}
                    </span>
                    <span class="badge bg-dark fs-6">
                        ${line.requiredQuantity?string["0.##"]} ${line.unit}
                    </span>
                </div>

                <#if line.matchedItems?has_content>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0 align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Product</th>
                                    <th>Provider</th>
                                    <th>Price</th>
                                    <th>In Stock</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                <#list line.matchedItems as item>
                                <tr class="${item.lowestPrice?then('table-warning', '')}">
                                    <td>
                                        ${item.name}
                                        <#if item.lowestPrice>
                                            <span class="badge bg-success ms-1">Best Price</span>
                                        </#if>
                                    </td>
                                    <td><small class="text-muted">${item.providerName!""}</small></td>
                                    <td class="fw-bold">₪${item.price} / ${item.unit}</td>
                                    <td><small>${item.availableQuantity} units</small></td>
                                    <td>
                                        <form action="/cart/add/${item.itemId}" method="post">
                                            <input type="hidden" name="quantity" value="1"/>
                                            <button type="submit" class="btn btn-sm btn-outline-dark">
                                                <i class="bi bi-cart-plus me-1"></i>Add
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                                </#list>
                            </tbody>
                        </table>
                    </div>
                </div>
                <#else>
                <div class="card-body text-muted small">
                    <i class="bi bi-exclamation-circle me-1"></i>No matching products found in store.
                </div>
                </#if>
            </div>
            </#list>

            <!-- Add all best-price items -->
            <div class="card shadow-sm border-warning">
                <div class="card-body d-flex align-items-center justify-content-between flex-wrap gap-3">
                    <div>
                        <h6 class="fw-bold mb-1">
                            <i class="bi bi-bag-check me-2 text-warning"></i>Add all best-price items to cart
                        </h6>
                        <small class="text-muted">Adds the lowest-priced match for each material.</small>
                    </div>
                    <form method="post" action="/calculator/add-all">
                        <#list response.materials as line>
                            <#if line.matchedItems?has_content>
                                <input type="hidden" name="itemIds" value="${line.matchedItems[0].itemId}"/>
                            </#if>
                        </#list>
                        <button type="submit" class="btn btn-warning fw-bold">
                            <i class="bi bi-cart-check me-2"></i>Add All to Cart
                        </button>
                    </form>
                </div>
            </div>

            </#if>

        </div>
    </div>
</div>

<script>
function toggleFields() {
    const isWall = document.getElementById('wall').checked;
    document.getElementById('widthField').style.display  = isWall ? 'none'  : '';
    document.getElementById('heightField').style.display = isWall ? ''      : 'none';
}
// Run on page load to restore correct state after form submit
document.addEventListener('DOMContentLoaded', toggleFields);
</script>

</@layout.main>
