<#macro main pageTitle="">
<#assign lang = springMacroRequestContext.locale.language>
<#assign isRtl = (lang == "ar" || lang == "he")>
<!DOCTYPE html>
<html lang="${lang}" dir="<#if isRtl>rtl<#else>ltr</#if>">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>${pageTitle} - Conex</title>
    <link rel="icon" type="image/svg+xml" href="/img/logo-icon.svg"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"/>
    <link rel="stylesheet" href="/css/main.css"/>
    <#if isRtl><link rel="stylesheet" href="/css/rtl.css"/></#if>
</head>
<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top shadow">
    <div class="container">
        <a class="navbar-brand" href="/">
            <img src="/img/logo.svg" alt="Conex" height="40"/>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMain">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarMain">
            <!-- Search -->
            <form class="d-flex mx-auto w-50" action="/search" method="get">
                <div class="input-group">
                    <input class="form-control" type="search" name="query"
                           placeholder="${springMacroRequestContext.getMessage('nav.search_placeholder')}"/>
                    <button class="btn btn-warning" type="submit">
                        <i class="bi bi-search"></i>
                    </button>
                </div>
            </form>
            <ul class="navbar-nav ms-auto align-items-center gap-2">
                <li class="nav-item">
                    <a class="nav-link" href="/products"><i class="bi bi-grid me-1"></i>${springMacroRequestContext.getMessage('nav.products')}</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="/agent"><i class="bi bi-robot me-1"></i>${springMacroRequestContext.getMessage('nav.ai_assistant')}</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="/calculator"><i class="bi bi-building me-1"></i>${springMacroRequestContext.getMessage('nav.calculator')}</a>
                </li>
                <#if currentUser?? && currentUser.canAddItems()>
                <li class="nav-item">
                    <a class="btn btn-warning btn-sm" href="/items/new">
                        <i class="bi bi-plus-circle me-1"></i>${springMacroRequestContext.getMessage('nav.add_item')}
                    </a>
                </li>
                </#if>
                <li class="nav-item">
                    <a class="btn btn-outline-warning btn-sm" href="/cart">
                        <i class="bi bi-cart3 fs-5"></i>
                    </a>
                </li>

                <!-- Language Switcher -->
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle text-white px-2" href="#" data-bs-toggle="dropdown">
                        <#if lang == "ar">🇸🇦
                        <#elseif lang == "he">🇮🇱
                        <#elseif lang == "ru">🇷🇺
                        <#elseif lang == "zh">🇨🇳
                        <#else>🇺🇸
                        </#if>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item<#if lang == 'en'> active</#if>" href="?lang=en">🇺🇸 ${springMacroRequestContext.getMessage('lang.en')}</a></li>
                        <li><a class="dropdown-item<#if lang == 'ar'> active</#if>" href="?lang=ar">🇸🇦 ${springMacroRequestContext.getMessage('lang.ar')}</a></li>
                        <li><a class="dropdown-item<#if lang == 'he'> active</#if>" href="?lang=he">🇮🇱 ${springMacroRequestContext.getMessage('lang.he')}</a></li>
                        <li><a class="dropdown-item<#if lang == 'ru'> active</#if>" href="?lang=ru">🇷🇺 ${springMacroRequestContext.getMessage('lang.ru')}</a></li>
                        <li><a class="dropdown-item<#if lang == 'zh'> active</#if>" href="?lang=zh">🇨🇳 ${springMacroRequestContext.getMessage('lang.zh')}</a></li>
                    </ul>
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
                                    <i class="bi bi-box-arrow-right me-1"></i>${springMacroRequestContext.getMessage('nav.sign_out')}
                                </button>
                            </form>
                        </li>
                    </ul>
                </li>
                <#else>
                <li class="nav-item">
                    <a class="btn btn-outline-light btn-sm" href="/auth/login">
                        <i class="bi bi-person me-1"></i>${springMacroRequestContext.getMessage('nav.sign_in')}
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
        <p class="mb-1">&copy; 2025 Conex. ${springMacroRequestContext.getMessage('footer.rights')}</p>
        <small class="text-muted">${springMacroRequestContext.getMessage('footer.tagline')}</small>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="/js/main.js"></script>
</body>
</html>
</#macro>
