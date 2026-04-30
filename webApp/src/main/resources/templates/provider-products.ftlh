<#import "layout/main.ftlh" as layout>
<@layout.main pageTitle="${provider.name}">

<div class="container my-5">

    <div class="card shadow-sm mb-5 border-0 bg-dark text-white">
        <div class="card-body p-4">
            <div class="d-flex align-items-center gap-4">
                <div class="bg-warning rounded-circle d-flex align-items-center justify-content-center" style="width:80px;height:80px;">
                    <i class="bi bi-shop fs-2 text-dark"></i>
                </div>
                <div>
                    <h2 class="fw-bold mb-1">${provider.name}</h2>
                    <#if provider.location??><p class="mb-1"><i class="bi bi-geo-alt me-1 text-warning"></i>${provider.location}</p></#if>
                    <#if provider.phone??><p class="mb-1"><i class="bi bi-telephone me-1 text-warning"></i>${provider.phone}</p></#if>
                    <#if provider.email??><p class="mb-0"><i class="bi bi-envelope me-1 text-warning"></i>${provider.email}</p></#if>
                </div>
            </div>
        </div>
    </div>

    <h4 class="fw-bold mb-4">${springMacroRequestContext.getMessage('common.products')} <small class="text-muted fs-6">(${items?size})</small></h4>

    <#if items?? && items?has_content>
    <div class="row g-4">
        <#list items as item>
        <div class="col-6 col-md-4 col-lg-3">
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
                    <div class="mt-2 d-flex justify-content-between align-items-center">
                        <span class="fw-bold fs-5">₪${item.price}</span>
                        <small class="text-muted">${item.quantity!0} ${item.unit!"unit"}(s)</small>
                    </div>
                </div>
                <div class="card-footer bg-white border-top-0 pb-3">
                    <a href="/products/${item.id?c}" class="btn btn-dark btn-sm w-100">${springMacroRequestContext.getMessage('common.view_details')}</a>
                </div>
            </div>
        </div>
        </#list>
    </div>
    <#else>
    <div class="text-center py-5">
        <i class="bi bi-box-seam fs-1 text-muted"></i>
        <p class="mt-3 text-muted">${springMacroRequestContext.getMessage('common.no_products')}</p>
    </div>
    </#if>

</div>

</@layout.main>
