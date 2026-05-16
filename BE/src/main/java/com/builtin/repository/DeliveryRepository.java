package com.builtin.repository;

import com.builtin.model.Delivery;
import com.builtin.model.DeliveryStage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface DeliveryRepository extends JpaRepository<Delivery, Long> {
    List<Delivery> findByStage(DeliveryStage stage);
    List<Delivery> findByDeliveryAccountId(Long deliveryAccountId);
    Optional<Delivery> findByDealId(Long dealId);

    @Query("SELECT d.deliveryAccount.id FROM Delivery d WHERE d.deliveryAccount IS NOT NULL AND d.stage IN :stages")
    List<Long> findActiveDriverAccountIds(@Param("stages") Collection<DeliveryStage> stages);
}
