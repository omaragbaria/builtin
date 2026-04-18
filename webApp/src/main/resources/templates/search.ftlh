<#import "layout/main.ftlh" as layout>
<@layout.main pageTitle="Search Results">

<div class="container my-5">
    <h4 class="fw-bold mb-1">
        <#if query?? && query?has_content>
            Results for "<span class="text-warning">${query}</span>"
        <#else>
            All Products
        </#if>
    </h4>
    <p class="text-muted mb-4">${items?size} item(s) found</p>

    <#if items?? && items?has_content>
    <div class="row g-4">
        <#list items as item>
        <div class="col-6 col-md-4 col-lg-3">
            <div class="card h-100 shadow-sm product-card">
                <div class="card-img-top product-img-placeholder d-flex align-items-center justify-content-center bg-light">
                    <i class="bi bi-box-seam fs-1 text-secondary"></i>
                </div>
                <div class="card-body d-flex flex-column">
                    <#if item.category??><small class="text-muted text-uppercase fw-semibold">${item.category}</small></#if>
                    <h6 class="card-title mt-1 mb-auto">${item.name}</h6>
                    <#if item.provider??><small class="text-muted mt-2"><i class="bi bi-shop me-1"></i>${item.provider.name}</small></#if>
                    <div class="mt-2 fw-bold fs-5">₪${item.price}</div>
                </div>
                <div class="card-footer bg-white border-top-0 pb-3">
                    <a href="/products/${item.id?c}" class="btn btn-dark btn-sm w-100">View Details</a>
                </div>
            </div>
        </div>
        </#list>
    </div>
    <#else>
    <div class="text-center py-5">
        <i class="bi bi-search fs-1 text-muted"></i>
        <p class="mt-3 text-muted fs-5">No results found for "<strong>${query}</strong>"</p>
        <a href="/products" class="btn btn-dark">Browse All Products</a>
    </div>
    </#if>
</div>

</@layout.main>
