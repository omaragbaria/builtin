package com.builtin.webapp.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class DeliveryDto {
    private Long id;
    private Long dealId;
    private BigDecimal dealTotal;
    private String dealShippingMethod;
    private String dealStatus;
    private String customerName;
    private String customerEmail;
    private String stage;
    private LocalDateTime eta;
    private LocalDateTime assignedAt;
    private LocalDateTime createdAt;
    private Long deliveryAccountId;
    private String deliveryAccountName;
    private String deliveryAccountEmail;
    private String vehicleType;
    private String deliveryAccountType;
}
