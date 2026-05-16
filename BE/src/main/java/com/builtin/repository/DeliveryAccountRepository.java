package com.builtin.repository;

import com.builtin.model.DeliveryAccount;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DeliveryAccountRepository extends JpaRepository<DeliveryAccount, Long> {
    Optional<DeliveryAccount> findByEmail(String email);
    boolean existsByEmail(String email);
    List<DeliveryAccount> findByLatitudeIsNotNullAndLongitudeIsNotNull();
}
