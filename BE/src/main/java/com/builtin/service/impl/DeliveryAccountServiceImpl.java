package com.builtin.service.impl;

import com.builtin.dto.CreateDeliveryAccountRequest;
import com.builtin.exception.ResourceNotFoundException;
import com.builtin.model.DeliveryAccount;
import com.builtin.model.Driver;
import com.builtin.repository.DeliveryAccountRepository;
import com.builtin.repository.DriverRepository;
import com.builtin.service.DeliveryAccountService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class DeliveryAccountServiceImpl implements DeliveryAccountService {

    private final DeliveryAccountRepository deliveryAccountRepository;
    private final DriverRepository driverRepository;

    @Override
    public DeliveryAccount create(CreateDeliveryAccountRequest req) {
        DeliveryAccount account = DeliveryAccount.builder()
                .firstName(req.getFirstName())
                .lastName(req.getLastName())
                .email(req.getEmail())
                .phone(req.getPhone())
                .deliveryAccountType(req.getDeliveryAccountType())
                .vehicleType(req.getVehicleType())
                .build();

        DeliveryAccount saved = deliveryAccountRepository.save(account);

        if (req.getDrivers() != null) {
            req.getDrivers().forEach(dr -> {
                Driver driver = Driver.builder()
                        .name(dr.getName())
                        .phone(dr.getPhone())
                        .deliveryAccount(saved)
                        .build();
                driverRepository.save(driver);
            });
        }

        return deliveryAccountRepository.findById(saved.getId()).orElse(saved);
    }

    @Override
    public DeliveryAccount getById(Long id) {
        return deliveryAccountRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("DeliveryAccount", id));
    }

    @Override
    public List<DeliveryAccount> getAll() {
        return deliveryAccountRepository.findAll();
    }

    @Override
    public DeliveryAccount update(Long id, CreateDeliveryAccountRequest req) {
        DeliveryAccount existing = getById(id);
        existing.setFirstName(req.getFirstName());
        existing.setLastName(req.getLastName());
        existing.setEmail(req.getEmail());
        existing.setPhone(req.getPhone());
        existing.setDeliveryAccountType(req.getDeliveryAccountType());
        existing.setVehicleType(req.getVehicleType());
        return deliveryAccountRepository.save(existing);
    }

    @Override
    public void delete(Long id) {
        getById(id);
        deliveryAccountRepository.deleteById(id);
    }

    @Override
    public Driver addDriver(Long id, CreateDeliveryAccountRequest.DriverRequest req) {
        DeliveryAccount account = getById(id);
        Driver driver = Driver.builder()
                .name(req.getName())
                .phone(req.getPhone())
                .deliveryAccount(account)
                .build();
        return driverRepository.save(driver);
    }

    @Override
    public void removeDriver(Long accountId, Long driverId) {
        Driver driver = driverRepository.findById(driverId)
                .orElseThrow(() -> new ResourceNotFoundException("Driver", driverId));
        if (!driver.getDeliveryAccount().getId().equals(accountId)) {
            throw new IllegalArgumentException("Driver does not belong to this delivery account");
        }
        driverRepository.deleteById(driverId);
    }

    @Override
    public Optional<DeliveryAccount> findByEmail(String email) {
        return deliveryAccountRepository.findByEmail(email);
    }
}
