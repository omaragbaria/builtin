<#import "layout/main.ftlh" as layout>
<@layout.main pageTitle="${springMacroRequestContext.getMessage('tracking.title')}">
<#assign showMap = (delivery?? && delivery.stage == "IN_DELIVERY" && delivery.driverLatitude?? && delivery.driverLongitude??)>
<#if showMap>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.css"
      integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="anonymous"/>
</#if>

<div class="container my-5">
  <div class="row justify-content-center">
    <div class="col-lg-7">

      <h2 class="fw-bold mb-1"><i class="bi bi-search me-2"></i>${springMacroRequestContext.getMessage('tracking.title')}</h2>
      <p class="text-muted mb-4">${springMacroRequestContext.getMessage('tracking.subtitle')}</p>

      <!-- Search form -->
      <div class="card shadow-sm mb-4">
        <div class="card-body">
          <form method="get" action="/deliveries/track/0" id="trackForm" class="d-flex gap-2">
            <input type="number" id="dealIdInput" name="_dealId" class="form-control"
                   placeholder="${springMacroRequestContext.getMessage('tracking.order_placeholder')}"
                   <#if dealId??>value="${dealId}"</#if>
                   min="1" required/>
            <button type="submit" class="btn btn-dark text-nowrap">
              <i class="bi bi-search me-1"></i>${springMacroRequestContext.getMessage('tracking.track_button')}
            </button>
          </form>
        </div>
      </div>

      <#-- ── Not found ── -->
      <#if notFound??>
      <div class="alert alert-warning">
        <i class="bi bi-exclamation-triangle me-2"></i>
        ${springMacroRequestContext.getMessage('tracking.not_found.prefix')} <strong>#${dealId}</strong>. ${springMacroRequestContext.getMessage('tracking.not_found.suffix')}
      </div>
      </#if>

      <#-- ── Delivery found ── -->
      <#if delivery??>
      <#assign stages     = ["PENDING_ASSIGNMENT","ACCEPTED","IN_DELIVERY","ARRIVED"]>
      <#assign stageLabels = [
        springMacroRequestContext.getMessage('tracking.stage.pending'),
        springMacroRequestContext.getMessage('tracking.stage.accepted'),
        springMacroRequestContext.getMessage('tracking.stage.in_delivery'),
        springMacroRequestContext.getMessage('tracking.stage.arrived')
      ]>
      <#assign stageDescs  = [
        springMacroRequestContext.getMessage('tracking.stage.pending.desc'),
        springMacroRequestContext.getMessage('tracking.stage.accepted.desc'),
        springMacroRequestContext.getMessage('tracking.stage.in_delivery.desc'),
        springMacroRequestContext.getMessage('tracking.stage.arrived.desc')
      ]>
      <#assign stageIcons  = ["bi-hourglass-split","bi-person-check","bi-truck","bi-house-check-fill"]>
      <#assign currentIdx  = 0>
      <#list stages as s><#if s == delivery.stage><#assign currentIdx = s?index></#if></#list>

      <!-- Order summary card -->
      <div class="card shadow-sm mb-3">
        <div class="card-body">
          <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
            <div>
              <h5 class="fw-bold mb-1">${springMacroRequestContext.getMessage('common.order')} #${delivery.dealId}</h5>
              <div class="text-muted small">
                <span class="badge bg-secondary me-1">${delivery.dealShippingMethod!""}</span>
                ${springMacroRequestContext.getMessage('tracking.order_total')}: <strong>₪${delivery.dealTotal!""}</strong>
              </div>
            </div>
            <#if delivery.eta??>
            <div class="text-end">
              <div class="text-muted small">${springMacroRequestContext.getMessage('tracking.eta')}</div>
              <div class="fw-bold text-primary fs-5">
                <i class="bi bi-clock me-1"></i>${delivery.eta?string("EEE, dd MMM · HH:mm")}
              </div>
            </div>
            <#else>
            <div class="text-muted small fst-italic">${springMacroRequestContext.getMessage('tracking.eta_not_set')}</div>
            </#if>
          </div>
        </div>
      </div>

      <!-- Progress timeline -->
      <div class="card shadow-sm mb-3">
        <div class="card-body py-4">
          <h6 class="text-muted fw-semibold mb-4 text-uppercase small letter-spacing-1">${springMacroRequestContext.getMessage('tracking.progress')}</h6>
          <div class="position-relative">
            <!-- Connecting line -->
            <div class="position-absolute top-0 start-0 end-0" style="top:18px!important;height:3px;background:#dee2e6;z-index:0;margin:0 36px;"></div>
            <div class="position-absolute top-0 start-0" style="top:18px!important;height:3px;background:#0d6efd;z-index:1;margin-left:36px;
              width:calc(${currentIdx} * (100% - 72px) / 3);"></div>

            <div class="d-flex justify-content-between position-relative" style="z-index:2;">
              <#list stages as s>
              <#assign idx  = s?index>
              <#assign done = (idx < currentIdx)>
              <#assign curr = (idx == currentIdx)>
              <div class="d-flex flex-column align-items-center text-center" style="width:80px;">
                <div class="rounded-circle d-flex align-items-center justify-content-center mb-2
                  <#if done>bg-success text-white shadow-sm
                  <#elseif curr>bg-primary text-white shadow
                  <#else>bg-white text-muted border</#if>"
                  style="width:36px;height:36px;border-width:2px!important;">
                  <#if done>
                    <i class="bi bi-check-lg"></i>
                  <#else>
                    <i class="bi ${stageIcons[idx]} small"></i>
                  </#if>
                </div>
                <div class="fw-semibold small <#if done>text-success<#elseif curr>text-primary<#else>text-muted</#if>">
                  ${stageLabels[idx]}
                </div>
                <#if curr>
                <div class="text-muted" style="font-size:0.7rem;">${stageDescs[idx]}</div>
                </#if>
              </div>
              </#list>
            </div>
          </div>
        </div>
      </div>

      <!-- Live GPS map (6.3) -->
      <#if showMap>
      <div class="card shadow-sm mb-3 border-primary border-opacity-50">
        <div class="card-header bg-primary bg-opacity-10">
          <h6 class="fw-bold mb-0 text-uppercase small text-primary">
            <i class="bi bi-geo-alt-fill me-2"></i>${springMacroRequestContext.getMessage('tracking.live_location')}
          </h6>
        </div>
        <div class="card-body p-0">
          <div id="trackingMap" style="height:240px;border-radius:0 0 .375rem .375rem;"></div>
        </div>
        <div class="card-footer text-muted small py-1">
          <i class="bi bi-arrow-clockwise me-1"></i>${springMacroRequestContext.getMessage('tracking.updates_every')}
        </div>
      </div>
      <#elseif delivery.stage == "IN_DELIVERY">
      <div class="card shadow-sm mb-3 border-warning border-opacity-50">
        <div class="card-body text-muted small">
          <i class="bi bi-geo-alt me-2"></i>${springMacroRequestContext.getMessage('tracking.driver_pending')}
        </div>
      </div>
      </#if>

      <!-- Courier info -->
      <#if delivery.deliveryAccountName?has_content>
      <div class="card shadow-sm mb-3">
        <div class="card-body">
          <h6 class="fw-semibold mb-3"><i class="bi bi-person-badge me-2"></i>${springMacroRequestContext.getMessage('tracking.your_courier')}</h6>
          <div class="d-flex align-items-center gap-3">
            <div class="rounded-circle bg-primary bg-opacity-10 d-flex align-items-center justify-content-center" style="width:48px;height:48px;">
              <i class="bi bi-person-fill text-primary fs-5"></i>
            </div>
            <div>
              <div class="fw-semibold">${delivery.deliveryAccountName}</div>
              <div class="text-muted small">
                <#if delivery.vehicleType?has_content>
                <i class="bi bi-car-front me-1"></i>${delivery.vehicleType?replace("_"," ")?lower_case?cap_first}
                </#if>
                <#if delivery.deliveryAccountType?has_content>
                &nbsp;·&nbsp;<span class="text-capitalize">${delivery.deliveryAccountType?lower_case}</span>
                </#if>
              </div>
            </div>
          </div>
        </div>
      </div>
      <#else>
      <div class="card shadow-sm mb-3 border-warning">
        <div class="card-body text-muted">
          <i class="bi bi-hourglass-split me-2 text-warning"></i>
          ${springMacroRequestContext.getMessage('tracking.waiting_courier')}
        </div>
      </div>
      </#if>

      <!-- Link to full detail page -->
      <div class="mt-3">
        <a href="/deliveries/${delivery.id}" class="btn btn-primary w-100">
          <i class="bi bi-box-arrow-up-right me-2"></i>${springMacroRequestContext.getMessage('tracking.view_full')}
        </a>
      </div>

      <!-- Auto-refresh notice (4.4) -->
      <div class="d-flex align-items-center justify-content-between text-muted small mt-3">
        <span><i class="bi bi-arrow-clockwise me-1"></i>${springMacroRequestContext.getMessage('tracking.refresh_in')} <span id="trackCountdown">30</span>s</span>
        <span>${springMacroRequestContext.getMessage('tracking.last_updated')} <strong id="lastUpdated"></strong></span>
      </div>

      </#if><!-- /delivery found -->

    </div>
  </div>
</div>

<#if showMap>
<script src="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.js"
        integrity="sha256-20cZj7jPjVBz6KZbVZS6njO7ZbsHHxu0fItPZ9TZO6c=" crossorigin="anonymous"></script>
</#if>
<script>
// Redirect track form to the correct URL
document.getElementById('trackForm')?.addEventListener('submit', function(e) {
    e.preventDefault();
    const id = document.getElementById('dealIdInput').value;
    if (id) window.location.href = '/deliveries/track/' + id;
});

// Show last-updated time
const lastUpdatedEl = document.getElementById('lastUpdated');
if (lastUpdatedEl) {
    const now = new Date();
    lastUpdatedEl.textContent = now.toLocaleTimeString();
}

// Auto-refresh countdown (4.4) — only when viewing a delivery
<#if delivery??>
let secs = 30;
const cntEl = document.getElementById('trackCountdown');
setInterval(() => {
    secs--;
    if (cntEl) cntEl.textContent = secs;
    if (secs <= 0) location.reload();
}, 1000);
</#if>

<#if showMap>
(function () {
    const lat = ${delivery.driverLatitude?c};
    const lng = ${delivery.driverLongitude?c};
    const map = L.map('trackingMap').setView([lat, lng], 15);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
        maxZoom: 19
    }).addTo(map);
    L.marker([lat, lng])
        .addTo(map)
        .bindPopup('<strong>${springMacroRequestContext.getMessage('tracking.courier_on_way')}</strong>')
        .openPopup();
})();
</#if>
</script>

</@layout.main>
