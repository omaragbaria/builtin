<#import "layout/main.ftlh" as layout>
<@layout.main pageTitle="Delivery Dashboard">

<div class="container my-5">
    <h2 class="fw-bold mb-1"><i class="bi bi-truck me-2"></i>Delivery Dashboard</h2>
    <p class="text-muted mb-4">Manage package deliveries</p>

    <#if message??>
    <div class="alert alert-success alert-dismissible fade show">
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    </#if>
    <#if error??>
    <div class="alert alert-danger alert-dismissible fade show">
        ${error}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    </#if>

    <#-- ═══════════════ DELIVERY ACCOUNT VIEW ═══════════════ -->
    <#if currentUser.userType == "DELIVERY">

        <#-- Pending packages -->
        <div class="card shadow-sm mb-4">
            <div class="card-header bg-warning bg-opacity-10">
                <h5 class="mb-0 fw-bold"><i class="bi bi-clock-history me-2 text-warning"></i>Packages Waiting for Assignment
                    <span class="badge bg-warning text-dark ms-2">${pendingDeliveries?size}</span>
                </h5>
            </div>
            <div class="card-body p-0">
                <#if pendingDeliveries?has_content>
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Deal #</th>
                                <th>Shipping</th>
                                <th>Total</th>
                                <th>Placed</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <#list pendingDeliveries as d>
                            <tr>
                                <td><span class="fw-bold">#${d.dealId}</span></td>
                                <td><span class="badge bg-secondary">${d.dealShippingMethod!""}</span></td>
                                <td>₪${d.dealTotal!""}</td>
                                <td class="text-muted small">${d.createdAt!""}</td>
                                <td>
                                    <form method="post" action="/deliveries/${d.id}/accept">
                                        <button type="submit" class="btn btn-success btn-sm">
                                            <i class="bi bi-check-circle me-1"></i>Accept
                                        </button>
                                    </form>
                                </td>
                            </tr>
                            </#list>
                        </tbody>
                    </table>
                </div>
                <#else>
                <div class="text-center py-4 text-muted">
                    <i class="bi bi-inbox fs-3"></i>
                    <p class="mt-2 mb-0">No packages waiting for assignment.</p>
                </div>
                </#if>
            </div>
        </div>

        <#-- My deliveries -->
        <div class="card shadow-sm">
            <div class="card-header bg-primary bg-opacity-10">
                <h5 class="mb-0 fw-bold"><i class="bi bi-box-seam me-2 text-primary"></i>My Deliveries
                    <span class="badge bg-primary ms-2">${myDeliveries?size}</span>
                </h5>
            </div>
            <div class="card-body p-0">
                <#if myDeliveries?has_content>
                <#list myDeliveries as d>
                <div class="p-3 border-bottom">
                    <div class="d-flex justify-content-between align-items-start flex-wrap gap-2">
                        <div>
                            <span class="fw-bold">Deal #${d.dealId}</span>
                            <span class="ms-2 badge
                                <#if d.stage == "ACCEPTED">bg-info text-dark
                                <#elseif d.stage == "IN_DELIVERY">bg-primary
                                <#elseif d.stage == "ARRIVED">bg-success
                                <#else>bg-secondary</#if>">
                                ${d.stage?replace("_", " ")}
                            </span>
                            <div class="text-muted small mt-1">
                                Total: ₪${d.dealTotal!""} &nbsp;·&nbsp; ${d.dealShippingMethod!""}
                                <#if d.eta??>&nbsp;·&nbsp; ETA: ${d.eta}</#if>
                            </div>
                        </div>
                        <div class="d-flex gap-2 flex-wrap">

                            <#-- Stage update -->
                            <#if d.stage != "ARRIVED">
                            <form method="post" action="/deliveries/${d.id}/stage" class="d-inline">
                                <select name="stage" class="form-select form-select-sm" onchange="this.form.submit()" style="min-width:150px;">
                                    <option value="ACCEPTED"    <#if d.stage == "ACCEPTED">selected</#if>>Accepted</option>
                                    <option value="IN_DELIVERY" <#if d.stage == "IN_DELIVERY">selected</#if>>In Delivery</option>
                                    <option value="ARRIVED"     <#if d.stage == "ARRIVED">selected</#if>>Arrived</option>
                                </select>
                            </form>
                            </#if>

                            <#-- ETA update -->
                            <form method="post" action="/deliveries/${d.id}/eta" class="d-flex gap-1">
                                <input type="datetime-local" name="eta" class="form-control form-control-sm"
                                       style="width:190px;"
                                       <#if d.eta??>value="${d.eta?string("yyyy-MM-dd'T'HH:mm")}"</#if>/>
                                <button type="submit" class="btn btn-outline-secondary btn-sm">
                                    <i class="bi bi-clock"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
                </#list>
                <#else>
                <div class="text-center py-4 text-muted">
                    <i class="bi bi-truck fs-3"></i>
                    <p class="mt-2 mb-0">No deliveries assigned to you yet.</p>
                </div>
                </#if>
            </div>
        </div>

    <#-- ═══════════════ ADMIN VIEW ═══════════════ -->
    <#elseif currentUser.userType == "SUPER_ADMIN">

        <div class="card shadow-sm">
            <div class="card-header">
                <h5 class="mb-0 fw-bold"><i class="bi bi-list-check me-2"></i>All Deliveries</h5>
            </div>
            <div class="card-body p-0">
                <#if allDeliveries?has_content>
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Deal #</th>
                                <th>Stage</th>
                                <th>Assigned To</th>
                                <th>ETA</th>
                                <th>Total</th>
                                <th>Shipping</th>
                            </tr>
                        </thead>
                        <tbody>
                            <#list allDeliveries as d>
                            <tr>
                                <td class="text-muted small">${d.id}</td>
                                <td><strong>#${d.dealId}</strong></td>
                                <td>
                                    <span class="badge
                                        <#if d.stage == "PENDING_ASSIGNMENT">bg-warning text-dark
                                        <#elseif d.stage == "ACCEPTED">bg-info text-dark
                                        <#elseif d.stage == "IN_DELIVERY">bg-primary
                                        <#elseif d.stage == "ARRIVED">bg-success
                                        <#else>bg-secondary</#if>">
                                        ${d.stage?replace("_", " ")}
                                    </span>
                                </td>
                                <td>${d.deliveryAccountName!"-"}</td>
                                <td class="small">${d.eta!"-"}</td>
                                <td>₪${d.dealTotal!""}</td>
                                <td><span class="badge bg-secondary">${d.dealShippingMethod!""}</span></td>
                            </tr>
                            </#list>
                        </tbody>
                    </table>
                </div>
                <#else>
                <div class="text-center py-4 text-muted">No deliveries found.</div>
                </#if>
            </div>
        </div>

    </#if>
</div>

</@layout.main>
