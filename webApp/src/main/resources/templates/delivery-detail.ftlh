<#import "layout/main.ftlh" as layout>
<@layout.main pageTitle="Delivery #${delivery.id}">
<#assign showMap = (delivery.stage == "IN_DELIVERY" && delivery.driverLatitude?? && delivery.driverLongitude??)>
<#if showMap>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.css"
      integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin="anonymous"/>
</#if>

<#-- ── Helpers ──────────────────────────────────────────────────────── -->
<#assign stages      = ["PENDING_ASSIGNMENT","ACCEPTED","IN_DELIVERY","ARRIVED"]>
<#assign stageLabels = [
  springMacroRequestContext.getMessage('tracking.stage.pending'),
  springMacroRequestContext.getMessage('stage.accepted'),
  springMacroRequestContext.getMessage('tracking.stage.in_delivery'),
  springMacroRequestContext.getMessage('stage.delivered')
]>
<#assign stageDescs  = [
  springMacroRequestContext.getMessage('tracking.stage.pending.desc'),
  springMacroRequestContext.getMessage('tracking.stage.accepted.desc'),
  springMacroRequestContext.getMessage('tracking.stage.in_delivery.desc'),
  springMacroRequestContext.getMessage('tracking.stage.arrived.desc')
]>
<#assign stageIcons  = ["bi-hourglass-split","bi-person-check-fill","bi-truck","bi-house-check-fill"]>
<#assign stageColors = ["warning","info","primary","success"]>

<#assign currentIdx = 0>
<#list stages as s><#if s == delivery.stage><#assign currentIdx = s?index></#if></#list>

<#-- Role flags -->
<#assign isAdmin    = (currentUser?? && currentUser.userType == "DELIVERY")>
<#assign isSuperAdmin = (currentUser?? && currentUser.userType == "SUPER_ADMIN")>
<#assign isOwner    = (isAdmin && delivery.deliveryAccountId?? && currentUser.deliveryAccountId??
                       && delivery.deliveryAccountId == currentUser.deliveryAccountId)>
<#assign canControl = (isOwner && delivery.stage != "ARRIVED")>

<div class="container my-5">

  <!-- ── Navigation ─────────────────────────────────────────────────── -->
  <div class="d-flex align-items-center gap-3 mb-4">
    <button class="btn btn-outline-secondary btn-sm" onclick="history.back()">
      <i class="bi bi-arrow-left me-1"></i>${springMacroRequestContext.getMessage('common.back')}
    </button>
    <nav aria-label="breadcrumb" class="flex-grow-1">
      <ol class="breadcrumb mb-0">
        <li class="breadcrumb-item"><a href="/">${springMacroRequestContext.getMessage('common.home')}</a></li>
        <#if currentUser?? && (currentUser.userType == "DELIVERY" || currentUser.userType == "SUPER_ADMIN")>
        <li class="breadcrumb-item"><a href="/deliveries">${springMacroRequestContext.getMessage('nav.deliveries')}</a></li>
        <#else>
        <li class="breadcrumb-item"><a href="/deliveries/track">${springMacroRequestContext.getMessage('nav.track_order')}</a></li>
        </#if>
        <li class="breadcrumb-item active">${springMacroRequestContext.getMessage('common.order')} #${delivery.dealId}</li>
      </ol>
    </nav>
    <#if delivery.stage != "ARRIVED">
    <span class="text-muted small"><i class="bi bi-arrow-clockwise me-1"></i>${springMacroRequestContext.getMessage('detail.refreshing_in')} <span id="countdown">30</span>s</span>
    </#if>
  </div>

  <div class="row g-4">

    <!-- ── LEFT COLUMN ──────────────────────────────────────────────── -->
    <div class="col-lg-8">

      <!-- Order header -->
      <div class="card shadow-sm mb-4">
        <div class="card-body">
          <div class="d-flex justify-content-between align-items-start flex-wrap gap-3">
            <div>
              <h3 class="fw-bold mb-1">${springMacroRequestContext.getMessage('common.order')} <span class="text-primary">#${delivery.dealId}</span></h3>
              <div class="d-flex gap-2 flex-wrap">
                <span class="badge bg-secondary">${delivery.dealShippingMethod!""}</span>
                <span class="badge
                  <#if delivery.dealStatus == "COMPLETE">bg-success
                  <#elseif delivery.dealStatus == "DELIVERY">bg-primary
                  <#elseif delivery.dealStatus == "PROCESSING">bg-info text-dark
                  <#else>bg-warning text-dark</#if>">
                  ${delivery.dealStatus!""}
                </span>
              </div>
            </div>
            <div class="text-end">
              <div class="text-muted small">${springMacroRequestContext.getMessage('detail.order_total')}</div>
              <div class="fw-bold fs-4">₪${delivery.dealTotal!""}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Stage progress (5.3) -->
      <div class="card shadow-sm mb-4">
        <div class="card-header">
          <h6 class="fw-bold mb-0 text-uppercase small text-muted">
            <i class="bi bi-signpost-split me-2"></i>${springMacroRequestContext.getMessage('tracking.progress')}
          </h6>
        </div>
        <div class="card-body py-4 px-4">
          <div class="position-relative mb-4">
            <!-- Background track -->
            <div class="position-absolute" style="top:18px;left:36px;right:36px;height:3px;background:#dee2e6;z-index:0;"></div>
            <!-- Filled track -->
            <div class="position-absolute" style="top:18px;left:36px;height:3px;background:#0d6efd;z-index:1;
                 width:calc(${currentIdx} * (100% - 72px) / 3);"></div>

            <div class="d-flex justify-content-between position-relative" style="z-index:2;">
              <#list stages as s>
              <#assign idx  = s?index>
              <#assign done = (idx < currentIdx)>
              <#assign curr = (idx == currentIdx)>
              <div class="d-flex flex-column align-items-center text-center" style="width:25%;">
                <div class="rounded-circle d-flex align-items-center justify-content-center mb-2 shadow-sm
                  <#if done>bg-success text-white<#elseif curr>bg-primary text-white<#else>bg-white text-muted border border-2</#if>"
                  style="width:40px;height:40px;">
                  <#if done>
                    <i class="bi bi-check-lg"></i>
                  <#else>
                    <i class="bi ${stageIcons[idx]}"></i>
                  </#if>
                </div>
                <div class="fw-semibold small <#if done>text-success<#elseif curr>text-primary<#else>text-muted</#if>">
                  ${stageLabels[idx]}
                </div>
                <div class="text-muted" style="font-size:0.7rem;">${stageDescs[idx]}</div>
              </div>
              </#list>
            </div>
          </div>

          <!-- ETA banner -->
          <#if delivery.eta??>
          <div class="alert alert-primary d-flex align-items-center gap-3 mb-0 py-2">
            <i class="bi bi-clock-fill fs-5"></i>
            <div>
              <div class="fw-semibold">${springMacroRequestContext.getMessage('detail.estimated_arrival')}</div>
              <div>${delivery.eta?replace('T', ' ')?keep_before('.')}</div>
            </div>
          </div>
          <#else>
          <div class="alert alert-secondary d-flex align-items-center gap-2 mb-0 py-2">
            <i class="bi bi-clock"></i>
            <span>${springMacroRequestContext.getMessage('detail.eta_not_set')}</span>
          </div>
          </#if>
        </div>
      </div>

      <!-- Package contents (5.3) -->
      <div class="card shadow-sm mb-4">
        <div class="card-header d-flex justify-content-between align-items-center">
          <h6 class="fw-bold mb-0 text-uppercase small text-muted">
            <i class="bi bi-boxes me-2"></i>${springMacroRequestContext.getMessage('detail.package_contents')}
          </h6>
          <#if items?has_content>
          <span class="badge bg-secondary">${items?size} item<#if items?size != 1>s</#if></span>
          </#if>
        </div>
        <#if items?has_content>
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0">
            <thead class="table-light">
              <tr>
                <th>${springMacroRequestContext.getMessage('detail.item')}</th>
                <th class="text-center">${springMacroRequestContext.getMessage('detail.qty')}</th>
                <th class="text-end">${springMacroRequestContext.getMessage('detail.unit_price')}</th>
                <th class="text-end">${springMacroRequestContext.getMessage('detail.subtotal')}</th>
              </tr>
            </thead>
            <tbody>
              <#list items as item>
              <tr>
                <td>
                  <div class="fw-semibold">${item.name}</div>
                  <#if item.serialNumber?has_content>
                  <div class="text-muted small">${springMacroRequestContext.getMessage('detail.sku')} ${item.serialNumber}</div>
                  </#if>
                </td>
                <td class="text-center">
                  <span class="fw-semibold">${item.quantity!1}</span>
                  <span class="text-muted small ms-1">${item.unit!""}</span>
                </td>
                <td class="text-end">₪${item.price!""}</td>
                <td class="text-end fw-semibold">
                  <#if item.price?? && item.quantity??>
                  ₪${item.price * item.quantity}
                  <#else>—</#if>
                </td>
              </tr>
              </#list>
            </tbody>
            <tfoot class="table-light">
              <tr>
                <td colspan="3" class="text-end fw-bold">${springMacroRequestContext.getMessage('detail.items_total')}</td>
                <td class="text-end fw-bold">₪${delivery.dealTotal!""}</td>
              </tr>
            </tfoot>
          </table>
        </div>
        <#else>
        <div class="card-body text-center text-muted py-4">
          <i class="bi bi-box-seam fs-3"></i>
          <p class="mt-2 mb-0">${springMacroRequestContext.getMessage('detail.items_unavailable')}</p>
        </div>
        </#if>
      </div>

      <!-- Delivery account update controls (5.4) -->
      <#if canControl>
      <div class="card shadow-sm border-primary mb-4">
        <div class="card-header bg-primary bg-opacity-10">
          <h6 class="fw-bold mb-0 text-primary">
            <i class="bi bi-pencil-square me-2"></i>${springMacroRequestContext.getMessage('detail.update_delivery')}
          </h6>
        </div>
        <div class="card-body">
          <div class="row g-3">
            <!-- Stage update -->
            <div class="col-md-6">
              <label class="form-label fw-semibold">${springMacroRequestContext.getMessage('detail.delivery_stage')}</label>
              <form method="post" action="/deliveries/${delivery.id}/stage">
                <div class="input-group">
                  <select name="stage" class="form-select">
                    <option value="ACCEPTED"    <#if delivery.stage == "ACCEPTED">selected</#if>>
                      ✓ ${springMacroRequestContext.getMessage('stage.accepted')}
                    </option>
                    <option value="IN_DELIVERY" <#if delivery.stage == "IN_DELIVERY">selected</#if>>
                      🚚 ${springMacroRequestContext.getMessage('stage.in_delivery')}
                    </option>
                    <option value="ARRIVED">
                      🏠 ${springMacroRequestContext.getMessage('delivery.stage.arrived_option')}
                    </option>
                  </select>
                  <button type="submit" class="btn btn-primary">${springMacroRequestContext.getMessage('common.update')}</button>
                </div>
              </form>
            </div>
            <!-- ETA update -->
            <div class="col-md-6">
              <label class="form-label fw-semibold">${springMacroRequestContext.getMessage('detail.eta_label')}</label>
              <form method="post" action="/deliveries/${delivery.id}/eta">
                <div class="input-group">
                  <input type="datetime-local" name="eta" class="form-control"
                         <#if delivery.eta??>value="${delivery.eta?keep_before('.')}"</#if>/>
                  <button type="submit" class="btn btn-outline-primary">${springMacroRequestContext.getMessage('detail.set_eta')}</button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
      </#if>

      <#-- Arrived confirmation -->
      <#if delivery.stage == "ARRIVED" && isOwner>
      <div class="alert alert-success d-flex gap-2 align-items-center">
        <i class="bi bi-check-circle-fill fs-5"></i>
        <div><strong>${springMacroRequestContext.getMessage('detail.delivery_complete_strong')}</strong> ${springMacroRequestContext.getMessage('detail.delivery_complete')}</div>
      </div>
      </#if>

    </div>

    <!-- ── RIGHT COLUMN ─────────────────────────────────────────────── -->
    <div class="col-lg-4">

      <!-- Courier card -->
      <div class="card shadow-sm mb-3">
        <div class="card-header">
          <h6 class="fw-bold mb-0 text-uppercase small text-muted">
            <i class="bi bi-person-badge me-2"></i>${springMacroRequestContext.getMessage('detail.courier')}
          </h6>
        </div>
        <div class="card-body">
          <#if delivery.deliveryAccountName?has_content>
          <div class="d-flex align-items-center gap-3">
            <div class="rounded-circle bg-primary bg-opacity-10 d-flex align-items-center justify-content-center flex-shrink-0"
                 style="width:52px;height:52px;">
              <i class="bi bi-person-fill text-primary fs-4"></i>
            </div>
            <div>
              <div class="fw-semibold">${delivery.deliveryAccountName}</div>
              <div class="text-muted small">
                <#if delivery.vehicleType?has_content>
                <i class="bi bi-car-front me-1"></i>${delivery.vehicleType?replace("_"," ")?lower_case?cap_first}
                </#if>
              </div>
              <#if delivery.deliveryAccountType?has_content>
              <span class="badge bg-light text-dark border mt-1 text-capitalize">
                ${delivery.deliveryAccountType?lower_case}
              </span>
              </#if>
            </div>
          </div>
          <#else>
          <div class="text-center text-muted py-3">
            <i class="bi bi-hourglass-split fs-3 text-warning"></i>
            <p class="mt-2 mb-0 small">${springMacroRequestContext.getMessage('detail.awaiting_courier')}</p>
          </div>
          </#if>
        </div>
      </div>

      <!-- Customer info — admin only (5.2) -->
      <#if isSuperAdmin>
      <div class="card shadow-sm mb-3 border-danger border-opacity-25">
        <div class="card-header bg-danger bg-opacity-10">
          <h6 class="fw-bold mb-0 text-uppercase small text-muted">
            <i class="bi bi-person-lines-fill me-2"></i>${springMacroRequestContext.getMessage('detail.customer')}
          </h6>
        </div>
        <div class="card-body">
          <#if delivery.customerName?has_content>
          <div class="fw-semibold">${delivery.customerName}</div>
          <div class="text-muted small">
            <i class="bi bi-envelope me-1"></i>${delivery.customerEmail!"—"}
          </div>
          <#else>
          <span class="text-muted small">${springMacroRequestContext.getMessage('detail.no_customer')}</span>
          </#if>
        </div>
      </div>
      </#if>

      <!-- Live GPS map (6.3) -->
      <#if showMap>
      <div class="card shadow-sm mb-3 border-primary border-opacity-50">
        <div class="card-header bg-primary bg-opacity-10">
          <h6 class="fw-bold mb-0 text-uppercase small text-primary">
            <i class="bi bi-geo-alt-fill me-2"></i>${springMacroRequestContext.getMessage('tracking.live_location')}
          </h6>
        </div>
        <div class="card-body p-0">
          <div id="trackingMap" style="height:260px;border-radius:0 0 .375rem .375rem;"></div>
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

      <!-- Delivery metadata -->
      <div class="card shadow-sm mb-3">
        <div class="card-header">
          <h6 class="fw-bold mb-0 text-uppercase small text-muted">
            <i class="bi bi-info-circle me-2"></i>${springMacroRequestContext.getMessage('common.details')}
          </h6>
        </div>
        <ul class="list-group list-group-flush">
          <li class="list-group-item d-flex justify-content-between py-2">
            <span class="text-muted small">${springMacroRequestContext.getMessage('detail.delivery_id')}</span>
            <span class="fw-semibold small">#${delivery.id}</span>
          </li>
          <li class="list-group-item d-flex justify-content-between py-2">
            <span class="text-muted small">${springMacroRequestContext.getMessage('detail.shipping')}</span>
            <span class="badge bg-secondary">${delivery.dealShippingMethod!""}</span>
          </li>
          <#if delivery.assignedAt??>
          <li class="list-group-item d-flex justify-content-between py-2">
            <span class="text-muted small">${springMacroRequestContext.getMessage('detail.accepted_at')}</span>
            <span class="small">${delivery.assignedAt?replace('T', ' ')?keep_before('.')}</span>
          </li>
          </#if>
          <li class="list-group-item d-flex justify-content-between py-2">
            <span class="text-muted small">${springMacroRequestContext.getMessage('detail.created')}</span>
            <span class="small">${delivery.createdAt?keep_before('T')}</span>
          </li>
        </ul>
      </div>

      <!-- Admin quick-accept if unassigned -->
      <#if isSuperAdmin && delivery.stage == "PENDING_ASSIGNMENT">
      <div class="alert alert-warning small">
        <i class="bi bi-exclamation-triangle me-1"></i>
        ${springMacroRequestContext.getMessage('detail.no_courier_warning')}
      </div>
      </#if>

    </div>
  </div>
</div>

<#if showMap>
<script src="https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/leaflet.js"
        integrity="sha256-20cZj7jPjVBz6KZbVZS6njO7ZbsHHxu0fItPZ9TZO6c=" crossorigin="anonymous"></script>
</#if>
<script>
<#if delivery.stage != "ARRIVED">
let secs = 30;
const el = document.getElementById('countdown');
setInterval(() => {
    if (el) el.textContent = --secs;
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
        .bindPopup('<strong>${delivery.deliveryAccountName!""}</strong><br>Last known position')
        .openPopup();
})();
</#if>
</script>

</@layout.main>
