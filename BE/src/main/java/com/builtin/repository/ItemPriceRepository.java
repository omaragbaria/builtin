package com.builtin.repository;

import com.builtin.model.ItemPrice;
import com.builtin.model.ShippingMethod;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ItemPriceRepository extends JpaRepository<ItemPrice, Long> {
    List<ItemPrice> findByItemId(Long itemId);
    Optional<ItemPrice> findFirstByItemIdAndShippingMethod(Long itemId, ShippingMethod method);
}
