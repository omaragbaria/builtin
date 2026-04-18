package com.builtin.dto;

import com.builtin.model.ShippingMethod;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class CheckoutRequest {

    private Long userId;

    @NotNull
    private ShippingMethod shippingMethod;

    @NotNull
    private List<CheckoutItem> items;

    @Data
    public static class CheckoutItem {
        private Long itemId;
        private Integer quantity;
    }
}
