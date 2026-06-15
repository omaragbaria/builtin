<#import "layout/main.ftlh" as layout>
<@layout.main pageTitle="Delivery Dashboard">

<#macro stageBadge stage>
  <#if stage == "PENDING_ASSIGNMENT"><span class="badge bg-warning text-dark">${springMacroRequestContext.getMessage('stage.pending')}</span>
  <#elseif stage == "ACCEPTED"><span class="badge bg-info text-dark">${springMacroRequestContext.getMessage('stage.accepted')}</span>
  <#elseif stage == "IN_DELIVERY"><span class="badge bg-primary">${springMacroRequestContext.getMessage('stage.in_delivery')}</span>
  <#elseif stage == "ARRIVED"><span class="badge bg-success">${springMacroRequestContext.getMessage('stage.arrived')}</span>
  <#else><span class="badge bg-secondary">${stage}</span>
  </#if>
</#macro>

<#macro stageTimeline stage>
<#assign stages = ["PENDING_ASSIGNMENT","ACCEPTED","IN_DELIVERY","ARRIVED"]>
<#assign labels = [
  springMacroRequestContext.getMessage('stage.pending'),
  springMacroRequestContext.getMessage('stage.accepted'),
  springMacroRequestContext.getMessage('stage.in_delivery'),
  springMacroRequestContext.getMessage('stage.arrived')
]>
<#assign icons  = ["bi-hourglass-split","bi-check-circle","bi-truck","bi-house-check"]>
<#assign currentIdx = 0>
<#list stages as s><#if s == stage><#assign currentIdx = s?index></#if></#list>
<div class="d-flex align-items-center gap-0 my-2">
  <#list stages as s>
  <#assign idx = s?index>
  <#assign done = (idx < currentIdx)>
  <#assign active = (idx == currentIdx)>
  <div class="d-flex flex-column align-items-center" style="min-width:70px;">
    <div class="rounded-circle d-flex align-items-center justify-content-center
      <#if done>bg-success text-white<#elseif active>bg-primary text-white<#else>bg-light text-muted border</#if>"
      style="width:36px;height:36px;">
      <i class="bi ${icons[idx]} small"></i>
    </div>
    <span class="text-center mt-1" style="font-size:0.7rem;
      <#if done>color:#198754<#elseif active>color:#0d6efd;font-weight:600<#else>color:#aaa</#if>">
      ${labels[idx]}
    </span>
  </div>
  <#if idx < 3>
  <div class="flex-grow-1 border-top mt-0 mb-3 mx-1
    <#if idx < currentIdx>border-success<#else>border-secondary</#if>"
    style="border-width:2px!important;margin-top:-16px!important;"></div>
  </#if>
  </#list>
</div>
</#macro>

<div class="container-fluid px-4 my-4">

  <!-- Header -->
  <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
    <div>
      <h2 class="fw-bold mb-0"><i class="bi bi-truck me-2"></i>${springMacroRequestContext.getMessage('delivery.title')}</h2>
      <p class="text-muted mb-0 small">
        <#if currentUser.userType == "DELIVERY">${springMacroRequestContext.getMessage('delivery.subtitle.driver')}<#else>${springMacroRequestContext.getMessage('delivery.subtitle.admin')}</#if>
      </p>
    </div>
    <div class="d-flex align-items-center gap-3">
      <span class="text-muted small"><i class="bi bi-arrow-clockwise me-1"></i>${springMacroRequestContext.getMessage('delivery.auto_refresh')} <span id="countdown">30</span>s</span>
      <a href="/deliveries/track" class="btn btn-outline-secondary btn-sm">
        <i class="bi bi-search me-1"></i>${springMacroRequestContext.getMessage('delivery.track_order')}
      </a>
    </div>
  </div>

  <#if message??>
  <div class="alert alert-success alert-dismissible fade show">
    <i class="bi bi-check-circle me-2"></i>${message}
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  </#if>
  <#if error??>
  <div class="alert alert-danger alert-dismissible fade show">
    <i class="bi bi-exclamation-circle me-2"></i>${error}
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  </#if>

  <!-- ═══════════════════════════════════════════════════════
       DELIVERY ACCOUNT VIEW  (4.3)
       ═══════════════════════════════════════════════════════ -->
  <#if currentUser.userType == "DELIVERY">

  <div class="row g-3 mb-4">
    <div class="col-6 col-md-3">
      <div class="card border-warning h-100 text-center py-3">
        <div class="fs-2 fw-bold text-warning">${pendingDeliveries?size}</div>
        <div class="text-muted small">${springMacroRequestContext.getMessage('delivery.awaiting_assignment')}</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card border-info h-100 text-center py-3">
        <#assign acceptedCount = 0>
        <#list myDeliveries as d><#if d.stage == "ACCEPTED"><#assign acceptedCount = acceptedCount + 1></#if></#list>
        <div class="fs-2 fw-bold text-info">${acceptedCount}</div>
        <div class="text-muted small">${springMacroRequestContext.getMessage('stage.accepted')}</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card border-primary h-100 text-center py-3">
        <#assign inDeliveryCount = 0>
        <#list myDeliveries as d><#if d.stage == "IN_DELIVERY"><#assign inDeliveryCount = inDeliveryCount + 1></#if></#list>
        <div class="fs-2 fw-bold text-primary">${inDeliveryCount}</div>
        <div class="text-muted small">${springMacroRequestContext.getMessage('stage.in_delivery')}</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card border-success h-100 text-center py-3">
        <#assign arrivedCount = 0>
        <#list myDeliveries as d><#if d.stage == "ARRIVED"><#assign arrivedCount = arrivedCount + 1></#if></#list>
        <div class="fs-2 fw-bold text-success">${arrivedCount}</div>
        <div class="text-muted small">${springMacroRequestContext.getMessage('stage.delivered')}</div>
      </div>
    </div>
  </div>

  <!-- Pending Packages -->
  <div class="card shadow-sm mb-4">
    <div class="card-header d-flex justify-content-between align-items-center">
      <h5 class="mb-0 fw-bold"><i class="bi bi-inbox text-warning me-2"></i>${springMacroRequestContext.getMessage('delivery.waiting_heading')}</h5>
      <span class="badge bg-warning text-dark">${pendingDeliveries?size}</span>
    </div>
    <#if pendingDeliveries?has_content>
    <div class="list-group list-group-flush">
      <#list pendingDeliveries as d>
      <div class="list-group-item p-3">
        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
          <div>
            <span class="fw-bold fs-5">#${d.dealId}</span>
            <span class="badge bg-secondary ms-2">${d.dealShippingMethod!""}</span>
            <div class="text-muted small mt-1">
              <i class="bi bi-currency-exchange me-1"></i>₪${d.dealTotal!""}
              &nbsp;·&nbsp;
              <i class="bi bi-calendar3 me-1"></i>${d.createdAt!?string}
            </div>
          </div>
          <div class="d-flex gap-2">
            <a href="/deliveries/${d.id}" class="btn btn-outline-secondary btn-sm">
              <i class="bi bi-eye me-1"></i>${springMacroRequestContext.getMessage('common.details')}
            </a>
            <form method="post" action="/deliveries/${d.id}/accept">
              <button type="submit" class="btn btn-success">
                <i class="bi bi-check-circle me-1"></i>${springMacroRequestContext.getMessage('delivery.accept_package')}
              </button>
            </form>
          </div>
        </div>
      </div>
      </#list>
    </div>
    <#else>
    <div class="card-body text-center py-5 text-muted">
      <i class="bi bi-inbox fs-1"></i>
      <p class="mt-2 mb-0">${springMacroRequestContext.getMessage('delivery.no_pending')}</p>
    </div>
    </#if>
  </div>

  <!-- My Active Deliveries -->
  <div class="card shadow-sm">
    <div class="card-header d-flex justify-content-between align-items-center">
      <h5 class="mb-0 fw-bold"><i class="bi bi-box-seam text-primary me-2"></i>${springMacroRequestContext.getMessage('delivery.my_deliveries')}</h5>
      <span class="badge bg-primary">${myDeliveries?size}</span>
    </div>
    <#if myDeliveries?has_content>
    <div class="list-group list-group-flush">
      <#list myDeliveries as d>
      <div class="list-group-item p-4">
        <!-- Header row -->
        <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-3">
          <div>
            <span class="fw-bold fs-5">${springMacroRequestContext.getMessage('common.order')} #${d.dealId}</span>
            <span class="ms-2"><@stageBadge d.stage!"" /></span>
            <#if d.customerName?has_content>
            <div class="text-muted small mt-1">
              <i class="bi bi-person me-1"></i>${d.customerName}
              <#if d.customerEmail?has_content>
              &nbsp;·&nbsp;<i class="bi bi-envelope me-1"></i>${d.customerEmail}
              </#if>
            </div>
            </#if>
            <div class="text-muted small">
              <i class="bi bi-currency-exchange me-1"></i>₪${d.dealTotal!""}
              &nbsp;·&nbsp;${d.dealShippingMethod!""}
            </div>
          </div>
          <#if d.eta??>
          <div class="text-end">
            <div class="text-muted small">${springMacroRequestContext.getMessage('delivery.col.eta')}</div>
            <div class="fw-semibold text-primary">
              <i class="bi bi-clock me-1"></i>${d.eta?replace('T', ' ')?keep_before('.')}
            </div>
          </div>
          </#if>
        </div>

        <!-- Stage timeline -->
        <@stageTimeline d.stage!"" />

        <!-- Detail link -->
        <div class="mt-2">
          <a href="/deliveries/${d.id}" class="btn btn-outline-primary btn-sm">
            <i class="bi bi-box-arrow-up-right me-1"></i>${springMacroRequestContext.getMessage('delivery.view_full')}
          </a>
        </div>

        <!-- Controls (hidden for ARRIVED) -->
        <#if d.stage != "ARRIVED">
        <div class="d-flex gap-2 flex-wrap mt-3 pt-3 border-top">
          <form method="post" action="/deliveries/${d.id}/stage" class="d-flex align-items-center gap-2">
            <label class="text-muted small mb-0">${springMacroRequestContext.getMessage('delivery.update_stage')}</label>
            <select name="stage" class="form-select form-select-sm" style="width:auto;" onchange="this.form.submit()">
              <option value="ACCEPTED"    <#if d.stage == "ACCEPTED">selected</#if>>${springMacroRequestContext.getMessage('stage.accepted')}</option>
              <option value="IN_DELIVERY" <#if d.stage == "IN_DELIVERY">selected</#if>>${springMacroRequestContext.getMessage('stage.in_delivery')}</option>
              <option value="ARRIVED">${springMacroRequestContext.getMessage('delivery.stage.arrived_option')}</option>
            </select>
          </form>
          <form method="post" action="/deliveries/${d.id}/eta" class="d-flex align-items-center gap-2">
            <label class="text-muted small mb-0">${springMacroRequestContext.getMessage('delivery.col.eta')}:</label>
            <input type="datetime-local" name="eta" class="form-control form-control-sm" style="width:200px;"
                   <#if d.eta??>value="${d.eta?keep_before('.')}"</#if>/>
            <button type="submit" class="btn btn-outline-secondary btn-sm">
              <i class="bi bi-clock-fill"></i> ${springMacroRequestContext.getMessage('delivery.set')}
            </button>
          </form>
        </div>
        <#else>
        <div class="mt-2 text-success small"><i class="bi bi-check-circle-fill me-1"></i>${springMacroRequestContext.getMessage('delivery.delivered_message')}</div>
        </#if>
      </div>
      </#list>
    </div>
    <#else>
    <div class="card-body text-center py-5 text-muted">
      <i class="bi bi-truck fs-1"></i>
      <p class="mt-2 mb-0">${springMacroRequestContext.getMessage('delivery.no_deliveries')}</p>
    </div>
    </#if>
  </div>


  <!-- ═══════════════════════════════════════════════════════
       ADMIN VIEW  (4.2)
       ═══════════════════════════════════════════════════════ -->
  <#elseif currentUser.userType == "SUPER_ADMIN">

  <!-- Stats row -->
  <div class="row g-3 mb-4">
    <div class="col-6 col-md-3">
      <div class="card border-warning h-100 text-center py-3">
        <div class="fs-2 fw-bold text-warning">${(stageCounts["PENDING_ASSIGNMENT"])!0}</div>
        <div class="text-muted small">${springMacroRequestContext.getMessage('stage.pending')}</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card border-info h-100 text-center py-3">
        <div class="fs-2 fw-bold text-info">${(stageCounts["ACCEPTED"])!0}</div>
        <div class="text-muted small">${springMacroRequestContext.getMessage('stage.accepted')}</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card border-primary h-100 text-center py-3">
        <div class="fs-2 fw-bold text-primary">${(stageCounts["IN_DELIVERY"])!0}</div>
        <div class="text-muted small">${springMacroRequestContext.getMessage('stage.in_delivery')}</div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card border-success h-100 text-center py-3">
        <div class="fs-2 fw-bold text-success">${(stageCounts["ARRIVED"])!0}</div>
        <div class="text-muted small">${springMacroRequestContext.getMessage('stage.arrived')}</div>
      </div>
    </div>
  </div>

  <!-- Filter tabs -->
  <ul class="nav nav-tabs mb-3" id="stageTabs">
    <li class="nav-item"><a class="nav-link active" href="#" data-filter="ALL">${springMacroRequestContext.getMessage('delivery.tab_all')} <span class="badge bg-secondary">${allDeliveries?size}</span></a></li>
    <li class="nav-item"><a class="nav-link" href="#" data-filter="PENDING_ASSIGNMENT">${springMacroRequestContext.getMessage('delivery.tab_pending')} <span class="badge bg-warning text-dark">${(stageCounts["PENDING_ASSIGNMENT"])!0}</span></a></li>
    <li class="nav-item"><a class="nav-link" href="#" data-filter="ACCEPTED">${springMacroRequestContext.getMessage('stage.accepted')} <span class="badge bg-info text-dark">${(stageCounts["ACCEPTED"])!0}</span></a></li>
    <li class="nav-item"><a class="nav-link" href="#" data-filter="IN_DELIVERY">${springMacroRequestContext.getMessage('stage.in_delivery')} <span class="badge bg-primary">${(stageCounts["IN_DELIVERY"])!0}</span></a></li>
    <li class="nav-item"><a class="nav-link" href="#" data-filter="ARRIVED">${springMacroRequestContext.getMessage('stage.arrived')} <span class="badge bg-success">${(stageCounts["ARRIVED"])!0}</span></a></li>
  </ul>

  <div class="card shadow-sm">
    <div class="card-body p-0">
      <#if allDeliveries?has_content>
      <div class="table-responsive">
        <table class="table table-hover align-middle mb-0" id="deliveriesTable">
          <thead class="table-light">
            <tr>
              <th>${springMacroRequestContext.getMessage('delivery.col.order')}</th>
              <th>${springMacroRequestContext.getMessage('delivery.col.customer')}</th>
              <th>${springMacroRequestContext.getMessage('delivery.col.stage')}</th>
              <th>${springMacroRequestContext.getMessage('delivery.col.courier')}</th>
              <th>${springMacroRequestContext.getMessage('delivery.col.vehicle')}</th>
              <th>${springMacroRequestContext.getMessage('delivery.col.eta')}</th>
              <th>${springMacroRequestContext.getMessage('delivery.col.total')}</th>
              <th>${springMacroRequestContext.getMessage('delivery.col.shipping')}</th>
              <th>${springMacroRequestContext.getMessage('delivery.col.track')}</th>
            </tr>
          </thead>
          <tbody>
            <#list allDeliveries as d>
            <tr data-stage="${d.stage!""}">
              <td><strong>#${d.dealId}</strong></td>
              <td>
                <#if d.customerName?has_content>
                <div class="fw-semibold">${d.customerName}</div>
                <div class="text-muted small">${d.customerEmail!""}</div>
                <#else><span class="text-muted">—</span></#if>
              </td>
              <td><@stageBadge d.stage!"" /></td>
              <td>
                <#if d.deliveryAccountName?has_content>
                <div>${d.deliveryAccountName}</div>
                <div class="text-muted small">${d.deliveryAccountType!""}</div>
                <#else><span class="text-muted text-nowrap"><i class="bi bi-hourglass-split me-1"></i>${springMacroRequestContext.getMessage('delivery.unassigned')}</span></#if>
              </td>
              <td>
                <#if d.vehicleType?has_content>
                <span class="badge bg-light text-dark border">
                  <i class="bi bi-car-front me-1"></i>${d.vehicleType?replace("_"," ")?lower_case?cap_first}
                </span>
                <#else>—</#if>
              </td>
              <td class="text-nowrap small">
                <#if d.eta??>${d.eta?replace('T', ' ')?keep_before('.')}<#else><span class="text-muted">—</span></#if>
              </td>
              <td class="fw-semibold">₪${d.dealTotal!""}</td>
              <td><span class="badge bg-light text-dark border">${d.dealShippingMethod!""}</span></td>
              <td>
                <a href="/deliveries/${d.id}" class="btn btn-outline-primary btn-sm" title="View details">
                  <i class="bi bi-eye"></i>
                </a>
              </td>
            </tr>
            </#list>
          </tbody>
        </table>
      </div>
      <#else>
      <div class="text-center py-5 text-muted">
        <i class="bi bi-inbox fs-1"></i>
        <p class="mt-2">${springMacroRequestContext.getMessage('delivery.no_deliveries_admin')}</p>
      </div>
      </#if>
    </div>
  </div>

  </#if>
</div>

<script>
// ── Auto-refresh countdown (4.4) ──────────────────────────────────────
let seconds = 30;
const countEl = document.getElementById('countdown');
setInterval(() => {
    seconds--;
    if (countEl) countEl.textContent = seconds;
    if (seconds <= 0) location.reload();
}, 1000);

// ── GPS location broadcast (6.2) — active while driver has accepted or in-delivery packages ──
<#if currentUser.userType == "DELIVERY" && ((acceptedCount!0) + (inDeliveryCount!0)) gt 0>
(function () {
    const banner = (msg) => {
        let el = document.getElementById('gpsBanner');
        if (!el) {
            el = document.createElement('div');
            el.id = 'gpsBanner';
            el.className = 'alert alert-warning small mb-3';
            document.querySelector('.container-fluid')?.prepend(el);
        }
        el.innerHTML = '<i class="bi bi-geo-alt me-1"></i>' + msg;
    };
    if (!navigator.geolocation) {
        banner('Geolocation is not supported on this device — couriers cannot share live location.');
        return;
    }
    const send = (lat, lng) => fetch('/deliveries/location', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ lat, lng })
    }).catch(() => {});
    navigator.geolocation.watchPosition(
        pos => send(pos.coords.latitude, pos.coords.longitude),
        err => {
            if (err.code === err.PERMISSION_DENIED) {
                banner('Location permission denied. Customers cannot see your live position. Re-enable location for this site to share GPS.');
            } else if (err.code === err.POSITION_UNAVAILABLE) {
                banner('GPS signal unavailable.');
            } else if (err.code === err.TIMEOUT) {
                banner('GPS timed out — retrying.');
            }
        },
        { enableHighAccuracy: true, maximumAge: 15000, timeout: 10000 }
    );
})();
</#if>

// ── Admin filter tabs ──────────────────────────────────────────────────
document.querySelectorAll('#stageTabs .nav-link').forEach(tab => {
    tab.addEventListener('click', e => {
        e.preventDefault();
        document.querySelectorAll('#stageTabs .nav-link').forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        const filter = tab.dataset.filter;
        document.querySelectorAll('#deliveriesTable tbody tr').forEach(row => {
            row.style.display = (filter === 'ALL' || row.dataset.stage === filter) ? '' : 'none';
        });
    });
});
</script>

</@layout.main>
