package com.builtin.repository;

import com.builtin.model.Item;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ItemRepository extends JpaRepository<Item, Long> {
    List<Item> findByProviderId(Long providerId);
    List<Item> findByDealId(Long dealId);
    Optional<Item> findBySerialNumber(String serialNumber);
}
