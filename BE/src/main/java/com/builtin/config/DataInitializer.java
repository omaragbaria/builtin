package com.builtin.config;

import com.builtin.service.ProductSeederService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements ApplicationRunner {

    private final ProductSeederService productSeederService;

    @Override
    public void run(ApplicationArguments args) {
        productSeederService.seed();
    }
}
