<#import "layout/main.ftlh" as layout>
<@layout.main pageTitle="My Locations">

<div class="container my-5">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <h4 class="fw-bold mb-4"><i class="bi bi-geo-alt me-2"></i>My Branch Locations</h4>

            <#if success??>
            <div class="alert alert-success py-2">${success}</div>
            </#if>
            <#if error??>
            <div class="alert alert-danger py-2">${error}</div>
            </#if>

            <!-- Existing locations -->
            <#if locations?? && locations?has_content>
            <div class="card shadow-sm mb-4">
                <div class="card-header fw-semibold">Current Locations</div>
                <ul class="list-group list-group-flush">
                    <#list locations as loc>
                    <li class="list-group-item d-flex justify-content-between align-items-start">
                        <div>
                            <div class="fw-semibold">${loc.label!""}</div>
                            <div class="text-muted small">
                                <#if loc.city?has_content>${loc.city}</#if><#if loc.country?has_content>, ${loc.country}</#if>
                                <#if loc.zipCode?has_content> &mdash; ${loc.zipCode}</#if>
                            </div>
                            <#if loc.latitude?? && loc.longitude??>
                            <div class="text-muted small">
                                <i class="bi bi-pin-map"></i>
                                ${loc.latitude?string["0.######"]}, ${loc.longitude?string["0.######"]}
                            </div>
                            </#if>
                        </div>
                        <form method="post" action="/providers/locations/${loc.id}/delete"
                              onsubmit="return confirm('Remove this location?')">
                            <button type="submit" class="btn btn-outline-danger btn-sm">
                                <i class="bi bi-trash"></i>
                            </button>
                        </form>
                    </li>
                    </#list>
                </ul>
            </div>
            <#else>
            <div class="alert alert-info">
                No branch locations yet. Add your first location below.
            </div>
            </#if>

            <!-- Add new location -->
            <div class="card shadow-sm">
                <div class="card-header fw-semibold">Add Location</div>
                <div class="card-body p-4">
                    <form method="post" action="/providers/locations">
                        <div class="row g-3">
                            <div class="col-12">
                                <label class="form-label fw-semibold">Label <span class="text-danger">*</span></label>
                                <input type="text" name="label" class="form-control" required
                                       placeholder="e.g. Main Warehouse, Tel Aviv Branch"/>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">City</label>
                                <input type="text" name="city" class="form-control" placeholder="Tel Aviv"/>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Country</label>
                                <input type="text" name="country" class="form-control" placeholder="Israel"/>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-semibold">Zip Code</label>
                                <input type="text" name="zipCode" class="form-control"/>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-semibold">Latitude</label>
                                <input type="number" name="latitude" class="form-control"
                                       step="0.000001" id="latInput"/>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-semibold">Longitude</label>
                                <input type="number" name="longitude" class="form-control"
                                       step="0.000001" id="lngInput"/>
                            </div>
                            <div class="col-12">
                                <button type="button" class="btn btn-outline-secondary btn-sm"
                                        onclick="detectLocation()">
                                    <i class="bi bi-crosshair me-1"></i>Use My Current Location
                                </button>
                                <span id="geoStatus" class="text-muted small ms-2"></span>
                            </div>
                        </div>
                        <div class="mt-4">
                            <button type="submit" class="btn btn-dark px-4">
                                <i class="bi bi-plus-circle me-1"></i>Add Location
                            </button>
                        </div>
                    </form>
                </div>
            </div>

        </div>
    </div>
</div>

<script>
function detectLocation() {
    const status = document.getElementById('geoStatus');
    if (!navigator.geolocation) {
        status.textContent = 'Geolocation not supported.';
        return;
    }
    status.textContent = 'Detecting...';
    navigator.geolocation.getCurrentPosition(
        pos => {
            document.getElementById('latInput').value = pos.coords.latitude.toFixed(6);
            document.getElementById('lngInput').value = pos.coords.longitude.toFixed(6);
            status.textContent = 'Location captured.';
        },
        () => { status.textContent = 'Could not detect location.'; }
    );
}
</script>

</@layout.main>
