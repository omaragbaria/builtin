package com.builtin.repository;

import com.builtin.model.Driver;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DriverRepository extends JpaRepository<Driver, Long> {
    List<Driver> findByDeliveryAccountId(Long deliveryAccountId);
}
