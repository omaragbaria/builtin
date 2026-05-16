package com.builtin.dto;

import com.builtin.model.DeliveryStage;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
public class DeliveryResponseDto {
    private Long id;

    // Deal info
    private Long dealId;
    private BigDecimal dealTotal;
    private String dealShippingMethod;
    private String dealStatus;
    private String customerName;
    private String customerEmail;

    // Delivery state
    private DeliveryStage stage;
    private LocalDateTime eta;
    private LocalDateTime assignedAt;
    private LocalDateTime createdAt;

    // Assigned delivery account (null until accepted)
    private Long deliveryAccountId;
    private String deliveryAccountName;
    private String deliveryAccountEmail;
    private String vehicleType;
    private String deliveryAccountType;
    private Double driverLatitude;
    private Double driverLongitude;
}
