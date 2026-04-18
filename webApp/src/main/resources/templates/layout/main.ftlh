<#macro main pageTitle="">
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>${pageTitle} - BuiltIn Store</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"/>
    <link rel="stylesheet" href="/css/main.css"/>
</head>
<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top shadow">
    <div class="container">
        <a class="navbar-brand fw-bold fs-4" href="/">
            <i class="bi bi-bag-fill me-2 text-warning"></i>BuiltIn
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMain">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarMain">
            <!-- Search -->
            <form class="d-flex mx-auto w-50" action="/search" method="get">
                <div class="input-group">
                    <input class="form-control" type="search" name="query"
                           placeholder="Search products..."/>
                    <button class="btn btn-warning" type="submit">
                        <i class="bi bi-search"></i>
                    </button>
                </div>
            </form>
            <ul class="navbar-nav ms-auto align-items-center gap-2">
                <li class="nav-item">
                    <a class="nav-link" href="/products"><i class="bi bi-grid me-1"></i>Products</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="/agent"><i class="bi bi-robot me-1"></i>AI Assistant</a>
                </li>
                <#if currentUser?? && currentUser.canAddItems()>
                <li class="nav-item">
                    <a class="btn btn-warning btn-sm" href="/items/new">
                        <i class="bi bi-plus-circle me-1"></i>Add Item
                    </a>
                </li>
                </#if>
                <li class="nav-item">
                    <a class="btn btn-outline-warning btn-sm" href="/cart">
                        <i class="bi bi-cart3 fs-5"></i>
                    </a>
                </li>
                <#if currentUser??>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle text-white" href="#" data-bs-toggle="dropdown">
                        <i class="bi bi-person-circle me-1"></i>${currentUser.displayName}
                        <span class="badge bg-warning text-dark ms-1 small">${currentUser.userType}</span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><span class="dropdown-item-text text-muted small">${currentUser.email}</span></li>
                        <li><hr class="dropdown-divider"/></li>
                        <li>
                            <form method="post" action="/auth/logout" class="px-3">
                                <button type="submit" class="btn btn-outline-danger btn-sm w-100">
                                    <i class="bi bi-box-arrow-right me-1"></i>Sign Out
                                </button>
                            </form>
                        </li>
                    </ul>
                </li>
                <#else>
                <li class="nav-item">
                    <a class="btn btn-outline-light btn-sm" href="/auth/login">
                        <i class="bi bi-person me-1"></i>Sign In
                    </a>
                </li>
                </#if>
            </ul>
        </div>
    </div>
</nav>

<!-- Page content -->
<main>
    <#nested/>
</main>

<!-- Footer -->
<footer class="bg-dark text-white mt-5 py-4">
    <div class="container text-center">
        <p class="mb-1">&copy; 2025 BuiltIn Store. All rights reserved.</p>
        <small class="text-muted">Your one-stop shop for everything.</small>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="/js/main.js"></script>
</body>
</html>
</#macro>
