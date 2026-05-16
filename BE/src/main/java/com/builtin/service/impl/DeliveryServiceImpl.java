package com.builtin.service.impl;

import com.builtin.dto.DeliveryResponseDto;
import com.builtin.exception.ResourceNotFoundException;
import com.builtin.model.*;
import com.builtin.repository.DeliveryAccountRepository;
import com.builtin.repository.DeliveryRepository;
import com.builtin.repository.DealRepository;
import com.builtin.service.DeliveryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class DeliveryServiceImpl implements DeliveryService {

    private final DeliveryRepository deliveryRepository;
    private final DeliveryAccountRepository deliveryAccountRepository;
    private final DealRepository dealRepository;

    @Override
    public DeliveryResponseDto createForDeal(Deal deal) {
        Delivery delivery = Delivery.builder()
                .deal(deal)
                .stage(DeliveryStage.PENDING_ASSIGNMENT)
                .build();
        return toDto(deliveryRepository.save(delivery));
    }

    @Override
    public DeliveryResponseDto accept(Long deliveryId, Long deliveryAccountId) {
        Delivery delivery = findEntity(deliveryId);
        if (delivery.getStage() != DeliveryStage.PENDING_ASSIGNMENT) {
            throw new IllegalStateException("Package is not available for assignment (stage: " + delivery.getStage() + ")");
        }
        DeliveryAccount account = deliveryAccountRepository.findById(deliveryAccountId)
                .orElseThrow(() -> new ResourceNotFoundException("DeliveryAccount", deliveryAccountId));

        delivery.setDeliveryAccount(account);
        delivery.setStage(DeliveryStage.ACCEPTED);
        delivery.setAssignedAt(LocalDateTime.now());

        Deal deal = delivery.getDeal();
        deal.setStatus(DealStatus.DELIVERY);
        dealRepository.save(deal);

        return toDto(deliveryRepository.save(delivery));
    }

    @Override
    public DeliveryResponseDto updateStage(Long deliveryId, DeliveryStage stage) {
        Delivery delivery = findEntity(deliveryId);
        delivery.setStage(stage);

        if (stage == DeliveryStage.ARRIVED) {
            Deal deal = delivery.getDeal();
            deal.setStatus(DealStatus.COMPLETE);
            dealRepository.save(deal);
        }

        return toDto(deliveryRepository.save(delivery));
    }

    @Override
    public DeliveryResponseDto updateEta(Long deliveryId, LocalDateTime eta) {
        Delivery delivery = findEntity(deliveryId);
        delivery.setEta(eta);
        return toDto(deliveryRepository.save(delivery));
    }

    @Override
    public DeliveryResponseDto getById(Long deliveryId) {
        return toDto(findEntity(deliveryId));
    }

    @Override
    public List<DeliveryResponseDto> getPending() {
        return deliveryRepository.findByStage(DeliveryStage.PENDING_ASSIGNMENT)
                .stream().map(this::toDto).toList();
    }

    @Override
    public List<DeliveryResponseDto> getByAccount(Long deliveryAccountId) {
        return deliveryRepository.findByDeliveryAccountId(deliveryAccountId)
                .stream().map(this::toDto).toList();
    }

    @Override
    public List<DeliveryResponseDto> getAll() {
        return deliveryRepository.findAll().stream().map(this::toDto).toList();
    }

    @Override
    public Optional<DeliveryResponseDto> findByDealId(Long dealId) {
        return deliveryRepository.findByDealId(dealId).map(this::toDto);
    }

    @Override
    public void autoAssignNearest(Long deliveryId, Double deliveryLat, Double deliveryLng) {
        List<DeliveryAccount> candidates = deliveryAccountRepository.findByLatitudeIsNotNullAndLongitudeIsNotNull();
        Set<Long> busyIds = Set.copyOf(deliveryRepository.findActiveDriverAccountIds(
                List.of(DeliveryStage.ACCEPTED, DeliveryStage.IN_DELIVERY)));

        DeliveryAccount nearest = candidates.stream()
                .filter(da -> !busyIds.contains(da.getId()))
                .min(Comparator.comparingDouble(da ->
                        haversineKm(deliveryLat, deliveryLng, da.getLatitude(), da.getLongitude())))
                .orElseThrow(() -> new IllegalStateException(
                        "No drivers are currently available for immediate pickup. " +
                        "Please try again shortly or choose another shipping method."));

        Delivery delivery = findEntity(deliveryId);
        delivery.setDeliveryAccount(nearest);
        delivery.setStage(DeliveryStage.ACCEPTED);
        delivery.setAssignedAt(LocalDateTime.now());

        Deal deal = delivery.getDeal();
        deal.setStatus(DealStatus.DELIVERY);
        dealRepository.save(deal);
        deliveryRepository.save(delivery);
    }

    private double haversineKm(double lat1, double lon1, double lat2, double lon2) {
        final double R = 6371.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                 + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                 * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    private Delivery findEntity(Long id) {
        return deliveryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Delivery", id));
    }

    private DeliveryResponseDto toDto(Delivery d) {
        DeliveryResponseDto.DeliveryResponseDtoBuilder b = DeliveryResponseDto.builder()
                .id(d.getId())
                .stage(d.getStage())
                .eta(d.getEta())
                .assignedAt(d.getAssignedAt())
                .createdAt(d.getCreatedAt());

        if (d.getDeal() != null) {
            Deal deal = d.getDeal();
            b.dealId(deal.getId())
             .dealTotal(deal.getTotalPrice())
             .dealShippingMethod(deal.getShippingMethod() != null ? deal.getShippingMethod().name() : null)
             .dealStatus(deal.getStatus() != null ? deal.getStatus().name() : null);
            if (deal.getUser() != null) {
                b.customerName(deal.getUser().getFirstName() + " " + deal.getUser().getLastName())
                 .customerEmail(deal.getUser().getEmail());
            }
        }

        if (d.getDeliveryAccount() != null) {
            DeliveryAccount da = d.getDeliveryAccount();
            b.deliveryAccountId(da.getId())
             .deliveryAccountName(da.getFirstName() + " " + da.getLastName())
             .deliveryAccountEmail(da.getEmail())
             .vehicleType(da.getVehicleType() != null ? da.getVehicleType().name() : null)
             .deliveryAccountType(da.getDeliveryAccountType() != null ? da.getDeliveryAccountType().name() : null)
             .driverLatitude(da.getLatitude())
             .driverLongitude(da.getLongitude());
        }

        return b.build();
    }
}
