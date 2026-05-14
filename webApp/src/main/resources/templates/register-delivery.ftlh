<#import "layout/main.ftlh" as layout>
<@layout.main pageTitle="Register Delivery Account">

<div class="container my-5">
    <div class="row justify-content-center">
        <div class="col-lg-7">

            <h2 class="fw-bold mb-1"><i class="bi bi-truck me-2"></i>Register Delivery Account</h2>
            <p class="text-muted mb-4">Sign up as a delivery partner to start accepting packages.</p>

            <#if error??>
            <div class="alert alert-danger">${error}</div>
            </#if>

            <div class="card shadow-sm">
                <div class="card-body p-4">
                    <form method="post" action="/delivery/register" id="deliveryForm">

                        <!-- Basic info -->
                        <div class="row g-3 mb-3">
                            <div class="col-sm-6">
                                <label class="form-label fw-semibold">First Name</label>
                                <input type="text" name="firstName" class="form-control" required/>
                            </div>
                            <div class="col-sm-6">
                                <label class="form-label fw-semibold">Last Name</label>
                                <input type="text" name="lastName" class="form-control" required/>
                            </div>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-sm-6">
                                <label class="form-label fw-semibold">Email</label>
                                <input type="email" name="email" class="form-control" required/>
                            </div>
                            <div class="col-sm-6">
                                <label class="form-label fw-semibold">Phone</label>
                                <input type="text" name="phone" class="form-control"/>
                            </div>
                        </div>

                        <!-- Account type -->
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Account Type</label>
                            <div class="d-flex gap-3">
                                <div class="form-check border rounded p-3 flex-fill">
                                    <input class="form-check-input" type="radio" name="deliveryAccountType"
                                           id="type-freelance" value="FREELANCE" checked
                                           onchange="toggleDrivers()">
                                    <label class="form-check-label" for="type-freelance">
                                        <i class="bi bi-person-fill me-1 text-primary"></i>
                                        <strong>Freelance</strong>
                                        <div class="text-muted small">Individual delivery driver</div>
                                    </label>
                                </div>
                                <div class="form-check border rounded p-3 flex-fill">
                                    <input class="form-check-input" type="radio" name="deliveryAccountType"
                                           id="type-company" value="COMPANY"
                                           onchange="toggleDrivers()">
                                    <label class="form-check-label" for="type-company">
                                        <i class="bi bi-building me-1 text-warning"></i>
                                        <strong>Company</strong>
                                        <div class="text-muted small">Delivery company with drivers</div>
                                    </label>
                                </div>
                            </div>
                        </div>

                        <!-- Vehicle type -->
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Vehicle Type</label>
                            <select name="vehicleType" class="form-select" required>
                                <#list vehicleTypes as vt>
                                <option value="${vt}">${vt?replace("_", " ")?lower_case?cap_first}</option>
                                </#list>
                            </select>
                        </div>

                        <!-- Drivers section (company only) -->
                        <div id="driversSection" class="mb-3" style="display:none;">
                            <label class="form-label fw-semibold">Drivers</label>
                            <div id="driversList"></div>
                            <button type="button" class="btn btn-outline-primary btn-sm mt-2" onclick="addDriver()">
                                <i class="bi bi-plus-circle me-1"></i>Add Driver
                            </button>
                        </div>

                        <hr/>
                        <button type="submit" class="btn btn-dark w-100 btn-lg">
                            <i class="bi bi-person-check me-2"></i>Register
                        </button>
                        <a href="/auth/login" class="btn btn-outline-secondary w-100 mt-2">
                            <i class="bi bi-arrow-left me-1"></i>Back to Login
                        </a>

                    </form>
                </div>
            </div>

        </div>
    </div>
</div>

<script>
let driverCount = 0;

function toggleDrivers() {
    const isCompany = document.querySelector('input[name="deliveryAccountType"]:checked').value === 'COMPANY';
    document.getElementById('driversSection').style.display = isCompany ? 'block' : 'none';
}

function addDriver() {
    const container = document.getElementById('driversList');
    const div = document.createElement('div');
    div.className = 'row g-2 mb-2 driver-row';
    div.innerHTML = `
        <div class="col-sm-5">
            <input type="text" name="driverNames" class="form-control" placeholder="Driver name" required/>
        </div>
        <div class="col-sm-5">
            <input type="text" name="driverPhones" class="form-control" placeholder="Phone number" required/>
        </div>
        <div class="col-sm-2">
            <button type="button" class="btn btn-outline-danger btn-sm w-100" onclick="this.closest('.driver-row').remove()">
                <i class="bi bi-trash"></i>
            </button>
        </div>`;
    container.appendChild(div);
    driverCount++;
}
</script>

</@layout.main>
