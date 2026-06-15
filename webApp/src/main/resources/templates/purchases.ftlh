<#import "layout/main.ftlh" as layout>
<@layout.main pageTitle="${springMacroRequestContext.getMessage('purchases.title')}">

<#-- status -> bootstrap color -->
<#function statusColor s>
  <#if s == "PENDING_APPROVAL"><#return "warning">
  <#elseif s == "PROCESSING"><#return "info">
  <#elseif s == "DELIVERY"><#return "primary">
  <#elseif s == "COMPLETE"><#return "success">
  <#elseif s == "CANCELED"><#return "danger">
  <#else><#return "secondary">
  </#if>
</#function>

<div class="container my-5">
  <div class="row justify-content-center">
    <div class="col-lg-8">

      <h2 class="fw-bold mb-1"><i class="bi bi-bag me-2"></i>${springMacroRequestContext.getMessage('purchases.title')}</h2>
      <p class="text-muted mb-4">${springMacroRequestContext.getMessage('purchases.subtitle')}</p>

      <#if !deals?? || deals?size == 0>
      <div class="alert alert-light border text-center py-5">
        <i class="bi bi-bag fs-1 text-muted d-block mb-2"></i>
        ${springMacroRequestContext.getMessage('purchases.empty')}
        <div class="mt-3">
          <a href="/products" class="btn btn-warning btn-sm">
            <i class="bi bi-grid me-1"></i>${springMacroRequestContext.getMessage('nav.products')}
          </a>
        </div>
      </div>
      <#else>
      <div class="list-group shadow-sm">
        <#list deals as deal>
        <a href="/deliveries/track/${deal.id?c}" class="list-group-item list-group-item-action">
          <div class="d-flex w-100 justify-content-between align-items-center">
            <div>
              <h6 class="mb-1 fw-bold">#${deal.id?c}</h6>
              <small class="text-muted">
                <#if deal.dealDate??>${deal.dealDate?replace("T", " ")?keep_before(".")}</#if>
                <#if deal.shippingMethod??> · <i class="bi bi-box-seam"></i> ${deal.shippingMethod}</#if>
              </small>
            </div>
            <div class="text-end">
              <div class="fw-bold text-warning mb-1">₪${deal.totalPrice?string("0.00")}</div>
              <span class="badge bg-${statusColor(deal.status)}">
                ${springMacroRequestContext.getMessage('purchases.status.' + deal.status)}
              </span>
            </div>
          </div>
        </a>
        </#list>
      </div>
      </#if>

    </div>
  </div>
</div>

</@layout.main>
