package com.builtin.webapp.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class ItemPriceDto {
    private Long id;
    private BigDecimal amount;
    private String currency;
    private String shippingMethod;
    private String deliveryTime;
}
