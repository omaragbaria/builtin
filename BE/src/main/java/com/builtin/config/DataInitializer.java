package com.builtin.config;

import com.builtin.model.DeliveryAccount;
import com.builtin.model.DeliveryAccountType;
import com.builtin.model.VehicleType;
import com.builtin.repository.DeliveryAccountRepository;
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
    private final DeliveryAccountRepository deliveryAccountRepository;

    @Override
    public void run(ApplicationArguments args) {
        productSeederService.seed();
        seedDeliveryAccount();
    }

    private void seedDeliveryAccount() {
        if (deliveryAccountRepository.existsByEmail("dlv@builtin.com")) return;

        DeliveryAccount dlv = DeliveryAccount.builder()
                .firstName("Dlv")
                .lastName("Account")
                .email("dlv@builtin.com")
                .phone("0500000000")
                .deliveryAccountType(DeliveryAccountType.FREELANCE)
                .vehicleType(VehicleType.MOTORBIKE)
                .build();

        deliveryAccountRepository.save(dlv);
        log.info("Seeded delivery account: dlv@builtin.com");
    }
}
