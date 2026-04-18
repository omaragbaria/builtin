package com.builtin.webapp.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class DealDto {
    private Long id;
    private BigDecimal totalPrice;
    private String status;
    private String shippingMethod;
    private LocalDateTime dealDate;
}
