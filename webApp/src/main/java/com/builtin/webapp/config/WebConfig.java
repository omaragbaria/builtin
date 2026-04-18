package com.builtin.webapp.config;

import com.builtin.webapp.interceptor.SessionUserInterceptor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new SessionUserInterceptor())
                .excludePathPatterns("/auth/**", "/css/**", "/js/**", "/photos/**", "/error");
    }
}
