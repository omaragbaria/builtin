<!DOCTYPE html>
<#assign lang = springMacroRequestContext.locale.language>
<#assign isRtl = (lang == "ar" || lang == "he")>
<html lang="${lang}" dir="<#if isRtl>rtl<#else>ltr</#if>">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>${springMacroRequestContext.getMessage('login.title')} - Conex</title>
    <link rel="icon" type="image/svg+xml" href="/img/logo-icon.svg"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"/>
    <link rel="stylesheet" href="/css/main.css"/>
    <#if isRtl><link rel="stylesheet" href="/css/rtl.css"/></#if>
</head>
<body class="bg-light d-flex align-items-center" style="min-height:100vh;">

<!-- Language switcher (top right) -->
<div class="position-fixed top-0 end-0 p-3" style="z-index:1050;">
    <div class="dropdown">
        <button class="btn btn-outline-secondary btn-sm dropdown-toggle" data-bs-toggle="dropdown">
            <#if lang == "ar">🇸🇦
            <#elseif lang == "he">🇮🇱
            <#elseif lang == "ru">🇷🇺
            <#elseif lang == "zh">🇨🇳
            <#else>🇺🇸
            </#if>
        </button>
        <ul class="dropdown-menu dropdown-menu-end">
            <li><a class="dropdown-item<#if lang == 'en'> active</#if>" href="?lang=en">🇺🇸 ${springMacroRequestContext.getMessage('lang.en')}</a></li>
            <li><a class="dropdown-item<#if lang == 'ar'> active</#if>" href="?lang=ar">🇸🇦 ${springMacroRequestContext.getMessage('lang.ar')}</a></li>
            <li><a class="dropdown-item<#if lang == 'he'> active</#if>" href="?lang=he">🇮🇱 ${springMacroRequestContext.getMessage('lang.he')}</a></li>
            <li><a class="dropdown-item<#if lang == 'ru'> active</#if>" href="?lang=ru">🇷🇺 ${springMacroRequestContext.getMessage('lang.ru')}</a></li>
            <li><a class="dropdown-item<#if lang == 'zh'> active</#if>" href="?lang=zh">🇨🇳 ${springMacroRequestContext.getMessage('lang.zh')}</a></li>
        </ul>
    </div>
</div>

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-5 col-lg-4">

            <div class="text-center mb-4">
                <img src="/img/logo.svg" alt="Conex" style="height:60px;"/>
                <p class="text-muted small mt-2">Connect &amp; Execute</p>
            </div>

            <div class="card shadow-sm">
                <div class="card-body p-4">
                    <h5 class="fw-bold mb-1">${springMacroRequestContext.getMessage('login.title')}</h5>
                    <p class="text-muted small mb-3">${springMacroRequestContext.getMessage('login.subtitle')}</p>

                    <#if error??>
                    <div class="alert alert-danger py-2 small">${error}</div>
                    </#if>

                    <form method="post" action="/auth/login">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">${springMacroRequestContext.getMessage('login.username')}</label>
                            <input type="text" name="username" class="form-control"
                                   placeholder="user / provider / admin" required autofocus/>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-semibold">${springMacroRequestContext.getMessage('login.password')}</label>
                            <input type="password" name="password" class="form-control"
                                   placeholder="••••" required/>
                        </div>
                        <button type="submit" class="btn btn-dark w-100">
                            <i class="bi bi-box-arrow-in-right me-1"></i>${springMacroRequestContext.getMessage('login.btn')}
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
