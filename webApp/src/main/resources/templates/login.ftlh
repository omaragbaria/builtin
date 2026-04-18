<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Sign In - Conex</title>
    <link rel="icon" type="image/svg+xml" href="/img/logo-icon.svg"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"/>
    <link rel="stylesheet" href="/css/main.css"/>
</head>
<body class="bg-light d-flex align-items-center" style="min-height:100vh;">

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-5 col-lg-4">

            <div class="text-center mb-4">
                <img src="/img/logo.svg" alt="Conex" style="height:60px;"/>
                <p class="text-muted small mt-2">Connect &amp; Execute</p>
            </div>

            <div class="card shadow-sm">
                <div class="card-body p-4">
                    <h5 class="fw-bold mb-1">Sign In</h5>
                    <p class="text-muted small mb-3">Enter your credentials to continue.</p>

                    <#if error??>
                    <div class="alert alert-danger py-2 small">${error}</div>
                    </#if>

                    <form method="post" action="/auth/login">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">Username</label>
                            <input type="text" name="username" class="form-control"
                                   placeholder="user / provider / admin" required autofocus/>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-semibold">Password</label>
                            <input type="password" name="password" class="form-control"
                                   placeholder="••••" required/>
                        </div>
                        <button type="submit" class="btn btn-dark w-100">
                            <i class="bi bi-box-arrow-in-right me-1"></i>Sign In
                        </button>
                    </form>
                </div>
            </div>

            <p class="text-center text-muted small mt-3">
                <i class="bi bi-info-circle me-1"></i>
                Use <strong>user</strong>, <strong>provider</strong>, or <strong>admin</strong> with password <strong>1234</strong>
            </p>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
