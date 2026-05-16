<#import "layout/main.ftlh" as layout>
<@layout.main pageTitle="Edit Item">

<div class="container my-5">
    <div class="row justify-content-center">
        <div class="col-md-7">
            <div class="d-flex align-items-center mb-4 gap-2">
                <a href="/products/${itemId?c}" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-left"></i>
                </a>
                <h4 class="fw-bold mb-0">Edit Item</h4>
            </div>

            <#if error??>
            <div class="alert alert-danger py-2">${error}</div>
            </#if>

            <div class="card shadow-sm">
                <div class="card-body p-4">
                    <form method="post" action="/items/${itemId?c}/edit" enctype="multipart/form-data">

                        <div class="row g-3">
                            <div class="col-12">
                                <label class="form-label fw-semibold">Name <span class="text-danger">*</span></label>
                                <input type="text" name="name" class="form-control" required
                                       value="${item.name!''}"/>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Description</label>
                                <input type="text" name="type" class="form-control"
                                       value="${item.type!''}"/>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Category</label>
                                <input type="text" name="category" class="form-control"
                                       value="${item.category!''}"/>
                            </div>

                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Price <span class="text-danger">*</span></label>
                                <div class="input-group">
                                    <span class="input-group-text">₪</span>
                                    <input type="number" name="price" class="form-control" min="0"
                                           step="0.01" required value="${item.price!'0.00'}"/>
                                </div>
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-semibold">Quantity <span class="text-danger">*</span></label>
                                <input type="number" name="quantity" class="form-control" min="0"
                                       required value="${item.quantity!'1'}"/>
                            </div>

                            <div class="col-md-3">
                                <label class="form-label fw-semibold">Unit <span class="text-danger">*</span></label>
                                <select name="unit" class="form-select" required>
                                    <#list units as u>
                                    <option value="${u}" <#if item.unit?? && item.unit == u>selected</#if>>${u}</option>
                                    </#list>
                                </select>
                            </div>

                            <div class="col-12">
                                <label class="form-label fw-semibold">Serial Number</label>
                                <input type="text" name="serialNumber" class="form-control"
                                       value="${item.serialNumber!''}"/>
                            </div>

                            <#if providers??>
                            <div class="col-12">
                                <label class="form-label fw-semibold">Provider</label>
                                <select name="provider.id" class="form-select">
                                    <option value="">None</option>
                                    <#list providers as p>
                                    <option value="${p.id}"
                                        <#if item.provider?? && item.provider.id == p.id>selected</#if>
                                    >${p.name}</option>
                                    </#list>
                                </select>
                            </div>
                            </#if>

                            <#-- 8.4: item stock locations -->
                            <#if providerLocations?? && providerLocations?has_content>
                            <div class="col-12">
                                <label class="form-label fw-semibold">
                                    <i class="bi bi-geo-alt me-1"></i>Stock Locations
                                </label>
                                <div class="border rounded p-3 bg-light">
                                    <div class="text-muted small mb-2">Select which of your branches carry this item.</div>
                                    <#list providerLocations as loc>
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox"
                                               name="locationIds" value="${loc.id}"
                                               id="loc-${loc.id}"
                                               <#if selectedLocationIds?? && selectedLocationIds?seq_contains(loc.id)>checked</#if>>
                                        <label class="form-check-label" for="loc-${loc.id}">
                                            <strong>${loc.label!loc.city!""}</strong>
                                            <#if loc.city?has_content || loc.country?has_content>
                                            <span class="text-muted small ms-1">
                                                — <#if loc.city?has_content>${loc.city}</#if><#if loc.country?has_content>, ${loc.country}</#if>
                                            </span>
                                            </#if>
                                            <#if loc.latitude?? && loc.longitude??>
                                            <span class="text-muted small ms-1">
                                                <i class="bi bi-pin-map"></i> ${loc.latitude?string["0.####"]}, ${loc.longitude?string["0.####"]}
                                            </span>
                                            </#if>
                                        </label>
                                    </div>
                                    </#list>
                                </div>
                                <div class="form-text">Locations are managed in <a href="/providers/locations">My Locations</a>.</div>
                            </div>
                            <#elseif providerLocations??>
                            <div class="col-12">
                                <div class="alert alert-info py-2 small">
                                    <i class="bi bi-geo-alt me-1"></i>
                                    No branch locations set up yet.
                                    <a href="/providers/locations" class="alert-link">Add your first location</a> to assign stock locations to items.
                                </div>
                            </div>
                            </#if>

                            <div class="col-12">
                                <label class="form-label fw-semibold">Add Photos</label>
                                <input type="file" name="photos" class="form-control"
                                       multiple accept="image/*"/>
                                <div class="form-text">Upload new photos to add to this item.</div>
                            </div>
                        </div>

                        <div class="d-flex gap-2 mt-4">
                            <button type="submit" class="btn btn-dark px-4">
                                <i class="bi bi-save me-1"></i>Save Changes
                            </button>
                            <a href="/products/${itemId?c}" class="btn btn-outline-secondary px-4">Cancel</a>
                        </div>

                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

</@layout.main>
