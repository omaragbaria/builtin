<#import "layout/main.ftlh" as layout>
<@layout.main pageTitle="Home">

<!-- Hero -->
<section class="hero-section text-white text-center py-5">
    <div class="container py-4">
        <h1 class="display-4 fw-bold mb-3">Welcome to BuiltIn Store</h1>
        <p class="lead mb-4">Discover quality products from trusted providers near you.</p>
        <form class="d-flex justify-content-center" action="/search" method="get">
            <div class="input-group w-50">
                <input class="form-control form-control-lg" type="search" name="query" placeholder="What are you looking for?" />
                <button class="btn btn-warning btn-lg" type="submit">
                    <i class="bi bi-search me-1"></i>Search
                </button>
            </div>
        </form>
    </div>
</section>

<!-- Providers -->
<#if providers?? && providers?has_content>
<section class="container my-5">
    <h2 class="fw-bold mb-4"><i class="bi bi-shop me-2 text-warning"></i>Our Stores</h2>
    <div class="row g-3">
        <#list providers as provider>
        <div class="col-6 col-md-4 col-lg-3">
            <a href="/products/provider/${provider.id?c}" class="text-decoration-none">
                <div class="card h-100 text-center shadow-sm provider-card">
                    <div class="card-body py-4">
                        <div class="provider-icon mb-3">
                            <i class="bi bi-shop fs-1 text-warning"></i>
                        </div>
                        <h6 class="card-title fw-bold">${provider.name}</h6>
                        <#if provider.location??>
                        <small class="text-muted"><i class="bi bi-geo-alt me-1"></i>${provider.location}</small>
                        </#if>
                    </div>
                </div>
            </a>
        </div>
        </#list>
    </div>
</section>
</#if>

<!-- Featured Products -->
<#if featuredItems?? && featuredItems?has_content>
<section class="container my-5">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="fw-bold mb-0"><i class="bi bi-star me-2 text-warning"></i>Featured Products</h2>
        <a href="/products" class="btn btn-outline-dark btn-sm">View All <i class="bi bi-arrow-right ms-1"></i></a>
    </div>
    <div class="row g-4">
        <#list featuredItems as item>
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
                    <#if item.category??>
                    <small class="text-muted text-uppercase fw-semibold">${item.category}</small>
                    </#if>
                    <h6 class="card-title mt-1 mb-auto">${item.name}</h6>
                    <div class="mt-3 d-flex justify-content-between align-items-center">
                        <span class="fw-bold text-dark fs-5">₪${item.price}</span>
                        <#if item.quantity?? && item.quantity gt 0>
                        <small class="text-success"><i class="bi bi-check-circle me-1"></i>In Stock</small>
                        <#else>
                        <small class="text-danger"><i class="bi bi-x-circle me-1"></i>Out of Stock</small>
                        </#if>
                    </div>
                </div>
                <div class="card-footer bg-white border-top-0 pb-3">
                    <a href="/products/${item.id?c}" class="btn btn-dark btn-sm w-100">View Details</a>
                </div>
            </div>
        </div>
        </#list>
    </div>
</section>
</#if>

</@layout.main>
