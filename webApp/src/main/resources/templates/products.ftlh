<#import "layout/main.ftlh" as layout>
<@layout.main pageTitle="Products">

<div class="container my-5">
    <#if success??>
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="bi bi-check-circle me-1"></i>${success}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    </#if>
    <#if error??>
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="bi bi-exclamation-circle me-1"></i>${error}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    </#if>
    <div class="row g-4">

        <!-- Sidebar filters -->
        <div class="col-lg-3">
            <div class="card shadow-sm sticky-top" style="top: 80px;">
                <div class="card-body">
                    <h5 class="fw-bold mb-3"><i class="bi bi-funnel me-2"></i>Filters</h5>

                    <form method="get" action="/products" id="filterForm">
                        <input type="hidden" name="view" value="${view!'card'}">

                        <!-- Price Range -->
                        <h6 class="text-muted text-uppercase fw-semibold mb-2">Price Range</h6>
                        <div class="mb-1">
                            <label class="form-label small text-muted">
                                ₪<span id="minVal">${(minPrice??)?then(minPrice, 0)}</span>
                                &nbsp;–&nbsp;
                                ₪<span id="maxVal">${(maxPrice??)?then(maxPrice, globalMax)}</span>
                            </label>
                        </div>
                        <div class="mb-1">
                            <label class="form-label small">Min</label>
                            <input type="range" class="form-range" id="minSlider" name="minPrice"
                                   min="0" max="${globalMax}" step="10"
                                   value="${(minPrice??)?then(minPrice, 0)}"
                                   oninput="updateRange()">
                        </div>
                        <div class="mb-3">
                            <label class="form-label small">Max</label>
                            <input type="range" class="form-range" id="maxSlider" name="maxPrice"
                                   min="0" max="${globalMax}" step="10"
                                   value="${(maxPrice??)?then(maxPrice, globalMax)}"
                                   oninput="updateRange()">
                        </div>

                        <hr/>

                        <!-- Category -->
                        <#if categories?? && categories?has_content>
                        <h6 class="text-muted text-uppercase fw-semibold mb-2">Category</h6>
                        <div class="list-group list-group-flush mb-3" style="max-height:260px;overflow-y:auto;">
                            <label class="list-group-item list-group-item-action d-flex align-items-center gap-2 py-2">
                                <input class="form-check-input" type="radio" name="category" value=""
                                       <#if !selectedCategory?? || selectedCategory == "">checked</#if>
                                       onchange="this.form.submit()">
                                <span>All Categories</span>
                            </label>
                            <#list categories as cat>
                            <label class="list-group-item list-group-item-action d-flex align-items-center gap-2 py-2">
                                <input class="form-check-input" type="radio" name="category" value="${cat}"
                                       <#if selectedCategory?? && selectedCategory == cat>checked</#if>
                                       onchange="this.form.submit()">
                                <span>${cat}</span>
                            </label>
                            </#list>
                        </div>
                        </#if>

                        <button type="submit" class="btn btn-dark w-100 btn-sm">
                            <i class="bi bi-search me-1"></i>Apply Filters
                        </button>
                        <a href="/products" class="btn btn-outline-secondary w-100 btn-sm mt-2">
                            <i class="bi bi-x-circle me-1"></i>Clear
                        </a>
                    </form>
                </div>
            </div>
        </div>

        <!-- Product area -->
        <div class="col-lg-9">
            <!-- Toolbar -->
            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
                <h4 class="fw-bold mb-0">
                    <#if selectedCategory??>${selectedCategory}<#else>All Products</#if>
                    <small class="text-muted fs-6 ms-2">(${items?size} items)</small>
                </h4>
                <div class="d-flex align-items-center gap-2">
                    <#if currentUser?? && currentUser.canAddItems()>
                    <a href="/items/new" class="btn btn-dark btn-sm">
                        <i class="bi bi-plus-circle me-1"></i>Add Item
                    </a>
                    </#if>
                    <!-- View toggle -->
                    <div class="btn-group" role="group">
                        <a href="?<#if selectedCategory??>category=${selectedCategory}&</#if><#if minPrice??>minPrice=${minPrice}&</#if><#if maxPrice??>maxPrice=${maxPrice}&</#if>view=card"
                           class="btn btn-sm <#if view == 'card'>btn-dark<#else>btn-outline-dark</#if>">
                            <i class="bi bi-grid-3x3-gap"></i>
                        </a>
                        <a href="?<#if selectedCategory??>category=${selectedCategory}&</#if><#if minPrice??>minPrice=${minPrice}&</#if><#if maxPrice??>maxPrice=${maxPrice}&</#if>view=list"
                           class="btn btn-sm <#if view == 'list'>btn-dark<#else>btn-outline-dark</#if>">
                            <i class="bi bi-list-ul"></i>
                        </a>
                    </div>
                </div>
            </div>

            <#if items?? && items?has_content>

            <#-- CARD VIEW -->
            <#if view == 'card'>
            <div class="row g-4">
                <#list items as item>
                <div class="col-6 col-md-4">
                    <div class="card h-100 shadow-sm product-card">
                        <#if item.photos?? && item.photos?has_content>
                        <img src="/photos/${item.photos[0].fileName}" class="card-img-top"
                             alt="${item.name}" style="height:180px;object-fit:cover;">
                        <#else>
                        <div class="card-img-top product-img-placeholder d-flex align-items-center justify-content-center bg-light">
                            <i class="bi bi-box-seam fs-1 text-secondary"></i>
                        </div>
                        </#if>
                        <div class="card-body d-flex flex-column">
                            <#if item.category??><small class="text-muted text-uppercase fw-semibold">${item.category}</small></#if>
                            <h6 class="card-title mt-1 mb-auto">${item.name}</h6>
                            <#if item.type??><small class="text-muted mt-1" style="font-size:0.75rem">${item.type}</small></#if>
                            <#if item.provider??><small class="text-muted mt-2"><i class="bi bi-shop me-1"></i>${item.provider.name}</small></#if>
                            <div class="mt-2 d-flex justify-content-between align-items-center">
                                <span class="fw-bold fs-5">₪${item.price}</span>
                                <small class="text-muted">${item.unit!"UNIT"}</small>
                            </div>
                        </div>
                        <div class="card-footer bg-white border-top-0 pb-3">
                            <a href="/products/${item.id?c}" class="btn btn-dark btn-sm w-100">View Details</a>
                        </div>
                    </div>
                </div>
                </#list>
            </div>

            <#-- LIST VIEW -->
            <#else>
            <div class="d-flex flex-column gap-3">
                <#list items as item>
                <div class="card shadow-sm product-card">
                    <div class="card-body d-flex align-items-center gap-3">
                        <div class="flex-shrink-0 bg-light rounded d-flex align-items-center justify-content-center"
                             style="width:72px;height:72px;">
                            <#if item.photos?? && item.photos?has_content>
                            <img src="/photos/${item.photos[0].fileName}" alt="${item.name}"
                                 style="width:72px;height:72px;object-fit:cover;border-radius:6px;">
                            <#else>
                            <i class="bi bi-box-seam fs-2 text-secondary"></i>
                            </#if>
                        </div>
                        <div class="flex-grow-1 min-width-0">
                            <#if item.serialNumber??><small class="text-muted">מק"ט ${item.serialNumber}</small></#if>
                            <h6 class="mb-1 fw-semibold">${item.name}</h6>
                            <#if item.type??><small class="text-muted">${item.type}</small></#if>
                            <#if item.provider??><div><small class="text-muted"><i class="bi bi-shop me-1"></i>${item.provider.name}</small></div></#if>
                        </div>
                        <div class="text-end flex-shrink-0">
                            <div class="fw-bold fs-5 text-dark">₪${item.price}</div>
                            <small class="text-muted d-block">${item.unit!"UNIT"}</small>
                            <a href="/products/${item.id?c}" class="btn btn-dark btn-sm mt-2">View</a>
                        </div>
                    </div>
                </div>
                </#list>
            </div>
            </#if>

            <#else>
            <div class="text-center py-5">
                <i class="bi bi-search fs-1 text-muted"></i>
                <p class="mt-3 text-muted">No products found.</p>
                <a href="/products" class="btn btn-dark">Browse All</a>
            </div>
            </#if>
        </div>

    </div>
</div>

<script>
function updateRange() {
    const min = document.getElementById('minSlider').value;
    const max = document.getElementById('maxSlider').value;
    document.getElementById('minVal').textContent = min;
    document.getElementById('maxVal').textContent = max;
}
</script>

</@layout.main>
