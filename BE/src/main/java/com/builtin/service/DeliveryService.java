package com.builtin.service;

import com.builtin.dto.DeliveryResponseDto;
import com.builtin.model.Deal;
import com.builtin.model.DeliveryStage;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface DeliveryService {
    DeliveryResponseDto createForDeal(Deal deal);
    DeliveryResponseDto accept(Long deliveryId, Long deliveryAccountId);
    DeliveryResponseDto updateStage(Long deliveryId, DeliveryStage stage);
    DeliveryResponseDto updateEta(Long deliveryId, LocalDateTime eta);
    DeliveryResponseDto getById(Long deliveryId);
    List<DeliveryResponseDto> getPending();
    List<DeliveryResponseDto> getByAccount(Long deliveryAccountId);
    List<DeliveryResponseDto> getAll();
    Optional<DeliveryResponseDto> findByDealId(Long dealId);
}
