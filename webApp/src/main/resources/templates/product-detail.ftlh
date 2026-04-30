<#import "layout/main.ftlh" as layout>
<@layout.main pageTitle="${item.name}">

<div class="container my-5">

    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/" class="text-decoration-none">${springMacroRequestContext.getMessage('common.home')}</a></li>
            <li class="breadcrumb-item"><a href="/products" class="text-decoration-none">${springMacroRequestContext.getMessage('common.products')}</a></li>
            <#if item.category??><li class="breadcrumb-item"><a href="/products?category=${item.category}" class="text-decoration-none">${item.category}</a></li></#if>
            <li class="breadcrumb-item active">${item.name}</li>
        </ol>
    </nav>

    <div class="row g-5">
        <div class="col-md-5">
            <#if item.photos?? && item.photos?has_content>
                <#if item.photos?size == 1>
                <div class="rounded shadow-sm overflow-hidden bg-light">
                    <img src="/photos/${item.photos[0].fileName}" alt="${item.name}"
                         class="w-100" style="max-height:420px;object-fit:contain;">
                </div>
                <#else>
                <div id="photoCarousel" class="carousel slide rounded shadow-sm overflow-hidden" data-bs-ride="carousel">
                    <div class="carousel-indicators">
                        <#list item.photos as photo>
                        <button type="button" data-bs-target="#photoCarousel"
                                data-bs-slide-to="${photo?index}"
                                class="<#if photo?is_first>active</#if>"></button>
                        </#list>
                    </div>
                    <div class="carousel-inner bg-light">
                        <#list item.photos as photo>
                        <div class="carousel-item <#if photo?is_first>active</#if>">
                            <img src="/photos/${photo.fileName}" class="d-block w-100"
                                 alt="${item.name} photo ${photo?index + 1}"
                                 style="max-height:420px;object-fit:contain;">
                        </div>
                        </#list>
                    </div>
                    <button class="carousel-control-prev" type="button" data-bs-target="#photoCarousel" data-bs-slide="prev">
                        <span class="carousel-control-prev-icon"></span>
                    </button>
                    <button class="carousel-control-next" type="button" data-bs-target="#photoCarousel" data-bs-slide="next">
                        <span class="carousel-control-next-icon"></span>
                    </button>
                </div>
                </#if>
            <#else>
            <div class="product-detail-img d-flex align-items-center justify-content-center bg-light rounded shadow-sm">
                <i class="bi bi-box-seam text-secondary" style="font-size: 8rem;"></i>
            </div>
            </#if>
        </div>

        <div class="col-md-7">
            <#if item.category??><span class="badge bg-warning text-dark mb-2">${item.category}</span></#if>
            <h1 class="fw-bold">${item.name}</h1>

            <#if item.provider??>
            <a href="/products/provider/${item.provider.id?c}" class="text-decoration-none text-muted mb-3 d-block">
                <i class="bi bi-shop me-1"></i>${item.provider.name}
                <#if item.provider.location??> &mdash; ${item.provider.location}</#if>
            </a>
            </#if>

            <hr/>

            <div class="d-flex align-items-end gap-3 mb-3">
                <span class="display-6 fw-bold">₪${item.price}</span>
                <span class="text-muted mb-2">${springMacroRequestContext.getMessage('product.per')} ${item.unit!"unit"}</span>
            </div>

            <#if item.quantity?? && item.quantity gt 0>
            <p class="text-success fw-semibold"><i class="bi bi-check-circle-fill me-1"></i>${springMacroRequestContext.getMessage('common.in_stock')} &mdash; ${item.quantity} ${item.unit!"unit"}(s)</p>
            <#else>
            <p class="text-danger fw-semibold"><i class="bi bi-x-circle-fill me-1"></i>${springMacroRequestContext.getMessage('common.out_of_stock')}</p>
            </#if>

            <ul class="list-unstyled mb-4">
                <#if item.type??><li><span class="text-muted">${springMacroRequestContext.getMessage('product.type')}:</span> <strong>${item.type}</strong></li></#if>
                <#if item.serialNumber??><li><span class="text-muted">${springMacroRequestContext.getMessage('product.serial')}:</span> <strong>${item.serialNumber}</strong></li></#if>
            </ul>

            <#if item.quantity?? && item.quantity gt 0>
            <form action="/cart/add/${item.id?c}" method="post" class="d-flex gap-2">
                <input type="number" name="quantity" value="1" min="1" max="${item.quantity}"
                       class="form-control w-25" />
                <button type="submit" class="btn btn-warning btn-lg flex-grow-1">
                    <i class="bi bi-cart-plus me-2"></i>${springMacroRequestContext.getMessage('product.add_to_cart')}
                </button>
            </form>
            </#if>
            <#if currentUser?? && currentUser.canEdit(item)>
            <a href="/items/${item.id?c}/edit" class="btn btn-outline-secondary mt-3">
                <i class="bi bi-pencil me-1"></i>${springMacroRequestContext.getMessage('product.edit')}
            </a>
            </#if>
        </div>
    </div>

    <#if providerItems?? && providerItems?has_content>
    <section class="mt-5">
        <h4 class="fw-bold mb-4">${springMacroRequestContext.getMessage('product.more_from_store')}</h4>
        <div class="row g-4">
            <#list providerItems as related>
            <div class="col-6 col-md-3">
                <div class="card h-100 shadow-sm product-card">
                    <#if related.photos?? && related.photos?has_content>
                    <img src="/photos/${related.photos[0].fileName}" class="card-img-top"
                         alt="${related.name}" style="height:140px;object-fit:cover;">
                    <#else>
                    <div class="card-img-top product-img-placeholder d-flex align-items-center justify-content-center bg-light">
                        <i class="bi bi-box-seam fs-2 text-secondary"></i>
                    </div>
                    </#if>
                    <div class="card-body">
                        <h6 class="card-title">${related.name}</h6>
                        <span class="fw-bold">₪${related.price}</span>
                    </div>
                    <div class="card-footer bg-white border-top-0 pb-3">
                        <a href="/products/${related.id?c}" class="btn btn-outline-dark btn-sm w-100">${springMacroRequestContext.getMessage('common.view')}</a>
                    </div>
                </div>
            </div>
            </#list>
        </div>
    </section>
    </#if>

</div>

</@layout.main>
