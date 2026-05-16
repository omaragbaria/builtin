package com.builtin.dto;

import com.builtin.model.ShippingMethod;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class ItemPriceRequest {
    private BigDecimal amount;
    private String currency;
    private ShippingMethod shippingMethod;
    private String deliveryTime;
}
