package com.builtin.repository;

import com.builtin.model.Delivery;
import com.builtin.model.DeliveryStage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DeliveryRepository extends JpaRepository<Delivery, Long> {
    List<Delivery> findByStage(DeliveryStage stage);
    List<Delivery> findByDeliveryAccountId(Long deliveryAccountId);
    Optional<Delivery> findByDealId(Long dealId);
}
