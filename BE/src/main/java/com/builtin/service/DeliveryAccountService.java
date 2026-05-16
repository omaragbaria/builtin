package com.builtin.service;

import com.builtin.dto.CreateDeliveryAccountRequest;
import com.builtin.model.DeliveryAccount;
import com.builtin.model.Driver;

import java.util.List;
import java.util.Optional;

public interface DeliveryAccountService {
    DeliveryAccount create(CreateDeliveryAccountRequest request);
    DeliveryAccount getById(Long id);
    List<DeliveryAccount> getAll();
    DeliveryAccount update(Long id, CreateDeliveryAccountRequest request);
    void delete(Long id);
    Driver addDriver(Long id, CreateDeliveryAccountRequest.DriverRequest driverRequest);
    void removeDriver(Long accountId, Long driverId);
    Optional<DeliveryAccount> findByEmail(String email);
    void updateLocation(Long id, Double latitude, Double longitude);
}
