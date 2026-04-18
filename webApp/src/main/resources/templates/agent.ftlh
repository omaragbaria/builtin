<#import "layout/main.ftlh" as layout>
<@layout.main pageTitle="AI Assistant">

<div class="container my-5">
    <div class="row justify-content-center">
        <div class="col-lg-10">

            <!-- Header -->
            <div class="text-center mb-4">
                <i class="bi bi-robot fs-1 text-warning"></i>
                <h2 class="fw-bold mt-2">AI Materials Assistant</h2>
                <p class="text-muted">Tell me what you want to build and I'll calculate the materials you need.</p>
            </div>

            <!-- Input form -->
            <div class="card shadow-sm mb-4">
                <div class="card-body">
                    <form method="post" action="/agent">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Describe your project</label>
                            <textarea name="message" rows="3" class="form-control"
                                      placeholder="e.g. I want to build a wall closet from oak wood, 4m wide, 60cm deep and 1.8m high"
                                      required>${message!""}</textarea>
                            <div class="form-text">Include material type, dimensions (width, depth, height), and project type.</div>
                        </div>
                        <button type="submit" class="btn btn-warning fw-bold">
                            <i class="bi bi-calculator me-2"></i>Calculate Materials
                        </button>
                    </form>
                </div>
            </div>

            <#if response??>

            <!-- Project summary -->
            <div class="alert alert-secondary d-flex align-items-center gap-2 mb-4">
                <i class="bi bi-info-circle-fill text-warning fs-5"></i>
                <span>${response.projectSummary}</span>
            </div>

            <!-- Materials list -->
            <#list response.materials as line>
            <div class="card shadow-sm mb-3">
                <div class="card-header bg-light d-flex justify-content-between align-items-center">
                    <span class="fw-bold"><i class="bi bi-hammer me-2"></i>${line.materialType}</span>
                    <span class="badge bg-dark">
                        Required: ${line.requiredQuantity?string["0.##"]} ${line.unit}
                    </span>
                </div>

                <#if line.matchedItems?has_content>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0 align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Product</th>
                                    <th>Provider</th>
                                    <th>Price</th>
                                    <th>Available</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                <#list line.matchedItems as item>
                                <tr class="${item.lowestPrice?then('table-warning', '')}">
                                    <td>
                                        ${item.name}
                                        <#if item.lowestPrice>
                                            <span class="badge bg-success ms-1">Best Price</span>
                                        </#if>
                                    </td>
                                    <td><small class="text-muted">${item.providerName!""}</small></td>
                                    <td class="fw-bold">$${item.price} / ${item.unit}</td>
                                    <td><small>${item.availableQuantity} in stock</small></td>
                                    <td>
                                        <form action="/cart/add/${item.itemId}" method="post">
                                            <input type="hidden" name="quantity" value="1"/>
                                            <button type="submit" class="btn btn-sm btn-outline-dark">
                                                <i class="bi bi-cart-plus me-1"></i>Add
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                                </#list>
                            </tbody>
                        </table>
                    </div>
                </div>
                <#else>
                <div class="card-body text-muted">
                    <i class="bi bi-exclamation-circle me-1"></i>
                    No matching products found in store for this material.
                </div>
                </#if>
            </div>
            </#list>

            <!-- Add all best-price items to cart -->
            <div class="card shadow-sm border-warning">
                <div class="card-body d-flex align-items-center justify-content-between">
                    <div>
                        <h6 class="fw-bold mb-1"><i class="bi bi-bag-check me-2 text-warning"></i>Add all best-price items to cart</h6>
                        <small class="text-muted">Adds the lowest-priced match for each material.</small>
                    </div>
                    <form method="post" action="/agent/add-all">
                        <input type="hidden" name="message" value="${message!""}"/>
                        <#list response.materials as line>
                            <#if line.matchedItems?has_content>
                                <#assign best = line.matchedItems[0]>
                                <input type="hidden" name="itemIds" value="${best.itemId}"/>
                            </#if>
                        </#list>
                        <button type="submit" class="btn btn-warning fw-bold">
                            <i class="bi bi-cart-check me-2"></i>Add All to Cart
                        </button>
                    </form>
                </div>
            </div>

            </#if>

        </div>
    </div>
</div>

</@layout.main>
